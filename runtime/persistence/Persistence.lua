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
	crystal.log.info("Saved player save to " .. fullPath);
end

Persistence.loadFromDisk = function(self, path)
	local fileContent = love.filesystem.read(path);
	local pod = TableUtils.unserialize(fileContent);
	local newSaveData = self._saveDataClass:fromPOD(pod);
	local fullPath = StringUtils.mergePaths(love.filesystem.getRealDirectory(path), path);
	crystal.log.info("Loaded player save from " .. fullPath);
	self._saveData = newSaveData;
end

crystal.cmd.add("save fileName:string", function(fileName)
	PERSISTENCE:getSaveData():save(SCENE);
	PERSISTENCE:writeToDisk(fileName);
end);

crystal.cmd.add("load fileName:string", function(fileName)
	PERSISTENCE:loadFromDisk(fileName);
	PERSISTENCE:getSaveData():load();
end);

--#region Tests

local BaseSaveData = require("persistence/BaseSaveData");

crystal.test.add("Starts with blank save", function()
	local persistence = Persistence:new(BaseSaveData);
	assert(persistence:getSaveData():is_instance_of(BaseSaveData));
end);

crystal.test.add("Saves and loads data", function()
	local foo;

	local SaveData = Class("TestSaveData", BaseSaveData);
	SaveData.toPOD = function(self)
		return { foo = self.foo };
	end;
	SaveData.fromPOD = function(self, pod)
		local saveData = SaveData:new();
		saveData.foo = pod.foo;
		return saveData;
	end;
	SaveData.save = function(self, scene)
		self.foo = foo;
	end;
	SaveData.load = function(self)
		foo = self.foo;
	end;

	local persistence = Persistence:new(SaveData);

	foo = "bar";
	persistence:getSaveData():save(nil);
	persistence:writeToDisk("test.crystal");
	foo = "not bar";
	persistence:loadFromDisk("test.crystal");
	assert(foo == "not bar");
	persistence:getSaveData():load();
	assert(foo == "bar");
end);

crystal.test.add("Has global API", function()
	assert(PERSISTENCE);
end);

--#endregion

return Persistence;
