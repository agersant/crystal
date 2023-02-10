local SwitcherTransition = require("ui/bricks/elements/switcher/SwitcherTransition");

local CrossFade = Class("CrossFade", SwitcherTransition);
CrossFade.init = function(self)
	CrossFade.super.init(self, 2);
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
