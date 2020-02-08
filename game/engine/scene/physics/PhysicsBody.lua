require("engine/utils/OOP");
local Features = require("engine/dev/Features");
local Component = require("engine/ecs/Component");
local Entity = require("engine/ecs/Entity");
local MathUtils = require("engine/utils/MathUtils");
local PhysicsDebugDraw = require("engine/scene/physics/PhysicsDebugDraw");

local PhysicsBody = Class("PhysicsBody", Component);

PhysicsBody.init = function(self, physicsWorld, bodyType)
	PhysicsBody.super.init(self);
	self._body = love.physics.newBody(physicsWorld, 0, 0, bodyType);
	self._body:setFixedRotation(true);
	self._body:setUserData(self);
	self:setDirection8(1, 0);
end

PhysicsBody.awake = function(self)
	PhysicsBody.super.awake(self);
	if Features.debugDraw then
		local ecs = self:getEntity():getECS();
		local childEntity = ecs:spawn(Entity); -- TODO despawn when this component is removed!!
		childEntity:addComponent(PhysicsDebugDraw:new(self._body));
	end
end

PhysicsBody.attach = function(self, other)
	other:attachTo(self);
end

PhysicsBody.attachTo = function(self, other)
	self._parent = other;
end

PhysicsBody.getParent = function(self)
	return self._parent;
end

PhysicsBody.update = function(self, dt)
	if self._parent then
		local x, y = self._parent:getEntity():getPosition();
		self:setPosition(x, y);
	end
end

PhysicsBody.getBody = function(self)
	return self._body;
end

PhysicsBody.getPosition = function(self)
	return self._body:getX(), self._body:getY();
end

PhysicsBody.setPosition = function(self, x, y)
	self._body:setPosition(x, y);
end

PhysicsBody.getAngle = function(self)
	return self._angle;
end

PhysicsBody.setAngle = function(self, angle)
	self:setDirection8(MathUtils.angleToDir8(angle));
	self._angle = angle;
end

PhysicsBody.setDirection8 = function(self, xDir8, yDir8)
	assert(xDir8 == 0 or xDir8 == 1 or xDir8 == -1);
	assert(yDir8 == 0 or yDir8 == 1 or yDir8 == -1);
	assert(xDir8 ~= 0 or yDir8 ~= 0);

	if xDir8 == self._xDir8 and yDir8 == self._yDir8 then
		return;
	end

	if xDir8 * yDir8 == 0 then
		if xDir8 == 1 then
			self._dir4 = "right";
		elseif xDir8 == -1 then
			self._dir4 = "left";
		elseif yDir8 == 1 then
			self._dir4 = "down";
		elseif yDir8 == -1 then
			self._dir4 = "up";
		end
	else
		if xDir8 ~= self._xDir8 then
			self._dir4 = yDir8 == 1 and "down" or "up";
		end
		if yDir8 ~= self._yDir8 then
			self._dir4 = xDir8 == 1 and "right" or "left";
		end
	end

	self._xDir8 = xDir8;
	self._yDir8 = yDir8;
	self._xDir4 = self._dir4 == "left" and -1 or self._dir4 == "right" and 1 or 0;
	self._yDir4 = self._dir4 == "up" and -1 or self._dir4 == "down" and 1 or 0;

	self._angle = math.atan2(yDir8, xDir8);
end

PhysicsBody.getDirection4 = function(self)
	return self._dir4;
end

PhysicsBody.setLinearVelocity = function(self, x, y)
	self._body:setLinearVelocity(x, y);
end

PhysicsBody.distanceToEntity = function(self, entity)
	local targetX, targetY = entity:getPosition();
	return self:distanceTo(targetX, targetY);
end

PhysicsBody.distance2ToEntity = function(self, entity)
	local targetX, targetY = entity:getPosition();
	return self:distance2To(targetX, targetY);
end

PhysicsBody.distanceTo = function(self, targetX, targetY)
	local x, y = self:getPosition();
	return MathUtils.distance(x, y, targetX, targetY);
end

PhysicsBody.distance2To = function(self, targetX, targetY)
	local x, y = self:getPosition();
	return MathUtils.distance2(x, y, targetX, targetY);
end

return PhysicsBody;
