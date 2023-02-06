local System = require("ecs/System");
local Collision = require("mapscene/physics/Collision");
local Hitbox = require("mapscene/physics/Hitbox");
local TouchTrigger = require("mapscene/physics/TouchTrigger");
local Weakbox = require("mapscene/physics/Weakbox");

local PhysicsSystem = Class("PhysicsSystem", System);

local beginContact, endContact;

PhysicsSystem.init = function(self, ecs)
	PhysicsSystem.super.init(self, ecs);
	self._world = love.physics.newWorld(0, 0, false);
	self._contactCallbacks = {};
	self._world:setCallbacks(function(...)
		beginContact(self, ...);
	end, function(...)
		endContact(self, ...);
	end);
end

PhysicsSystem.getWorld = function(self)
	return self._world;
end

PhysicsSystem.duringPhysics = function(self, dt)
	self._world:update(dt);
	for _, callback in ipairs(self._contactCallbacks) do
		callback.func(unpack(callback.args));
	end
	self._contactCallbacks = {};
end

beginContact = function(self, fixtureA, fixtureB, contact)
	local objectA = fixtureA:getUserData();
	local objectB = fixtureB:getUserData();
	if not objectA or not objectB then
		return;
	end
	if objectA:isInstanceOf(Hitbox) and objectB:isInstanceOf(Weakbox) then
		table.insert(self._contactCallbacks, { func = objectA.onBeginTouch, args = { objectA, objectB } });
	elseif objectA:isInstanceOf(Weakbox) and objectB:isInstanceOf(Hitbox) then
		table.insert(self._contactCallbacks, { func = objectB.onBeginTouch, args = { objectB, objectA } });
	elseif objectA:isInstanceOf(Collision) and objectB:isInstanceOf(Collision) then
		table.insert(self._contactCallbacks, { func = objectA.onBeginTouch, args = { objectA, objectB } });
		table.insert(self._contactCallbacks, { func = objectB.onBeginTouch, args = { objectB, objectA } });
	elseif objectA:isInstanceOf(TouchTrigger) and objectB:isInstanceOf(Collision) then
		table.insert(self._contactCallbacks, { func = objectA.onBeginTouch, args = { objectA, objectB } });
	elseif objectA:isInstanceOf(Collision) and objectB:isInstanceOf(TouchTrigger) then
		table.insert(self._contactCallbacks, { func = objectB.onBeginTouch, args = { objectB, objectA } });
	end
end

endContact = function(self, fixtureA, fixtureB, contact)
	local objectA = fixtureA:getUserData();
	local objectB = fixtureB:getUserData();
	if not objectA or not objectB then
		return;
	end
	if objectA:isInstanceOf(Hitbox) and objectB:isInstanceOf(Weakbox) then
		table.insert(self._contactCallbacks, { func = objectA.onEndTouch, args = { objectA, objectB } });
	elseif objectA:isInstanceOf(Weakbox) and objectB:isInstanceOf(Hitbox) then
		table.insert(self._contactCallbacks, { func = objectB.onEndTouch, args = { objectB, objectA } });
	elseif objectA:isInstanceOf(Collision) and objectB:isInstanceOf(Collision) then
		table.insert(self._contactCallbacks, { func = objectA.onEndTouch, args = { objectA, objectB } });
		table.insert(self._contactCallbacks, { func = objectB.onEndTouch, args = { objectB, objectA } });
	elseif objectA:isInstanceOf(TouchTrigger) and objectB:isInstanceOf(Collision) then
		table.insert(self._contactCallbacks, { func = objectA.onEndTouch, args = { objectA, objectB } });
	elseif objectA:isInstanceOf(Collision) and objectB:isInstanceOf(TouchTrigger) then
		table.insert(self._contactCallbacks, { func = objectB.onEndTouch, args = { objectB, objectA } });
	end
end

return PhysicsSystem;
