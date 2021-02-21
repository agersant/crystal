require("engine/utils/OOP");
local CombatData = require("arpg/field/combat/CombatData");
local TitleScreen = require("arpg/frontend/TitleScreen");
local PartyMember = require("arpg/persistence/party/PartyMember");
local AllComponents = require("engine/ecs/query/AllComponents");
local System = require("engine/ecs/System");

local GameOverSystem = Class("GameOverSystem", System);

GameOverSystem.init = function(self, ecs)
	GameOverSystem.super.init(self, ecs);
	self._query = AllComponents:new({CombatData, PartyMember});
	self:getECS():addQuery(self._query);
end

GameOverSystem.afterScripts = function(self)
	local entities = self._query:getEntities();
	for entity in pairs(entities) do
		local combatData = entity:getComponent(CombatData);
		if not combatData:isDead() then
			return;
		end
	end
	ENGINE:loadScene(TitleScreen:new());
end

return GameOverSystem;
