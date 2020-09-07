require("engine/utils/OOP");
local Dialog = require("arpg/field/hud/dialog/Dialog");
local Assets = require("engine/resources/Assets");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local Sprite = require("engine/mapscene/display/Sprite");
local Collision = require("engine/mapscene/physics/Collision");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local Entity = require("engine/ecs/Entity");
local Script = require("engine/script/Script");

local NPC = Class("NPC", Entity);

local script = function(self)
	while true do
		local player = self:waitFor("interact");
		if self:beginDialog(player) then
			self:join(self:sayLine(
          							"The harvest this year was meager, there is no spare bread for a stranger like you. If I cannot feed my children, why would I feed you? Extra lines of text to get to line four, come on just a little more."));
			self:join(self:sayLine("Now leave this town before things go awry, please."));
			self:endDialog();
		end
	end
end

-- PUBLIC API

NPC.init = function(self, scene)
	NPC.super.init(self, scene);
	local sheet = Assets:getSpritesheet("arpg/assets/spritesheet/Sahagin.lua");
	self:addComponent(Sprite:new(sheet));
	self:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	self:addComponent(Collision:new(self:getComponent(PhysicsBody), 4));
	self:addComponent(ScriptRunner:new());
	self:addComponent(Dialog:new(scene:getHUD():getDialogBox()));
	self:addScript(Script:new(script));
end

return NPC;
