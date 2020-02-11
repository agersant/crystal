require("engine/utils/OOP");
local Teams = require("engine/combat/Teams");
local Actions = require("engine/scene/Actions");
local Script = require("engine/script/Script");
local HUD = require("engine/ui/hud/HUD");

local CombatLogic = Class("CombatLogic", Script);

local logic = function(self)

	self:thread(function(self)
		while true do
			local target = self:waitFor("+giveHit");
			if Teams:areEnemies(self._entity:getTeam(), target:getTeam()) then
				if not self._entity:isDead() then
					self._entity:inflictDamageTo(target);
				end
			end
		end
	end);

	self:thread(function(self)
		local controller = self._entity:getController();
		while true do
			local damage, damageAmount = self:waitFor("takeHit");
			assert(damageAmount);
			HUD:showDamage(self._entity, damageAmount);
			self._entity:signal("interruptByDamage");
			if controller:isIdle() then
				local attacker = damage:getOrigin();
				local attackerX, attackerY = attacker:getPosition();
				local x, y = self._entity:getPosition();
				local xFromAttacker = x - attackerX;
				local yFromAttacker = y - attackerY;
				local angleFromAttacker = math.atan2(yFromAttacker, xFromAttacker);
				controller:doAction(Actions.knockback(angleFromAttacker));
			end
		end
	end);

	while true do
		self:waitFor("death");
		local controller = self._entity:getController();
		if controller:isInstanceOf(InputDrivenController) then -- TODO
			controller:disable();
		end
		self:waitFor("idle");
		controller:stopAction();
		controller:doAction(Actions.death);
	end

end

-- PUBLIC API

CombatLogic.init = function(self, entity)
	assert(entity);
	self._entity = entity;
	CombatLogic.super.init(self, logic);
end

return CombatLogic;
