gui = {}

c_select = 2
c_ammoF = 3
c_ammo = 4

function gui:load()
	self.x = 42
	self.y = 1

	self.w = 18
	self.h = Map.sh

	self.dscw = 29
	self.dsch = Map.h-Map.sh

	self.plyStr = Cstring:new()
	self.invStr = Cstring:new()
	self.dscStr = Cstring:new()
end 

function gui:mousepressed(button)
	if(self.highlight>0) then
		if(button == 1) then
			player:event("select",{index = self.highlight})
		elseif(button == 2) then
			local item = player.inventory:getItem(self.highlight)
			player:event("drop",{item = item})
		end
	end
end


function gui:update()
	local y = math.floor(mouseY)
	if(mouseX>=Map.sw and 11<=y and y<= 30) then
		self.highlight = y-10
	else
		self.highlight = -1
	end

	self.plyStr = Cstring:new()
	self.invStr = Cstring:new()
	self.dscStr = Cstring:new()

	local c = player.hp:getDescription().color[1]
	local hp,maxHp = player.hp:getHp()

	self.plyStr = 
	player:getName() .. "\n" ..
	Cstring:new(hp .. "/" .. maxHp,c) .. "\n" .. "\n" .. "\n" .. "\n" .. "\n" .."\n"


	for i in ipairs(player.equipment.slots) do
		if(player.equipment.slots[i].item and player.equipment.slots[i].item.gun) then
			local gun = player.equipment.slots[i].item.gun
			self.plyStr = self.plyStr .. gun.bullet.name .. ": " .. player.inventory.ammo[gun.bullet] .. "\n"
			for j = 1 , gun.magSize do
				if(j<=gun.mag) then
					self.plyStr = self.plyStr .. string.char(c_ammoF)
				else
					self.plyStr = self.plyStr .. string.char(c_ammo)
				end
			end
			
		end
	end
	

	if(mouseP:get(FOV) > 0.5) then
		local list = mouseP:getEntities()
		local getInfo = list[#list]
		for i,v in pairs(list) do
			if(v.solid) then
				getInfo = v
			end
			if(v.item) then
				getInfo = v
				break
			end

		end
	
		self:info(getInfo)
	end

	if(self.highlight>0) then
		self:info(player.inventory.items[self.highlight][1])
	end

	self.invStr = Cstring:new("------------------",{100,100,100})

	for i=1,20 do
		local s =  Cstring:new()
		local item = player.inventory.items[i][1]

		if(i<11) then
			s = s .. Cstring:new("" .. i%10,{60,60,60})
		else
			s = s .. Cstring:new("-", {50,50,50})
		end

		if(item) then
			if(item.maxStack > 1) then
				local n = # player.inventory.items[i]
				s = s .. Cstring:new(n .. "x", {120,120,120})
			end
			
			s = s .. Cstring:new(item.name, item.color)
			if(item.gun) then
				s = s .. Cstring:new(" " .. item.gun.mag .. "/" .. player.inventory.ammo[item.gun.bullet])
			end
			if(item.laser) then
				s = s .. Cstring:new(" " .. player.inventory.ammo[item.laser.bullet])
			end
		end
		s = s .. "\n"
		self.invStr = self.invStr .. s
	end
end

function gui:info(e)
	if(e) then
		self.dscStr = e:getName() .. "\n" .. e:event("description",{s = Cstring:new()}).s
	end
end

function gui:draw()
	--draw highlight equipped and mouse-over

	for i=1,20 do
		local item = player.inventory.items[i][1]
		if(player.equipment:isEquipped(item)) then
			for j=1,self.w do
				batch:setColor(10,10,10)
				batch:add(quads[c_fill],(j-1+self.x)*Graphics.cw,(i+10-1+self.y)*Graphics.cw)
			end
		end
	end

	if(self.highlight>0) then
		for i=1,self.w do
			batch:setColor(30,30,30)
			batch:add(quads[c_fill],(i-1+self.x)*Graphics.cw,(self.highlight+10-1+self.y)*Graphics.cw)
		end
	end

	for x=0,Map.w do
		batch:setColor(150,150,150)
		batch:add(quads[16],x*8,31*8)
	end

	for y=0,self.h do
		batch:setColor(150,150,150)
		batch:add(quads[18],41*8,y*8)
	end

	for y=self.dsch+2,Map.h do
		batch:setColor(150,150,150)
		batch:add(quads[18],30*8,y*8)
	end


	self.plyStr:draw(self.x,self.y,self.w)
	self.invStr:draw(self.x,self.y+9,self.w)
	self.dscStr:draw(self.x-(self.dscw-self.w),self.y+31,self.dscw)
end
