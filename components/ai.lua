--[[
AI: 
make different AI 'modes'. Every enemy AI is defined as a state machine 
different AI's are simply defined by reacting to triggers and changing the state
-maybe add a priority to each state, to choose when conflicts happen (no flip-flopping)
-add single triggered responses e.g. use special ability when health low

also make some variables to define senses
erratic = chance of random movement even when attacking
alertness = time since seeing enemy

modes: 
	sleeping
	search food
	run away/frightened
	patrol
	guard room
	fight melee
	fight ranged
	track player (smell)
	explore
	stalk player from distance
	...

Flee: 
	- take cover: move to nearest position out of player fov
	- flee: movebackwards from smell path (getting cornered? -> highly connective map so no problem probably)
	   -> maybe keep a universal dead-end map


difficulties:
	how to handle inventory/pickups by monsters?.

Mix of the two:
 high level state machine (idle, sleeping, hunting, running)
 low level utility selector

Utility:
	http://gdcvault.com/play/1012410/Improving-AI-Decision-Modeling-Through
]]

require 'aiSenses'
require 'aiBehaviour'

Ai = {}

function Ai:new(b)
	local new = Component:new("ai")
	setmetatable(new, self)
	self.__index = self
	setmetatable(self, Component)

	new.behaviours = b
	for k,v in pairs(new.behaviours) do
		v.ai = new
	end
	
	new.dir = Dir:random()

	new.senses = Senses:new(new)

	new.dijkstra = nil
	new.memory = 500
	new.mTimer = new.memory

	return new
end

function Ai:event(e)
	if(e.id == "turn" ) then
		--calculate sensory information
		self.senses:turn()


		--calculate priority for all behaviours
		for k,v in pairs(self.behaviours) do
			v:evaluate()
		end
		--sort behaviours from highest to lowest priority
		local function f(b1,b2)
			return b1.priority > b2.priority
		end
		table.sort(self.behaviours, f)

		--execute highest priority first, until an action is made
		for k,v in ipairs(self.behaviours) do
			if(self.owner.counter.time <= 0) then
				if(v.priority > 0) then
					v:execute()
				end
			else
				break
			end
		end

		--[[
		if(self.prevD~=self.dijkstra and self.dijkstra == teamD["player"]) then
			particles:spawn(self.owner.pos,"string",{s = "!",c = {150,150,0}})
		end
		]]

		--if doing nothing or action failed: wait
		if(self.owner.counter.time <= 0) then
			self.owner:event("wait", {time = 10})
		end
	elseif(e.id == "update") then
		self.mTimer = self.mTimer + 1
		if(self.mTimer == self.memory) then
			self.dijkstra = nil
		end
	end
	return e
end


function Ai:followDijkstra(Dmap)
	if(Dmap) then
		local p = self.owner.pos
		--make a list of all lowest directions on dijkstra neighborhood
		local s = p:get(Dmap)-1
		local list = {}
		for i,v in pairs(Dir:getAll()) do
			if((p+v):passable()) then
				local val = (p+v):get(Dmap)

				if(val < s) then
					s = val
					list = {v}
				elseif(val == s) then
					table.insert(list,v)
				end
			end
		end
		--select a random direction from this list
		if(#list>0 and #list<4) then
			self.dir = list[math.random(#list)]
		end
	end
end