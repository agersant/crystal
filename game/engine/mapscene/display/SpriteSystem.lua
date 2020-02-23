require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local AnimationEndEvent = require("engine/mapscene/display/AnimationEndEvent");
local Sprite = require("engine/mapscene/display/Sprite");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local SpriteSystem = Class("SpriteSystem", System);

SpriteSystem.init = function(self, ecs)
	SpriteSystem.super.init(self, ecs);
	self._bodyQuery = AllComponents:new({Sprite, PhysicsBody});
	self:getECS():addQuery(self._bodyQuery);
end

SpriteSystem.beforeScripts = function(self, dt)
	local ecs = self:getECS();
	local sprites = ecs:getAllComponents(Sprite);
	for _, sprite in ipairs(sprites) do
		sprite:update(dt);
	end
end

SpriteSystem.duringScripts = function(self, dt)
	local animationEndEvents = self:getECS():getEvents(AnimationEndEvent);
	for _, event in ipairs(animationEndEvents) do
		local scriptRunner = event:getEntity():getComponent(ScriptRunner);
		if scriptRunner then
			scriptRunner:signalAllScripts("animationEnd");
		end
	end
end

SpriteSystem.afterScripts = function(self, dt)
	local entities = self._bodyQuery:getEntities();
	for entity in pairs(entities) do
		local sprite = entity:getComponent(Sprite);
		local physicsBody = entity:getComponent(PhysicsBody);
		local x, y = physicsBody:getPosition();
		sprite:setSpritePosition(x, y - physicsBody:getAltitude());
		sprite:setZOrder(y);
	end
end

return SpriteSystem;
