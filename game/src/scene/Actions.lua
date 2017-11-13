require( "src/utils/OOP" );
local MathUtils = require( "src/utils/MathUtils" );

local Actions = Class( "Actions" );



Actions.idle = function( self )
	local entity = self:getEntity();
	local animName = "idle_" .. entity:getDirection4();
	entity:setAnimation( animName );
	entity:setSpeed( 0 );
end

Actions.lookAt = function( target )
	return function( self )
		local entity = self:getEntity();
		local x, y = entity:getPosition();
		local targetX, targetY = target:getPosition();
		local deltaX, deltaY = targetX - x, targetY - y;
		local angle = math.atan2( deltaY, deltaX );
		entity:setAngle( angle );
	end
end

Actions.walk = function( angle )
	return function( self )
		local entity = self:getEntity();
		entity:setAngle( angle );
		local animName = "walk_" .. entity:getDirection4();
		entity:setAnimation( animName );
		entity:setSpeed( entity:getMovementSpeed() );
	end
end

Actions.attack = function( self )
	self:endOn( "interruptByDamage" );
	local entity = self:getEntity();
	entity:setSpeed( 0 );
	entity:setAnimation( "attack_" .. entity:getDirection4(), true );
	self:waitFor( "animationEnd" );
	Actions.idle( self );
end

Actions.knockback = function( angle )
	return function( self )
		local entity = self:getEntity();
		entity:setSpeed( 40 );
		entity:setDirection8( MathUtils.angleToDir8( angle ) );
		entity:setAnimation( "knockback_" .. entity:getDirection4(), true );
		self:wait( .25 );
		entity:setAngle( math.pi + angle );
		Actions.idle( self );
	end
end

Actions.death = function( self )
	local entity = self:getEntity();
	entity:setSpeed( 0 );
	entity:setAnimation( "death" );
	self:waitFor( "animationEnd" );
	local scene = entity:getScene();
	scene:checkLoseCondition();
	while true do
		self:wait( 1 );
	end
end


return Actions;
