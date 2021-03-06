require("engine/utils/OOP");

local Teams = Class("Teams");

Teams.party = 0;
Teams.wild = 1;

Teams.isValid = function(self, team)
	return team == Teams.party or team == Teams.wild;
end

Teams.areAllies = function(self, teamA, teamB)
	assert(Teams:isValid(teamA));
	assert(Teams:isValid(teamB));
	return teamA == teamB;
end

Teams.areEnemies = function(self, teamA, teamB)
	assert(Teams:isValid(teamA));
	assert(Teams:isValid(teamB));
	return teamA ~= teamB;
end

return Teams;
