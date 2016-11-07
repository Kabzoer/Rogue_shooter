Level = {}

c_fill = 1

c_wall = 128
c_floor = 129
c_floor2 = 130
c_rubbish = 131

c_box = 144

c_wire = 160
c_wire2 = 176
c_pipe = 192

function Level:load()
	map = Map:new(c_wall) 
	map_c = Map:new({120,120,140}) 

	solid = Map:new(true)
	blockFOV = Map:new(false)
end

function Level:generate()
	mapc = love.image.newImageData( "map2.png")
	--mapGen
	for x=0,mapc:getWidth()-1 do
		for y=0,mapc:getHeight()-1 do
			local r = mapc:getPixel(x,y)
			local p = Pos:new(x,y)
			if(r < 5) then
				self:put(p,"floor")
			elseif(r == 160) then
				local door = factory.door(p)

				door.pos = p
				table.insert(entities,door)
			else
				self:put(p,"wall")
			end
		end
	end

	Level:decorate()
end

function Level:decorate()
	local numGenerated = 0
	while (numGenerated < 25) do
		local p = Pos:random()
		local d = Dir:random()
		if(p:get(map)==0) then
			numGenerated = numGenerated + 1 
			local ch = c_wire
			local rnd = math.random(0,2)
			if(rnd == 0) then
				ch = c_wire2
			elseif(rnd == 1) then
				ch = c_pipe
			end
			local col = {math.random(20,50),math.random(20,50),math.random(20,50)}
			if(ch == c_pipe) then
				col = {math.random(30,60),math.random(20,40),math.random(0,20)}
			end


			self:makeWire(p,d,ch,col)
			self:makeWire(p,d+2,ch,col)
			if(math.random()<0.5) then
				self:makeWire(p,d+1,ch,col)
				if(math.random()<0.5) then
					self:makeWire(p,d+3,ch,col)
				end
				p:set(map,ch+6)
				p:set(map_c,{col[1]+20,col[2]+20,col[3]+20})
			end
		end
	end

 	for x=0,mapc:getWidth()-1 do
		for y=0,mapc:getHeight()-1 do
			local p = Pos:new(x,y)
			if(p:get(map) == 0) then
				local r = math.random()
				if(r<0.2) then
					p:set(map,c_floor)
				elseif(r<0.5) then
					p:set(map,c_floor2)
				end
			end
		end
	end
 end 

function Level:makeWire(p,d,ch,col)	
	local newd = d
	for j =1,100 do --100 tries max
		
		newd = d

		if(math.random()<0.6 and j>2) then
			if(math.random()<0.5) then
				newd = d+1
			else
				newd = d-1
			end
		end

		if((p+newd):get(map) == 0 or j==100) then
			if(j%7 == 6 and math.random()<0.5) then
				p:set(map,ch+6)
				p:set(map_c,{col[1]+20,col[2]+20,col[3]+20})
			else
				p:set(map,ch+getR(d,newd))
				p:set(map_c,col)

			end
			
			d = newd
			p = p+d

			local index = math.random(1,3)
			col = {col[1],col[2],col[3]}
			col[index] = col[index] + 3
			--col = {math.random(10,60),math.random(10,40),math.random(10,40)}

		elseif((p+newd):get(map) == c_wall) then
			p:set(map,ch+getR(d,newd))
			p:set(map_c,col)
			break
		end
	end
end

function getR(d1,d2)
	local r1 = (-d1).r
	local r2 = d2.r
	if(r1>r2) then
		local r = r1
		r1 = r2
		r2 = r
	end
	if(r1%2 == r2%2) then
		return r1%2
	else
		if(r1 == 1 and r2 == 2) then
			return 2
		elseif(r1 == 2 and r2 == 3) then
			return 3
		elseif(r1 == 3 and r2 == 4) then
			return 5
		else
			return 4
		end
	end
end

function Level:put(p,type)
	if(type == "wall") then
		p:set(map,c_wall)
		p:set(map_c,{120,120,140})
		p:set(solid,true)
		p:set(blockFOV,true)

	elseif(type == "floor") then
		p:set(map,0)
		p:set(map_c,{40,40,60})
		p:set(solid,false)
		p:set(blockFOV,false)

	elseif(type == "door closed") then
		p:set(map,toChar('+'))
		p:set(blockFOV,true)
	elseif(type == "door open") then
		p:set(map,toChar('+'))
		p:set(blockFOV,false)
	elseif(type == "blood") then
		local ch = p:get(map)
		if(ch == 0 or ch == c_floor or ch == c_floor2) then
			p:set(map, c_smoke + math.random(0,3))
			p:set(map_c,{100,0,20})
		end
	elseif(type == "rubbish") then
		local ch = p:get(map)
		if(ch == c_wall) then
			if(math.random()<0.7) then
				p:set(map, c_rubbish)
			else
				p:set(map, 0)
			end
		else
			if(math.random()<0.1) then
				p:set(map, c_rubbish)
			end
		end

		p:set(solid,false)
		p:set(blockFOV,false)
	end
end

function Level:addRandom(e)
	local p = Pos:random()

    while true do
    	p = Pos:random()
        if p:passable(false) then
            break
        end
    end

    self:addEntity(p,e)
end

function Level:addEntity(p,e)
	e.dead = false
	e.pos = p
	table.insert(entities,e)
end

function Level:destroy(p,r)
	for i = 1,2 do
		local field = AoE_circle(p,r,0.2)

		for x=1,Map.w-1 do
			for y=1,Map.h-1 do
				q = Pos:new(x,y)
				if(q:get(field)) then
					if(math.random()<0.7) then
						Level:put(q,"rubbish")
					end
				end
			end
		end
	end
end