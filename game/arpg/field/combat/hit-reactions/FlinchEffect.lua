require("engine/utils/OOP");
local OnHitEffect = require("arpg/field/combat/effects/OnHitEffect");
local Flinch = require("arpg/field/combat/hit-reactions/Flinch");
local FlinchAmounts = require("arpg/field/combat/hit-reactions/FlinchAmounts");

local FlinchEffect = Class("FlinchEffect", OnHitEffect);

FlinchEffect.init = function(self, amount)
	FlinchEffect.super.init(self);
	self._amount = amount or FlinchAmounts.SMALL;
end

FlinchEffect.apply = function(self, attacker, victim, damage)
	local attacker = attacker:getEntity();
	local victim = victim:getEntity();
	local flinch = victim:getComponent(Flinch);
	if flinch then
		flinch:beginFlinch(attacker:getAngle(), self._amount);
	end
end

return FlinchEffect;
