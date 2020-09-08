require("engine/utils/OOP");
local FlinchAmounts = require("arpg/field/combat/hit-reactions/FlinchAmounts");
local FlinchEffect = require("arpg/field/combat/hit-reactions/FlinchEffect");
local DamageUnit = require("arpg/field/combat/damage/DamageUnit");
local Skill = require("arpg/field/combat/skill/Skill");

local ComboAttack = Class("ComboAttack", Skill);

local getComboSwingAction = function(swingCount)
	return function(self)
		if swingCount == 1 or swingCount == 3 then
			self:tween(200, 0, 0.20, "inQuadratic", function(speed)
				self:setMovementAngle(self:getAngle());
				self:setSpeed(speed);
			end);
		else
			self:setSpeed(0);
		end

		self:resetMultiHitTracking();
		local flinchAmount = swingCount == 3 and FlinchAmounts.LARGE or FlinchAmounts.SMALL;
		local onHitEffects = {FlinchEffect:new(flinchAmount)};
		self:setDamagePayload({DamageUnit:new(1)}, onHitEffects);

		self:join(self:playAnimation("attack_" .. self:getDirection4() .. "_" .. swingCount, true));
	end
end

local performCombo = function(self)
	self:endOn("disrupted");
	local comboCounter = 0;
	while self:isIdle() and comboCounter < 4 do
		local swing = self:doAction(getComboSwingAction(comboCounter));
		comboCounter = comboCounter + 1;
		local didInputNextMove = false;
		local inputWatch = self:thread(function(self)
			self:waitFor("+useSkill");
			didInputNextMove = true;
		end);
		if not self:join(swing) or not self:isIdle() then
			break
		end
		if not inputWatch:isDead() then
			inputWatch:stop();
		end
		if not didInputNextMove then
			break
		end
	end
end

local comboAttackScript = function(self)
	while true do
		self:waitFor("+useSkill");
		local comboThread = self:thread(performCombo);
		local finished = self:join(comboThread);
		if not finished then
			self:stopAction();
		end
	end
end

ComboAttack.init = function(self, skillSlot)
	ComboAttack.super.init(self, skillSlot, comboAttackScript);
end

return ComboAttack;
