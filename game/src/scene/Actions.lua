require( "src/utils/OOP" );
local MathUtils = require( "src/utils/MathUtils" );



local Actions = Class( "Actions" );



Actions.idle = function( self )
	local entity = self:getEntity();
	local animName = "idle_" .. entity:getDirection4();
	entity:setAnimation( animName );
	entity:setSpeed( 0 );
end

Actions.walk = function( self )
	local entity = self:getEntity();
	local animName = "walk_" .. entity:getDirection4();
	entity:setAnimation( animName );
	entity:setSpeed( 144 );
end

Actions.attack = function( self )
	self:endOn( "interruptByDamage" );
	local entity = self:getEntity();
	entity:setSpeed( 0 );
	entity:setAnimation( "attack_" .. entity:getDirection4(), true );
	self:waitFor( "animationEnd" );
end

Actions.knockback = function( angle )
	return function( self )
		local entity = self:getEntity();
		entity:setSpeed( 160 );
		entity:setDirection8( MathUtils.angleToDir8( angle ) );
		entity:setAnimation( "knockback_" .. entity:getDirection4(), true );
		self:wait( .25 );
	end
end



return Actions;
