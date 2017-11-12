require( "src/utils/OOP" );
local Scene = require( "src/scene/Scene" );
local Dialog = require( "src/ui/HUD/Dialog" );

local HUD = Class( "HUD", Scene );


HUD.init = function( self )
	HUD.super.init( self );
	self._widgets = {};
	self._dialog = Dialog:new( self );
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
