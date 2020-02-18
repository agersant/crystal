require("engine/utils/OOP");
local AnimationSelectionSystem = require("arpg/field/animation/AnimationSelectionSystem");
local CombatSystem = require("arpg/field/combat/CombatSystem");
local GameOverSystem = require("arpg/field/combat/GameOverSystem");
local SkillSystem = require("arpg/field/combat/skill/SkillSystem");
local InteractionControls = require("arpg/field/controls/InteractionControls");
local MovementControls = require("arpg/field/controls/MovementControls");
local MovementControlsSystem = require("arpg/field/controls/MovementControlsSystem");
local InteractionControlsSystem = require("arpg/field/controls/InteractionControlsSystem");
local Teams = require("arpg/field/combat/Teams");
local DamageNumbersSystem = require("arpg/field/hud/damage/DamageNumbersSystem");
local HUD = require("arpg/field/hud/HUD");
local PartyMember = require("arpg/persistence/party/PartyMember");
local MapScene = require("engine/mapscene/MapScene");
local Persistence = require("engine/persistence/Persistence");
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
			entity:addComponent(MovementControls:new());
			entity:addComponent(InteractionControls:new());
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
	ecs:addSystem(InteractionControlsSystem:new(ecs));
	ecs:addSystem(SkillSystem:new(ecs));
	ecs:addSystem(CombatSystem:new(ecs));
	ecs:addSystem(DamageNumbersSystem:new(ecs));
	ecs:addSystem(GameOverSystem:new(ecs));
end

Field.update = function(self, dt)
	Field.super.update(self, dt);
	self._hud:update(dt);
end

Field.draw = function(self)
	Field.super.draw(self);
	self._hud:draw();
end

Field.getHUD = function(self)
	return self._hud;
end

return Field;
