local Goal = require("modules/ai/goal");

---@class EntityGoal : Goal
---@field private entity Entity
local EntityGoal = Class("EntityGoal", Goal);

EntityGoal.init = function(self, entity, radius)
	EntityGoal.super.init(self, radius);
	self.entity = entity;
end

---@return boolean
EntityGoal.is_valid = function(self)
	return self.entity:is_valid();
end

---@return number
---@return number
EntityGoal.position = function(self)
	return self.entity:position();
end

--#region Tests

crystal.test.add("EntityGoal can accept/reject positions", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty.lua");

	local target = scene:spawn(crystal.Entity);
	target:add_component(crystal.Body);
	target:set_position(8, 12);

	local goal = EntityGoal:new(target, 1);
	local x, y = goal:position();
	assert(x == 8);
	assert(y == 12);

	assert(goal:is_position_acceptable(8.5, 11.8));
	assert(not goal:is_position_acceptable(10, 10));
end);

--#endregion

return EntityGoal;
