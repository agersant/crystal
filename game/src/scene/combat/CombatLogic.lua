require( "src/utils/OOP" );
local Actions = require( "src/scene/Actions" );



local CombatLogic = Class( "CombatLogic" );



-- PUBLIC API

CombatLogic.init = function( self, controller )
	
	assert( controller );
	self._controller = controller;
	
	controller:thread( function( controller )
		local entity = controller:getEntity();
		while true do
			local target = controller:waitFor( "giveHit" );
			-- TODO make a proper damage class with more info than just attacker
			target:receiveDamage( { attacker = entity } );
		end
	end );
	
	controller:thread( function( controller )
		local entity = controller:getEntity();
		while true do
			local damage = controller:waitFor( "takeHit" );
			entity:signal( "interruptByDamage" );
			if controller:isIdle() then
				local attackerX, attackerY = damage.attacker:getPosition();
				local x, y = entity:getPosition();
				local xFromAttacker = x - attackerX;
				local yFromAttacker = y - attackerY;
				local angleFromAttacker = math.atan2( yFromAttacker, xFromAttacker );
				controller:doAction( Actions.knockback( angleFromAttacker ) );
			end
		end
	end );
	
end



return CombatLogic;
