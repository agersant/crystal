require("engine/utils/OOP");
local ComboAttack = require("content/skill/ComboAttack");
local Dash = require("content/skill/Dash");
local Assets = require("engine/resources/Assets");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local Sprite = require("engine/mapscene/display/Sprite");
local Locomotion = require("engine/mapscene/physics/Locomotion");
local Collision = require("engine/mapscene/physics/Collision");
local Hitbox = require("engine/mapscene/physics/Hitbox");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local Weakbox = require("engine/mapscene/physics/Weakbox");
local Entity = require("engine/ecs/Entity");

local Warrior = Class("Warrior", Entity);

-- PUBLIC API

Warrior.init = function(self, scene)
	Warrior.super.init(self, scene);
	local sheet = Assets:getSpritesheet("assets/spritesheet/duran.lua");
	self:addComponent(Sprite:new(sheet));
	self:addComponent(Locomotion:new());
	self:addComponent(PhysicsBody:new(scene:getPhysicsWorld(), "dynamic"));
	self:addComponent(Collision:new(6));
	-- self:addCombatData(); TODO
	self:addComponent(Hitbox:new());
	self:addComponent(Weakbox:new());
	self:addComponent(ScriptRunner:new());
	-- self:addCombatLogic(); TODO

	self:addComponent(ComboAttack:new(1));
	self:addComponent(Dash:new(2));
end

return Warrior;
