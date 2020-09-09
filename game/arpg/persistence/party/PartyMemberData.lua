require("engine/utils/OOP");
local PartyMember = require("arpg/persistence/party/PartyMember");
local InputListener = require("engine/mapscene/behavior/InputListener");

local PartyMemberData = Class("PartyMemberData");

PartyMemberData.init = function(self, instanceClass)
	self._instanceClass = instanceClass;
end

PartyMemberData.getInstanceClass = function(self)
	assert(self._instanceClass);
	return self._instanceClass;
end

PartyMemberData.getAssignedPlayer = function(self)
	return self._assignedPlayer;
end

PartyMemberData.setAssignedPlayer = function(self, assignedPlayer)
	self._assignedPlayer = assignedPlayer;
end

PartyMemberData.toPOD = function(self)
	return {instanceClass = self:getInstanceClass(), assignedPlayer = self:getAssignedPlayer()};
end

PartyMemberData.fromPOD = function(self, pod)
	assert(pod.instanceClass);
	local partyMemberData = PartyMemberData:new(pod.instanceClass);
	partyMemberData:setAssignedPlayer(pod.assignedPlayer);
	return partyMemberData;
end

PartyMemberData.fromEntity = function(self, entity)
	local className = entity:getClassName();
	assert(entity:getComponent(PartyMember));
	local inputListener = entity:getComponent(InputListener);

	local partyMemberData = PartyMemberData:new(className);
	if inputListener then
		PartyMemberData:setAssignedPlayer(inputListener:getAssignedPlayer());
	end
	return partyMemberData;
end

return PartyMemberData;
