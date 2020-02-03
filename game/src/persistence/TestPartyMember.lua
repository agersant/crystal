local PartyMember = require("src/persistence/PartyMember");

local tests = {};

tests[#tests + 1] = {name = "Instance class"};
tests[#tests].body = function()
	local original = PartyMember:new("Sailor");
	assert(original:getInstanceClass() == "Sailor");
	local copy = PartyMember:fromPOD(original:toPOD());
	assert(copy:getInstanceClass() == original:getInstanceClass());
end

tests[#tests + 1] = {name = "Assigned player"};
tests[#tests].body = function()
	local original = PartyMember:new("Sailor");
	original:setAssignedPlayer(2);
	assert(original:getAssignedPlayer() == 2);
	local copy = PartyMember:fromPOD(original:toPOD());
	assert(copy:getAssignedPlayer() == original:getAssignedPlayer());
end

return tests;
