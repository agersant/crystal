require( "src/utils/OOP" );
local Skill = require( "src/combat/Skill" );
local Actions = require( "src/scene/Actions" );

local ComboAttack = Class( "ComboAttack", Skill );



-- PUBLIC API

ComboAttack.init = function( self, entity )
	ComboAttack.super.init( self, entity );
end

ComboAttack.run = function( self )
	self:thread( function( self)
		while true do
			self:waitFor( "useSkill" );
			local controller = self:getController();
			if controller:isIdle() then
				controller :doAction( Actions.attack );
			end
		end
	end );
end


return ComboAttack;
