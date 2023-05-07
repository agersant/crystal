local Fixture = require(CRYSTAL_RUNTIME .. "/modules/physics/fixture");

---@class Sensor : Fixture
---@field on_activate fun(Sensor, Fixture, Entity, Contact)
---@field on_deactivate fun(Sensor, Fixture, Entity, Contact)
local Sensor = Class("Sensor", Fixture);

local noop = function()
end

Sensor.init = function(self, shape)
	Sensor.super.init(self, shape);
	assert(self.fixture);
	self.fixture:setSensor(true);
	self.on_activate = noop;
	self.on_deactivate = noop;
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

Sensor.enable_activation_by_everything = function(self)
	self:add_all_categories_to_mask();
end

Sensor.disable_activation_by_everything = function(self)
	self:remove_all_categories_from_mask();
end

---@param other_fixture Fixture
---@param other_entity Entity
---@param contact love.Contact
Sensor.on_begin_contact = function(self, other_fixture, other_entity, contact)
	self:on_activate(other_fixture, other_entity, contact);
end

---@param other_fixture Fixture
---@param other_entity Entity
---@param contact love.Contact
Sensor.on_end_contact = function(self, other_fixture, other_entity, contact)
	self:on_deactivate(other_fixture, other_entity, contact);
end

---@return { [Fixture]: Entity }
Sensor.activations = function(self)
	return self:active_contacts();
end

return Sensor;
