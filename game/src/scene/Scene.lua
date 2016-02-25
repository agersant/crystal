require( "src/utils/OOP" );

local Scene = Class( "Scene" );

Scene.init = function( self )
end

Scene.update = function( self )
end

Scene.draw = function( self )
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