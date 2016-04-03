require( "src/utils/OOP" );
local Script = require( "src/scene/controller/Script" );

local Skill = Class( "Skill", Script );



-- PUBLIC API

Skill.init = function( self, entity )
	Skill.super.init( self, entity, self.run );
	assert( entity );
	self._entity = entity;	
end

Skill.run = function()
end



return Skill;
