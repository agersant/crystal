require( "src/utils/OOP" );
local Skill = require( "src/combat/Skill" );
local Actions = require( "src/scene/Actions" );

local ComboAttack = Class( "ComboAttack", Skill );



local doComboMove = function( self )
	local controller = self:getController();
	local comboCounter = self._comboCounter;
	controller:doAction( function( self )
		self:endOn( "interruptByDamage" );
		local entity = self:getEntity();
		entity:setSpeed( 0 );
		entity:setAnimation( "attack_" .. entity:getDirection4() .. "_" .. comboCounter, true );
		self:waitFor( "animationEnd" );		
	end );
end



-- PUBLIC API

ComboAttack.init = function( self, entity )
	ComboAttack.super.init( self, entity );
end

ComboAttack.run = function( self )
	
	self:thread( function( self)
		while true do
			local controller = self:getController();
			
			self:waitFor( "useSkill" );
			self._comboCounter = 0;
			
			while controller:isIdle() do
				
				doComboMove( self );
				
				self._comboCounter = self._comboCounter + 1;
				self._didInputNextMove = false;
				
				local inputWatch = self:thread( function( self )
					self:waitFor( "useSkill" );
					self._didInputNextMove = true;
				end );
				
				self:waitFor( "idle" );
				assert( controller:isIdle() );
				
				if not inputWatch:isDead() then
					inputWatch:stop();
				end
				
				if not self._didInputNextMove then
					Actions.idle( controller );
					break;
				end
				
			end
		end
	end );
end


return ComboAttack;
