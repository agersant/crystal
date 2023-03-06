local MathUtils = require("utils/MathUtils");

---@alias Layer { damping: number }

---@class PhysicsBody
---@field private _body love.Body
---@field private _angle number # in radians
---@field private dir4_x number
---@field private dir4_y number
---@field private dir8_y number
---@field private dir8_y number
---@field private parent_joint love.Joint
---@field private child_joints { [love.Joint]: boolean }
local PhysicsBody = Class("PhysicsBody", crystal.Component);

PhysicsBody.init = function(self, world, body_type)
	self._body = love.physics.newBody(world, 0, 0, body_type);
	self._body:setFixedRotation(true);
	self._body:setUserData(self);
	self._body:setActive(false);
	self._body:setMass(1);
	self:set_angle(0);
	self.parent_joint = nil;
	self.child_joints = {};
end

PhysicsBody.on_added = function(self)
	self._body:setActive(true);
end

PhysicsBody.on_removed = function(self)
	self:detach_from_parent();
	for joint in pairs(self.child_joints) do
		local _, child = joint:getBodies();
		local child = child:getUserData();
		child:detach_from_parent();
	end
	self._body:destroy();
end

---@param parent_entity Entity
PhysicsBody.attach_to = function(self, parent_entity)
	self:detach_from_parent();

	local parent = parent_entity:component(PhysicsBody);
	local x, y = parent:position();
	self:set_position(x, y);
	self:set_velocity(0, 0);
	-- Attached entities should not weigh down their parent because
	-- it would affect the behavior of `applyLinearImpulse`.
	-- Mass also cannot be zero but this is close enough.
	self._body:setMass(1E-10);

	local joint = love.physics.newWeldJoint(parent._body, self._body, x, y, x, y);
	self.parent_joint = joint;
	parent.child_joints[joint] = true;
end

PhysicsBody.detach_from_parent = function(self)
	if not self.parent_joint then
		return;
	end
	local parent = self.parent_joint:getBodies():getUserData();
	parent.child_joints[self.parent_joint] = nil;
	self.parent_joint:destroy();
	self.parent_joint = nil;
	self._body:setMass(1);
end

---@return love.Body
PhysicsBody.body = function(self)
	return self._body;
end

---@return number
---@return number
PhysicsBody.position = function(self)
	return self._body:getX(), self._body:getY();
end

---@param x number
---@param y number
PhysicsBody.set_position = function(self, x, y)
	if self.parent_joint then
		return;
	end
	self._body:setPosition(x, y);
	for joint in pairs(self.child_joints) do
		local _, child = joint:getBodies();
		local child = child:getUserData();
		child:set_position(x, y);
	end
end

---@return number # in radians
PhysicsBody.angle = function(self)
	return self._angle;
end

---@param angle number # in radians
PhysicsBody.set_angle = function(self, angle)
	self:set_direction8(MathUtils.angleToDir8(angle));
	self._angle = angle;
end

---@param target_x number
---@param target_y number
PhysicsBody.look_at = function(self, target_x, target_y)
	local x, y = self:position();
	local delta_x, delta_y = target_x - x, target_y - y;
	local angle = math.atan2(delta_y, delta_x);
	self:set_angle(angle);
end

---@param dir8_x number
---@param dir8_y number
PhysicsBody.set_direction8 = function(self, dir8_x, dir8_y)
	assert(dir8_x == 0 or dir8_x == 1 or dir8_x == -1);
	assert(dir8_y == 0 or dir8_y == 1 or dir8_y == -1);
	assert(dir8_x ~= 0 or dir8_y ~= 0);

	if dir8_x == self.dir8_x and dir8_y == self.dir8_y then
		return;
	end

	if dir8_x * dir8_y == 0 then
		self.dir4_x = dir8_x;
		self.dir4_y = dir8_y;
	else
		if dir8_x ~= self.dir8_x then
			self.dir4_x = 0;
			self.dir4_y = dir8_y;
		end
		if dir8_y ~= self.dir8_y then
			self.dir4_x = dir8_x;
			self.dir4_y = 0;
		end
	end

	self.dir8_x = dir8_x;
	self.dir8_y = dir8_y;
	self._angle = math.atan2(dir8_y, dir8_x);
end

---@return number x
---@return number y
PhysicsBody.direction4 = function(self)
	return self.dir4_x, self.dir4_y;
end

---@return number # in radians
PhysicsBody.angle4 = function(self)
	return math.atan2(self.dir4_y, self.dir4_x);
end

---@return number x
---@return number y
PhysicsBody.velocity = function(self)
	return self._body:getLinearVelocity();
end

---@param x number
---@param y number
PhysicsBody.set_velocity = function(self, x, y)
	if self.parent_joint then
		return;
	end
	self._body:setLinearVelocity(x, y);
end


---@param x number
---@param y number
PhysicsBody.apply_linear_impulse = function(self, x, y)
	if self.parent_joint then
		return;
	end
	self._body:applyLinearImpulse(x, y);
end

---@return number
PhysicsBody.damping = function(self)
	return self._body:getLinearDamping();
end

---@param damping number
PhysicsBody.set_damping = function(self, damping)
	self._body:setLinearDamping(damping);
end

---@param entity Entity
---@return number
PhysicsBody.distance_to_entity = function(self, entity)
	local target_x, target_y = entity:position();
	return self:distance_to(target_x, target_y);
end

---@param entity Entity
---@return number
PhysicsBody.distance_squared_to_entity = function(self, entity)
	local target_x, target_y = entity:position();
	return self:distance_squared_to(target_x, target_y);
end

---@param target_x number
---@param target_y number
---@return number
PhysicsBody.distance_to = function(self, target_x, target_y)
	local x, y = self:position();
	return MathUtils.distance(x, y, target_x, target_y);
end

---@param target_x number
---@param target_y number
---@return number
PhysicsBody.distance_squared_to = function(self, target_x, target_y)
	local x, y = self:position();
	return MathUtils.distance2(x, y, target_x, target_y);
end

--#region Tests

crystal.test.add("look_at turns to correct direction", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(crystal.Entity);
	entity:add_component(PhysicsBody, scene:physics_world(), "dynamic");

	entity:look_at(10, 0);
	assert(entity:angle() == 0);
	local x, y = entity:direction4();
	assert(x == 1 and y == 0);

	entity:look_at(0, 10);
	assert(entity:angle() == 0.5 * math.pi);
	local x, y = entity:direction4();
	assert(x == 0 and y == 1);

	entity:look_at(-10, 0);
	assert(entity:angle() == math.pi);
	local x, y = entity:direction4();
	assert(x == -1 and y == 0);

	entity:look_at(0, -10);
	assert(entity:angle() == -0.5 * math.pi);
	local x, y = entity:direction4();
	assert(x == 0 and y == -1);
end);

crystal.test.add("Direction is preserved when switching to adjacent diagonal", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(crystal.Entity);
	entity:add_component(PhysicsBody, scene:physics_world(), "dynamic");

	entity:set_angle(0.25 * math.pi);
	local x, y = entity:direction4();
	assert(x == 1 and y == 0);

	entity:set_angle(-0.25 * math.pi);
	local x, y = entity:direction4();
	assert(x == 1 and y == 0);

	entity:set_angle(-0.75 * math.pi);
	local x, y = entity:direction4();
	assert(x == 0 and y == -1);

	entity:set_angle(-0.25 * math.pi);
	local x, y = entity:direction4();
	assert(x == 0 and y == -1);
end);

crystal.test.add("Can measure distances", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(crystal.Entity);
	entity:add_component(PhysicsBody, scene:physics_world(), "dynamic");

	local target = scene:spawn(crystal.Entity);
	target:add_component(PhysicsBody, scene:physics_world(), "dynamic");
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
	entity:add_component(PhysicsBody, scene:physics_world(), "dynamic");

	local vx, vy = entity:velocity();
	assert(vx == 0);
	assert(vy == 0);

	entity:set_velocity(1, 2);
	local vx, vy = entity:velocity();
	assert(vx == 1);
	assert(vy == 2);
end);

crystal.test.add("Can read/write angle", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(crystal.Entity);
	entity:add_component(PhysicsBody, scene:physics_world(), "dynamic");
	assert(entity:angle() == 0);
	entity:set_angle(50);
	assert(entity:angle() == 50);
end);

crystal.test.add("Can read/write damping", function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(crystal.Entity);
	entity:add_component(PhysicsBody, scene:physics_world(), "dynamic");
	assert(entity:damping() == 0);
	entity:set_damping(50);
	assert(entity:damping() == 50);
end);

--#endregion

return PhysicsBody;
