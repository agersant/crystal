local CLI = require("engine/dev/cli/CLI");
local PlayerSave = require("engine/persistence/PlayerSave");
local MapScene = require("engine/scene/MapScene");
local Scene = require("engine/scene/Scene");

local save = function(fileName)
	local playerSave = PlayerSave:getCurrent();
	local scene = Scene:getCurrent();
	scene:saveTo(playerSave);
	playerSave:writeToDisk(fileName);
end

CLI:addCommand("save fileName:string", save);

local load = function(fileName)
	local playerSave = PlayerSave:loadFromDisk(fileName);
	PlayerSave:setCurrent(playerSave);
	MapScene:loadFrom(playerSave);
end

CLI:addCommand("load fileName:string", load);
