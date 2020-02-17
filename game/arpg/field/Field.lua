require("engine/utils/OOP");
local CombatSystem = require("arpg/combat/CombatSystem");
local SkillSystem = require("arpg/combat/skill/SkillSystem");
local Teams = require("arpg/combat/Teams");
local AnimationSelectionSystem = require("arpg/field/animation/AnimationSelectionSystem");
local MovementControlsSystem = require("arpg/field/movement/MovementControlsSystem");
local PartyMember = require("arpg/party/PartyMember");
local TitleScreen = require("arpg/ui/frontend/TitleScreen");
local HUD = require("arpg/ui/hud/HUD");
local MapScene = require("engine/mapscene/MapScene");
local Persistence = require("engine/persistence/Persistence");
local Scene = require("engine/Scene");
local UIScene = require("engine/ui/UIScene");
local InputListener = require("engine/mapscene/behavior/InputListener");

local Field = Class("Field", MapScene);

local spawnParty = function(self, x, y, startAngle)
	local partyData = Persistence:getSaveData():getParty();
	assert(partyData);
	for i, partyMemberData in ipairs(partyData:getMembers()) do
		local assignedPlayerIndex = partyMemberData:getAssignedPlayer();
		local className = partyMemberData:getInstanceClass();
		local class = Class:getByName(className);
		assert(class);

		local entity = self:spawn(class, {});
		entity:addComponent(PartyMember:new());
		if assignedPlayerIndex then
			entity:addComponent(InputListener:new(assignedPlayerIndex));
		end
		entity:setTeam(Teams.party);
		entity:setPosition(x, y);
		entity:setAngle(startAngle);
	end
end

Field.init = function(self, mapName, startX, startY, startAngle)
	self._hud = HUD:new(self);

	Field.super.init(self, mapName);

	local mapWidth = self._map:getWidthInPixels();
	local mapHeight = self._map:getHeightInPixels();
	startX = startX or mapWidth / 2;
	startY = startY or mapHeight / 2;
	startAngle = startAngle or 0;
	spawnParty(self, startX, startY, startAngle);
end

Field.addSystems = function(self)
	Field.super.addSystems(self);
	local ecs = self:getECS();
	ecs:addSystem(AnimationSelectionSystem:new(ecs));
	ecs:addSystem(MovementControlsSystem:new(ecs));
	ecs:addSystem(SkillSystem:new(ecs));
	ecs:addSystem(CombatSystem:new(ecs));
end

Field.update = function(self, dt)
	Field.super.update(self, dt);
	self._hud:update(dt);
end

Field.draw = function(self)
	Field.super.draw(self);
	self._hud:draw();
end

Field.checkLoseCondition = function(self) -- TODO
	for _, partyEntity in ipairs(self._partyEntities) do
		if not partyEntity:isDead() then
			return;
		end
	end
	Scene:setCurrent(UIScene:new(TitleScreen:new()));
end

return Field;
