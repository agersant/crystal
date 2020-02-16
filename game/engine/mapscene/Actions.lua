require("engine/utils/OOP");
local MathUtils = require("engine/utils/MathUtils");

local Actions = Class("Actions");

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

Actions.death = function(self)
	local entity = self:getEntity();
	entity:setSpeed(0);
	entity:setAnimation("death");
	self:waitFor("animationEnd");
	local scene = entity:getScene();
	scene:checkLoseCondition();
	while true do
		self:wait(1);
	end
end

return Actions;
