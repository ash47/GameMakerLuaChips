--Required functions:
dofile "lua/Functions.lua" -- More functions
dofile "lua/Bitwise.lua" -- Bitwise functions
dofile "lua/Binary.lua" -- Load binary stuff
Require("popups")
Require("surface")
Require("res")
Require("rooms")
Require("drawing")
Require("objects")
Require("sounds")
Require("io")
Require("game")

--Level Loading Function
function Chip_Load_Map(f, n) -- F=filename; n=levelid
	local xx, yy, i, oldmap = 0, 0, 0, levelnumber or 0; -- Init variables
	local f = bin_open(f); -- Open the file for reading
	local code = read_long(f); -- Grab the level code / ruleset
	
	if(code ~= "0002AAAC") then -- Is this a valid map pack?
		show_message("This is NOT a valid chips data file!");
		return false
	end
	
	numlevels = read_word(f); -- Grab how many levels are in the pack:
	local bimap = read_word(f); -- Grab how many bytes in this level
	
	if(n>numlevels) then -- Are there even n levels in this pack?
		show_message("You can't load level number "..n.." since the pack only contains "..numlevels.." levels!");
		return false
	end
		
	local nn = n-1
	while(nn>0) do
		nn=nn-1 -- Tell it we went to the next map
		bin_skip(f,bimap); -- Skip a level
		bimap = read_word(f); -- Grab how many bytes in this level 
	end
	
	levelnumber = read_word(f) or 0; -- Level Number
	timelimit = read_word(f) or -1; -- Time Limit
	totalchips = read_word(f) or 0; -- Chips required
	read_word(f); -- Map detail, useless, no need to store it
	local bifl = read_word(f); -- Number of bytes in the first layer
	
	--Reset some key values
	hint = ""
	password = "NOPASSWORD"
	leveltitle = "<No Title>"
	monsters_total = 0
	
	--Reset the time countdowner:
	alarm(1,30);
	
	--Start monsters moving:
	monsters_canmove_ = 6;
	
	--Force floors:
	Chip_Forcer_recalc = 0;
	
	--Ice Floors:
	Chip_Ice_recalc = 0;
	Chip_ice_dir = 0
	
	--We are ingame now:
	ingame = true;
	
	--Blocks:
	Chip_Last_Dir = 110;
	
	--Reset Items
	Chip_has_flippers = false;
	Chip_has_fireboots = false;
	Chip_has_scates = false;
	Chip_has_suction = false;
	Chip_has_greenkey = false;
	Chip_has_bluekey = 0;
	Chip_has_redkey = 0;
	Chip_has_yellowkey = 0;
	
	--Reset the layers:
	Layer_One = {}
	Layer_Two = {}
	for i=0, 31 do
		Layer_One[i] = {}
		Layer_Two[i] = {}
	end
	
	--Clear the monster list:
	monsters_x = {}
	monsters_y = {}
	monsters_sort = {}
	monsters_canmove = {}
	monsters_total = 0
	
	--Clear cloning list:
	clone_x = {}
	clone_y = {}
	clone_xx = {}
	clone_yy = {}
	clone_total = 0
	
	--Reset Chips
	Chip_x = 0;
	Chip_y = 0;
	upR = 0;
	leftR = 0;
	
	--Load the first layer:
	while(bifl>0) do
		local tmp = read_byte(f) or 0;
		bifl = bifl-1;
		if(tmp == 255) then
			tmp = read_byte(f) or 0;
			tmpa = read_byte(f) or 0;
			bifl = bifl-2;
			for i=1, tmp, 1 do
				--Assign the tile to the correct place:
				Layer_One[xx][yy] = tmpa
				--Find Chip:
				if(tmp>=108 and tmp<=111)then
					Chip_x=xx
					Chip_y=yy
				end
				--Move to the next square:
				xx = xx+1;
				if(xx>31) then
					xx=0;
					yy=yy+1;
				end
			end
		else
			--Assign the tile:
			Layer_One[xx][yy] = tmp
			--Find Chip:
			if(tmp>=108 and tmp<=111)then
				Chip_x=xx
				Chip_y=yy
			end
			--Move to the next square:
			xx = xx+1;
			if(xx>31) then
				xx=0;
				yy=yy+1;
			end
		end
	end
	
	--Reset Chip Canmove
	Chip_canmove = 0;
	
	--Bytes in the second layer:
	local bisl = read_word(f);
	
	-- Skip the second layer:
	--bin_skip(f,bisl);
	
	local xx,yy = 0,0;
	
	--Load the second layer:
	while(bisl>0) do
		local tmp = read_byte(f) or 0;
		bisl = bisl-1;
		if(tmp == 255) then
			tmp = read_byte(f) or 0;
			tmpa = read_byte(f) or 0;
			bisl = bisl-2;
			for i=1, tmp, 1 do
				--Assign the tile to the correct place:
				Layer_Two[xx][yy] = tmpa
				--Move to the next square:
				xx = xx+1;
				if(xx>31) then
					xx=0;
					yy=yy+1;
				end
			end
		else
			--Assign the tile:
			Layer_Two[xx][yy] = tmp
			--Move to the next square:
			xx = xx+1;
			if(xx>31) then
				xx=0;
				yy=yy+1;
			end
		end
	end
	
	--Number of bytes in the optional area:
	local biop = read_word(f);
	
	--Loop through all the fields:
	while(biop>0) do
		local field = read_byte(f); --Field Number
		local bif = read_byte(f);   --Bytes in field
		biop = biop-2-bif; -- Remove the bytes read this session
		
		-- Map title:
		if(field == 3) then
			leveltitle = ""
			while(bif>0) do
				bif=bif-1
				leveltitle = leveltitle..string.char(read_byte(f));
			end
		--List of bear traps:
		elseif(field == 4)then
			--Clear beartrap list:
			bear_x = {};
			bear_y = {};
			bear_xx = {};
			bear_yy = {};
			bear_open = {};
			bear_total = 0;
			while(bif>0) do
				bif=bif-10;
				bear_total = bear_total+1;
				bear_x[bear_total] = read_word(f);
				bear_y[bear_total] = read_word(f);
				bear_xx[bear_total] = read_word(f);
				bear_yy[bear_total] = read_word(f);
				bear_open[bear_total] = 0;
				read_word(f); -- No idea what this is used for
			end
		--List of cloning machines:
		elseif(field == 5)then
			--Clear cloning list:
			clone_x = {};
			clone_y = {};
			clone_xx = {};
			clone_yy = {};
			clone_total = 0;
			while(bif>0) do
				bif=bif-8;
				clone_total = clone_total+1;
				clone_x[clone_total] = read_word(f);
				clone_y[clone_total] = read_word(f);
				clone_xx[clone_total] = read_word(f);
				clone_yy[clone_total] = read_word(f);
			end
		-- Password:
		elseif(field == 6) then
			password = ""
			while(bif>1) do
				bif=bif-1
				password = password..string.char(bxor(read_byte(f),153));
			end
			read_byte(f) -- Read terminating 0
		-- Hint:
		elseif(field == 7) then
			hint = ""
			while(bif>0) do
				bif=bif-1
				hint = hint..string.char(read_byte(f));
			end
		-- Monsters:
		elseif(field == 10) then
			monsters_x = {}
			monsters_y = {}
			monsters_sort = {}
			monsters_canmove = {}
			monsters_total = 0
			
			while(bif>0) do
				bif=bif-2
				monsters_total = monsters_total+1;
				monsters_x[monsters_total] = read_byte(f) or 0;
				monsters_y[monsters_total] = read_byte(f) or 0;
				monsters_canmove[monsters_total]=1;
				if(Chip_is_monster(Layer_One[monsters_x[monsters_total]][monsters_y[monsters_total]])) then
					monsters_sort[monsters_total] = Layer_One[monsters_x[monsters_total]][monsters_y[monsters_total]]
				elseif(Chip_is_monster(Layer_Two[monsters_x[monsters_total]][monsters_y[monsters_total]])) then
					monsters_sort[monsters_total] = Layer_Two[monsters_x[monsters_total]][monsters_y[monsters_total]]
				else
					monsters_total = monsters_total-1
				end
			end
		-- Unknown or unused field, Skip:
		else
			bin_skip(f,bif);
		end
	end
	bin_close(f) -- Close the file
	
	--Only restart the music if we change maps:
	if(oldmap~=levelnumber)then
		--Stop the old music:
		sound_stop(music_1)
		sound_stop(music_2)
		
		--Start the sexy music:
		if(levelnumber == math.floor(levelnumber/2)*2)then
			sound_loop(music_1)
		else
			sound_loop(music_2)
		end
	end
	
	--Patch tanks:
	--for i=1,monsters_total do
	--	monsters_canmove[i]=1;
	--end
end

--Level Loading Function
function Chip_Preview_Map(f, n, v) -- F=filename; n=levelid; v=assign variables?
	local xx, yy, i = 0, 0, 0; -- Init variables
	local f = bin_open(f); -- Open the file for reading
	local code = read_long(f); -- Grab the level code / ruleset
	if(code ~= "0002AAAC") then -- Is this a valid map pack?
		show_message("This is NOT a valid chips data file!");
		return false
	end
	
	prev_numlevels = read_word(f); -- Grab how many levels are in the pack:
		
	local bimap = read_word(f); -- Grab how many bytes in this level
	
	if(n>prev_numlevels) then -- Are there even n levels in this pack?
		return false
	end
	
	local nn = n-1
	while(nn>0) do
		nn=nn-1 -- Tell it we went to the next map
		bin_skip(f,bimap); -- Skip a level
		bimap = read_word(f); -- Grab how many bytes in this level 
	end
	
	if(v)then
		prev_levelnumber = read_word(f) or 0; -- Level Number
		prev_timelimit = read_word(f) or -1; -- Time Limit
		if(prev_timelimit==-1)then prev_timelimit="No Timelimit";else prev_timelimit=prev_timelimit.." seconds";end
		prev_totalchips = read_word(f) or 0; -- Chips required
	else
		read_word(f);read_word(f);read_word(f);
	end
	read_word(f); -- Map detail, useless, no need to store it
	local bifl = read_word(f); -- Number of bytes in the first layer
	
	local prev_layer = {}
	for i=0, 31 do
		prev_layer[i] = {}
	end
	
	local prev_Chip_x,prev_Chip_y = 0,0;
	
	--Render the map:
	while(bifl>0) do
		local tmp = read_byte(f) or 0;
		bifl = bifl-1;
		if(tmp == 255) then
			tmp = read_byte(f) or 0;
			tmpa = read_byte(f) or 0;
			bifl = bifl-2;
			for i=1, tmp, 1 do
				--Assign the tile to the correct place:
				prev_layer[xx][yy] = tmpa
				--Find Chip:
				if(tmp>=108 and tmp<=111)then
					prev_Chip_x=xx
					prev_Chip_y=yy
				end
				--Move to the next square:
				xx = xx+1;
				if(xx>31) then
					xx=0;
					yy=yy+1;
				end
			end
		else
			--Assign the tile:
			prev_layer[xx][yy] = tmp
			--Find Chip:
			if(tmp>=108 and tmp<=111)then
				prev_Chip_x=xx
				prev_Chip_y=yy
			end
			--Move to the next square:
			xx = xx+1;
			if(xx>31) then
				xx=0;
				yy=yy+1;
			end
		end
	end
	
	--Reset some key values
	if(v) then
		prev_leveltitle = "<No Title>"
		-- Skip the second layer:
		bin_skip(f,read_word(f));
		
		--Number of bytes in the optional area:
		local biop = read_word(f);
		
		--Loop through all the fields:
		while(biop>0) do
			local field = read_byte(f); --Field Number
			local bif = read_byte(f);   --Bytes in field
			biop = biop-2-bif; -- Remove the bytes read this session
			
			-- Map title:
			if(field == 3) then
				prev_leveltitle = ""
				while(bif>0) do
					bif=bif-1
					prev_leveltitle = prev_leveltitle..string.char(read_byte(f));
				end
				break;
			else
				bin_skip(f,bif);
			end
		end
	end
	-- Close the file
	bin_close(f)
	
	--Draw the map:
	local xx,yy,xxx,yyy = 0,0,math.min(23,math.max(0,prev_Chip_x-4)),math.min(23,math.max(0,prev_Chip_y-4));
	-- Create a surface to render to
	local surf = surface_create(144, 144);
	--Start rendering to the surface:
	surface_set_target(surf);
	--Draw on the preview:
	for xx=0,8 do
		for yy=0,8 do
			draw_sprite(spr_tile_mini[prev_layer[xx+xxx][yy+yyy] or 0],0,xx*16,yy*16)
		end
	end
	--Stop rendering to the surface:
	surface_reset_target()
	--Create the sprite:
	local spr_preview = sprite_create_from_surface(surf,0,0,144,144,0,0,0,0); -- Create and store the image
	--Free the surface:
	surface_free(surf);
	--Return the result:
	return spr_preview;
end

--Load the three images required:
function Chip_preview_three(f,n)
	spr_preview_m = Chip_Preview_Map(f,n,true);
	if(n>1) then spr_preview_l = Chip_Preview_Map(f,n-1,false);else spr_preview_l = Chip_Preview_Map(f,prev_numlevels,false);end
	if(n<prev_numlevels)then spr_preview_r = Chip_Preview_Map(f,n+1,false);else spr_preview_r = Chip_Preview_Map(f,1,false);end
	prev_currentlevel = n;
end

function Chip_Hud()
	--Draw the map:
	local xx,yy,xxx,yyy = 0,0,math.min(23,math.max(0,Chip_x-4)),math.min(23,math.max(0,Chip_y-4));
	--xxx = math.min(27,xxx)
	--yyy = math.min(27,yyy) -- Limit x and y values
	
	for xx=0,8 do
		for yy=0,8 do
			draw_sprite(spr_tile[Layer_Two[xx+xxx][yy+yyy] or 0],0,xx*32+32,yy*32+32)
			draw_sprite(spr_tile_top[Layer_One[xx+xxx][yy+yyy] or 0],0,xx*32+32,yy*32+32)
		end
	end
	
	--for a=0,11 do
	--	draw_sprite(spr_font_yellow[a], 0, a*17, 0);
	--	draw_sprite(spr_font_green[a], 0, a*17, 23);
	--end
	
	--Draw the items on:
	if(Chip_has_redkey>0)then draw_sprite(spr_tile[101],0,352,247);end -- red key
	if(Chip_has_bluekey>0)then draw_sprite(spr_tile[100],0,384,247);end -- cyan key
	if(Chip_has_yellowkey>0)then draw_sprite(spr_tile[103],0,416,247);end -- yellow key
	if(Chip_has_greenkey)then draw_sprite(spr_tile[102],0,448,247);end -- green key
	
	if(Chip_has_scates)then draw_sprite(spr_tile[106],0,352,279);end -- skates
	if(Chip_has_suction)then draw_sprite(spr_tile[107],0,384,279);end -- suction cup
	if(Chip_has_fireboots)then draw_sprite(spr_tile[105],0,416,279);end -- fire boots
	if(Chip_has_flippers)then draw_sprite(spr_tile[104],0,448,279);end -- flippers
	
	--Work out what to draw: (Level)
	local chipsleft,value,drawvalueh,drawvaluet,yesmas = levelnumber,math.floor(levelnumber/100),0,0,false;
	if(value == 0)then drawvalueh = 10;yesmas=true;else drawvalueh = value;end
	chipsleft=chipsleft-value*100;
	value = math.floor(chipsleft/10);
	if(value == 0 and yesmas)then drawvaluet = 10;else drawvaluet = value;yesmas=true;end
	chipsleft=chipsleft-value*10;
	
	--Draw the level number:
	draw_sprite(spr_font_green[drawvalueh],0,386,63);
	draw_sprite(spr_font_green[drawvaluet],0,403,63);
	draw_sprite(spr_font_green[chipsleft],0,420,63);
	
	--Work out what to draw: (Chips)
	local chipsleft,value,drawvalueh,drawvaluet,yesmas = totalchips,math.floor(totalchips/100),0,0,false;
	if(value == 0)then drawvalueh = 10;yesmas=true;else drawvalueh = value;end
	chipsleft=chipsleft-value*100;
	value = math.floor(chipsleft/10);
	if(value == 0 and yesmas)then drawvaluet = 10;else drawvaluet = value;yesmas=true;end
	chipsleft=chipsleft-value*10;
	
	--Draw the chips:
	if(totalchips>0)then
		draw_sprite(spr_font_green[drawvalueh],0,386,215);
		draw_sprite(spr_font_green[drawvaluet],0,403,215);
		draw_sprite(spr_font_green[chipsleft],0,420,215);
	else
		draw_sprite(spr_font_yellow[drawvalueh],0,386,215);
		draw_sprite(spr_font_yellow[drawvaluet],0,403,215);
		draw_sprite(spr_font_yellow[chipsleft],0,420,215);
	end
	
	--Render the time limit on:
	if(timelimit<0) then
		draw_sprite(spr_font_green[11],0,386,125);
		draw_sprite(spr_font_green[11],0,403,125);
		draw_sprite(spr_font_green[11],0,420,125);
	else
		local chipsleft,value,drawvalueh,drawvaluet,yesmas = timelimit,math.floor(timelimit/100),0,0,false;
		if(value == 0)then drawvalueh = 10;yesmas=true;else drawvalueh = value;end
		chipsleft=chipsleft-value*100;
		value = math.floor(chipsleft/10);
		if(value == 0 and yesmas)then drawvaluet = 10;else drawvaluet = value;yesmas=true;end
		chipsleft=chipsleft-value*10;
		
		if(timelimit>15)then
			draw_sprite(spr_font_green[drawvalueh],0,386,125);
			draw_sprite(spr_font_green[drawvaluet],0,403,125);
			draw_sprite(spr_font_green[chipsleft],0,420,125);
		else
			draw_sprite(spr_font_yellow[drawvalueh],0,386,125);
			draw_sprite(spr_font_yellow[drawvaluet],0,403,125);
			draw_sprite(spr_font_yellow[chipsleft],0,420,125);
		end
	end
	
	--Draw the hint:
	if(Layer_Two[Chip_x][Chip_y]==47) then
		draw_sprite(hintbg,0,352,165);
		draw_set_color(color(0,255,255));
		draw_set_font(font_hint);
		draw_text_center(416,174,"Hint: "..hint,-1,120);
	end
end

--Shortcut Keys:
function Chips_Keyboard_Shortcuts()
	-- Next Level
	if(keyboard_check_pressed(78) == 1) then
		Chip_Load_Map("chips.dat", levelnumber+1);
	end
	
	--Previous Level
	if(keyboard_check_pressed(80) == 1) then
		Chip_Load_Map("chips.dat", levelnumber-1);
	end
	
	--GoTo:
	if(keyboard_check_pressed(71) == 1) then
		Chip_Load_Map("chips.dat", tonumber(get_string("Enter a level number to load (1 - 149):",levelnumber)));
	end
	
	--Back to menu:
	if(keyboard_check_pressed(27) == 1) then
		ingame = false;
		sound_stop_all();
		Chip_preview_three("chips.dat",levelnumber);
	end
	
	--Restart:
	if(keyboard_check_pressed(82) == 1) then
		Chip_Load_Map("chips.dat", levelnumber);
	end
end

--Load in a tileset:
function Chip_Load_Tileset(f)
	local surf = surface_create(32, 32); -- Create a surface to render to
	local tileset = sprite_add(f, 0, 0, 0, 0, 0); -- Load in the tileset
	local a,xx,yy = 0,0,0; -- TileID
	
	spr_tile = {}
	spr_tile_top = {}
	
	--Loop through and generate each tile:
	for xx=0,4 do
		for yy=0, 15 do
			surface_set_target(surf); -- Render to the surface
			draw_sprite(tileset, 0, xx*-32, yy*-32); -- Draw the sprite on
			surface_reset_target()
			spr_tile[a] = sprite_create_from_surface(surf,0,0,32,32,0,0,0,0); -- Create and store the image
			spr_tile_top[a] = spr_tile[a]; --also store it here
			
			sprite_save(spr_tile_top[a], 0, "Sprites/bot_"..a..".png")
			sprite_save(spr_tile_top[a], 0, "Sprites/top_"..a..".png")
			a = a+1; -- Increment a
		end
	end
	
	for xx=5,6 do
		for yy=0, 15 do
			surface_set_target(surf); -- Render to the surface
			draw_sprite(tileset, 0, xx*-32, yy*-32); -- Draw the sprite on
			surface_reset_target()
			spr_tile[a] = sprite_create_from_surface(surf,0,0,32,32,0,0,0,0); -- Create and store the image
			
			sprite_save(spr_tile[a], 0, "Sprites/top_"..a..".png")
			sprite_save(spr_tile[a], 0, "Sprites/bot_"..a..".png")
			a = a+1; -- Increment a
		end
	end
	
	a = 64; -- Start at 64
	
	--Loop through and generate the top tiles:
	for xx=0,3 do
		for yy=0, 15 do
			surface_set_target(surf); -- Render to the surface
			surface_reset() -- Clear the surface
			draw_sprite(tileset, 0, xx*-32-224, yy*-32); -- Draw the sprite on
			surface_reset_target()
			spr_tile_top[a] = sprite_create_from_surface(surf,0,0,32,32,0,0,0,0); -- Create and store the image
			
			sprite_save(spr_tile_top[a], 0, "Sprites/top_"..a..".png")
			a = a+1; -- Increment a
		end
	end
	
	--Free Resources:
	sprite_delete(tileset);
	surface_free(surf);
end

--Load in a mini tileset:
function Chip_Load_Mini_Tileset(f)
	local surf = surface_create(16, 16); -- Create a surface to render to
	local tileset = sprite_add(f, 0, 0, 0, 0, 0); -- Load in the tileset
	local a,xx,yy = 0,0,0; -- TileID
	
	spr_tile_mini = {}
	
	--Loop through and generate each tile:
	for xx=0,6 do
		for yy=0, 15 do
			surface_set_target(surf); -- Render to the surface
			draw_sprite(tileset, 0, xx*-16, yy*-16); -- Draw the sprite on
			surface_reset_target()
			spr_tile_mini[a] = sprite_create_from_surface(surf,0,0,16,16,0,0,0,0); -- Create and store the image
			a = a+1; -- Increment a
		end
	end
	
	--Store the black image:
	surface_set_target(surf);
	draw_set_color(color(0,0,0))
	draw_rectangle(0,0,16,16)
	surface_reset_target()
	spr_tile_mini[a] = sprite_create_from_surface(surf,0,0,16,16,0,0,0,0);
	
	--Free Resources:
	sprite_delete(tileset);
	surface_free(surf);
end

--Load a font:
function chips_font_add(f)
	local surf = surface_create(17, 23); -- Create a surface to render to
	local tileset = sprite_add(f, 0, 0, 0, 0, 0); -- Load in the tileset
	local a,yy = 0,0; -- TileID
	
	spr_font_green = {}
	spr_font_yellow = {}
	
	--Loop through and generate each tile:
	for yy=11,0,-1 do
		surface_set_target(surf); -- Render to the surface
		draw_sprite(tileset, 0, 0, yy*-23); -- Draw the sprite on
		surface_reset_target()
		spr_font_yellow[a] = sprite_create_from_surface(surf,0,0,17,23,0,0,0,0); -- Create and store the image
		a = a+1; -- Increment a
	end
	
	a = 0;
	
	for yy=11,0,-1 do
		surface_set_target(surf); -- Render to the surface
		draw_sprite(tileset, 0, 0, yy*-23-276); -- Draw the sprite on
		surface_reset_target()
		spr_font_green[a] = sprite_create_from_surface(surf,0,0,17,23,0,0,0,0); -- Create and store the image
		a = a+1; -- Increment a
	end
	
	--Free Resources:
	sprite_delete(tileset);
	surface_free(surf);
end

--Build the GUI:
function Chip_Build_gui()
	local surf = surface_create(512, 352); -- Create a surface to render to
	local xx,yy = 0,0; -- Some variables
	
	-- Render to the surface:
	surface_set_target(surf);
	-- Clear the surface:
	surface_reset()
	
	local f = bin_open("images/levelselect.47");
	local a = read_byte(f);
	local w=color(255,255,255)
	
	while(a~=255)do
		draw_sprite(spr_tile_mini[a or 0],0,xx*16,yy*16);
		xx=xx+1;
		if(xx>31)then
			xx=0;
			yy=yy+1;
		end
		a = read_byte(f);
	end
	
	--Stop reading from the file:
	bin_close(f);
	
	--Draw on some text:
	draw_set_font(font_ls);
	draw_set_color(white);
	draw_text_center(256,273,"Press 'Enter'#to begin!",-1,-1)
	draw_text_center(432,242,"Top Times",-1,-1)
	draw_text_center(96,337,"Press 'R' to browse replays",-1,-1)
	draw_text_center(416,337,"Press 'H' to view highscores",-1,-1)
	
	--Add the arrows on:
	local arrow = sprite_add("images/arrow_left.png", 0, 0, 0, 0, 0); -- Load in the tileset
	draw_sprite(arrow,0,169,126)
	sprite_delete(arrow);
	local arrow = sprite_add("images/arrow_right.png", 0, 0, 0, 0, 0); -- Load in the tileset
	draw_sprite(arrow,0,332,126)
	sprite_delete(arrow);
	
	--Stop rendering to the surface:
	surface_reset_target()
	
	--Add the image:
	gui_levelselect = sprite_create_from_surface(surf,0,0,512,352,0,0,0,0);
	
	--Free Resources:
	surface_free(surf);
end

--Check if something is exists in a square:
function Chip_at_square(xx,yy,cc)
	--Grab both tiles:
	local c = Layer_One[xx][yy] or 0
	return(cc==c)
end

--Bear Traps:
function BrownButton(x,y,o) -- o = on/off
	if(Layer_Two[x][y] == 39 or Layer_One[x][y] == 39) then
		local i = 0;
		--Lets find any bear traps it matches:
		for i=1,bear_total do
			--Is it at our position?
			if(bear_x[i]==x and bear_y[i]==y)then
				if(o==1) then
					-- Play button noise:
					sound_play(sound_button);
				end
				
				--Open or close the trap:
				bear_open[i] = o;
			end
		end
	end
end

--For clone machines:
function CheckClones(x,y)
	local i = 0;
	--Lets find any clone machines it matches:
	for i=1,clone_total do
		--Is it at our position?
		if(clone_x[i]==x and clone_y[i]==y)then
			-- Play button noise:
			sound_play(sound_button);
			
			--Clone:
			local sort,xx,yy=Layer_One[clone_xx[i]][clone_yy[i]],clone_xx[i],clone_yy[i];
			
			--Cloneblock North
			if(sort==14)then
				Clone_block(xx,yy-1)
			--Cloneblock West
			elseif(sort==15)then
				Clone_block(xx-1,yy)
			--Cloneblock South
			elseif(sort==16)then
				Clone_block(xx,yy+1)
			--Cloneblock East
			elseif(sort==17)then
				Clone_block(xx+1,yy)
			--Bug North
			elseif(sort==64)then
				Monster_Clone(xx,yy-1,sort)
			--Bug West
			elseif(sort==65)then
				Monster_Clone(xx-1,yy,sort)
			--Bug South
			elseif(sort==66)then
				Monster_Clone(xx,yy+1,sort)
			--Bug East
			elseif(sort==67)then
				Monster_Clone(xx+1,yy,sort)
			--Fireball North
			elseif(sort==68)then
				Monster_Clone(xx,yy-1,sort)
			--Fireball West
			elseif(sort==69)then
				Monster_Clone(xx-1,yy,sort)
			--Fireball South
			elseif(sort==70)then
				Monster_Clone(xx,yy+1,sort)
			--Fireball East
			elseif(sort==71)then
				Monster_Clone(xx+1,yy,sort)
			--Ball North
			elseif(sort==72)then
				Monster_Clone(xx,yy-1,sort)
			--Ball West
			elseif(sort==73)then
				Monster_Clone(xx-1,yy,sort)
			--Ball South
			elseif(sort==74)then
				Monster_Clone(xx,yy+1,sort)
			--Ball East
			elseif(sort==75)then
				Monster_Clone(xx+1,yy,sort)
			--Tank North
			elseif(sort==76)then
				Monster_Clone(xx,yy-1,sort)
			--Tank West
			elseif(sort==77)then
				Monster_Clone(xx-1,yy,sort)
			--Tank South
			elseif(sort==78)then
				Monster_Clone(xx,yy+1,sort)
			--Tank East
			elseif(sort==79)then
				Monster_Clone(xx+1,yy,sort)
			--Glider North
			elseif(sort==80)then
				Monster_Clone(xx,yy-1,sort)
			--Glider West
			elseif(sort==81)then
				Monster_Clone(xx-1,yy,sort)
			--Glider South
			elseif(sort==82)then
				Monster_Clone(xx,yy+1,sort)
			--Glider East
			elseif(sort==83)then
				Monster_Clone(xx+1,yy,sort)
			--Walker North
			elseif(sort==88)then
				Monster_Clone(xx,yy-1,sort)
			--Walker West
			elseif(sort==89)then
				Monster_Clone(xx-1,yy,sort)
			--Walker South
			elseif(sort==90)then
				Monster_Clone(xx,yy+1,sort)
			--Walker East
			elseif(sort==91)then
				Monster_Clone(xx+1,yy,sort)
			--Centipede North
			elseif(sort==96)then
				Monster_Clone(xx,yy-1,sort)
			--Centipede West
			elseif(sort==97)then
				Monster_Clone(xx-1,yy,sort)
			--Centipede South
			elseif(sort==98)then
				Monster_Clone(xx,yy+1,sort)
			--Centipede East
			elseif(sort==99)then
				Monster_Clone(xx+1,yy,sort)
			end
		end
	end
end
function Monster_Clone(xx,yy,sort)
	if(not Chip_is_monster_solid(xx,yy)) then
		local a=Layer_One[xx][yy];
		Layer_Two[xx][yy] = Layer_One[xx][yy];
		Layer_One[xx][yy] = sort;
		monsters_total = monsters_total+1;
		monsters_x[monsters_total] = xx;
		monsters_y[monsters_total] = yy;
		monsters_canmove[monsters_total]=1;
		monsters_sort[monsters_total] = sort;
		--Try to kill Chip:
		if(a == 108 or a == 109 or a == 110 or a == 111) then
			Chip_dodeath("Ooops! Look out for creatures!",-1)
		end
	end
end
function Clone_block(xx,yy)
	if(not Chip_is_block_solid(xx,yy))then
		Layer_Two[xx][yy] = Layer_One[xx][yy];
		Layer_One[xx][yy] = 10;
	elseif(Chip_at_square(xx,yy,108) or Chip_at_square(xx,yy,109) or Chip_at_square(xx,yy,110) or Chip_at_square(xx,yy,111))then
		Chip_dodeath("Ooops! Watch out for moving blocks!",10)
	end
end

--Handle monsters:
dofile("lua/monster_control.lua")

--Handle chip:
dofile("lua/chip_control.lua")
