local Fixture = require(CRYSTAL_RUNTIME .. "modules/physics/fixture");

---@class Collider : Fixture
---@field on_collide fun(Sensor, Fixture, Entity, Contact)
---@field on_uncollide fun(Sensor, Fixture, Entity, Contact)
local Collider = Class("Collider", Fixture);

local noop = function()
end

Collider.init = function(self, shape)
	Collider.super.init(self, shape);
	assert(self.fixture);
	self:set_friction(0);
	self:set_restitution(0);
	self:enable_collision_with("level");
	self.on_collide = noop;
	self.on_uncollide = noop;
end

Collider.enable_collider = function(self)
	self:enable();
end

Collider.disable_collider = function(self)
	self:disable();
end

---@param ... string
Collider.enable_collision_with = function(self, ...)
	self:add_category_to_mask(...);
end

---@param ... string
Collider.disable_collision_with = function(self, ...)
	self:remove_category_from_mask(...);
end

Collider.enable_collision_with_everything = function(self)
	self:add_all_categories_to_mask();
end

Collider.disable_collision_with_everything = function(self)
	self:remove_all_categories_from_mask();
end

---@param friction number
Collider.set_friction = function(self, friction)
	self.fixture:setFriction(friction);
end

---@param restitution number
Collider.set_restitution = function(self, restitution)
	self.fixture:setRestitution(restitution);
end

---@param other_fixture Fixture
---@param other_entity Entity
---@param contact love.Contact
Collider.on_begin_contact = function(self, other_fixture, other_entity, contact)
	self:on_collide(other_fixture, other_entity, contact);
end

---@param other_fixture Fixture
---@param other_entity Entity
---@param contact love.Contact
Collider.on_end_contact = function(self, other_fixture, other_entity, contact)
	self:on_uncollide(other_fixture, other_entity, contact);
end

---@return { [Fixture]: Entity }
Collider.collisions = function(self)
	return self:active_contacts();
end

return Collider;
