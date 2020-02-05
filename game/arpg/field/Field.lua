require("engine/utils/OOP");
local MapScene = require("engine/scene/MapScene");
local Teams = require("engine/combat/Teams");
local Party = require("engine/persistence/Party");
local PartyMember = require("engine/persistence/PartyMember");
local Scene = require("engine/scene/Scene");
local UIScene = require("engine/ui/UIScene");
local TitleScreen = require("engine/ui/frontend/TitleScreen");
local TableUtils = require("engine/utils/TableUtils");

local Field = Class("Field", MapScene);

-- IMPLEMENTATION

local spawnParty = function(self, party, x, y)
	assert(party);
	for i, partyMember in ipairs(party:getMembers()) do
		local entity = partyMember:spawn(self, {});
		entity:setPosition(x, y);
	end
end

-- PUBLIC API

Field.init = function(self, mapName, party, partyX, partyY)
	Field.super.init(self, mapName);

	local mapWidth = self._map:getWidthInPixels();
	local mapHeight = self._map:getHeightInPixels();
	self._partyX = partyX or mapWidth / 2;
	self._partyY = partyY or mapHeight / 2;
	spawnParty(self, party, self._partyX, self._partyY);
end

-- PARTY

Field.addEntityToParty = function(self, entity)
	assert(not TableUtils.contains(self._partyEntities, entity));
	table.insert(self._partyEntities, entity);
	self._camera:addTrackedEntity(entity);
	entity:setTeam(Teams.party);
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

-- SAVE

Field.saveTo = function(self, playerSave)
	assert(playerSave);

	local party = Party:new();
	for i, entity in ipairs(self._partyEntities) do
		local partyMember = PartyMember:fromEntity(entity);
		party:addMember(partyMember);
	end
	playerSave:setParty(party);

	assert(#self._partyEntities > 0);
	local partyLeader = self._partyEntities[1];
	local x, y = partyLeader:getPosition();
	playerSave:setLocation(self._mapName, x, y);
end

Field.loadFrom = function(self, playerSave)
	local map, x, y = playerSave:getLocation();
	local party = playerSave:getParty();
	local scene = Field:new(map, party, x, y);
	Scene:setCurrent(scene);
end

return Field;
