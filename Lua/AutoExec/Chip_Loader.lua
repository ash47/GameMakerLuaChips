--Required GM functions:
dofile "lua/chips.lua" -- Chips Challenge functions

--Load in our background:
bg = background_add("images/hud.png",0,0);
hintbg = sprite_add("images/hint.png", 0, 0, 0, 0, 0);

--Add our font:
chips_font_add("images/font.png");
font_hint = font_add("Fonts/arial.ttf",10,1,1,0,255);
font_ls = font_add("Fonts/arial.ttf",8,1,0,0,255); -- Level Select

--Define colours:
white = color(255,255,255)
grey = color(153,153,153)

--Import our sounds:
sound_bummer = sound_add("Sounds/BUMMER.WAV",0,1);
sound_pickup_chip = sound_add("Sounds/CLICK3.WAV",0,1);
sound_pickup_key = sound_add("Sounds/BLIP2.WAV",0,1);
sound_open_door = sound_add("Sounds/DOOR.WAV",0,1);
sound_wall_solid = sound_add("Sounds/OOF3.WAV",0,1);
sound_thief = sound_add("Sounds/STRIKE.WAV",0,1);
sound_teleport = sound_add("Sounds/TELEPORT.WAV",0,1);
sound_water = sound_add("Sounds/WATER2.WAV",0,1);
sound_finish = sound_add("Sounds/DITTY1.WAV",0,1);
sound_button = sound_add("Sounds/POP2.WAV",0,1);

--Import our "music"
music_1 = sound_add("Sounds/CHIP01.MID",0,1);
music_2 = sound_add("Sounds/CHIP02.MID",0,1);
sound_volume(music_1,0.75);
sound_volume(music_2,0.75);

--Setup a room
MyRoom = room_add();							--Create a new room!
room_set_dim(MyRoom,512,352);						--Set the room's dimentions
room_set_background(MyRoom,0,1,0,bg,0,0,0,0,0,0,1);
room_goto(MyRoom);								--Goto our new room

--Load up the two tilesets:
Chip_Load_Tileset("images/tileset.png");
Chip_Load_Mini_Tileset("images/tileset_mini.png")

--Build the GUI:
Chip_Build_gui();

--Are we ingame?
ingame = false;

--Generate a preview:
Chip_preview_three("chips.dat",1);

--Load a level, or not:
--Chip_Load_Map("chips.dat", tonumber(get_string("Enter a level number to load (1 - 149):","1")));

--Display level details:
--show_message("Level: "..leveltitle.."#Password: "..password)

--Draw the map
function onDraw()
	if(ingame) then
		--Chips movement:
		Chip_Move_Chip()
		
		--Move the monsters:
		Chip_Move_Monsters()
		
		--Render the HUD:
		Chip_Hud();
		
		--Shortcut Keys:
		Chips_Keyboard_Shortcuts();
	else
		--Render the main GUI:
		draw_sprite(gui_levelselect,0,0,0)
		
		--Allow the user to change levels:
		if(keyboard_check_pressed(37) == 1)then
			prev_currentlevel=prev_currentlevel-1;
			if(prev_currentlevel<1)then prev_currentlevel=prev_numlevels;end
			Chip_preview_three("chips.dat",prev_currentlevel);
		elseif(keyboard_check_pressed(39) == 1)then
			prev_currentlevel=prev_currentlevel+1;
			if(prev_currentlevel>prev_numlevels)then prev_currentlevel=1;end
			Chip_preview_three("chips.dat",prev_currentlevel);
		end
		
		if(keyboard_check_pressed(13) == 1)then
			Chip_Load_Map("chips.dat", prev_currentlevel);
		end
		
		--Render the grey text on:
		draw_set_font(font_ls);
		draw_set_color(grey);
		draw_text(34,258,"x"..prev_totalchips)
		draw_text(34,276,prev_timelimit)
		draw_text(34,292,"<No Recond>")
		
		--Render White text on:
		draw_set_color(white);
		draw_text_center(256,17,prev_leveltitle,-1,-1)
		draw_text_center(80,242,prev_leveltitle,-1,-1)
		
		--Render the previews:
		draw_sprite_ext(spr_preview_l,0,39,86,0.75,0.75,0,white,1);
		draw_sprite(spr_preview_m,0,184,62)
		draw_sprite_ext(spr_preview_r,0,378,86,0.75,0.75,0,white,1);
		
		--End the game:
		if(keyboard_check_pressed(27) == 1) then
			game_end();
		end
	end
	
	--Run the alarms: (TEMP)
	alarmProccess()
	
	return 0;
end

--Timer:
function onAlarm1()
	-- RERUN the alarm:
	alarm(1,30);
	
	timelimit=timelimit-1;
	if(timelimit==0)then
		Chip_dodeath("Ooops! Out of time!",-1)
	end
end

--Reset Sprite:
function onAlarm2()
	if(Layer_Two[Chip_x][Chip_y]==3)then
		Layer_One[Chip_x][Chip_y] = 62;
	else
		Layer_One[Chip_x][Chip_y] = 110;
	end
end
