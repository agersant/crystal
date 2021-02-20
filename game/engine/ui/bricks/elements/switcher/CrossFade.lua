require("engine/utils/OOP");
local SwitcherTransition = require("engine/ui/bricks/elements/switcher/SwitcherTransition");
local MathUtils = require("engine/utils/MathUtils");

local CrossFade = Class("CrossFade", SwitcherTransition);
CrossFade.init = function(self)
	CrossFade.super.init(self, 2);
end

CrossFade.computeDesiredSize = function(self)
	local fromWidth = 0;
	local fromHeight = 0;
	if self._from then
		local joint = self._from:getJoint();
		local childWidth, childHeight = self._from:getDesiredSize();
		fromWidth, fromHeight = joint:computeDesiredSize(childWidth, childHeight);
	end

	local toWidth = 0;
	local toHeight = 0;
	if self._to then
		local joint = self._to:getJoint();
		local childWidth, childHeight = self._to:getDesiredSize();
		toWidth, toHeight = joint:computeDesiredSize(childWidth, childHeight);
	end

	local t = self:getProgress();
	return MathUtils.lerp(t, fromWidth, toWidth), MathUtils.lerp(t, fromHeight, toHeight);
end

CrossFade.draw = function(self, width, height)
	local r, g, b, a = love.graphics.getColor();
	local t = self:getProgress();

	if self._from then
		love.graphics.setColor(r, g, b, a * (1 - t));
		self._from:draw();
	end

	if self._to then
		love.graphics.setColor(r, g, b, a * t);
		self._to:draw();
	end
end

return CrossFade;
