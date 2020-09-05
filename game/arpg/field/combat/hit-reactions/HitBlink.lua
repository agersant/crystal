require("engine/utils/OOP");
local Behavior = require("engine/mapscene/behavior/Behavior");
local Colors = require("engine/resources/Colors");

local HitBlink = Class("HitBlink", Behavior);

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
	HitBlink.super.init(self, script);
end

return HitBlink;
