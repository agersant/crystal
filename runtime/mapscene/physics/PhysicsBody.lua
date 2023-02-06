local Component = require("ecs/Component");
local MathUtils = require("utils/MathUtils");

local PhysicsBody = Class("PhysicsBody", Component);

local getState = function(self)
	local x, y = self:getPosition();
	local vx, vy = self:getLinearVelocity();
	local dampingX, dampingY = self:getLinearDamping();
	return {
		x = x,
		y = y,
		vx = vx,
		vy = vy,
		dampingX = dampingX,
		dampingY = dampingY,
		altitude = self:getAltitude(),
		angle = self:getAngle(),
	};
end

local setState = function(self, state)
	if state.x and state.y then
		self:setPosition(state.x, state.y);
	end
	self:setLinearVelocity(state.vx, state.vy);
	self:setAltitude(state.altitude);
	self:setAngle(state.angle);
end

PhysicsBody.init = function(self, physicsWorld, bodyType)
	PhysicsBody.super.init(self);
	self._body = love.physics.newBody(physicsWorld, 0, 0, bodyType);
	self._body:setFixedRotation(true);
	self._body:setUserData(self);
	self._body:setActive(false);
	self:setAngle(0);
	self._altitude = 0;
end

PhysicsBody.pushPhysicsBodyState = function(self, options)
	local state = getState(self);
	if not options or not options.includePosition then
		state.x = nil;
		state.y = nil;
	end
	return function()
		setState(self, state);
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

PhysicsBody.lookAt = function(self, targetX, targetY)
	local x, y = self:getPosition();
	local deltaX, deltaY = targetX - x, targetY - y;
	local angle = math.atan2(deltaY, deltaX);
	self:setAngle(angle);
end

PhysicsBody.setDirection8 = function(self, xDir8, yDir8)
	assert(xDir8 == 0 or xDir8 == 1 or xDir8 == -1);
	assert(yDir8 == 0 or yDir8 == 1 or yDir8 == -1);
	assert(xDir8 ~= 0 or yDir8 ~= 0);

	if xDir8 == self._xDir8 and yDir8 == self._yDir8 then
		return;
	end

	if xDir8 * yDir8 == 0 then
		self._xDir4 = xDir8;
		self._yDir4 = yDir8;
	else
		if xDir8 ~= self._xDir8 then
			self._xDir4 = 0;
			self._yDir4 = yDir8;
		end
		if yDir8 ~= self._yDir8 then
			self._xDir4 = xDir8;
			self._yDir4 = 0;
		end
	end

	self._xDir8 = xDir8;
	self._yDir8 = yDir8;

	self._angle = math.atan2(yDir8, xDir8);
end

PhysicsBody.getDirection4 = function(self)
	return self._xDir4, self._yDir4;
end

PhysicsBody.getAngle4 = function(self)
	return math.atan2(self._yDir4, self._xDir4);
end

PhysicsBody.setLinearVelocity = function(self, x, y)
	self._body:setLinearVelocity(x, y);
end

PhysicsBody.getLinearVelocity = function(self)
	return self._body:getLinearVelocity();
end

PhysicsBody.setLinearDamping = function(self, x, y)
	self._body:setLinearDamping(x, y);
end

PhysicsBody.getLinearDamping = function(self)
	return self._body:getLinearDamping();
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

PhysicsBody.setAltitude = function(self, altitude)
	assert(altitude);
	self._altitude = altitude;
end

PhysicsBody.getAltitude = function(self)
	return self._altitude;
end

return PhysicsBody;
