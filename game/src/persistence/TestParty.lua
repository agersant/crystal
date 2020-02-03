assert(gConf.unitTesting);
local Party = require("src/persistence/Party");
local PartyMember = require("src/persistence/PartyMember");

local tests = {};

tests[#tests + 1] = {name = "Add member"};
tests[#tests].body = function()
	local party = Party:new();
	local member = PartyMember:new("Thief");
	party:addMember(member);
	assert(#party:getMembers() == 1);
	assert(party:getMembers()[1] == member);
end

tests[#tests + 1] = {name = "Remove member"};
tests[#tests].body = function()
	local party = Party:new();
	local member = PartyMember:new("Thief");
	party:addMember(member);
	party:removeMember(member);
	assert(#party:getMembers() == 0);
end

tests[#tests + 1] = {name = "Save and load"};
tests[#tests].body = function()
	local original = Party:new();
	local member = PartyMember:new("Thief");
	original:addMember(member);
	local copy = Party:fromPOD(original:toPOD());
	assert(#copy:getMembers() == 1);
	assert(copy:getMembers()[1]:getInstanceClass() == original:getMembers()[1]:getInstanceClass());
	assert(copy:getMembers()[1]:getAssignedPlayer() == original:getMembers()[1]:getAssignedPlayer());
end

return tests;
