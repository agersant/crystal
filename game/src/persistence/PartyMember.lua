require( "src/utils/OOP" );
local PlayerController = require( "src/scene/controller/PlayerController" );

local PartyMember = Class( "PartyMember" );



-- PUBLIC API

PartyMember.init = function( self, instanceClass )
	self._instanceClass = instanceClass;
end

PartyMember.getInstanceClass = function( self )
	assert( self._instanceClass );
	return self._instanceClass;
end

PartyMember.getAssignedPlayer = function( self )
	return self._assignedPlayer;
end

PartyMember.setAssignedPlayer = function( self, assignedPlayer )
	self._assignedPlayer = assignedPlayer;
end

PartyMember.toPOD = function( self )
	return {
		instanceClass = self:getInstanceClass(),
		assignedPlayer = self:getAssignedPlayer(),
	};
end

PartyMember.spawn = function( self, scene, options )
	assert( type( options ) == "table" );
	local className = self:getInstanceClass();
	local class = Class:getByName( className );
	assert( class );
	
	local entity = scene:spawn( class, options );
	entity:addToParty();
	
	local assignedPlayer = self:getAssignedPlayer();
	if assignedPlayer then
		entity:addController( PlayerController, assignedPlayer );
	end
	
	return entity;
end



-- STATIC

PartyMember.fromPOD = function( self, pod )
	assert( pod.instanceClass );
	local partyMember = PartyMember:new( pod.instanceClass );
	partyMember:setAssignedPlayer( pod.assignedPlayer );
	return partyMember;
end

PartyMember.fromEntity = function( self, entity )
	local className = entity:getClassName();
	local partyMember = PartyMember:new( className );
	partyMember:setAssignedPlayer( entity:getAssignedPlayer() );
	return partyMember;
end


return PartyMember;
