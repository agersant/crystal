require("engine/utils/OOP");
local HitWidget = require("arpg/field/hud/damage/HitWidget");
local Entity = require("engine/ecs/Entity");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local WorldWidget = require("engine/mapscene/display/WorldWidget");
local Parent = require("engine/mapscene/physics/Parent");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local Script = require("engine/script/Script");

local HitWidgetEntity = Class("HitWidgetEntity", Entity);

HitWidgetEntity.init = function(self, scene, victim, amount)
	assert(amount);
	HitWidgetEntity.super.init(self, scene);

	local hitWidget = HitWidget:new(amount);
	self:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	self:addComponent(WorldWidget:new(hitWidget));
	self:addComponent(Parent:new(victim));
	self:addComponent(ScriptRunner:new());

	hitWidget:animateIn();
	self:addScript(Script:new(function(self)
		self:wait(0.8);
		hitWidget:animateOut();
		self:wait(0.5);
		self:despawn();
	end));
end

return HitWidgetEntity;
