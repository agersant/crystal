require("engine/utils/OOP");
local System = require("engine/ecs/System");
local AllComponents = require("engine/ecs/query/AllComponents");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local Sprite = require("engine/mapscene/display/Sprite");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");

local SpriteSystem = Class("SpriteSystem", System);

SpriteSystem.init = function(self, ecs)
	SpriteSystem.super.init(self, ecs);
	self._bodyQuery = AllComponents:new({Sprite, PhysicsBody});
	self._scriptQuery = AllComponents:new({Sprite, ScriptRunner});
	self:getECS():addQuery(self._bodyQuery);
	self:getECS():addQuery(self._scriptQuery);
end

SpriteSystem.beforeScripts = function(self, dt)
	local ecs = self:getECS();
	local sprites = ecs:getAllComponents(Sprite);
	for _, sprite in ipairs(sprites) do
		sprite:update(dt);
	end
end

SpriteSystem.duringScripts = function(self, dt)
	local entities = self._scriptQuery:getEntities();
	for entity in pairs(entities) do
		local sprite = entity:getComponent(Sprite);
		local scriptRunner = entity:getComponent(ScriptRunner);
		if sprite:justCompletedAnimation() then
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
		sprite:setSpritePosition(x, y);
		sprite:setZOrder(y);
	end
end

return SpriteSystem;
