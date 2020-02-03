require("src/utils/OOP");
local AlignGoal = require("src/ai/movement/AlignGoal");
local EntityGoal = require("src/ai/movement/EntityGoal");
local PositionGoal = require("src/ai/movement/PositionGoal");
local Actions = require("src/scene/Actions");

local Movement = Class("Movement");

-- IMPLEMENTATION

local stepTowards = function(self, targetX, targetY)
	local entity = self:getEntity();
	if self:isIdle() then
		local distToTarget2 = entity:distance2To(targetX, targetY);
		local epsilon = entity:getMovementSpeed() * self._dt / 2;
		if distToTarget2 >= epsilon * epsilon then
			local x, y = entity:getPosition();
			local deltaX, deltaY = targetX - x, targetY - y;
			local angle = math.atan2(deltaY, deltaX);
			self:doAction(Actions.walk(angle));
			return false;
		else
			entity:setPosition(targetX, targetY);
			self:doAction(Actions.idle);
			return true;
		end
	end
end

local followPath = function(self, path)
	for i, waypointX, waypointY in path:vertices() do
		while true do
			local reachedWaypoint = stepTowards(self, waypointX, waypointY);
			if reachedWaypoint then
				break
			else
				self:waitFrame();
			end
		end
	end
end

local walkToGoal = function(goal, repathDelay)
	return function(self)
		local pathingThread;
		local entity = self:getEntity();

		-- Follow path
		self:thread(function(self)
			while true do
				self:endOn("endWalkToGoal");
				self:endOn("closeEnough");
				self:waitFor("repath");
				pathingThread = self:thread(function(self)
					self:endOn("repath");
					if not goal:isValid() then
						self:signal("pathEnd");
					end
					local targetX, targetY = goal:getPosition();
					local path = entity:findPathTo(targetX, targetY);
					followPath(self, path);
					self:signal("pathEnd");
				end);
			end
		end);

		-- Stop when close enough to objective
		self:thread(function(self)
			self:endOn("endWalkToGoal");
			while true do
				local x, y = entity:getPosition();
				if goal:isValid() and goal:isPositionAcceptable(x, y) then
					self:signal("closeEnough");
				end
				self:waitFrame();
			end
		end);

		-- Trigger repath
		self:thread(function(self)
			self:endOn("endWalkToGoal");
			while true do
				self:signal("repath");
				self:wait(repathDelay);
			end
		end);

		if pathingThread and not pathingThread:isDead() then
			self:waitForAny({"pathEnd", "closeEnough"});
		else
			-- Path completed immediately
		end
		self:signal("endWalkToGoal");

		if self:isIdle() then
			self:doAction(Actions.idle);
		end

		local x, y = entity:getPosition();
		return goal:isValid() and goal:isPositionAcceptable(x, y);
	end
end

-- PUBLIC API

Movement.walkToEntity = function(targetEntity, targetRadius)
	assert(targetRadius >= 0);
	local goal = EntityGoal:new(targetEntity, targetRadius);
	local repathDelay = .5;
	return walkToGoal(goal, repathDelay);
end

Movement.walkToPoint = function(targetX, targetY, targetRadius)
	assert(targetRadius >= 0);
	local goal = PositionGoal:new(targetX, targetY, targetRadius);
	local repathDelay = 2;
	return walkToGoal(goal, repathDelay);
end

Movement.alignWithEntity = function(movingEntity, targetEntity, targetRadius)
	assert(targetRadius >= 0);
	local goal = AlignGoal:new(movingEntity, targetEntity, targetRadius);
	local repathDelay = 1;
	return walkToGoal(goal, repathDelay);
end

return Movement;
