require("engine/utils/OOP");
local MapScene = require("engine/scene/MapScene");
local Teams = require("engine/combat/Teams");
local Party = require("arpg/party/Party");
local PartyMember = require("arpg/party/PartyMember");
local PlayerSave = require("engine/persistence/PlayerSave");
local Scene = require("engine/scene/Scene");
local UIScene = require("engine/ui/UIScene");
local TitleScreen = require("engine/ui/frontend/TitleScreen");
local TableUtils = require("engine/utils/TableUtils");
local PlayerController = require("engine/scene/controller/PlayerController");

local Field = Class("Field", MapScene);

-- IMPLEMENTATION

local spawnParty = function(self, x, y)
	local party = PlayerSave:getCurrent():getParty();
	assert(party);
	for i, partyMember in ipairs(party:getMembers()) do
		local className = partyMember:getInstanceClass();
		local class = Class:getByName(className);
		assert(class);
		local entity = class:new(self, {});
		entity:addToParty();
		local assignedPlayer = partyMember:getAssignedPlayer();
		if assignedPlayer then
			entity:addController(PlayerController:new(entity, assignedPlayer));
		end
		entity:setPosition(x, y);
	end
end

-- PUBLIC API

Field.init = function(self, mapName, startX, startY)
	Field.super.init(self, mapName);

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
