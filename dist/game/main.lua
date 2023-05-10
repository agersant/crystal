require("crystal");

crystal.assets.set_directories({ "assets" });

local HelloWorld = Class("HelloWorld", crystal.Scene);

HelloWorld.draw = function(self)
	local width, height = crystal.window.viewport_size();
	local font = crystal.ui.font("crystal_bold_xl");
	love.graphics.setFont(font);
	love.graphics.printf("Hello World", 0, (height - font:getHeight()) / 2, width, "center");
end

crystal.player_start = function()
	crystal.scene.replace(HelloWorld:new());
end
