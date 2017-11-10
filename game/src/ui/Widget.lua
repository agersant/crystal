require( "src/utils/OOP" );
local Script = require( "src/scene/Script" );

local Widget = Class( "Widget", Script );


Widget.init = function( self, scene, scriptFunction )
	Widget.super.init( self, scene, scriptFunction );
	self._children = {};
end

Widget.update = function( self, dt )
	Widget.super.update( self, dt );
	for _, child in ipairs( self._children ) do
		child:update( dt );
	end
end

Widget.draw = function( self )
	for _, child in ipairs( self._children ) do
		child:draw();
	end
end



return Widget;
