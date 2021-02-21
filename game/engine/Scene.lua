require("engine/utils/OOP");

local Scene = Class("Scene");

Scene.init = function(self)
end

Scene.update = function(self, dt)
end

Scene.draw = function(self)
end

TERMINAL:addCommand("loadScene sceneName:string", function(sceneName)
	local class = Class:getByName(sceneName);
	assert(class);
	assert(class:isInstanceOf(Scene));
	local newScene = class:new();
	ENGINE:loadScene(newScene);
end);

return Scene;
