--Move the monsters::
function Chip_Move_Monsters()
	monsters_canmove_=monsters_canmove_-1;
	if(monsters_canmove_>0)then
		return false
	else
		monsters_canmove_=6;
	end
	
	--Do we need to fix the monster list?
	listfix=false;
	
	local i = 1;
	mmmtotal = monsters_total;
	while(i<=mmmtotal) do
		--Do something based on what it is:
		local sort,xx,yy = monsters_sort[i],monsters_x[i],monsters_y[i];
		local under = Layer_Two[monsters_x[i]][monsters_y[i]];
		local doit = true;
		
		--Bear Traps
		if(under==43)then
			local j=0;
			doit = false;
			while(j<bear_total) do
				j=j+1;
				if(bear_xx[j]==xx and bear_yy[j]==yy) then
					if(bear_open[j] == 1) then
						doit = true;
						break;
					end
				end
			end
		end
		--Clone Machines:
		if(under==49)then
			doit = false;
		end
		
		if(doit) then
			--Bug North
			if(sort == 64) then
				--Always try to move left,up,right,down
				if(not Chip_is_monster_solid(xx-1,yy) and not Chip_at_square(xx-1,yy,4)) then -- West
					monsters_sort[i] = 65 -- set WEST
					Chip_monster_move(i,xx,yy,-1,0)
				elseif(not Chip_is_monster_solid(xx,yy-1) and not Chip_at_square(xx,yy-1,4)) then -- North
					monsters_sort[i] = 64 -- set NORTH
					Chip_monster_move(i,xx,yy,0,-1)
				elseif(not Chip_is_monster_solid(xx+1,yy) and not Chip_at_square(xx+1,yy,4)) then -- EAST
					monsters_sort[i] = 67 -- set EAST
					Chip_monster_move(i,xx,yy,1,0)
				elseif(not Chip_is_monster_solid(xx,yy+1) and not Chip_at_square(xx,yy+1,4)) then -- South
					monsters_sort[i] = 66 -- set SOUTH
					Chip_monster_move(i,xx,yy,0,1)
				end
			end
			
			--Bug West
			if(sort == 65) then
				--Always try to move left,up,right,down
				if(not Chip_is_monster_solid(xx,yy+1) and not Chip_at_square(xx,yy+1,4)) then -- South
					monsters_sort[i] = 66 -- set SOUTH
					Chip_monster_move(i,xx,yy,0,1)
				elseif(not Chip_is_monster_solid(xx-1,yy) and not Chip_at_square(xx-1,yy,4)) then -- West
					monsters_sort[i] = 65 -- set WEST
					Chip_monster_move(i,xx,yy,-1,0)
				elseif(not Chip_is_monster_solid(xx,yy-1) and not Chip_at_square(xx,yy-1,4)) then -- North
					monsters_sort[i] = 64 -- set NORTH
					Chip_monster_move(i,xx,yy,0,-1)
				elseif(not Chip_is_monster_solid(xx+1,yy) and not Chip_at_square(xx+1,yy,4)) then -- EAST
					monsters_sort[i] = 67 -- set EAST
					Chip_monster_move(i,xx,yy,1,0)
				end
			end
			
			--Bug South
			if(sort == 66) then
				--Always try to move left,up,right,down
				if(not Chip_is_monster_solid(xx+1,yy) and not Chip_at_square(xx+1,yy,4)) then -- EAST
					monsters_sort[i] = 67 -- set EAST
					Chip_monster_move(i,xx,yy,1,0)
				elseif(not Chip_is_monster_solid(xx,yy+1) and not Chip_at_square(xx,yy+1,4)) then -- South
					monsters_sort[i] = 66 -- set SOUTH
					Chip_monster_move(i,xx,yy,0,1)
				elseif(not Chip_is_monster_solid(xx-1,yy) and not Chip_at_square(xx-1,yy,4)) then -- West
					monsters_sort[i] = 65 -- set WEST
					Chip_monster_move(i,xx,yy,-1,0)
				elseif(not Chip_is_monster_solid(xx,yy-1) and not Chip_at_square(xx,yy-1,4)) then -- North
					monsters_sort[i] = 64 -- set NORTH
					Chip_monster_move(i,xx,yy,0,-1)
				end
			end
			
			--Bug East
			if(sort == 67) then
				--Always try to move left,up,right,down
				if(not Chip_is_monster_solid(xx,yy-1) and not Chip_at_square(xx,yy-1,4)) then -- North
					monsters_sort[i] = 64 -- set NORTH
					Chip_monster_move(i,xx,yy,0,-1)
				elseif(not Chip_is_monster_solid(xx+1,yy) and not Chip_at_square(xx+1,yy,4)) then -- EAST
					monsters_sort[i] = 67 -- set EAST
					Chip_monster_move(i,xx,yy,1,0)
				elseif(not Chip_is_monster_solid(xx,yy+1) and not Chip_at_square(xx,yy+1,4)) then -- South
					monsters_sort[i] = 66 -- set SOUTH
					Chip_monster_move(i,xx,yy,0,1)
				elseif(not Chip_is_monster_solid(xx-1,yy) and not Chip_at_square(xx-1,yy,4)) then -- West
					monsters_sort[i] = 65 -- set WEST
					Chip_monster_move(i,xx,yy,-1,0)
				end
			end
			
			--Fireball North
			if(sort == 68) then
				--Always try to move forward, right, left, backward
				if(not Chip_is_monster_solid(xx,yy-1)) then -- North
					monsters_sort[i] = 68 -- set NORTH
					Chip_monster_move(i,xx,yy,0,-1)
				elseif(not Chip_is_monster_solid(xx+1,yy)) then -- EAST
					monsters_sort[i] = 71 -- set EAST
					Chip_monster_move(i,xx,yy,1,0)
				elseif(not Chip_is_monster_solid(xx-1,yy)) then -- West
					monsters_sort[i] = 69 -- set WEST
					Chip_monster_move(i,xx,yy,-1,0)
				elseif(not Chip_is_monster_solid(xx,yy+1)) then -- South
					monsters_sort[i] = 70 -- set SOUTH
					Chip_monster_move(i,xx,yy,0,1)
				end
			end
			
			--Fireball West
			if(sort == 69) then
				--Always try to move forward, right, left, backward
				if(not Chip_is_monster_solid(xx-1,yy)) then -- West
					monsters_sort[i] = 69 -- set WEST
					Chip_monster_move(i,xx,yy,-1,0)
				elseif(not Chip_is_monster_solid(xx,yy-1)) then -- North
					monsters_sort[i] = 68 -- set NORTH
					Chip_monster_move(i,xx,yy,0,-1)
				elseif(not Chip_is_monster_solid(xx,yy+1)) then -- South
					monsters_sort[i] = 70 -- set SOUTH
					Chip_monster_move(i,xx,yy,0,1)
				elseif(not Chip_is_monster_solid(xx+1,yy)) then -- EAST
					monsters_sort[i] = 71 -- set EAST
					Chip_monster_move(i,xx,yy,1,0)
				end
			end
			
			--Fireball South
			if(sort == 70) then
				--Always try to move forward, right, left, backward
				if(not Chip_is_monster_solid(xx,yy+1)) then -- South
					monsters_sort[i] = 70 -- set SOUTH
					Chip_monster_move(i,xx,yy,0,1)
				elseif(not Chip_is_monster_solid(xx-1,yy)) then -- West
					monsters_sort[i] = 69 -- set WEST
					Chip_monster_move(i,xx,yy,-1,0)
				elseif(not Chip_is_monster_solid(xx+1,yy)) then -- EAST
					monsters_sort[i] = 71 -- set EAST
					Chip_monster_move(i,xx,yy,1,0)
				elseif(not Chip_is_monster_solid(xx,yy-1)) then -- North
					monsters_sort[i] = 68 -- set NORTH
					Chip_monster_move(i,xx,yy,0,-1)
				end
			end
			
			--Fireball East
			if(sort == 71) then
				--Always try to move forward, right, left, backward
				if(not Chip_is_monster_solid(xx+1,yy)) then -- EAST
					monsters_sort[i] = 71 -- set EAST
					Chip_monster_move(i,xx,yy,1,0)
				elseif(not Chip_is_monster_solid(xx,yy+1)) then -- South
					monsters_sort[i] = 70 -- set SOUTH
					Chip_monster_move(i,xx,yy,0,1)
				elseif(not Chip_is_monster_solid(xx,yy-1)) then -- North
					monsters_sort[i] = 68 -- set NORTH
					Chip_monster_move(i,xx,yy,0,-1)
				elseif(not Chip_is_monster_solid(xx-1,yy)) then -- West
					monsters_sort[i] = 69 -- set WEST
					Chip_monster_move(i,xx,yy,-1,0)
				end
			end
			
			--Ball North
			if(sort == 72) then
				if(Chip_is_monster_solid(xx,yy-1)) then
					if(not Chip_is_monster_solid(xx,yy+1)) then
						-- Change directions, move south:
						monsters_sort[i] = 74 -- SOUTH
						Chip_monster_move(i,xx,yy,0,1)
					end
				else
					--Move right
					Chip_monster_move(i,xx,yy,0,-1)
				end
			end
			
			--Ball West
			if(sort == 73) then
				if(Chip_is_monster_solid(xx-1,yy)) then
					if(not Chip_is_monster_solid(xx+1,yy)) then
						-- Change directions, move left:
						monsters_sort[i] = 75 -- EAST
						Chip_monster_move(i,xx,yy,1,0)
					end
				else
					--Move right
					Chip_monster_move(i,xx,yy,-1,0)
				end
			end
			
			--Ball South
			if(sort == 74) then
				if(Chip_is_monster_solid(xx,yy+1)) then
					if(not Chip_is_monster_solid(xx,yy-1)) then
						-- Change directions, move north:
						monsters_sort[i] = 72 -- NORTH
						Chip_monster_move(i,xx,yy,0,-1)
					end
				else
					--Move right
					Chip_monster_move(i,xx,yy,0,1)
				end
			end
			
			--Ball East
			if(sort == 75) then
				if(Chip_is_monster_solid(xx+1,yy)) then
					if(not Chip_is_monster_solid(xx-1,yy)) then
						-- Change directions, move left:
						monsters_sort[i] = 73 -- WEST
						Chip_monster_move(i,xx,yy,-1,0)
					end
				else
					--Move right
					Chip_monster_move(i,xx,yy,1,0)
				end
			end
			
			--Tank North
			if(sort == 76) then
				if(monsters_canmove[i] == 1) then
					if(Chip_is_monster_solid(xx,yy-1)) then
						monsters_canmove[i] = 0;
					else
						Chip_monster_move(i,xx,yy,0,-1)
					end
				end
			end
			
			--Tank West
			if(sort == 77) then
				if(monsters_canmove[i] == 1) then
					if(Chip_is_monster_solid(xx-1,yy)) then
						monsters_canmove[i] = 0;
					else
						Chip_monster_move(i,xx,yy,-1,0)
					end
				end
			end
			
			--Tank South
			if(sort == 78) then
				if(monsters_canmove[i] == 1) then
					if(Chip_is_monster_solid(xx,yy+1)) then
						monsters_canmove[i] = 0;
					else
						Chip_monster_move(i,xx,yy,0,1)
					end
				end
			end
			
			--Tank East
			if(sort == 79) then
				if(monsters_canmove[i] == 1) then
					if(Chip_is_monster_solid(xx+1,yy)) then
						monsters_canmove[i] = 0;
					else
						Chip_monster_move(i,xx,yy,1,0)
					end
				end
			end
			
			--Glider North
			if(sort == 80) then
				--Always try to move forward, left, right, backward
				if(not Chip_is_monster_solid(xx,yy-1)) then -- North
					monsters_sort[i] = 80 -- set NORTH
					Chip_monster_move(i,xx,yy,0,-1)
				elseif(not Chip_is_monster_solid(xx-1,yy)) then -- West
					monsters_sort[i] = 81 -- set WEST
					Chip_monster_move(i,xx,yy,-1,0)
				elseif(not Chip_is_monster_solid(xx+1,yy)) then -- EAST
					monsters_sort[i] = 83 -- set EAST
					Chip_monster_move(i,xx,yy,1,0)
				elseif(not Chip_is_monster_solid(xx,yy+1)) then -- South
					monsters_sort[i] = 82 -- set SOUTH
					Chip_monster_move(i,xx,yy,0,1)
				end
			end
			
			--Glider West
			if(sort == 81) then
				--Always try to move forward, left, right, backward
				if(not Chip_is_monster_solid(xx-1,yy)) then -- West
					monsters_sort[i] = 81 -- set WEST
					Chip_monster_move(i,xx,yy,-1,0)
				elseif(not Chip_is_monster_solid(xx,yy+1)) then -- South
					monsters_sort[i] = 82 -- set SOUTH
					Chip_monster_move(i,xx,yy,0,1)
				elseif(not Chip_is_monster_solid(xx,yy-1)) then -- North
					monsters_sort[i] = 80 -- set NORTH
					Chip_monster_move(i,xx,yy,0,-1)
				elseif(not Chip_is_monster_solid(xx+1,yy)) then -- EAST
					monsters_sort[i] = 83 -- set EAST
					Chip_monster_move(i,xx,yy,1,0)
				end
			end
			
			--Glider South
			if(sort == 82) then
				--Always try to move forward, left, right, backward
				if(not Chip_is_monster_solid(xx,yy+1)) then -- South
					monsters_sort[i] = 82 -- set SOUTH
					Chip_monster_move(i,xx,yy,0,1)
				elseif(not Chip_is_monster_solid(xx+1,yy)) then -- EAST
					monsters_sort[i] = 83 -- set EAST
					Chip_monster_move(i,xx,yy,1,0)
				elseif(not Chip_is_monster_solid(xx-1,yy)) then -- West
					monsters_sort[i] = 81 -- set WEST
					Chip_monster_move(i,xx,yy,-1,0)
				elseif(not Chip_is_monster_solid(xx,yy-1)) then -- North
					monsters_sort[i] = 80 -- set NORTH
					Chip_monster_move(i,xx,yy,0,-1)
				end
			end
			
			--Glider East
			if(sort == 83) then
				--Always try to move forward, left, right, backward
				if(not Chip_is_monster_solid(xx+1,yy)) then -- EAST
					monsters_sort[i] = 83 -- set EAST
					Chip_monster_move(i,xx,yy,1,0)
				elseif(not Chip_is_monster_solid(xx,yy-1)) then -- North
					monsters_sort[i] = 80 -- set NORTH
					Chip_monster_move(i,xx,yy,0,-1)
				elseif(not Chip_is_monster_solid(xx,yy+1)) then -- South
					monsters_sort[i] = 82 -- set SOUTH
					Chip_monster_move(i,xx,yy,0,1)
				elseif(not Chip_is_monster_solid(xx-1,yy)) then -- West
					monsters_sort[i] = 81 -- set WEST
					Chip_monster_move(i,xx,yy,-1,0)
				end
			end
			
			--Teeth
			if(sort == 84 or sort == 85 or sort == 86 or sort == 87) then
				--Can we move?
				if(monsters_canmove[i]==1) then
					--Stop it from moving again:
					monsters_canmove[i]=0;
					
					--How far do we have to move?
					local dx,dy,ddx,ddy = Chip_x-xx,Chip_y-yy,0,0;
					if(dx~=0)then ddx=dx/math.abs(dx);end
					if(dy~=0)then ddy=dy/math.abs(dy);end
					
					--Collision Detection:
					local a,b,mode = Chip_is_monster_solid(xx+ddx,yy),Chip_is_monster_solid(xx,yy+ddy),1;
					
					--Decide what to do:
					if(math.abs(dx)>math.abs(dy))then
						if(not a)then mode=2;elseif(b) then
							mode=0;
						end
					else
						if(b)then
							if(not a)then
								mode=2;
							else
								mode=0;
							end
						end
					end
					
					if(mode==1)then
						if(dy<0)then
							monsters_sort[i]=84;
						else
							monsters_sort[i]=86;
						end
						Chip_monster_move(i,xx,yy,0,dy/(math.abs(dy)));
					elseif(mode==2) then
						if(dx<0)then
							monsters_sort[i]=85;
						else
							monsters_sort[i]=87;
						end
						Chip_monster_move(i,xx,yy,dx/(math.abs(dx)),0);
					else
						if(math.abs(dy)>math.abs(dx))then
							if(dy<0)then monsters_sort[i]=84;
							else monsters_sort[i]=86;end
						else
							if(dx<0)then monsters_sort[i]=85;
							else monsters_sort[i]=87;end
						end
						Layer_One[xx][yy] = monsters_sort[i];
					end
				else
					monsters_canmove[i]=1;
				end
			end
			
			--Blob
			if(sort == 92 or sort == 93 or sort == 94 or sort == 95) then
				if(monsters_canmove[i]==1)then
					--Stop the blob moving again:
					monsters_canmove[i] = 0;
					
					--Move the blob:
					local dir, j = math.random(1,4), 0;
					while j<4 do
						if(dir==1)then
							if(not Chip_is_monster_solid(xx,yy-1)) then -- North
								Chip_monster_move(i,xx,yy,0,-1)
								j=4
							end
						elseif(dir==2)then
							if(not Chip_is_monster_solid(xx,yy+1)) then -- South
								Chip_monster_move(i,xx,yy,0,1)
								j=4
							end
						elseif(dir==3)then
							if(not Chip_is_monster_solid(xx+1,yy)) then -- East
								Chip_monster_move(i,xx,yy,1,0)
								j=4
							end
						elseif(dir==4)then
							if(not Chip_is_monster_solid(xx-1,yy)) then -- West
								Chip_monster_move(i,xx,yy,-1,0)
								j=4
							end
						end
						dir=dir+1;
						if(dir>4)then dir=1 end
						j=j+1;
					end
				else
					monsters_canmove[i] = 1;
				end
			end
			--Paramecium North
			if(sort == 96) then
				--Always try to move right, forward, left, backward
				if(not Chip_is_monster_solid(xx+1,yy)) then -- EAST
					monsters_sort[i] = 99 -- set EAST
					Chip_monster_move(i,xx,yy,1,0)
				elseif(not Chip_is_monster_solid(xx,yy-1)) then -- North
					monsters_sort[i] = 96 -- set NORTH
					Chip_monster_move(i,xx,yy,0,-1)
				elseif(not Chip_is_monster_solid(xx-1,yy)) then -- West
					monsters_sort[i] = 97 -- set WEST
					Chip_monster_move(i,xx,yy,-1,0)
				elseif(not Chip_is_monster_solid(xx,yy+1)) then -- South
					monsters_sort[i] = 98 -- set SOUTH
					Chip_monster_move(i,xx,yy,0,1)
				end
			end
			
			--Paramecium West
			if(sort == 97) then
				--Always try to move right, forward, left, backward
				if(not Chip_is_monster_solid(xx,yy-1)) then -- North
					monsters_sort[i] = 96 -- set NORTH
					Chip_monster_move(i,xx,yy,0,-1)
				elseif(not Chip_is_monster_solid(xx-1,yy)) then -- West
					monsters_sort[i] = 97 -- set WEST
					Chip_monster_move(i,xx,yy,-1,0)
				elseif(not Chip_is_monster_solid(xx,yy+1)) then -- South
					monsters_sort[i] = 98 -- set SOUTH
					Chip_monster_move(i,xx,yy,0,1)
				elseif(not Chip_is_monster_solid(xx+1,yy)) then -- EAST
					monsters_sort[i] = 99 -- set EAST
					Chip_monster_move(i,xx,yy,1,0)
				end
			end
			
			--Paramecium South
			if(sort == 98) then
				--Always try to move right, forward, left, backward
				if(not Chip_is_monster_solid(xx-1,yy)) then -- West
					monsters_sort[i] = 97 -- set WEST
					Chip_monster_move(i,xx,yy,-1,0)
				elseif(not Chip_is_monster_solid(xx,yy+1)) then -- South
					monsters_sort[i] = 98 -- set SOUTH
					Chip_monster_move(i,xx,yy,0,1)
				elseif(not Chip_is_monster_solid(xx+1,yy)) then -- EAST
					monsters_sort[i] = 99 -- set EAST
					Chip_monster_move(i,xx,yy,1,0)
				elseif(not Chip_is_monster_solid(xx,yy-1)) then -- North
					monsters_sort[i] = 96 -- set NORTH
					Chip_monster_move(i,xx,yy,0,-1)
				end
			end
			
			--Paramecium East
			if(sort == 99) then
				--Always try to move right, forward, left, backward
				if(not Chip_is_monster_solid(xx,yy+1)) then -- South
					monsters_sort[i] = 98 -- set SOUTH
					Chip_monster_move(i,xx,yy,0,1)
				elseif(not Chip_is_monster_solid(xx+1,yy)) then -- EAST
					monsters_sort[i] = 99 -- set EAST
					Chip_monster_move(i,xx,yy,1,0)
				elseif(not Chip_is_monster_solid(xx,yy-1)) then -- North
					monsters_sort[i] = 96 -- set NORTH
					Chip_monster_move(i,xx,yy,0,-1)
				elseif(not Chip_is_monster_solid(xx-1,yy)) then -- West
					monsters_sort[i] = 97 -- set WEST
					Chip_monster_move(i,xx,yy,-1,0)
				end
			end
		end
		
		--Hazard Test:
		Chip_monster_hazard(i,monsters_x[i],monsters_y[i]);
		
		--Buttons Test:
		BrownButton(xx,yy,0);
		Chip_monster_button(xx,yy,monsters_x[i] or 0,monsters_y[i] or 0);
		
		--Move onto the next monster:
		i = i+1;
	end
	
	if(listfix) then
		Chips_Monsterlist_patch()
	end
end

--Check for buttons:
function Chip_monster_button(xx,yy,x,y)
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
		--Blue Button:
		if(sort == 40)then
			--Play the button noise:
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
		--Brown Button:
		BrownButton(x,y,1);
		
		--Red Button:
		if(sort == 36)then
			CheckClones(x,y);
		end
	end
end

--Check if something is a monster:
function Chip_is_monster(a)
	if(a>=64 and a<=99) then
		return true
	else
		return false
	end
end

--Check if something is solid:
function Chip_is_monster_solid(xx,yy)
	if(xx>31 or xx<0 or yy>31 or yy<0) then return true end
	
	--Grab both tiles:
	local c = Layer_One[xx][yy] or 0;
	if(c>=108 and c<=111)then
		c = Layer_Two[xx][yy] or 0;
	end
	
	--Lets see if they are solid:
	if(c == 0) then return false end
	
	if(c == 1)then return true end
	if(c == 2)then return true end
	if(c == 5)then return true end
	
	--Blocked north, south etc here
	
	if(c == 10)then return true end
	if(c == 11)then return true end
	if(c == 10)then return true end
	
	if(c >= 14 and c<=17)then return true end
	if(c >= 22 and c<=25)then return true end
	
	if(c == 30)then return true end
	if(c == 31)then return true end
	
	if(c == 33)then return true end
	if(c == 34)then return true end
	if(c == 37)then return true end
	
	if(c == 44)then return true end
	if(c == 45)then return true end
	if(c == 46)then return true end
	
	if(c == 49)then return true end
	if(c == 50)then return true end
	
	if(c >= 64 and c<=99)then return true end
	
	if(c >= 104 and c<=107)then return true end
	
	return false
end

--Check if a monster should die:
function Chip_monster_hazard(i,xx,yy)
	local sort = monsters_sort[i] or 0
	local hazard = Layer_Two[xx][yy] or 0
	if(hazard == 0) then return end
	
	 -- BOMB
	if(hazard == 42)then
		--Bombs kill all:
		return Chips_mdie(i,xx,yy,true)
	end
	
	--Water
	if(hazard == 3)then
		--Kill everything but rockets:
		if(sort<80 or sort>83)then
			return Chips_mdie(i,xx,yy,false)
		end
	end
	
	--Fire
	if(hazard == 4)then
		--Kill everything but fireballs
		if(sort<68 or sort>71)then
			return Chips_mdie(i,xx,yy,false)
		end
	end
	
	--Chip:
	if(hazard>=108 and hazard<=111)then
		Chip_dodeath("Ooops! Look out for creatures!",-1)
	end
end

--Kill a monster:
function Chips_mdie(i,xx,yy, remove)
	monsters_sort[i]=-1
	listfix=true;
	if(remove)then
		Layer_One[xx][yy]=0;
		Layer_Two[xx][yy]=0;
	else
		Layer_One[xx][yy]=Layer_Two[xx][yy];
		Layer_Two[xx][yy]=0;
	end
end

--Fix the monster list:
function Chips_Monsterlist_patch()
	local i,lower,mx,my,ms,mcm,mt=1,0,monsters_x,monsters_y,monsters_sort,monsters_canmove,monsters_total
	monsters_x = {};
	monsters_y = {};
	monsters_sort = {};
	monsters_canmove = {};
	monsters_total = 0;
	
	--rebuild the monster list:
	while(i<=mt) do
		if(monsters_sort[i]~=-1)then
			monsters_total=monsters_total+1;
			monsters_x[monsters_total] = mx[i]
			monsters_y[monsters_total] = my[i]
			monsters_sort[monsters_total] = ms[i]
			monsters_canmove[monsters_total] = mcm[i]
		end
		
		--Move up:
		i=i+1;
	end
	
	--Decrease the total number of monsters:
	monsters_total=monsters_total-lower
end

--Move a monster:
function Chip_monster_move(i,xx,yy,xadd,yadd)
	local sort = monsters_sort[i]
	
	--Modify new layer:
	Layer_Two[xx+xadd][yy+yadd] = Layer_One[xx+xadd][yy+yadd];
	Layer_One[xx+xadd][yy+yadd] = sort;
	
	--Modify layer moving away from:
	Layer_One[xx][yy] = Layer_Two[xx][yy];
	Layer_Two[xx][yy] = 0;
	
	--Modify monster array:
	monsters_x[i] = monsters_x[i]+xadd
	monsters_y[i] = monsters_y[i]+yadd
end
