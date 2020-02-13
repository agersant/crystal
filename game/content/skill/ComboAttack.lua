require("engine/utils/OOP");
local DamageIntent = require("arpg/combat/damage/DamageIntent");
local DamageComponent = require("arpg/combat/damage/DamageComponent");
local Skill = require("arpg/combat/skill/Skill");
local Actions = require("engine/mapscene/Actions");

local ComboAttack = Class("ComboAttack", Skill);

local getComboSwingAction = function(swingCount)
	return function(self)
		if swingCount == 1 or swingCount == 3 then
			self:thread(function()
				self:tween(200, 0, 0.20, "inQuadratic", function(speed)
					self:setSpeed(speed);
				end);
			end);
		else
			self:setSpeed(0);
		end

		local damageIntent = DamageIntent:new();
		damageIntent:addComponent(DamageComponent:new(1));
		self:setDamageIntent(damageIntent);

		self:setAnimation("attack_" .. self:getDirection4() .. "_" .. swingCount, true);
		self:waitFor("animationEnd");
	end
end

local performCombo = function(self)
	self:endOn("disrupted");
	self._comboCounter = 0;
	while self:isIdle() do
		self:doAction(getComboSwingAction(self._comboCounter));
		self._comboCounter = self._comboCounter + 1;
		self._didInputNextMove = false;
		local inputWatch = self:thread(function(self)
			self:waitFor("+useSkill");
			self._didInputNextMove = true;
		end);
		self:waitFor("idle");
		if not self:isIdle() then
			break
		end
		if not inputWatch:isDead() then
			inputWatch:stop();
		end
		if not self._didInputNextMove then
			Actions.idle(self);
			break
		end
	end
end

local comboAttackScript = function(self)
	self:thread(function(self)
		while true do
			self:waitFor("+useSkill");
			local comboThread = self:thread(performCombo);
			while not comboThread:isDead() do -- TODO implement self:join(thread)
				self:waitFrame();
			end
		end
	end);
end

ComboAttack.init = function(self, skillSlot)
	ComboAttack.super.init(self, skillSlot, comboAttackScript);
end

return ComboAttack;
