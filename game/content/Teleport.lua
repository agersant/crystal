require("engine/utils/OOP");
local Persistence = require("engine/persistence/Persistence");
local Scene = require("engine/scene/Scene");
local Controller = require("engine/scene/behavior/Controller");
local ScriptRunner = require("engine/scene/behavior/ScriptRunner");
local PhysicsBody = require("engine/scene/physics/PhysicsBody");
local TouchTrigger = require("engine/scene/physics/TouchTrigger");
local Entity = require("engine/ecs/Entity");
local Field = require("arpg/field/Field");

local Teleport = Class("Teleport", Entity);
local TeleportController = Class("TeleportController", Controller);

-- IMPLEMENTATION

local doTeleport = function(self, triggeredBy)
	local teleportEntity = self:getEntity();
	local x, y = teleportEntity:getPosition();
	local px, py = triggeredBy:getPosition();
	local dx, dy = px - x, py - y;
	local finalX, finalY = teleportEntity._targetX + dx, teleportEntity._targetY;

	Persistence:getSaveData():save();
	local newScene = Field:new(teleportEntity._targetMap, finalX, finalY);
	Scene:setCurrent(newScene);

	local teleportAngle = teleportEntity:getAngle();
	for _, entity in ipairs(newScene:getPartyMemberEntities()) do
		entity:setAngle(teleportAngle);
	end
end

local teleportScript = function(self)
	local teleportEntity = self:getEntity();
	self:endOn("teleportActivated");
	while true do
		local triggeredBy = self:waitFor("+trigger"):getEntity();
		local watchDirectionThread = self:thread(function(self)
			while true do
				self:waitFrame();
				if triggeredBy:getAssignedPlayer() then
					local teleportAngle = teleportEntity:getAngle();
					local entityAngle = triggeredBy:getAngle();
					local correctDirection = math.abs(teleportAngle - entityAngle) < math.pi / 2;
					if correctDirection then
						self:signal("teleportActivated");
						doTeleport(self, triggeredBy);
					end
				end
			end
		end);
		self:thread(function(self)
			while true do
				local noLongerTriggering = self:waitFor("-trigger"):getEntity();
				if noLongerTriggering == triggeredBy then
					watchDirectionThread:stop();
					break
				end
			end
		end);
	end
end

TeleportController.init = function(self, scene)
	TeleportController.super.init(self, scene, teleportScript);
end

-- PUBLIC API

Teleport.init = function(self, scene, options)
	assert(options.targetMap);
	assert(options.targetX);
	assert(options.targetY);

	Teleport.super.init(self, scene);
	self:addComponent(PhysicsBody:new(scene));
	self:addComponent(TouchTrigger:new(scene, options.shape));
	self:addComponent(ScriptRunner:new(scene));
	self:addComponent(TeleportController:new(scene));
	self:setPosition(options.x, options.y);

	self._targetMap = options.targetMap;
	self._targetX = options.targetX;
	self._targetY = options.targetY;

	local mapWidth = scene:getMap():getWidthInPixels();
	local mapHeight = scene:getMap():getHeightInPixels();
	local left = math.abs(options.x);
	local top = math.abs(options.y);
	local right = math.abs(mapWidth - options.x);
	local bottom = math.abs(mapHeight - options.y);
	local dx = math.min(left, right);
	local dy = math.min(top, bottom);

	if dx < dy then
		if left < right then
			self:setAngle(math.pi);
		else
			self:setAngle(0);
		end
	else
		if top < bottom then
			self:setAngle(-math.pi / 2);
		else
			self:setAngle(math.pi / 2);
		end
	end
end

return Teleport;
