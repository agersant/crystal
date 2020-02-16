require("engine/utils/OOP");
local MathUtils = require("engine/utils/MathUtils");

local Actions = Class("Actions");

-- TODO remove this

Actions.knockback = function(angle)
	return function(self)
		local entity = self:getEntity();
		entity:setSpeed(40);
		entity:setDirection8(MathUtils.angleToDir8(angle));
		entity:setAnimation("knockback_" .. entity:getDirection4(), true);
		self:wait(.25);
		entity:setAngle(math.pi + angle);
		Actions.idle(self);
	end
end

return Actions;
