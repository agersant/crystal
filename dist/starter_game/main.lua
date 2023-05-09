require("crystal");

crystal.assets.set_directories({ "assets" });

local HelloWorld = Class("HelloWorld", crystal.Scene);

HelloWorld.draw = function(self)
	love.graphics.print("Hello World");
end

crystal.player_start = function()
	crystal.scene.replace(HelloWorld:new());
end
