require( "src/utils/OOP" );
local Teams = require( "src//combat/Teams" );
local Actions = require( "src/scene/Actions" );
local Script = require( "src/scene/Script" );

local CombatLogic = Class( "CombatLogic", Script );


local logic = function( self )
	
	self:thread( function( self )
		local entity = self:getEntity();
		while true do
			local target = self:waitFor( "+giveHit" );
			if Teams:areEnemies( entity:getTeam(), target:getTeam() ) then
				entity:inflictDamageTo( target );
			end
		end
	end );
	
	self:thread( function( self )
		local entity = self:getEntity();
		local controller = self:getController();
		while true do
			local damage = self:waitFor( "takeHit" );
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
	
	local entity = self:getEntity();
	while true do
		self:waitFor( "death" );
		entity:despawn();
	end
	
end


-- PUBLIC API

CombatLogic.init = function( self, entity )
	CombatLogic.super.init( self, entity, logic );
end



return CombatLogic;
