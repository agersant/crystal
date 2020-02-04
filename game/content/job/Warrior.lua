require("engine/utils/OOP");
local ComboAttack = require("content/skill/ComboAttack");
local Dash = require("content/skill/Dash");
local Assets = require("engine/resources/Assets");
local Sprite = require("engine/scene/component/Sprite");
local Entity = require("engine/scene/entity/Entity");

local Warrior = Class("Warrior", Entity);

-- PUBLIC API

Warrior.init = function(self, scene)
	Warrior.super.init(self, scene);
	local sheet = Assets:getSpritesheet("assets/spritesheet/duran.lua");
	self:addSprite(Sprite:new(sheet));
	self:addPhysicsBody("dynamic");
	self:addLocomotion();
	self:addCollisionPhysics();
	self:addCombatData();
	self:setCollisionRadius(6);
	self:setUseSpriteHitboxData(true);
	self:addScriptRunner();
	self:addCombatLogic();

	self:addSkill(ComboAttack:new(self));
	self:addSkill(Dash:new(self));
end

return Warrior;
