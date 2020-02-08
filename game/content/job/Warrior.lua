require("engine/utils/OOP");
local ComboAttack = require("content/skill/ComboAttack");
local Dash = require("content/skill/Dash");
local Assets = require("engine/resources/Assets");
local ScriptRunner = require("engine/scene/behavior/ScriptRunner");
local Renderer = require("engine/scene/display/Renderer");
local Sprite = require("engine/scene/display/Sprite");
local Locomotion = require("engine/scene/physics/Locomotion");
local Collision = require("engine/scene/physics/Collision");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");
local Entity = require("engine/ecs/Entity");

local Warrior = Class("Warrior", Entity);

-- PUBLIC API

Warrior.init = function(self, scene)
	Warrior.super.init(self, scene);
	local sheet = Assets:getSpritesheet("assets/spritesheet/duran.lua");
	self:addComponent(Renderer:new());
	self:addComponent(Sprite:new(sheet));
	self:addComponent(Locomotion:new());
	self:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	self:addComponent(Collision:new(6));
	-- self:addCombatData(); TODO
	self:setUseSpriteHitboxData(true);
	self:addComponent(ScriptRunner:new());
	-- self:addCombatLogic(); TODO

	-- self:addSkill(ComboAttack:new(self)); TODO
	-- self:addSkill(Dash:new(self)); TODO
end

return Warrior;
