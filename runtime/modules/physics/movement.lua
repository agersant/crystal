---@class Movement : Component
---@field private _speed number
---@field private _heading number # in radians
---@field private enabled boolean
local Movement = Class("Movement", crystal.Component);

Movement.init = function(self, speed)
	self._speed = speed or 10;
	self._heading = nil;
	self.enabled = true;
end

---@return boolean
Movement.is_movement_enabled = function(self)
	return self.enabled;
end

---@return fun()
Movement.disable_movement = function(self)
	self.enabled = false;
	return function()
		self:enable_movement();
	end
end

Movement.enable_movement = function(self)
	self.enabled = true;
end

---@return number
Movement.speed = function(self)
	return self._speed;
end

---@param speed number
Movement.set_speed = function(self, speed)
	self._speed = speed;
end

---@return number # in radians
Movement.heading = function(self)
	return self._heading;
end

---@param heading number # in radians
Movement.set_heading = function(self, heading)
	self._heading = heading;
end

return Movement;
