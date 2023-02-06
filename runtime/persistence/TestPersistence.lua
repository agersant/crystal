local BaseSaveData = require("persistence/BaseSaveData");
local Persistence = require("persistence/Persistence");

local tests = {};

tests[#tests + 1] = { name = "Starts with blank save" };
tests[#tests].body = function()
	local persistence = Persistence:new(BaseSaveData);
	assert(persistence:getSaveData():isInstanceOf(BaseSaveData));
end

tests[#tests + 1] = { name = "Saves and loads data" };
tests[#tests].body = function()

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
end

tests[#tests + 1] = { name = "Has global API" };
tests[#tests].body = function()
	assert(PERSISTENCE);
end

return tests;
