require("engine/utils/OOP");
local Assets = require("engine/resources/Assets");
local Controller = require("engine/scene/behavior/Controller");
local ScriptRunner = require("engine/scene/behavior/ScriptRunner");
local Sprite = require("engine/scene/display/Sprite");
local Collision = require("engine/scene/physics/Collision");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");
local Entity = require("engine/ecs/Entity");
local HUD = require("engine/ui/hud/HUD");

local NPC = Class("NPC", Entity);

local script = function(self)
	while true do
		local player = self:waitFor("interact");
		HUD:getDialog():open(self, player);
		HUD:getDialog():say(
						"The harvest this year was meager, there is no spare bread for a stranger like you. If I cannot feed my children, why would I feed you? Extra lines of text to get to line four, come on just a little more.");
		HUD:getDialog():say("Now leave this town before things go awry, please.");
		HUD:getDialog():close();
	end
end

-- PUBLIC API

NPC.init = function(self, scene)
	NPC.super.init(self, scene);
	local sheet = Assets:getSpritesheet("assets/spritesheet/Sahagin.lua");
	self:addComponent(Sprite:new(sheet));
	self:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	self:addComponent(Collision:new(4));
	self:addComponent(ScriptRunner:new());
	self:addComponent(Controller:new(script));
end

return NPC;
