require("engine/utils/OOP");
local Query = require("engine/ecs/query/Query");

local AllComponents = Class("AllComponents", Query);

AllComponents.init = function(self, classes)
	AllComponents.super.init(self, classes);
end

AllComponents.matches = function(self, entity)
	for _, class in ipairs(self:getClasses()) do
		if not entity:getComponent(class) then
			return false;
		end
	end
	return true;
end

return AllComponents;
