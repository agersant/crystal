require("engine/utils/OOP");
local Teams = require("engine/combat/Teams");
local Actions = require("engine/mapscene/Actions");
local Script = require("engine/script/Script");
local HUD = require("engine/ui/hud/HUD");

local CombatLogic = Class("CombatLogic", Script);

-- TODO all of this

local logic = function(self)

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
