local BaseSaveData = require("engine/persistence/BaseSaveData");
local Persistence = require("engine/persistence/Persistence");

local tests = {};

tests[#tests + 1] = {name = "Starts with blank save"};
tests[#tests].body = function()
	Persistence:init(BaseSaveData);
	assert(Persistence:getSaveData():isInstanceOf(BaseSaveData));
end

tests[#tests + 1] = {name = "Saves and loads data"};
tests[#tests].body = function()

	local foo;

	local SaveData = Class("TestSaveData", BaseSaveData);
	SaveData.toPOD = function(self)
		return {foo = self.foo};
	end;
	SaveData.fromPOD = function(self, pod)
		local saveData = SaveData:new();
		saveData.foo = pod.foo;
		return saveData;
	end;
	SaveData.save = function(self)
		self.foo = foo;
	end;
	SaveData.load = function(self)
		foo = self.foo;
	end;

	Persistence:init(SaveData);

	foo = "bar";
	Persistence:getSaveData():save();
	Persistence:writeToDisk("test.crystal");
	foo = "not bar";
	Persistence:loadFromDisk("test.crystal");
	assert(foo == "not bar");
	Persistence:getSaveData():load();
	assert(foo == "bar");
end

return tests;
