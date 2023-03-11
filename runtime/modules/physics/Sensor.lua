local Fixture = require("modules/physics/Fixture");

---@class Sensor : Fixture
local Sensor = Class("Sensor", Fixture);

Sensor.init = function(self, body, shape)
	Sensor.super.init(self, body, shape);
	assert(self.fixture);
	self.fixture:setSensor(true);
end

Sensor.enable_sensor = function(self)
	self:enable();
end

Sensor.disable_sensor = function(self)
	self:disable();
end

---@param ... string
Sensor.enable_activation_by = function(self, ...)
	self:add_category_to_mask(...);
end

---@param ... string
Sensor.disable_activation_by = function(self, ...)
	self:remove_category_from_mask(...);
end

return Sensor;
