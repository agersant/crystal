require("engine/utils/OOP");
local Log = require("engine/dev/Log");
local TableUtils = require("engine/utils/TableUtils");
local Module = require("engine/Module");

local Persistence = Class("Persistence");

-- IMPLEMENTATION

local getSaveDataClass = function(self)
	return Module:getCurrent().classes.SaveData;
end

-- STATIC

local saveData = nil;

Persistence.init = function(self)
	saveData = getSaveDataClass(self):new();
end

Persistence.getSaveData = function(self)
	return saveData;
end

Persistence.writeToDisk = function(self, path)
	local pod = saveData:toPOD();
	local fileContent = TableUtils.serialize(pod);
	love.filesystem.write(path, fileContent);
	local fullPath = love.filesystem.getRealDirectory(path) .. "/" .. path;
	Log:info("Saved player save to " .. fullPath);
end

Persistence.loadFromDisk = function(self, path)
	local fileContent = love.filesystem.read(path);
	local pod = TableUtils.unserialize(fileContent);
	local newSaveData = getSaveDataClass(self):fromPOD(pod);
	local fullPath = love.filesystem.getRealDirectory(path) .. "/" .. path;
	Log:info("Loaded player save from " .. fullPath);
	saveData = newSaveData;
end

return Persistence;
