require( "src/utils/OOP" );
local Skill = require( "src/scene/combat/Skill" );
local Actions = require( "src/scene/Actions" );

local ComboAttack = Class( "ComboAttack", Skill );


local attack = function( controller )
	controller:endOn( "interruptByDamage" );
	local entity = controller:getEntity();
	entity:setSpeed( 0 );
	entity:setAnimation( "attack_" .. entity:getDirection4(), true );
	controller:waitFor( "animationEnd" );
	Actions.idle( controller );
end


-- PUBLIC API

ComboAttack.init = function( self, entity )
	ComboAttack.super.init( self, entity );	
end

ComboAttack.use = function( self )
	local entity = self:getEntity();
	local controller = entity:getController();
	controller:doAction( attack );
end



return ComboAttack;
