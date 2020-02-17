require("engine/utils/OOP");
local Colors = require("engine/resources/Colors");
local Fonts = require("engine/resources/Fonts");
local Widget = require("engine/ui/Widget");
local Text = require("engine/ui/core/Text");

local Hit = Class("Hit", Widget);

local getScreenPosition = function(self)
	local x, y = self._victim:getPosition();
	local camera = self._field:getCamera();
	return camera:getRelativePosition(x, y);
end

local script = function(self)
	self:wait(2);
	self:remove();
end

Hit.init = function(self, field, victim, amount)
	Hit.super.init(self, script);
	assert(victim);
	assert(victim);
	assert(amount);
	self._field = field;
	self._victim = victim;

	assert(self._victim:isValid());
	self._lastKnownLeft, self._lastKnownTop = getScreenPosition(self);

	self._textWidget = Text:new("fat", 16);
	self._textWidget:setColor(Colors.barbadosCherry);
	self._textWidget:setAlignment("center");
	self._textWidget:setText(amount);
	self:addChild(self._textWidget);
end

Hit.updatePosition = function(self, dt)
	if self._victim:isValid() then
		local x, y = getScreenPosition(self);
		self._localLeft = x;
		self._localTop = y;
		self._lastKnownLeft = x;
		self._lastKnownTop = y;
	else
		self._localLeft = self._lastKnownLeft;
		self._localTop = self._lastKnownTop;
	end
	self._localRight = self._localLeft + 100;
	self._localBottom = self._localTop + 100;
end

return Hit;
