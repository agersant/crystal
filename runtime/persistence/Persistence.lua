local TableUtils = require("utils/TableUtils");
local StringUtils = require("utils/StringUtils");

local Persistence = Class("Persistence");

Persistence.init = function(self, saveDataClass)
	assert(saveDataClass);
	self._saveDataClass = saveDataClass;
	self._saveData = saveDataClass:new();
end

Persistence.getSaveData = function(self)
	return self._saveData;
end

Persistence.writeToDisk = function(self, path)
	local pod = self._saveData:toPOD();
	local fileContent = TableUtils.serialize(pod);
	love.filesystem.write(path, fileContent);
	local fullPath = StringUtils.mergePaths(love.filesystem.getRealDirectory(path), path);
	LOG:info("Saved player save to " .. fullPath);
end

Persistence.loadFromDisk = function(self, path)
	local fileContent = love.filesystem.read(path);
	local pod = TableUtils.unserialize(fileContent);
	local newSaveData = self._saveDataClass:fromPOD(pod);
	local fullPath = StringUtils.mergePaths(love.filesystem.getRealDirectory(path), path);
	LOG:info("Loaded player save from " .. fullPath);
	self._saveData = newSaveData;
end

TERMINAL:addCommand("save fileName:string", function(fileName)
	PERSISTENCE:getSaveData():save(SCENE);
	PERSISTENCE:writeToDisk(fileName);
end);

TERMINAL:addCommand("load fileName:string", function(fileName)
	PERSISTENCE:loadFromDisk(fileName);
	PERSISTENCE:getSaveData():load();
end);

return Persistence;
