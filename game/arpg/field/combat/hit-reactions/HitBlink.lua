require("engine/utils/OOP");
local Component = require("engine/ecs/Component");
local Colors = require("engine/resources/Colors");
local Script = require("engine/script/Script");

local HitBlink = Class("HitBlink", Component);

local script = function(self)
	while true do
		self:waitFor("receivedDamage");
		self:setHighlightColor(Colors.strawberry);
		self:wait(2 * 1 / 60);
		self:setHighlightColor(Colors.cyan);
		self:wait(2 * 1 / 60);
		self:setHighlightColor(nil);
		self:wait(2 * 1 / 60);
		self:waitTween(1, 0, 0.3, "inCubic", function(t)
			local c = Colors.strawberry;
			self:setHighlightColor({c[1] * t, c[2] * t, c[3] * t});
		end);
		self:setHighlightColor(nil);
	end
end

HitBlink.init = function(self)
	HitBlink.super.init(self);
	self._script = Script:new(script);
end

HitBlink.getScript = function(self)
	return self._script;
end

return HitBlink;
