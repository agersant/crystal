require("engine/utils/OOP");
local Field = require("arpg/field/Field");
local PartyData = require("arpg/party/PartyData");
local PartyMember = require("arpg/party/PartyMember");
local PartyMemberData = require("arpg/party/PartyMemberData");
local BaseSaveData = require("engine/persistence/BaseSaveData");
local Scene = require("engine/Scene");

local SaveData = Class("SaveData", BaseSaveData);

SaveData.init = function(self)
	SaveData.super.init(self);

	self._party = PartyData:new();
	local defaultPartyMember = PartyMemberData:new("Warrior");
	defaultPartyMember:setAssignedPlayer(1);
	self._party:addMember(defaultPartyMember);

	self._location = {};
	self:setLocation("nowhere", 0, 0);
end

SaveData.toPOD = function(self)
	return {party = self._party:toPOD(), location = self._location};
end

SaveData.getParty = function(self)
	return self._party;
end

SaveData.setParty = function(self, party)
	assert(party);
	self._party = party;
end

SaveData.getLocation = function(self)
	local location = self._location;
	return location.map, location.x, location.y;
end

SaveData.setLocation = function(self, map, x, y)
	assert(type(map) == "string");
	assert(type(x) == "number");
	assert(type(y) == "number");
	self._location.map = map;
	self._location.x = x;
	self._location.y = y;
end

SaveData.save = function(self)
	SaveData.super.save(self);

	local field = Scene:getCurrent();
	if field:isInstanceOf(Field) then
		local partyEntities = field:getECS():getAllEntitiesWith(PartyMember);

		local partyLeader;
		local partyLeaderPlayerIndex;

		local party = PartyData:new();
		for entity in pairs(partyEntities) do
			local partyMemberData = PartyMemberData:fromEntity(entity);
			party:addMember(partyMemberData);
			local playerIndex = partyMemberData:getAssignedPlayer();
			if not partyLeader then
				if playerIndex and (not partyLeader or playerIndex < partyLeaderPlayerIndex) then
					partyLeader = entity;
					partyLeaderPlayerIndex = playerIndex;
				end
			end
		end
		self:setParty(party);

		assert(partyLeader);
		local x, y = partyLeader:getPosition();
		assert(x);
		assert(y);
		self:setLocation(field:getMapName(), x, y);
	end
end

SaveData.load = function(self)
	SaveData.super.load(self);
	local map, x, y = self:getLocation();
	local scene = Field:new(map, x, y);
	Scene:setCurrent(scene);
end

-- STATIC

SaveData.fromPOD = function(self, pod)
	local playerSave = SaveData:new();
	assert(pod.party);
	playerSave._party = PartyData:fromPOD(pod.party);
	assert(pod.location);
	playerSave._location = pod.location;
	return playerSave;
end

return SaveData;
