---@class Goal
---@field private radius_squared number
local Goal = Class("Goal");

Goal.init = function(self, radius)
	self.radius_squared = radius * radius;
end

---@return boolean
Goal.is_valid = function(self)
	return true;
end

---@param x number
---@param y number
---@return boolean
Goal.is_position_acceptable = function(self, x, y)
	local target_x, target_y = self:position();
	local dist_to_target_squared = math.distance_squared(x, y, target_x, target_y);
	return dist_to_target_squared <= self.radius_squared;
end

---@return number
---@return number
Goal.position = function(self)
	error("Not implemented");
end

return Goal;
