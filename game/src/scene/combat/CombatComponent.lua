require( "src/utils/OOP" );

local CombatComponent = Class( "CombatComponent" );



-- PUBLIC API

CombatComponent.init = function( self, entity )
	assert( entity );
	self._entity = entity;
end

CombatComponent.receiveDamage = function( self, damage )
	self._entity:signal( "takeHit", damage );
	-- TODO, substract health
end



return CombatComponent;
