require( "src/utils/OOP" );

local Scene = Class( "Scene" );



-- PUBLIC API

Scene.init = function( self )
end

Scene.update = function( self, dt )
end

Scene.draw = function( self )
end

Scene.saveTo = function( self, playerSave )
end



-- STATIC

local currentScene = Scene:new();

Scene.getCurrent = function( self )
	return currentScene;
end

Scene.setCurrent = function( self, scene )
	assert( scene );
	currentScene = scene;
end



return Scene;
