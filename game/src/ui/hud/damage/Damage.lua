require( "src/utils/OOP" );
local Widget = require( "src/ui/Widget" );
local Hit = require( "src/ui/hud/damage/Hit" );

local Damage = Class( "Damage", Widget );



Damage.init = function( self )
	Damage.super.init( self );
end

Damage.show = function( self, victim, amount )
	assert( victim );
	assert( amount );
	local hit = Hit:new( victim, amount );
	self:addChild( hit );
end



return Damage;