local CLI = require("engine/dev/cli/CLI");
local Persistence = require("engine/persistence/Persistence");

local save = function(fileName)
	Persistence:getSaveData():save();
	Persistence:writeToDisk(fileName);
end

CLI:addCommand("save fileName:string", save);

local load = function(fileName)
	Persistence:loadFromDisk(fileName);
	Persistence:getSaveData():load();
end

CLI:addCommand("load fileName:string", load);
