P_NONE = 0
P_LOW = 20
P_NORMAL = 100
P_HIGH = 500
P_HIGHEST = 1000

Behaviour = {}

function Behaviour:new()
	local new = {}
	self.__index = self

	new.priority = P_LOW

	return new
end

function Behaviour:evaluate()

end

function Behaviour:execute()
	
end

Wander = {}
setmetatable( Wander, { __index = Behaviour } )

function Wander:new()
	local new = Behaviour:new()
	setmetatable(new, self)
	self.__index = self

	return new
end

function Wander:execute()
	if(math.random()<0.3) then
		if(math.random()<0.5) then
			self.ai.dir = self.ai.dir+1
		else
			self.ai.dir = self.ai.dir-1
		end
	end
	self.ai.owner:event("move",{dir = self.ai.dir})
end

Flee = {}
setmetatable( Flee, { __index = Behaviour } )

function Flee:new(team,base)
	local new = Behaviour:new()
	setmetatable(new, self)
	self.__index = self

	new.priority = 0
	new.baseP = base or P_NORMAL

	new.team = team
	return new
end

function Flee:evaluate()
	self.priority = self.baseP*self.ai.senses.teamScore[self.team]
end

function Flee:execute()
	self.ai:followDijkstra(teamF[self.team])
	self.ai.owner:event("move",{dir = self.ai.dir})
end


Attack = {}
setmetatable( Attack, { __index = Behaviour } )

function Attack:new(base)
	local new = Behaviour:new()
	setmetatable(new, self)
	self.__index = self

	new.priority = P_NONE
	new.baseP = base or P_HIGHEST

	return new
end

function Attack:evaluate()
	if(self.ai.senses.meleeEnemy) then
		self.priority = self.baseP
	else
		self.priority = P_NONE
	end
end

function Attack:execute()
	self.ai.owner:event("use",{name = "attack", target = self.ai.senses.meleeEnemy.pos})
end

Approach = {}
setmetatable( Approach, { __index = Behaviour } )

function Approach:new(team,base)
	local new = Behaviour:new()
	setmetatable(new, self)
	self.__index = self

	new.priority = 0
	new.baseP = base or P_NORMAL

	new.team = team
	return new
end

function Approach:evaluate()
	if(self.ai.senses.teamScore[self.team] > 0) then
		self.priority = self.baseP
	else
		self.priority = 0
	end
end

function Approach:execute()
	self.ai:followDijkstra(teamD[self.team])
	self.ai.owner:event("move",{dir = self.ai.dir})
end

