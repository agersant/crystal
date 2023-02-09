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

--#region Tests

local Entity = require("ecs/Entity");

crystal.test.add("LookAt turns to correct direction", { gfx = "mock" }, function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));

	entity:lookAt(10, 0);
	assert(entity:getAngle() == 0);
	local x, y = entity:getDirection4();
	assert(x == 1 and y == 0);

	entity:lookAt(0, 10);
	assert(entity:getAngle() == 0.5 * math.pi);
	local x, y = entity:getDirection4();
	assert(x == 0 and y == 1);

	entity:lookAt( -10, 0);
	assert(entity:getAngle() == math.pi);
	local x, y = entity:getDirection4();
	assert(x == -1 and y == 0);

	entity:lookAt(0, -10);
	assert(entity:getAngle() == -0.5 * math.pi);
	local x, y = entity:getDirection4();
	assert(x == 0 and y == -1);
end);

crystal.test.add("Direction is preserved when switching to adjacent diagonal", { gfx = "mock" }, function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));

	entity:setAngle(0.25 * math.pi);
	local x, y = entity:getDirection4();
	assert(x == 1 and y == 0);

	entity:setAngle( -0.25 * math.pi);
	local x, y = entity:getDirection4();
	assert(x == 1 and y == 0);

	entity:setAngle( -0.75 * math.pi);
	local x, y = entity:getDirection4();
	assert(x == 0 and y == -1);

	entity:setAngle( -0.25 * math.pi);
	local x, y = entity:getDirection4();
	assert(x == 0 and y == -1);
end);

crystal.test.add("Distance measurements", { gfx = "mock" }, function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));

	local target = scene:spawn(Entity);
	target:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	target:setPosition(10, 0);

	assert(entity:distanceToEntity(target) == 10);
	assert(entity:distance2ToEntity(target) == 100);
	assert(entity:distanceTo(target:getPosition()) == 10);
	assert(entity:distance2To(target:getPosition()) == 100);
end);

crystal.test.add("Stores velocity", { gfx = "mock" }, function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));

	local vx, vy = entity:getLinearVelocity();
	assert(vx == 0);
	assert(vy == 0);

	entity:setLinearVelocity(1, 2);
	local vx, vy = entity:getLinearVelocity();
	assert(vx == 1);
	assert(vy == 2);
end);

crystal.test.add("Stores angle", { gfx = "mock" }, function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	assert(entity:getAngle() == 0);
	entity:setAngle(50);
	assert(entity:getAngle() == 50);
end);

crystal.test.add("Stores altitude", { gfx = "mock" }, function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	assert(entity:getAltitude() == 0);
	entity:setAltitude(50);
	assert(entity:getAltitude() == 50);
end);

crystal.test.add("Can save and restore state", { gfx = "mock" }, function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));

	local restore = entity:pushPhysicsBodyState();

	entity:setLinearVelocity(1, 2);
	entity:setAltitude(3);
	entity:setAngle(4);

	restore();

	local vx, vy = entity:getLinearVelocity();
	assert(vx == 0);
	assert(vy == 0);
	assert(entity:getAltitude() == 0);
	assert(entity:getAngle() == 0);
end);

crystal.test.add("Can save and restore position", { gfx = "mock" }, function()
	local MapScene = require("mapscene/MapScene");
	local scene = MapScene:new("test-data/empty_map.lua");
	local entity = scene:spawn(Entity);
	entity:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));

	local restore = entity:pushPhysicsBodyState({ includePosition = true });
	entity:setPosition(100, 150);
	restore();
	local x, y = entity:getPosition();
	assert(x == 0);
	assert(y == 0);
end);

--#endregion

return PhysicsBody;
