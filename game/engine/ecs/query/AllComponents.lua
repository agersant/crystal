require("engine/utils/OOP");
local Query = require("engine/ecs/query/Query");
local TableUtils = require("engine/utils/TableUtils");

local AllComponents = Class("AllComponents", Query);

AllComponents.init = function(self, classes)
	AllComponents.super.init(self, classes);
end

AllComponents.matches = function(self, entity)
	for _, class in ipairs(self:getClasses()) do
		if TableUtils.countKeys(entity:getComponents(class)) == 0 then
			return false;
		end
	end
	return true;
end

return AllComponents;
