require("engine/utils/OOP");
local ComboAttack = require("content/skill/ComboAttack");
local Dash = require("content/skill/Dash");
local Assets = require("engine/resources/Assets");
local ScriptRunner = require("engine/scene/behavior/ScriptRunner");
local Sprite = require("engine/scene/display/Sprite");
local Locomotion = require("engine/scene/physics/Locomotion");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");
local Entity = require("engine/ecs/Entity");

local Warrior = Class("Warrior", Entity);

-- PUBLIC API

Warrior.init = function(self, scene)
	Warrior.super.init(self, scene);
	local sheet = Assets:getSpritesheet("assets/spritesheet/duran.lua");
	self:addComponent(Sprite:new(scene, sheet));
	self:addComponent(Locomotion:new(scene));
	self:addComponent(PhysicsBody:new(scene, "dynamic"));
	self:addCollisionPhysics();
	-- self:addCombatData(); TODO
	self:setCollisionRadius(6);
	self:setUseSpriteHitboxData(true);
	self:addComponent(ScriptRunner:new(scene));
	-- self:addCombatLogic(); TODO

	-- self:addSkill(ComboAttack:new(self)); TODO
	-- self:addSkill(Dash:new(self)); TODO
end

return Warrior;
