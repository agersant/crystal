require( "src/utils/OOP" );

local Skill = Class( "Skill" );



-- PUBLIC API

Skill.init = function( self, entity )
	assert( entity );
	self._entity = entity;
end

Skill.getEntity = function( self )
	return self._entity;
end

Skill.setup = function( self )
end

Skill.cleanup = function( self )
end

Skill.use = function( self )
end



return Skill;
