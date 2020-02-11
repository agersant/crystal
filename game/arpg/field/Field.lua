require("engine/utils/OOP");
local MapScene = require("engine/mapscene/MapScene");
local SkillSystem = require("arpg/combat/SkillSystem");
local TargetSelector = require("arpg/combat/ai/TargetSelector");
local Persistence = require("engine/persistence/Persistence");
local Scene = require("engine/Scene");
local UIScene = require("engine/ui/UIScene");
local TitleScreen = require("engine/ui/frontend/TitleScreen");
local TableUtils = require("engine/utils/TableUtils");
local InputListener = require("engine/mapscene/behavior/InputListener");
local PlayerController = require("engine/mapscene/behavior/PlayerController");

local Field = Class("Field", MapScene);

-- IMPLEMENTATION

local spawnParty = function(self, x, y)
	local party = Persistence:getSaveData():getParty();
	assert(party);
	for i, partyMember in ipairs(party:getMembers()) do
		local className = partyMember:getInstanceClass();
		local class = Class:getByName(className);
		assert(class);
		local entity = self:spawn(class, {});
		entity:addToParty();
		local assignedPlayer = partyMember:getAssignedPlayer();
		if assignedPlayer then
			entity:addComponent(InputListener:new(assignedPlayer));
			entity:addComponent(PlayerController:new());
		end
		entity:setPosition(x, y);
	end
end

-- PUBLIC API

Field.init = function(self, mapName, startX, startY)
	self._targetSelector = TargetSelector:new({}); -- TODO remove
	self._partyEntities = {}; -- TODO remove

	Field.super.init(self, mapName);

	local ecs = self:getECS();

	ecs:addSystem(SkillSystem:new(ecs));

	local mapWidth = self._map:getWidthInPixels();
	local mapHeight = self._map:getHeightInPixels();
	startX = startX or mapWidth / 2;
	startY = startY or mapHeight / 2;
	spawnParty(self, startX, startY);
end

-- PARTY

Field.addEntityToParty = function(self, entity)
	assert(not TableUtils.contains(self._partyEntities, entity));
	table.insert(self._partyEntities, entity);
	self._camera:addTrackedEntity(entity);
	-- entity:setTeam(Teams.party); TODO
end

Field.removeEntityFromParty = function(self, entity)
	assert(TableUtils.contains(self._partyEntities, entity));
	for i, partyEntity in ipairs(self._partyEntities) do
		if entity == partyEntity then
			table.remove(self._partyEntities, i);
			return;
		end
	end
	self._camera:removeTrackedEntity(entity);
end

Field.getPartyMemberEntities = function(self)
	return TableUtils.shallowCopy(self._partyEntities);
end

Field.checkLoseCondition = function(self)
	for _, partyEntity in ipairs(self._partyEntities) do
		if not partyEntity:isDead() then
			return;
		end
	end
	Scene:setCurrent(UIScene:new(TitleScreen:new()));
end

Field.getTargetSelector = function(self)
	return self._targetSelector;
end

return Field;
