require( "src/utils/OOP" );

local Scene = Class( "Scene" );

Scene.init = function( self )
	self._canProcessSignals = true;
end

Scene.update = function( self, dt )
end

Scene.draw = function( self )
end

Scene.canProcessSignals = function( self )
	return self._canProcessSignals;
end



local currentScene = Scene:new();

Scene.getCurrent = function( self )
	return currentScene;
end

Scene.setCurrent = function( self, scene )
	assert( scene );
	currentScene = scene;
end



return Scene;
