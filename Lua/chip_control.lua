Require("io")

--Move Chip:
function Chip_Move_Chip()
	--Handle force floors:
	if(Chip_Forcer_recalc>0)then
		if(Chip_has_suction==false)then
			Chip_canmove=Chip_canmove-1
			Chip_Forcer_recalc=Chip_Forcer_recalc-1
			
			if(Chip_Forcer_recalc==0)then
				local sort = Layer_Two[Chip_x][Chip_y];
				if(sort==18)then
					Chip_Forcer_recalc=3;
					if(not Chip_is_solid(Chip_x,Chip_y-1))then
						Chip_move(0,-1)
					end
				elseif(sort==19)then
					Chip_Forcer_recalc=3;
					if(not Chip_is_solid(Chip_x+1,Chip_y))then
						Chip_move(1,0)
					end
				elseif(sort==20)then
					Chip_Forcer_recalc=3;
					if(not Chip_is_solid(Chip_x-1,Chip_y))then
						Chip_move(-1,0)
					end
				elseif(sort==13)then
					Chip_Forcer_recalc=3;
					if(not Chip_is_solid(Chip_x,Chip_y+1))then
						Chip_move(0,1)
					end
				end
			end
		end
	end
	
	if(Chip_Ice_recalc>0)then
		if(Chip_has_scates)then
			Chip_Ice_recalc=0
		else
			--Stop chip from moving:
			Chip_canmove = 1;
			upR = 0;
			leftR = 0;
			
			--Count down:
			Chip_Ice_recalc=Chip_Ice_recalc-1
			
			--Move:
			if(Chip_Ice_recalc==0)then
				--Are we even on ice?
				local sort = Layer_Two[Chip_x][Chip_y];
				local domove = false;
				
				--Normal
				if(sort==12)then
					domove = true;
				end
				
				--NorthWest
				if(sort==26)then
					domove = true;
					if(Chip_ice_dir==1)then
						Chip_ice_dir=4;
					elseif(Chip_ice_dir==2)then
						Chip_ice_dir=3;
					end
				end
				
				--NorthEast
				if(sort==27)then
					domove = true;
					if(Chip_ice_dir==1)then
						Chip_ice_dir=2;
					elseif(Chip_ice_dir==4)then
						Chip_ice_dir=3;
					end
				end
				
				--SouthEast
				if(sort==28)then
					domove = true;
					if(Chip_ice_dir==3)then
						Chip_ice_dir=2;
					elseif(Chip_ice_dir==4)then
						Chip_ice_dir=1;
					end
				end
				
				--SouthWest
				if(sort==29)then
					domove = true;
					if(Chip_ice_dir==2)then
						Chip_ice_dir=1;
					elseif(Chip_ice_dir==3)then
						Chip_ice_dir=4;
					end
				end
				
				--Move:
				if(domove)then
					--Reset the ice countdown:
					Chip_Ice_recalc=3;
					
					--Move based on the direction:
					if(Chip_ice_dir==1)then --north
						if(not Chip_is_solid(Chip_x,Chip_y-1))then
							Chip_move(0,-1)
						else
							Chip_ice_dir=3
							Chip_move(0,1)
						end
					elseif(Chip_ice_dir==2)then --west
						if(not Chip_is_solid(Chip_x-1,Chip_y))then
							Chip_move(-1,0)
						else
							Chip_ice_dir=4
							Chip_move(1,0)
						end
					elseif(Chip_ice_dir==3)then --south
						if(not Chip_is_solid(Chip_x,Chip_y+1))then
							Chip_move(0,1)
						else
							Chip_ice_dir=1
							Chip_move(0,1)
						end
					elseif(Chip_ice_dir==4)then --east
						if(not Chip_is_solid(Chip_x+1,Chip_y))then
							Chip_move(1,0)
						else
							Chip_ice_dir=2
							Chip_move(-1,0)
						end
					end
				end
			end
		end
	end
	
	if(Chip_canmove<=0)then
		--Check keys:
		local up,left = 0,0;
		if(keyboard_check(40)==1)then up=up+1 end
		if(keyboard_check(38)==1)then up=up-1 end
		if(keyboard_check(39)==1)then left=left+1 end
		if(keyboard_check(37)==1)then left=left-1 end
		local canmove = true
		
		--Use keyholds:
		if(up==0 and left == 0)then
			if(upR~=0 or leftR~=0)then
				up = upR or 0;
				left = leftR or 0;
			end
		end
		
		--Reset key holds:
		upR = 0;
		leftR = 0;
		
		--Bear Traps
		if(Layer_Two[Chip_x][Chip_y]==43)then
			local j=0;
			local doit = true;
			while(j<bear_total) do
				j=j+1;
				if(bear_xx[j]==xx and bear_yy[j]==yy) then
					if(bear_open[j] == 1) then
						doit = false;
						break;
					end
				end
			end
			if(doit)then
				--Assign the trap:
				local i=0;
				--Which direction:
				if(up>0)then i=110; elseif(up<0)then i=108; end
				if(left>0)then i=111; elseif(left<0)then i=109; end
				--Play the sound:
				if(i==0)then i=Layer_One[Chip_x][Chip_y] else sound_play(sound_wall_solid); end
				--Change the sprite:
				Layer_One[Chip_x][Chip_y]=i;
				--Reset the movement:
				up=0;left=0;
				--Stop Chip from spamming:
				Chip_canmove=5;
				--Reset sprite after 1 second.
				alarm(2,30);
			end
		end
		
		--Move if possible:
		if(up~=0)then
			--Stop chip from moving again:
			if(Chip_Forcer_recalc>0)then Chip_canmove=5;else Chip_canmove=5;end
			
			if(up>0)then Chip_Last_Dir=3; else Chip_Last_Dir=1; end
			if(not Chip_is_solid(Chip_x,Chip_y+up))then
				--Move up/down
				Chip_move(0,up)
				canmove = false;
			end
		end
		
		if(canmove) then
			if(left~=0)then
				--Stop chip from moving again:
				if(Chip_Forcer_recalc>0)then Chip_canmove=5;else Chip_canmove=5;end
				
				if(left>0)then Chip_Last_Dir=4; else Chip_Last_Dir=2; end
				if(not Chip_is_solid(Chip_x+left,Chip_y))then
					--Move left/right
					Chip_move(left,0)
					canmove = false;
				end
			end
		end
		
		if(canmove)then
			--Sprite didn't change, fix it:
			if(left~=0 or up~=0)then
				local i=Layer_One[Chip_x][Chip_y];
				if(left>0)then i=111; elseif(left<0)then i=109; end
				if(up>0)then i=110; elseif(up<0)then i=108; end
				Layer_One[Chip_x][Chip_y] = i;
				
				--Reset sprite after 1 second.
				alarm(2,30);
			end
		end
	else
		if(Chip_canmove<3) then
			--Movement helper:
			if(keyboard_check(40)==1)then upR=1;leftR=0; end
			if(keyboard_check(38)==1)then upR=-1;leftR=0; end
			if(keyboard_check(39)==1)then leftR=1;upR=0; end
			if(keyboard_check(37)==1)then leftR=-1;upR=0; end
		end
		
		Chip_canmove = Chip_canmove-1
	end
end

--Check for buttons:
function Chip_button(xx,yy,x,y)
	if(not (xx==x and yy==y))then
		local sort=Layer_Two[x][y];
		--Green Button:
		if(sort == 35)then
			local i,j = 0,0
			for i=0,31 do
				for j=0,31 do
					if(Layer_One[i][j]==37)then
						Layer_One[i][j]=38
					elseif(Layer_One[i][j]==38)then
						Layer_One[i][j]=37
					end
					if(Layer_Two[i][j]==38)then
						Layer_Two[i][j]=37
					elseif(Layer_Two[i][j]==37)then
						Layer_Two[i][j]=38
					end
				end
			end
		end
		--Brown Button
		BrownButton(x,y,1);
		
		--Blue Button:
		if(sort == 40)then
			-- Play the button noise:
			sound_play(sound_button);
			local i = 0;
			
			--Rotate in one step:
			for i=1,monsters_total do
				if(monsters_sort[i]>=76 and monsters_sort[i]<=79)then
					monsters_sort[i]=monsters_sort[i]+2;
					if(monsters_sort[i]>79)then monsters_sort[i]=monsters_sort[i]-4;end
					monsters_canmove[i]=1;
				end
			end
			--Redraw the room:
			draw_force();
		end
		--Red Button:
		if(sort == 36)then
			CheckClones(x,y);
		end
	end
end

function Chip_is_solid(xx,yy)
	--Stop the player from getting out:
	if(xx>31 or xx<0 or yy>31 or yy<0) then sound_play(sound_wall_solid);return true; end
	
	--Is it solid?
	local solid=false;
	
	--Grab both tiles:
	local c = Layer_One[xx][yy] or 0
	
	--Filter:
	if(c >= 64 and c<=99)then c = Layer_Two[xx][yy] end
	
	--Lets see if they are solid:
	if(c == 0) then return false end
	
	if(c == 1)then solid=true; end
	if(c == 5)then solid=true; end
	
	--Blocked north, south etc here
	
	--Moveable dirt block:
	if(c == 10)then
		if(Chip_Last_Dir==1)then -- North
			solid=Chip_blockcalc(xx,yy+1,0,-1)
		elseif(Chip_Last_Dir==2)then -- West
			solid=Chip_blockcalc(xx+1,yy,-1,0)
		elseif(Chip_Last_Dir==3)then -- South
			solid=Chip_blockcalc(xx,yy-1,0,1)
		elseif(Chip_Last_Dir==4)then -- East
			solid=Chip_blockcalc(xx-1,yy,1,0)
		end
	end
	
	if(c >= 14 and c<=17)then return true end
	
	--Key Doors:
	if(c==22)then -- Blue
		solid=(Chip_has_bluekey==0)
	elseif(c==23)then -- Red
		solid=(Chip_has_redkey==0)
	elseif(c==24)then -- Green
		solid=(Chip_has_greenkey==false)
	elseif(c==25)then -- Yellow
		solid=(Chip_has_yellowkey==0)
	end
	
	if(c == 31)then Layer_One[xx][yy]=1; solid=true; end
	
	--Socket:
	if(c == 34)then solid=(totalchips>0) end
	
	--Switch block closed:
	if(c == 37)then solid=true; end
	
	if(c == 44)then Layer_One[xx][yy]=1; solid=true; end
	
	if(c == 49)then solid=true; end
	
	if(solid)then
		sound_play(sound_wall_solid);
		return true;
	end
	
	--Monsters
	--if(c >= 64 and c<=99)then return true end
	
	return false
end

function Chip_blockcalc(xx,yy,xadd,yadd)
	if(not Chip_is_block_solid(xx+xadd*2,yy+yadd*2))then
		--Do we make dirt?
		if(Layer_One[xx+xadd*2][yy+yadd*2]==3)then
			Layer_One[xx+xadd*2][yy+yadd*2] = 11;
			sound_play(sound_water);
		-- Teleporter:
		elseif(Layer_One[xx+xadd*2][yy+yadd*2]==41)then
			local XX, YY, foundone, XAT, YAT = xx+xadd*2, yy+yadd*2, false, xx+xadd, yy+yadd;
			while(YY>=0 and XX>=0 and foundone==false) do
				--Check the previous teleporter:
				XX=XX-1; if(XX<0)then XX=31;YY=YY-1 end;
				
				if(Layer_One[XX][YY] == 41)then
					if(not Chip_is_block_solid(XX+xadd,YY+yadd))then foundone = true;XAT=XX+xadd;YAT=YY+yadd;end
				end
			end
			--Reset and try again:
			XX, YY = 32, 31
			while((YY>=yy or XX>xx+1) and foundone==false) do
				--Check the previous teleporter:
				XX=XX-1; if(XX<0)then XX=31;YY=YY-1 end;
				
				if(Layer_One[XX][YY] == 41)then
					if(not Chip_is_block_solid(XX+xadd,YY+yadd))then foundone = true;XAT=XX+xadd;YAT=YY+yadd;end
				end
			end
			if(foundone)then
				--Move the block:
				Layer_Two[XAT][YAT] = Layer_One[XAT][YAT];
				Layer_One[XAT][YAT] = 10;
				Layer_One[xx+xadd][yy+yadd]=Layer_Two[xx+xadd][yy+yadd];
				Layer_Two[xx+xadd][yy+yadd] = 0;
				return false;
			else
				if(not Chip_is_block_solid(XX+xadd*3,YY+yadd*3))then
					Layer_Two[XX+xadd*3][yy+yadd*3] = Layer_One[xx+xadd*3][yy+yadd*3];
					Layer_One[XX+xadd*3][yy+yadd*3] = 10;
					Layer_One[xx+xadd][yy+yadd]=Layer_Two[xx+xadd][yy+yadd];
					Layer_Two[xx+xadd][yy+yadd] = 0;
					return false;
				else
					return true;
				end
			end
		--Is it a bomb?
		elseif(Layer_One[xx+xadd*2][yy+yadd*2]==42)then
			Layer_One[xx+xadd*2][yy+yadd*2] = 0;
		else
			Layer_Two[xx+xadd*2][yy+yadd*2]=Layer_One[xx+xadd*2][yy+yadd*2];
			Layer_One[xx+xadd*2][yy+yadd*2]=10;
		end
		
		--Bring up layer shit:
		
		Layer_One[xx+xadd][yy+yadd]=Layer_Two[xx+xadd][yy+yadd];
		Layer_Two[xx+xadd][yy+yadd] = 0;
		return false;
	end
	return true;
end

--Check if something is solid for a block:
function Chip_is_block_solid(xx,yy)
	if(xx>31 or xx<0 or yy>31 or yy<0) then return true end
	
	--Grab both tiles:
	local c = Layer_One[xx][yy] or 0
	
	--Lets see if they are solid:
	if(c == 0) then return false end
	
	if(c == 1)then return true end
	if(c == 5)then return true end
	
	if(c == 10)then return true end
	
	--Dirt:
	if(c == 11)then return true end
	
	--Blocked north, south etc here
	
	if(c >= 14 and c<=17)then return true end
	
	--Key Doors:
	if(c==22)then -- Blue
		return(Chip_has_bluekey==0)
	elseif(c==23)then -- Red
		return(Chip_has_redkey==0)
	elseif(c==24)then -- Green
		return(Chip_has_greenkey==false)
	elseif(c==25)then -- Yellow
		return(Chip_has_yellowkey==0)
	end
	
	if(c == 31)then Layer_One[xx][yy]=1; return true end
	
	--Socket:
	if(c == 34)then return(totalchips>0) end
	
	--Switch block closed:
	if(c == 37)then return true end
	
	if(c == 44)then return true end
	
	if(c == 49)then return true end
	
	--Monsters
	if(c >= 64 and c<=99)then return true end
	
	return false
end

--Move chips:
function Chip_move(xadd,yadd)
	--Modify the sprite:
	local i,j=110,62;
	if(xadd>0)then i=111;j=63; elseif(xadd<0)then i=109;j=61; end
	if(yadd>0)then i=110;j=62; elseif(yadd<0)then i=108;j=60; end
	
	--Reset sprite after 1 second.
	alarm(2,30);
	
	--Modify new layer:
	Layer_Two[Chip_x+xadd][Chip_y+yadd] = Layer_One[Chip_x+xadd][Chip_y+yadd];
	if(Layer_Two[Chip_x+xadd][Chip_y+yadd]==3)then
		Layer_One[Chip_x+xadd][Chip_y+yadd] = j;
	else
		Layer_One[Chip_x+xadd][Chip_y+yadd] = i;
	end
	
	--Modify layer moving away from:
	Layer_One[Chip_x][Chip_y] = Layer_Two[Chip_x][Chip_y];
	Layer_Two[Chip_x][Chip_y] = 0;
	
	Chip_button(Chip_x,Chip_y,Chip_x+xadd,Chip_y+yadd) -- Handle other buttons
	BrownButton(Chip_x,Chip_y,0); -- Turn off brown buttons
	
	--Modify chip array:
	Chip_x = Chip_x+xadd
	Chip_y = Chip_y+yadd
	
	--Pickup items:
	Chip_pickup_items()
	
	--Hazards:
	Chips_check_hazards()
end

function Chips_check_hazards()
	local sort=Layer_Two[Chip_x][Chip_y] or 0;
	
	--Water
	if(sort == 3)then
		if(Chip_has_flippers==false)then
			Chip_dodeath("Ooops! Chip can't swim without flippers!",51)
		end
	--Fire
	elseif(sort == 4)then
		if(Chip_has_fireboots==false)then
			Chip_dodeath("Ooops! Don't step in the fire without fire boots!",52)
		end
	--Bomb
	elseif(sort == 42)then
		Chip_dodeath("Ooops! Don't touch the bombs!",-1)
	--Creatures
	elseif(sort >= 64 and sort<=99)then
		Chip_dodeath("Ooops! Look out for creatures!",-1)
	end
end

function Chip_dodeath(str,i)
	--Stop monsters:
	mmmtotal = 0;
	
	--Assign the tile:
	if(i~=-1)then
		Layer_One[Chip_x][Chip_y] = i;
	end
	
	--Play the death sound:
	sound_play(sound_bummer);
	
	--Redraw the room:
	draw_force();
	
	--Display the error:
	show_message(str);
	
	--Restart the level:
	Chip_Load_Map("chips.dat",levelnumber);
end

function Chip_pickup_items()
	local sort = Layer_Two[Chip_x][Chip_y];
	
	-- Chip
	if(sort==2)then
		Layer_Two[Chip_x][Chip_y]=0;
		sound_play(sound_pickup_chip); -- Play our sound
		if(totalchips>0)then
			totalchips=totalchips-1;
		end
	-- Dirt
	elseif(sort==11)then
		Layer_Two[Chip_x][Chip_y]=0;
	-- Ice Normal
	elseif(sort==12 or sort==26 or sort==27 or sort==28 or sort==29)then
		Chip_Ice_recalc=3;
		local frame=Layer_One[Chip_x][Chip_y]
		if(frame==108)then -- North
			Chip_ice_dir = 1
		elseif(frame==109)then -- West
			Chip_ice_dir = 2
		elseif(frame==110)then -- South
			Chip_ice_dir = 3
		elseif(frame==111)then -- East
			Chip_ice_dir = 4
		end
		
	-- Force Floor SOUTH
	elseif(sort==13)then
		Chip_Forcer_recalc=3;
	-- Force Floor NORTH
	elseif(sort==18)then
		Chip_Forcer_recalc=3;
	-- Force Floor EAST
	elseif(sort==19)then
		Chip_Forcer_recalc=3;
	-- Force Floor WEST
	elseif(sort==20)then
		Chip_Forcer_recalc=3;
	-- EXIT
	elseif(sort==21)then
		--Redraw the room:
		draw_force();
		
		--Play the sound:
		sound_play(sound_finish);
		
		--Show the message:
		show_message("ONWARD!")
		
		--Load the next map:
		Chip_Load_Map("chips.dat",levelnumber+1);
	-- Blue Door
	elseif(sort==22)then
		Layer_Two[Chip_x][Chip_y]=0;
		Chip_has_bluekey=Chip_has_bluekey-1
		sound_play(sound_open_door);
	-- Red Door
	elseif(sort==23)then
		Layer_Two[Chip_x][Chip_y]=0;
		Chip_has_redkey=Chip_has_redkey-1
		sound_play(sound_open_door);
	-- Green Door
	elseif(sort==24)then
		Layer_Two[Chip_x][Chip_y]=0;
		sound_play(sound_open_door);
	-- Yellow Door
	elseif(sort==25)then
		Layer_Two[Chip_x][Chip_y]=0;
		Chip_has_yellowkey=Chip_has_yellowkey-1
		sound_play(sound_open_door);
	-- Blue Fading Wall
	elseif(sort==30)then
		Layer_Two[Chip_x][Chip_y]=0;
	-- Thief
	elseif(sort==33)then
		Chip_has_flippers = false;
		Chip_has_fireboots = false;
		Chip_has_scates = false;
		Chip_has_suction = false;
		sound_play(sound_thief);
	-- Socket
	elseif(sort==34)then
		Layer_Two[Chip_x][Chip_y]=0;
	-- Teleporter:
	elseif(sort==41)then
		local XX, YY, foundone, XAT, YAT,XXAT,YYAT = Chip_x, Chip_y, false, Chip_x, Chip_y,Chip_x,Chip_y;
		while(YY>=0 and XX>=0 and foundone==false) do
			--Check the previous teleporter:
			XX=XX-1; if(XX<0)then XX=31;YY=YY-1 end;
			
			if(Layer_One[XX][YY] == 41)then
				if(Chip_Last_Dir==1)then -- North
					if(not Chip_is_solid(XX,YY-1))then foundone = true;XAT=XX;YAT=YY-1;XXAT=XX;YYAT=YY;end
				elseif(Chip_Last_Dir==2)then -- West
					if(not Chip_is_solid(XX-1,YY))then foundone = true;XAT=XX-1;YAT=YY;XXAT=XX;YYAT=YY;end
				elseif(Chip_Last_Dir==3)then -- South
					if(not Chip_is_solid(XX,YY+1))then foundone = true;XAT=XX;YAT=YY+1;XXAT=XX;YYAT=YY;end
				elseif(Chip_Last_Dir==4)then -- East
					if(not Chip_is_solid(XX+1,YY))then foundone = true;XAT=XX+1;YAT=YY;XXAT=XX;YYAT=YY;end
				end
			end
		end
		--Reset and try again:
		XX, YY = 32, 31
		while((YY>=Chip_y or XX>Chip_x+1) and foundone==false) do
			--Check the previous teleporter:
			XX=XX-1; if(XX<0)then XX=31;YY=YY-1 end;
			
			if(Layer_One[XX][YY] == 41)then
				if(Chip_Last_Dir==1)then -- North
					if(not Chip_is_solid(XX,YY-1))then foundone = true;XAT=XX;YAT=YY-1;XXAT=XX;YYAT=YY;end
				elseif(Chip_Last_Dir==2)then -- West
					if(not Chip_is_solid(XX-1,YY))then foundone = true;XAT=XX-1;YAT=YY;XXAT=XX;YYAT=YY;end
				elseif(Chip_Last_Dir==3)then -- South
					if(not Chip_is_solid(XX,YY+1))then foundone = true;XAT=XX;YAT=YY+1;XXAT=XX;YYAT=YY;end
				elseif(Chip_Last_Dir==4)then -- East
					if(not Chip_is_solid(XX+1,YY))then foundone = true;XAT=XX+1;YAT=YY;XXAT=XX;YYAT=YY;end
				end
			end
		end
		if(foundone)then
			--Stop memory leak:
			Layer_One[XXAT][YYAT] = 0;
			
			--Move Chip:
			Chip_move(XXAT-Chip_x,YYAT-Chip_y);
			
			--Fix our memory leak patch:
			Layer_Two[XXAT][YYAT] = 41;
			
			--Move chip again:
			Chip_move(XAT-Chip_x,YAT-Chip_y);
			
			--Play teleport sound:
			sound_play(sound_teleport);
		else
			--Move chip:
			if(Chip_Last_Dir==1)then -- North
				if(not Chip_is_solid(XX,YY-1))then Chip_move(0,-1);else Chip_move(0,1);end
			elseif(Chip_Last_Dir==2)then -- West
				if(not Chip_is_solid(XX-1,YY))then Chip_move(-1,0);else Chip_move(1,0);end
			elseif(Chip_Last_Dir==3)then -- South
				if(not Chip_is_solid(XX,YY+1))then Chip_move(0,1);else Chip_move(0,-1);end
			elseif(Chip_Last_Dir==4)then -- East
				if(not Chip_is_solid(XX+1,YY))then Chip_move(1,0);else Chip_move(-1,0);end
			end
			
			--Play teleport sound:
			sound_play(sound_teleport);
		end
	--Pass Once
	elseif(sort==46)then
		Layer_Two[Chip_x][Chip_y]=1;
	-- Blue Key
	elseif(sort==100)then
		Layer_Two[Chip_x][Chip_y]=0;
		Chip_has_bluekey = Chip_has_bluekey+1;
		sound_play(sound_pickup_key);
	-- Red Key
	elseif(sort==101)then
		Layer_Two[Chip_x][Chip_y]=0;
		Chip_has_redkey = Chip_has_redkey+1;
		sound_play(sound_pickup_key);
	-- Green Key
	elseif(sort==102)then
		Layer_Two[Chip_x][Chip_y]=0;
		Chip_has_greenkey = true;
		sound_play(sound_pickup_key);
	-- Yellow Key
	elseif(sort==103)then
		Layer_Two[Chip_x][Chip_y]=0;
		Chip_has_yellowkey = Chip_has_yellowkey+1;
		sound_play(sound_pickup_key);
	-- Flippers
	elseif(sort==104)then
		Layer_Two[Chip_x][Chip_y]=0;
		Chip_has_flippers = true;
		sound_play(sound_pickup_key);
	-- Fireboots
	elseif(sort==105)then
		Layer_Two[Chip_x][Chip_y]=0;
		Chip_has_fireboots = true;
		sound_play(sound_pickup_key);
	-- Scates
	elseif(sort==106)then
		Layer_Two[Chip_x][Chip_y]=0;
		Chip_has_scates = true;
		sound_play(sound_pickup_key);
	-- Suction cup boots
	elseif(sort==107)then
		Layer_Two[Chip_x][Chip_y]=0;
		Chip_has_suction = true;
		sound_play(sound_pickup_key);
	end
end