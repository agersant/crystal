local AlignGoal = require("mapscene/behavior/ai/AlignGoal");
local EntityGoal = require("mapscene/behavior/ai/EntityGoal");
local PositionGoal = require("mapscene/behavior/ai/PositionGoal");
local MathUtils = require("utils/MathUtils");

local Navigation = Class("Navigation", crystal.Behavior);

local navigate = function(self, navigationMesh, goal, body, movement)
	if not goal:is_valid() then
		return false;
	end

	local x, y = body:position();
	local targetX, targetY = goal:position();
	local _, path = navigationMesh:findPath(x, y, targetX, targetY);
	if not path then
		return false;
	end

	local vertexIndex = 1;
	while true do
		if goal:is_valid() and goal:isPositionAcceptable(body:position()) then
			return true;
		end

		local waypointX, waypointY = path:getVertex(vertexIndex);
		if not waypointX or not waypointY then
			break
		end
		local x, y = body:position();
		local distToWaypoint2 = MathUtils.distance2(x, y, waypointX, waypointY);
		local epsilon = movement:speed() * self:delta_time();
		if distToWaypoint2 >= epsilon * epsilon then
			local deltaX, deltaY = waypointX - x, waypointY - y;
			local rotation = math.atan2(deltaY, deltaX);
			movement:set_heading(rotation);
			self:wait_frame();
		else
			body:set_position(waypointX, waypointY);
			vertexIndex = vertexIndex + 1;
		end
	end

	return false;
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
	return self:navigateToGoal(AlignGoal:new(self:entity(), targetEntity, targetRadius), repathDelay);
end

Navigation.navigateToGoal = function(self, goal, repathDelay)
	assert(goal);

	local body = self:entity():component(crystal.Body);
	local movement = self:entity():component(crystal.Movement);
	local navigationMesh = self:entity():ecs():getMap():getNavigationMesh();
	assert(body);
	assert(movement);
	assert(navigationMesh);

	self:script():stop_all_threads();
	return self:script():run_thread(function(self)
		self:defer(function()
			movement:set_heading(nil);
		end);

		local completion = self:thread(function(self)
			local signal = self:wait_for_any({ "success", "failure" });
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
					self:stop_on("repath");
					if navigate(self, navigationMesh, goal, body, movement) then
						self:signal("success");
					else
						self:signal("failure");
					end
				end);
				self:wait_for("repath");
			end
		end);

		return self:join(completion);
	end);
end

--#region Tests

local MapScene = require("mapscene/MapScene");

crystal.test.add("Walk to point", function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local startX, startY = 20, 20;
	local endX, endY = 300, 200;
	local acceptanceRadius = 6;

	local subject = scene:spawn(crystal.Entity);
	subject:add_component(crystal.Body);
	subject:add_component(crystal.Movement, 50);
	subject:set_position(startX, startY);
	subject:add_component(Navigation);
	subject:add_component(crystal.ScriptRunner);

	subject:navigateToPoint(endX, endY, acceptanceRadius);

	for i = 1, 1000 do
		scene:update(16 / 1000);
	end
	assert(subject:distance_to(endX, endY) < acceptanceRadius);
end);

crystal.test.add("Walk to entity", function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local startX, startY = 20, 20;
	local endX, endY = 300, 200;
	local acceptanceRadius = 6;

	local subject = scene:spawn(crystal.Entity);
	subject:add_component(crystal.Body);
	subject:add_component(crystal.Movement, 50);
	subject:set_position(startX, startY);
	subject:add_component(Navigation);
	subject:add_component(crystal.ScriptRunner);

	local target = scene:spawn(crystal.Entity);
	target:add_component(crystal.Body);
	target:set_position(endX, endY);

	subject:navigateToEntity(target, acceptanceRadius);

	for i = 1, 1000 do
		scene:update(16 / 1000);
	end
	assert(subject:distance_to_entity(target) < acceptanceRadius);
end);

crystal.test.add("Can use blocking script function", function()
	local scene = MapScene:new("test-data/empty_map.lua");

	local startX, startY = 20, 20;
	local endX, endY = 300, 200;
	local acceptanceRadius = 6;

	local sentinel = false;

	local subject = scene:spawn(crystal.Entity);
	subject:add_component(crystal.Body);
	subject:add_component(crystal.Movement, 50);
	subject:set_position(startX, startY);
	subject:add_component(Navigation);

	local scriptRunner = subject:add_component(crystal.ScriptRunner);
	scriptRunner:add_script(function(self)
		local success = self:join(self:navigateToPoint(endX, endY, acceptanceRadius));
		sentinel = success;
	end);

	for i = 1, 10 do
		scene:update(16 / 1000);
	end
	assert(not sentinel);
	for i = 1, 1000 do
		scene:update(16 / 1000);
	end
	assert(subject:distance_to(endX, endY) < acceptanceRadius);
	assert(sentinel);
end);

--#endregion

return Navigation;
