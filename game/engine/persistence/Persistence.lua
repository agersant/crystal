require("engine/utils/OOP");
local CLI = require("engine/dev/cli/CLI");
local Log = require("engine/dev/Log");
local TableUtils = require("engine/utils/TableUtils");
local StringUtils = require("engine/utils/StringUtils");

local Persistence = Class("Persistence");

local saveData = nil;

Persistence.init = function(self, saveDataClass)
	assert(saveDataClass);
	self._saveDataClass = saveDataClass;
	saveData = saveDataClass:new();
end

Persistence.getSaveData = function(self)
	return saveData;
end

Persistence.writeToDisk = function(self, path)
	local pod = saveData:toPOD();
	local fileContent = TableUtils.serialize(pod);
	love.filesystem.write(path, fileContent);
	local fullPath = StringUtils.mergePaths(love.filesystem.getRealDirectory(path), path);
	Log:info("Saved player save to " .. fullPath);
end

Persistence.loadFromDisk = function(self, path)
	local fileContent = love.filesystem.read(path);
	local pod = TableUtils.unserialize(fileContent);
	local newSaveData = self._saveDataClass:fromPOD(pod);
	local fullPath = StringUtils.mergePaths(love.filesystem.getRealDirectory(path), path);
	Log:info("Loaded player save from " .. fullPath);
	saveData = newSaveData;
end

CLI:registerCommand("save fileName:string", function(fileName)
	Persistence:getSaveData():save();
	Persistence:writeToDisk(fileName);
end);

CLI:registerCommand("load fileName:string", function(fileName)
	Persistence:loadFromDisk(fileName);
	Persistence:getSaveData():load();
end);

return Persistence;
