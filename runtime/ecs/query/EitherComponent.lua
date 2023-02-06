local Query = require("ecs/query/Query");
local TableUtils = require("utils/TableUtils");

local EitherComponent = Class("EitherComponent", Query);

EitherComponent.init = function(self, classes)
	EitherComponent.super.init(self, classes);
end

EitherComponent.matches = function(self, entity)
	for _, class in ipairs(self:getClasses()) do
		if TableUtils.countKeys(entity:getComponents(class)) ~= 0 then
			return true;
		end
	end
	return false;
end

return EitherComponent;
