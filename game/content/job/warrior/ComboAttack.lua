require("engine/utils/OOP");
local DamageIntent = require("arpg/combat/damage/DamageIntent");
local DamageUnit = require("arpg/combat/damage/DamageUnit");
local Skill = require("arpg/combat/skill/Skill");

local ComboAttack = Class("ComboAttack", Skill);

local getComboSwingAction = function(swingCount)
	return function(self)
		if swingCount == 1 or swingCount == 3 then
			self:thread(function()
				self:tween(200, 0, 0.20, "inQuadratic", function(speed)
					self:setMovementAngle(self:getAngle());
					self:setSpeed(speed);
				end);
			end);
		else
			self:setSpeed(0);
		end

		local damageIntent = DamageIntent:new();
		damageIntent:setUnits({DamageUnit:new(1)});
		self:setDamageIntent(damageIntent);

		self:setAnimation("attack_" .. self:getDirection4() .. "_" .. swingCount, true);
		self:waitFor("animationEnd");
	end
end

local performCombo = function(self)
	self:endOn("disrupted");
	self._comboCounter = 0;
	while self:isIdle() and self._comboCounter < 4 do
		local swing = self:doAction(getComboSwingAction(self._comboCounter));
		self._comboCounter = self._comboCounter + 1;
		self._didInputNextMove = false;
		local inputWatch = self:thread(function(self)
			self:waitFor("+useSkill");
			self._didInputNextMove = true;
		end);
		if not self:join(swing) or not self:isIdle() then
			break
		end
		if not inputWatch:isDead() then
			inputWatch:stop();
		end
		if not self._didInputNextMove then
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
