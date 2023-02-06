local AlignGoal = require("mapscene/behavior/ai/AlignGoal");
local EntityGoal = require("mapscene/behavior/ai/EntityGoal");
local PositionGoal = require("mapscene/behavior/ai/PositionGoal");
local Behavior = require("mapscene/behavior/Behavior");
local Locomotion = require("mapscene/physics/Locomotion");
local PhysicsBody = require("mapscene/physics/PhysicsBody");
local MathUtils = require("utils/MathUtils");

local Navigation = Class("Navigation", Behavior);

local navigate = function(self, navigationMesh, goal, physicsBody, locomotion)
	if not goal:isValid() then
		return false;
	end

	local x, y = physicsBody:getPosition();
	local targetX, targetY = goal:getPosition();
	local _, path = navigationMesh:findPath(x, y, targetX, targetY);
	if not path then
		return false;
	end

	local vertexIndex = 1;
	while true do
		if goal:isValid() and goal:isPositionAcceptable(physicsBody:getPosition()) then
			return true;
		end

		local waypointX, waypointY = path:getVertex(vertexIndex);
		if not waypointX or not waypointY then
			break
		end
		local x, y = physicsBody:getPosition();
		local distToWaypoint2 = MathUtils.distance2(x, y, waypointX, waypointY);
		local epsilon = locomotion:getSpeed() * self:getDeltaTime();
		if distToWaypoint2 >= epsilon * epsilon then
			local deltaX, deltaY = waypointX - x, waypointY - y;
			local angle = math.atan2(deltaY, deltaX);
			locomotion:setMovementAngle(angle);
			self:waitFrame();
		else
			physicsBody:setPosition(waypointX, waypointY);
			vertexIndex = vertexIndex + 1;
		end
	end

	return false;
end

Navigation.init = function(self)
	Navigation.super.init(self);
	assert(self._script);
end

Navigation.navigateToPoint = function(self, x, y, targetRadius)
	assert(x);
	assert(y);
	assert(targetRadius and targetRadius >= 0);
	local repathDelay = 2;
	return self:navigateToGoal(PositionGoal:new(x, y, targetRadius), repathDelay);
end

Navigation.navigateToEntity = function(self, targetEntity, targetRadius)
	assert(targetEntity);
	assert(targetRadius >= 0);
	local repathDelay = 0.5;
	return self:navigateToGoal(EntityGoal:new(targetEntity, targetRadius), repathDelay);
end

Navigation.alignWithEntity = function(self, targetEntity, targetRadius)
	assert(targetEntity);
	assert(targetRadius >= 0);
	local repathDelay = 0.5;
	return self:navigateToGoal(AlignGoal:new(self:getEntity(), targetEntity, targetRadius), repathDelay);
end

Navigation.navigateToGoal = function(self, goal, repathDelay)
	assert(goal);

	local physicsBody = self:getEntity():getComponent(PhysicsBody);
	local locomotion = self:getEntity():getComponent(Locomotion);
	local navigationMesh = self:getEntity():getECS():getMap():getNavigationMesh();
	assert(physicsBody);
	assert(locomotion);
	assert(navigationMesh);

	self._script:stopAllThreads();
	return self._script:addThreadAndRun(function(self)

		self:scope(function()
			locomotion:setMovementAngle(nil);
		end);

		local completion = self:thread(function(self)
			local signal = self:waitForAny({ "success", "failure" });
			return signal == "success";
		end);

		self:thread(function(self)
			while true do
				self:wait(repathDelay);
				self:signal("repath");
			end
		end);

		self:thread(function(self)
			while true do
				self:thread(function(self)
					self:endOn("repath");
					if navigate(self, navigationMesh, goal, physicsBody, locomotion) then
						self:signal("success");
					else
						self:signal("failure");
					end
				end);
				self:waitFor("repath");
			end
		end);

		return self:join(completion);
	end);
end

return Navigation;
