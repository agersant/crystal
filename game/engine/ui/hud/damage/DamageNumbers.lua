require("engine/utils/OOP");
local Widget = require("engine/ui/Widget");
local Hit = require("engine/ui/hud/damage/Hit");

local DamageNumbers = Class("DamageNumbers", Widget);

DamageNumbers.init = function(self)
	DamageNumbers.super.init(self);
end

DamageNumbers.show = function(self, victim, amount)
	assert(victim);
	assert(amount);
	local hit = Hit:new(victim, amount);
	self:addChild(hit);
end

return DamageNumbers;
