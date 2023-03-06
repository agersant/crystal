local Fixture = require("modules/physics/Fixture");

---@class Sensor : Fixture
local Sensor = Class("Sensor", Fixture);

Sensor.init = function(self, body, shape)
	Sensor.super.init(self, body, shape);
	assert(self.fixture);
	self.fixture:setSensor(true);
end

---@param ... string
Sensor.enable_activation_by = function(self, ...)
	self:add_to_mask(...);
end

---@param ... string
Sensor.disable_activation_by = function(self, ...)
	self:remove_from_mask(...);
end

return Sensor;
