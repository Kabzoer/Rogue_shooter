Move = {}

function Move:new(speed)
	local new = Component:new("move")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.speed = speed or 3

	return new
end

function Move:event(e)
	if(e.id == "move") then
		local dir = e.dir
		local np = self.owner.pos + dir

		if np:passable(true) then
			self.owner.pos = np
			self.owner:event( "wait", {time = 100/self.speed} )
			
			--self.dijkstra:calculate(self.owner.pos)
			--self.flee:calculateFlee(self.dijkstra,20)

			
		end
	end

	return e
end