require("engine/utils/OOP");
local Component = require("engine/ecs/Component");
local AlignGoal = require("engine/mapscene/behavior/ai/movement/AlignGoal");
local EntityGoal = require("engine/mapscene/behavior/ai/movement/EntityGoal");
local PositionGoal = require("engine/mapscene/behavior/ai/movement/PositionGoal");
local Script = require("engine/script/Script");

local MovementAI = Class("MovementAI", Component);

MovementAI.init = function(self)
	MovementAI.super.init(self);
	self._script = Script:new();
end

MovementAI.setNavigationGoal = function(self, goal)
	assert(goal);
	self._goal = goal;
	self._path = nil;
	self._waypointIndex = nil;
	self._pathAge = nil;
end

MovementAI.endNavigation = function(self)
	self._path = nil;
	self._waypointIndex = nil;
	self._goal = nil;
	self._pathAge = nil;
end

MovementAI.beginNavigationToPoint = function(self, x, y, targetRadius)
	assert(x);
	assert(y);
	assert(targetRadius >= 0);
	self._repathDelay = 2;
	self:setNavigationGoal(PositionGoal:new(x, y, targetRadius));
end

MovementAI.beginNavigationToEntity = function(self, targetEntity, targetRadius)
	assert(targetEntity);
	assert(targetRadius >= 0);
	self._repathDelay = 0.5;
	self:setNavigationGoal(EntityGoal:new(targetEntity, targetRadius));
end

MovementAI.beginAlignmentToEntity = function(self, targetEntity, targetRadius)
	assert(targetEntity);
	assert(targetRadius >= 0);
	self._repathDelay = 0.5;
	self:setNavigationGoal(AlignGoal:new(self:getEntity(), targetEntity, targetRadius));
end

MovementAI.navigateToPoint = function(self, x, y, targetRadius)
	self:beginNavigationToPoint(x, y, targetRadius);
	return self:navigateToGoal();
end

MovementAI.navigateToEntity = function(self, targetEntity, targetRadius)
	self:beginNavigationToEntity(targetEntity, targetRadius);
	return self:navigateToGoal();
end

MovementAI.alignWithEntity = function(self, targetEntity, targetRadius)
	self:beginAlignmentToEntity(targetEntity, targetRadius);
	return self:navigateToGoal();
end

MovementAI.navigateToGoal = function(self)
	assert(self._goal);
	if self._navigationThread and not self._navigationThread:isDead() then
		self._navigationThread:stop();
	end
	local myGoal = self._goal;
	self._navigationThread = self._script:addThreadAndRun(function(self)
		local result, resultGoal = self:waitForAny({"navigationSuccess", "navigationFailure"});
		assert(resultGoal);
		return resultGoal == myGoal and result == "navigationSuccess";
	end);
	return self._navigationThread;
end

MovementAI.needsRepath = function(self)
	assert(self._goal);
	assert(self._repathDelay);
	if not self._pathAge then
		return true;
	end
	return self._pathAge > self._repathDelay;
end

MovementAI.setPath = function(self, path)
	self._path = path;
	self._waypointIndex = 1;
	self._pathAge = 0;
end

MovementAI.setPathAge = function(self, age)
	self._pathAge = age;
end

MovementAI.getPathAge = function(self)
	return self._pathAge;
end

MovementAI.getGoal = function(self)
	return self._goal;
end

MovementAI.getCurrentWaypoint = function(self)
	return self._path:getVertex(self._waypointIndex);
end

MovementAI.nextWaypoint = function(self)
	self._waypointIndex = self._waypointIndex + 1;
end

MovementAI.getScript = function(self)
	return self._script;
end

return MovementAI;
