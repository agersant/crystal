local AlignGoal = require("modules/ai/align_goal");
local EntityGoal = require("modules/ai/entity_goal");
local PositionGoal = require("modules/ai/position_goal");

---@class Navigation : Component
---@field private script Script
---@field private path {[1]: number, [2]: number}[]
---@field private path_index number
local Navigation = Class("Navigation", crystal.Component);

local navigate;

Navigation.init = function(self)
	self.script = crystal.Script:new();
	self.path = nil;
	self.path_index = nil;
end

---@dt number
Navigation.update_navigation = function(self, dt)
	self.script:update(dt);
end

---@return {[1]: number, [2]: number}[] path
---@return number path_index
Navigation.navigation_state = function(self)
	return self.path, self.path_index;
end

---@param x number
---@param y number
---@param acceptance_radius number
---@return Thread
Navigation.navigate_to = function(self, x, y, acceptance_radius)
	assert(x);
	assert(y);
	acceptance_radius = acceptance_radius or 4;
	assert(acceptance_radius >= 0);
	local repath_delay = 2;
	local position_goal = PositionGoal:new(x, y, acceptance_radius);
	return self:navigate_to_goal(position_goal, repath_delay);
end

---@param target_entity Entity
---@param acceptance_radius number
---@return Thread
Navigation.navigate_to_entity = function(self, target_entity, acceptance_radius)
	assert(target_entity);
	acceptance_radius = acceptance_radius or 4;
	assert(acceptance_radius >= 0);
	local repath_delay = 0.5;
	local entity_goal = EntityGoal:new(target_entity, acceptance_radius);
	return self:navigate_to_goal(entity_goal, repath_delay);
end

---@param target_entity Entity
---@param acceptance_radius number
---@return Thread
Navigation.align_with_entity = function(self, target_entity, acceptance_radius)
	assert(target_entity);
	acceptance_radius = acceptance_radius or 4;
	assert(acceptance_radius >= 0);
	local repath_delay = 0.5;
	local entity_goal = EntityGoal:new(self:entity(), acceptance_radius);
	local align_goal = AlignGoal:new(self:entity(), entity_goal, acceptance_radius);
	return self:navigate_to_goal(align_goal, repath_delay);
end

---@private
---@param goal Goal
---@param repath_delay number
Navigation.navigate_to_goal = function(self, goal, repath_delay)
	assert(goal);

	local navigation = self;
	local body = self:entity():component(crystal.Body);
	local movement = self:entity():component(crystal.Movement);
	local map = self:entity():context("map");
	assert(body);
	assert(movement);
	assert(map);

	self.script:stop_all_threads();
	return self.script:run_thread(function(self)
		self:defer(function()
			movement:set_heading(nil);
		end);

		local completion = self:thread(function(self)
			local signal = self:wait_for_any({ "success", "failure" });
			return signal == "success";
		end);

		self:thread(function(self)
			while true do
				self:wait(repath_delay);
				self:signal("repath");
			end
		end);

		self:thread(function(self)
			while true do
				self:thread(function(self)
					self:stop_on("repath");
					if navigation:navigate(self, map, goal, body, movement) then
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

---@private
---@param thread Thread
---@param goal Goal
---@param body Body
---@param movement Movement
---@return boolean
Navigation.navigate = function(self, thread, map, goal, body, movement)
	if not goal:is_valid() then
		return false;
	end

	local x, y = body:position();
	local target_x, target_y = goal:position();
	self.path = map:find_path(x, y, target_x, target_y);
	if not self.path then
		return false;
	end

	self.path_index = 1;
	while true do
		if goal:is_valid() and goal:is_position_acceptable(body:position()) then
			return true;
		end

		local waypoint = self.path[self.path_index];
		if not waypoint then
			break;
		end
		local waypoint_x, waypoint_y = waypoint[1], waypoint[2];
		local x, y = body:position();
		local distance_squared = math.distance_squared(x, y, waypoint_x, waypoint_y);
		local epsilon = movement:speed() * thread:delta_time();
		if distance_squared >= epsilon * epsilon then
			local dx, dy = waypoint_x - x, waypoint_y - y;
			local rotation = math.atan2(dy, dx);
			movement:set_heading(rotation);
			thread:wait_frame();
		else
			body:set_position(waypoint_x, waypoint_y);
			self.path_index = self.path_index + 1;
		end
	end

	return false;
end

--#region Tests

crystal.test.add("Can walk to point", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty.lua");

	local start_x, start_y = 20, 20;
	local end_x, end_y = 300, 200;
	local acceptance_radius = 6;

	local subject = scene:spawn(crystal.Entity);
	subject:add_component(crystal.Body);
	subject:add_component(crystal.Movement, 50);
	subject:set_position(start_x, start_y);
	subject:add_component(Navigation);
	subject:add_component(crystal.ScriptRunner);

	subject:navigate_to(end_x, end_y, acceptance_radius);

	for i = 1, 1000 do
		scene:update(16 / 1000);
	end
	assert(subject:distance_to(end_x, end_y) < acceptance_radius);
end);

crystal.test.add("Can walk to entity", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty.lua");

	local start_x, start_y = 20, 20;
	local end_x, end_y = 300, 200;
	local acceptance_radius = 6;

	local subject = scene:spawn(crystal.Entity);
	subject:add_component(crystal.Body);
	subject:add_component(crystal.Movement, 50);
	subject:set_position(start_x, start_y);
	subject:add_component(Navigation);
	subject:add_component(crystal.ScriptRunner);

	local target = scene:spawn(crystal.Entity);
	target:add_component(crystal.Body);
	target:set_position(end_x, end_y);

	subject:navigate_to_entity(target, acceptance_radius);

	for i = 1, 1000 do
		scene:update(16 / 1000);
	end
	assert(subject:distance_to_entity(target) < acceptance_radius);
end);

crystal.test.add("Can block on navigation thread", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty.lua");

	local start_x, start_y = 20, 20;
	local end_x, end_y = 300, 200;
	local acceptance_radius = 6;

	local sentinel = false;

	local subject = scene:spawn(crystal.Entity);
	subject:add_component(crystal.Body);
	subject:add_component(crystal.Movement, 50);
	subject:set_position(start_x, start_y);
	subject:add_component(Navigation);

	local scriptRunner = subject:add_component(crystal.ScriptRunner);
	scriptRunner:add_script(function(self)
		local success = self:join(self:navigate_to(end_x, end_y, acceptance_radius));
		sentinel = success;
	end);

	for i = 1, 10 do
		scene:update(16 / 1000);
	end
	assert(not sentinel);
	for i = 1, 1000 do
		scene:update(16 / 1000);
	end
	assert(subject:distance_to(end_x, end_y) < acceptance_radius);
	assert(sentinel);
end);

--#endregion

return Navigation;
