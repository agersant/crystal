require("engine/utils/OOP");
local Query = require("engine/ecs/query/Query");

local EitherComponent = Class("EitherComponent", Query);

EitherComponent.init = function(self, classes)
	EitherComponent.super.init(self, classes);
end

EitherComponent.matches = function(self, entity)
	for _, class in ipairs(self:getClasses()) do
		if entity:getComponent(class) then
			return true;
		end
	end
	return false;
end

return EitherComponent;
