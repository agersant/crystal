require( "src/utils/OOP" );
local MathUtils = require( "src/utils/MathUtils" );

local CombatStat = Class( "CombatStat" );



-- PUBLIC API

CombatStat.init = function( self, value, minValue, maxValue )
	self._min = minValue;
	self._max = maxValue;
	self:setValue( value );
end

CombatStat.setValue = function( self, value )
	if self._min and self._max then
		self._value = MathUtils.clamp( self._min, value, self._max );
	elseif self._min then
		self._value = math.max( self._min, value );
	elseif self._max then
		self._value = math.min( self._max, value );
	end
end

CombatStat.getValue = function( self )
	return self._value;
end

CombatStat.substract = function( self, amount )
	self:setValue( self._value - amount );
end

CombatStat.add = function( self, amount )
	self:setValue( self._value + amount );
end


return CombatStat;
