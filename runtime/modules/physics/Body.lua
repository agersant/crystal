local MathUtils = require("utils/MathUtils");

---@alias Layer { damping: number }

---@class Body
---@field private _inner love.Body
---@field private _rotation number # in radians
---@field private parent_joint love.Joint
---@field private child_joints { [love.Joint]: boolean }
local Body = Class("Body", crystal.Component);

Body.init = function(self, body_type)
	local ecs = self:entity():ecs();
	local physics_system = ecs:system(crystal.PhysicsSystem);
	assert(physics_system);
	local world = physics_system:world();
	assert(world);
	self._inner = love.physics.newBody(world, 0, 0, body_type);
	self._inner:setFixedRotation(true);
	self._inner:setUserData(self);
	self._inner:setActive(false);
	self._inner:setMass(1);
	self._rotation = 0;
	self.parent_joint = nil;
	self.child_joints = {};
end

Body.on_added = function(self)
	self._inner:setActive(true);
end

Body.on_removed = function(self)
	self:detach_from_parent();
	for joint in pairs(self.child_joints) do
		local _, child = joint:getBodies();
		local child = child:getUserData();
		child:detach_from_parent();
	end
	self._inner:destroy();
end

---@param parent_entity Entity
Body.attach_to = function(self, parent_entity)
	self:detach_from_parent();

	local parent = parent_entity:component(Body);
	local x, y = parent:position();
	self:set_position(x, y);
	self:set_velocity(0, 0);
	-- Attached entities should not weigh down their parent because
	-- it would affect the behavior of `applyLinearImpulse`.
	-- Mass also cannot be zero but this is close enough.
	self._inner:setMass(1E-10);

	local joint = love.physics.newWeldJoint(parent._inner, self._inner, x, y, x, y);
	self.parent_joint = joint;
	parent.child_joints[joint] = true;
end

Body.detach_from_parent = function(self)
	if not self.parent_joint then
		return;
	end
	local parent = self.parent_joint:getBodies():getUserData();
	parent.child_joints[self.parent_joint] = nil;
	self.parent_joint:destroy();
	self.parent_joint = nil;
	self._inner:setMass(1);
end

---@return love.Body
Body.inner = function(self)
	return self._inner;
end

---@return number
---@return number
Body.position = function(self)
	return self._inner:getX(), self._inner:getY();
end

---@param x number
---@param y number
Body.set_position = function(self, x, y)
	if self.parent_joint then
		return;
	end
	self._inner:setPosition(x, y);
	for joint in pairs(self.child_joints) do
		local _, child = joint:getBodies();
		local child = child:getUserData();
		child:set_position(x, y);
	end
end

---@return number # in radians
Body.rotation = function(self)
	return self._rotation;
end

---@param rotation number # in radians
Body.set_rotation = function(self, rotation)
	self._rotation = rotation;
end

---@param target_x number
---@param target_y number
Body.look_at = function(self, target_x, target_y)
	local x, y = self:position();
	local delta_x, delta_y = target_x - x, target_y - y;
	local rotation = math.atan2(delta_y, delta_x);
	self:set_rotation(rotation);
end

---@return number x
---@return number y
Body.velocity = function(self)
	return self._inner:getLinearVelocity();
end

---@param x number
---@param y number
Body.set_velocity = function(self, x, y)
	if self.parent_joint then
		return;
	end
	self._inner:setLinearVelocity(x, y);
end


---@param x number
---@param y number
Body.apply_linear_impulse = function(self, x, y)
	if self.parent_joint then
		return;
	end
	self._inner:applyLinearImpulse(x, y);
end

---@return number
Body.damping = function(self)
	return self._inner:getLinearDamping();
end

---@param damping number
Body.set_damping = function(self, damping)
	self._inner:setLinearDamping(damping);
end

---@param entity Entity
---@return number
Body.distance_to_entity = function(self, entity)
	local target_x, target_y = entity:position();
	return self:distance_to(target_x, target_y);
end

---@param entity Entity
---@return number
Body.distance_squared_to_entity = function(self, entity)
	local target_x, target_y = entity:position();
	return self:distance_squared_to(target_x, target_y);
end

---@param target_x number
---@param target_y number
---@return number
Body.distance_to = function(self, target_x, target_y)
	local x, y = self:position();
	return MathUtils.distance(x, y, target_x, target_y);
end

---@param target_x number
---@param target_y number
---@return number
Body.distance_squared_to = function(self, target_x, target_y)
	local x, y = self:position();
	return MathUtils.distance2(x, y, target_x, target_y);
end

--#region Tests

crystal.test.add("look_at turns to correct direction", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(crystal.Entity);
	entity:add_component(Body, "dynamic");

	entity:look_at(10, 0);
	assert(entity:rotation() == 0);

	entity:look_at(0, 10);
	assert(entity:rotation() == 0.5 * math.pi);

	entity:look_at(-10, 0);
	assert(entity:rotation() == math.pi);

	entity:look_at(0, -10);
	assert(entity:rotation() == -0.5 * math.pi);
end);

crystal.test.add("Can measure distances", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(crystal.Entity);
	entity:add_component(Body, "dynamic");

	local target = scene:spawn(crystal.Entity);
	target:add_component(Body, "dynamic");
	target:set_position(10, 0);

	assert(entity:distance_to_entity(target) == 10);
	assert(entity:distance_squared_to_entity(target) == 100);
	assert(entity:distance_to(target:position()) == 10);
	assert(entity:distance_squared_to(target:position()) == 100);
end);

crystal.test.add("Can read/write velocity", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(crystal.Entity);
	entity:add_component(Body, "dynamic");

	local vx, vy = entity:velocity();
	assert(vx == 0);
	assert(vy == 0);

	entity:set_velocity(1, 2);
	local vx, vy = entity:velocity();
	assert(vx == 1);
	assert(vy == 2);
end);

crystal.test.add("Can read/write rotation", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(crystal.Entity);
	entity:add_component(Body, "dynamic");
	assert(entity:rotation() == 0);
	entity:set_rotation(50);
	assert(entity:rotation() == 50);
end);

crystal.test.add("Can read/write damping", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(crystal.Entity);
	entity:add_component(Body, "dynamic");
	assert(entity:damping() == 0);
	entity:set_damping(50);
	assert(entity:damping() == 50);
end);

--#endregion

return Body;
