require( "src/utils/OOP" );
local Actions = require( "src/scene/Actions" );
local Teams = require( "src/scene/combat/Teams" );

local CombatLogic = Class( "CombatLogic" );



-- PUBLIC API

CombatLogic.init = function( self, controller )
	
	assert( controller );
	self._controller = controller;
	
	controller:thread( function( controller )
		local entity = controller:getEntity();
		while true do
			local target = controller:waitFor( "+giveHit" );
			if Teams:areEnemies( entity:getTeam(), target:getTeam() ) then
				entity:inflictDamageTo( target );
			end
		end
	end );
	
	controller:thread( function( controller )
		local entity = controller:getEntity();
		while true do
			local damage = controller:waitFor( "takeHit" );
			entity:signal( "interruptByDamage" );
			if controller:isIdle() then
				local attacker = damage:getOrigin();
				local attackerX, attackerY = attacker:getPosition();
				local x, y = entity:getPosition();
				local xFromAttacker = x - attackerX;
				local yFromAttacker = y - attackerY;
				local angleFromAttacker = math.atan2( yFromAttacker, xFromAttacker );
				controller:doAction( Actions.knockback( angleFromAttacker ) );
			end
		end
	end );
	
	controller:thread( function( controller )
		local entity = controller:getEntity();
		while true do
			controller:waitFor( "death" );
			entity:despawn();
		end
	end );
	
end



return CombatLogic;
