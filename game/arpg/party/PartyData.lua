require("engine/utils/OOP");
local PartyMemberData = require("arpg/party/PartyMemberData");
local TableUtils = require("engine/utils/TableUtils");

local Party = Class("Party");

-- PUBLIC API

Party.init = function(self)
	self._members = {};
end

Party.addMember = function(self, member)
	assert(not TableUtils.contains(self._members, member));
	table.insert(self._members, member);
end

Party.removeMember = function(self, member)
	assert(TableUtils.contains(self._members, member));
	for i, partyMember in ipairs(self._members) do
		if partyMember == member then
			table.remove(self._members, i);
		end
	end
end

Party.getMembers = function(self)
	return TableUtils.shallowCopy(self._members);
end

Party.toPOD = function(self)
	local pod = {};
	pod.members = {};
	for i, partyMember in ipairs(self._members) do
		table.insert(pod.members, partyMember:toPOD());
	end
	return pod;
end

-- STATIC

Party.fromPOD = function(self, pod)
	local party = Party:new();
	assert(pod.members);
	for i, memberPOD in ipairs(pod.members) do
		local member = PartyMemberData:fromPOD(memberPOD);
		party:addMember(member);
	end
	return party;
end

return Party;
