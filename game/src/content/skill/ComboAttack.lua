require( "src/utils/OOP" );
local Skill = require( "src/combat/Skill" );
local Actions = require( "src/scene/Actions" );

local ComboAttack = Class( "ComboAttack", Skill );



local incrementCombo = function( self )
	self._comboCounter = self._comboCounter + 1;
	self._didInputNextMove = false;
end

local resetCombo = function( self )
	self._comboCounter = 0;
	self._didInputNextMove = false;
end



-- PUBLIC API

ComboAttack.init = function( self, entity )
	resetCombo( self );
	ComboAttack.super.init( self, entity );
end

ComboAttack.run = function( self )
	
	self:thread( function( self )
		while true do
			self:waitFor( "useSkill" );
			if self._comboCounter > 0 then
				self._didInputNextMove = true;
			end
		end
	end );
	
	self:thread( function( self)
		while true do
			self:waitFor( "useSkill" );
			local controller = self:getController();
			while controller:isIdle() do
				controller:doAction( Actions.attack );
				incrementCombo( self );
				self:waitFor( "idle" );
				assert( controller:isIdle() );
				if not self._didInputNextMove then
					break;
				end
			end
			resetCombo( self );
		end
	end );
end


return ComboAttack;
