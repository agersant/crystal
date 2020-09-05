require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local MovementAI = require("engine/mapscene/behavior/ai/MovementAI");
local NavigationFailureEvent = require("engine/mapscene/behavior/ai/NavigationFailureEvent");
local NavigationSuccessEvent = require("engine/mapscene/behavior/ai/NavigationSuccessEvent");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local Locomotion = require("engine/mapscene/physics/Locomotion");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local MathUtils = require("engine/utils/MathUtils");

local MovementAISystem = Class("MovementAISystem", System);

MovementAISystem.init = function(self, ecs, map)
	assert(map);
	MovementAISystem.super.init(self, ecs);
	self._map = map;
	self._query = AllComponents:new({Locomotion, PhysicsBody, MovementAI});
	self._withScriptRunner = AllComponents:new({MovementAI, ScriptRunner});
	self:getECS():addQuery(self._query);
	self:getECS():addQuery(self._withScriptRunner);
end

local followPath = function(self, locomotion, physicsBody, movementAI, epsilon)
	while true do
		local x, y = physicsBody:getPosition();
		local waypointX, waypointY = movementAI:getCurrentWaypoint();
		if not waypointX or not waypointY then
			locomotion:setMovementAngle(nil);
			movementAI:endNavigation();
			return;
		end
		local distToWaypoint2 = MathUtils.distance2(x, y, waypointX, waypointY);
		if distToWaypoint2 >= epsilon * epsilon then
			local deltaX, deltaY = waypointX - x, waypointY - y;
			local angle = math.atan2(deltaY, deltaX);
			locomotion:setMovementAngle(angle);
			return;
		end
		physicsBody:setPosition(waypointX, waypointY);
		movementAI:nextWaypoint();
	end
end

MovementAISystem.beforeScripts = function(self, dt)

	local entities = self._query:getEntities();
	for entity in pairs(entities) do
		local movementAI = entity:getComponent(MovementAI);
		local physicsBody = entity:getComponent(PhysicsBody);
		local locomotion = entity:getComponent(Locomotion);
		local epsilon = locomotion:getSpeed() * dt;

		local goal = movementAI:getGoal();
		if goal then
			if goal:isValid() then
				if movementAI:needsRepath() then
					local x, y = physicsBody:getPosition();
					local targetX, targetY = goal:getPosition();
					local _, newPath = self._map:findPath(x, y, targetX, targetY);
					movementAI:setPath(newPath);
				else
					movementAI:setPathAge(movementAI:getPathAge() + dt);
				end
			end

			if movementAI:getPath() then
				followPath(self, locomotion, physicsBody, movementAI, epsilon);
			end

			local x, y = physicsBody:getPosition();
			if goal:isValid() and goal:isPositionAcceptable(x, y) then
				locomotion:setMovementAngle(nil);
				movementAI:endNavigation();
				entity:createEvent(NavigationSuccessEvent, goal);
			elseif not movementAI:getGoal() or not movementAI:getPath() then
				locomotion:setMovementAngle(nil);
				movementAI:endNavigation();
				entity:createEvent(NavigationFailureEvent, goal);
			end
		end
	end
end

MovementAISystem.duringScripts = function(self, dt)
	-- Broadcast success events
	local successEvents = self:getECS():getEvents(NavigationSuccessEvent);
	for _, event in ipairs(successEvents) do
		local entity = event:getEntity();
		local scriptRunner = entity:getComponent(ScriptRunner);
		if scriptRunner then
			scriptRunner:signalAllScripts("navigationSuccess", event:getGoal());
		end
	end

	-- Broadcast failure events
	local failureEvents = self:getECS():getEvents(NavigationFailureEvent);
	for _, event in ipairs(failureEvents) do
		local entity = event:getEntity();
		local scriptRunner = entity:getComponent(ScriptRunner);
		if scriptRunner then
			scriptRunner:signalAllScripts("navigationFailure", event:getGoal());
		end
	end
end

return MovementAISystem;
