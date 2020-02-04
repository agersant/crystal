require("engine/utils/OOP");
local Assets = require("engine/resources/Assets");
local Actions = require("engine/scene/Actions");
local Script = require("engine/scene/Script");
local Controller = require("engine/scene/component/Controller");
local Sprite = require("engine/scene/component/Sprite");
local Entity = require("engine/scene/entity/Entity");
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
	self:addSprite(Sprite:new(sheet));
	self:addPhysicsBody("static");
	self:addCollisionPhysics();
	self:setCollisionRadius(4);
	self:addScriptRunner();
	self:addController(Controller:new(self, script));
end

return NPC;
