require( "src/utils/OOP" );
local Teams = require( "src//combat/Teams" );
local Actions = require( "src/scene/Actions" );
local Script = require( "src/scene/Script" );

local CombatLogic = Class( "CombatLogic", Script );


local logic = function( self )

	self:thread( function( self )
		while true do
			local target = self:waitFor( "+giveHit" );
			if Teams:areEnemies( self._entity:getTeam(), target:getTeam() ) then
				self._entity:inflictDamageTo( target );
			end
		end
	end );

	self:thread( function( self )
		local controller = self._entity:getController();
		while true do
			local damage = self:waitFor( "takeHit" );
			self._entity:signal( "interruptByDamage" );
			if controller:isIdle() then
				local attacker = damage:getOrigin();
				local attackerX, attackerY = attacker:getPosition();
				local x, y = self._entity:getPosition();
				local xFromAttacker = x - attackerX;
				local yFromAttacker = y - attackerY;
				local angleFromAttacker = math.atan2( yFromAttacker, xFromAttacker );
				controller:doAction( Actions.knockback( angleFromAttacker ) );
			end
		end
	end );

	while true do
		self:waitFor( "death" );
		self._entity:despawn();
	end

end


-- PUBLIC API

CombatLogic.init = function( self, entity )
	assert( entity );
	self._entity = entity;
	CombatLogic.super.init( self, entity:getScene(), logic );
end



return CombatLogic;
