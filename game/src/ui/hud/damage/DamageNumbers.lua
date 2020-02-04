require("src/utils/OOP");
local Widget = require("src/ui/Widget");
local Hit = require("src/ui/hud/damage/Hit");

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
