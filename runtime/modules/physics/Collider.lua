local Fixture = require("modules/physics/Fixture");

---@class Collider : Fixture
local Collider = Class("Collider", Fixture);

Collider.init = function(self, body, shape)
	Collider.super.init(self, body, shape);
	assert(self.fixture);
	self:set_friction(0);
	self:set_restitution(0);
	self:enable_collision_with("level");
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

---@param friction number
Collider.set_friction = function(self, friction)
	self.fixture:setFriction(friction);
end

---@param restitution number
Collider.set_restitution = function(self, restitution)
	self.fixture:setRestitution(restitution);
end

return Collider;
