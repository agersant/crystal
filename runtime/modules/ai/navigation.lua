local AlignGoal = require(CRYSTAL_RUNTIME .. "/modules/ai/align_goal");
local EntityGoal = require(CRYSTAL_RUNTIME .. "/modules/ai/entity_goal");
local PositionGoal = require(CRYSTAL_RUNTIME .. "/modules/ai/position_goal");

---@class Navigation : Component
---@field private map Map
---@field private script Script
---@field private path {[1]: number, [2]: number}[]
---@field private path_index number
---@field private repath_delay number
---@field private acceptance_radius number
local Navigation = Class("Navigation", crystal.Component);

local navigate;

Navigation.init = function(self, map)
	assert(map:inherits_from(crystal.Map));
	self.map = map;
	self.script = crystal.Script:new();
	self.path = nil;
	self.path_index = nil;
	self.repath_delay = 1;
	self.acceptance_radius = 4;
end

---@param dt number
Navigation.update_navigation = function(self, dt)
	self.script:update(dt);
end

---@param acceptance_radius number
Navigation.set_acceptance_radius = function(self, acceptance_radius)
	assert(acceptance_radius >= 0);
	self.acceptance_radius = acceptance_radius;
end

---@param repath_delay number # in seconds
Navigation.set_repath_delay = function(self, repath_delay)
	assert(repath_delay >= 0);
	self.repath_delay = repath_delay;
end

---@return {[1]: number, [2]: number}[] path
---@return number path_index
Navigation.navigation_state = function(self)
	return self.path, self.path_index;
end

---@param x number
---@param y number
---@param acceptance_radius number
---@param repath_delay number
---@return Thread
Navigation.navigate_to = function(self, x, y, acceptance_radius, repath_delay)
	assert(x);
	assert(y);
	acceptance_radius = acceptance_radius or self.acceptance_radius;
	repath_delay = repath_delay or self.repath_delay;
	assert(acceptance_radius >= 0);
	local position_goal = PositionGoal:new(x, y, acceptance_radius);
	return self:navigate_to_goal(position_goal, repath_delay);
end

---@param target_entity Entity
---@param acceptance_radius number
---@return Thread
Navigation.navigate_to_entity = function(self, target_entity, acceptance_radius, repath_delay)
	assert(target_entity);
	acceptance_radius = acceptance_radius or self.acceptance_radius;
	repath_delay = repath_delay or self.repath_delay;
	assert(acceptance_radius >= 0);
	local entity_goal = EntityGoal:new(target_entity, acceptance_radius);
	return self:navigate_to_goal(entity_goal, repath_delay);
end

---@param target_entity Entity
---@param acceptance_radius number
---@return Thread
Navigation.align_with_entity = function(self, target_entity, acceptance_radius, repath_delay)
	assert(target_entity);
	acceptance_radius = acceptance_radius or self.acceptance_radius;
	repath_delay = repath_delay or self.repath_delay;
	assert(acceptance_radius >= 0);
	local entity_goal = EntityGoal:new(self:entity(), acceptance_radius);
	local align_goal = AlignGoal:new(self:entity(), entity_goal, acceptance_radius);
	return self:navigate_to_goal(align_goal, repath_delay);
end

---@private
---@param goal Goal
---@param repath_delay number
Navigation.navigate_to_goal = function(self, goal, repath_delay)
	assert(goal);
	assert(repath_delay >= 0);

	local navigation = self;
	local body = self:entity():component(crystal.Body);
	local movement = self:entity():component(crystal.Movement);
	assert(body);
	assert(movement);

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
					if navigation:navigate(self, goal, body, movement) then
						self:signal("success");
					else
						self:signal("failure");
					end
				end);
				self:wait_for("repath");
			end
		end);

		return completion:block();
	end);
end

---@private
---@param thread Thread
---@param goal Goal
---@param body Body
---@param movement Movement
---@return boolean
Navigation.navigate = function(self, thread, goal, body, movement)
	if not goal:is_valid() then
		return false;
	end

	local x, y = body:position();
	local target_x, target_y = goal:position();
	self.path = self.map:find_path(x, y, target_x, target_y);
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

return Navigation;
