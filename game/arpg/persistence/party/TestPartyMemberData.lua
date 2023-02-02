local PartyMemberData = require("arpg/persistence/party/PartyMemberData");

local tests = {};

tests[#tests + 1] = { name = "Instance class" };
tests[#tests].body = function()
	local original = PartyMemberData:new("Sailor");
	assert(original:getInstanceClass() == "Sailor");
	local copy = PartyMemberData:fromPOD(original:toPOD());
	assert(copy:getInstanceClass() == original:getInstanceClass());
end

tests[#tests + 1] = { name = "Assigned player" };
tests[#tests].body = function()
	local original = PartyMemberData:new("Sailor");
	original:setAssignedPlayer(2);
	assert(original:getAssignedPlayer() == 2);
	local copy = PartyMemberData:fromPOD(original:toPOD());
	assert(copy:getAssignedPlayer() == original:getAssignedPlayer());
end

return tests;
