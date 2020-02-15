require("engine/utils/OOP");
local CombatData = require("arpg/combat/CombatData");
local CombatHitbox = require("arpg/combat/damage/DamageHitbox");
local IdleAnimation = require("arpg/field/animation/IdleAnimation");
local MovementControls = require("arpg/field/movement/MovementControls");
local WalkAnimation = require("arpg/field/animation/WalkAnimation");
local ComboAttack = require("content/skill/ComboAttack");
local Dash = require("content/skill/Dash");
local Assets = require("engine/resources/Assets");
local Actor = require("engine/mapscene/behavior/Actor");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local Sprite = require("engine/mapscene/display/Sprite");
local Locomotion = require("engine/mapscene/physics/Locomotion");
local Collision = require("engine/mapscene/physics/Collision");
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
	self:addComponent(CombatData:new());
	self:addComponent(CombatHitbox:new());
	self:addComponent(Weakbox:new());
	self:addComponent(ScriptRunner:new());
	self:addComponent(Actor:new());

	self:addComponent(IdleAnimation:new("idle"));
	self:addComponent(WalkAnimation:new("walk"));

	self:addComponent(MovementControls:new());
	self:addComponent(ComboAttack:new(1));
	self:addComponent(Dash:new(2));

	-- TODO reimplement knockback
end

return Warrior;
