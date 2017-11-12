require( "src/utils/OOP" );
local Dialog = require( "src/ui/HUD/Dialog" );

local HUD = Class( "HUD" );


HUD.init = function( self )
	self._widgets = {};
	self._dialog = Dialog:new();
	table.insert( self._widgets, self._dialog );
end

HUD.update = function( self, dt )
	for _, widget in ipairs( self._widgets ) do
		widget:update( dt );
	end
end

HUD.draw = function( self )
	for _, widget in ipairs( self._widgets ) do
		widget:draw();
	end
end

HUD.getDialog = function( self )
	return self._dialog;
end



local instance = HUD:new();
return instance;
