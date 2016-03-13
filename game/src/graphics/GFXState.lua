require( "src/utils/OOP" );

local GFXState = Class( "GFXState" );



-- PUBLIC API

GFXState.init = function( self )
	self._scaleX = 1;
	self._scaleY = 1;
end

GFXState.getScaleX = function( self )
	return self._scaleX;
end

GFXState.getScaleY = function( self )
	return self._scaleY;
end

GFXState.applyScaleX = function( self, scaleX )
	self._scaleX = self._scaleX * scaleX;
end

GFXState.applyScaleY = function( self, scaleY )
	self._scaleY = self._scaleY * scaleY;
end

GFXState.setScaleX = function( self, scaleX )
	self._scaleX = scaleX;
end

GFXState.setScaleY = function( self, scaleY )
	self._scaleY = scaleY;
end

GFXState.clone = function( self )
	local cloned = GFXState:new();
	cloned._scaleX = self._scaleX;
	cloned._scaleY = self._scaleY;
	return cloned;
end



return GFXState;
