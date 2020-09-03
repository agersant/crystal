require("engine/utils/OOP");
local CLI = require("engine/dev/cli/CLI");
local Persistence = require("engine/persistence/Persistence");

local Scene = Class("Scene");

Scene.init = function(self)
end

Scene.update = function(self, dt)
end

Scene.draw = function(self)
end

local currentScene = Scene:new();

Scene.getCurrent = function(self)
	return currentScene;
end

Scene.setCurrent = function(self, scene)
	assert(scene);
	currentScene = scene;
end

CLI:registerCommand("loadScene sceneName:string", function(sceneName)
	Persistence:getSaveData():save();
	local class = Class:getByName(sceneName);
	assert(class);
	assert(class:isInstanceOf(Scene));
	local newScene = class:new();
	Scene:setCurrent(newScene);
end);

return Scene;
