require("engine/utils/OOP");
local PartyMember = require("arpg/persistence/party/PartyMember");
local Persistence = require("engine/persistence/Persistence");
local MapSystem = require("engine/mapscene/MapSystem");
local ScriptRunner = require("engine/mapscene/behavior/ScriptRunner");
local PhysicsBody = require("engine/mapscene/physics/PhysicsBody");
local TouchTrigger = require("engine/mapscene/physics/TouchTrigger");
local Entity = require("engine/ecs/Entity");
local Script = require("engine/script/Script");
local StringUtils = require("engine/utils/StringUtils");
local Field = require("arpg/field/Field");

local Teleport = Class("Teleport", Entity);
local TeleportTouchTrigger = Class("TeleportTouchTrigger", TouchTrigger);

local doTeleport = function(self, triggeredBy)
	local teleportEntity = self:getEntity();
	local finalX, finalY = teleportEntity._targetX, teleportEntity._targetY;

	local targetMap = StringUtils.mergePaths(GAME.mapDirectory, teleportEntity._targetMap);
	local newScene = Field:new(targetMap, finalX, finalY, self:getAngle());
	LOAD_SCENE(newScene);
end

local teleportScript = function(self)
	local teleportEntity = self:getEntity();
	self:endOn("teleportActivated");
	while true do
		local triggeredBy = self:waitFor("+trigger");
		local watchDirectionThread = self:thread(function(self)
			while true do
				self:waitFrame();
				if triggeredBy:getComponent(PartyMember) then
					local teleportAngle = teleportEntity:getAngle();
					local entityAngle = triggeredBy:getAngle();
					local correctDirection = math.abs(teleportAngle - entityAngle) < math.pi / 2;
					if correctDirection then
						doTeleport(self, triggeredBy);
						self:signal("teleportActivated");
					end
				end
			end
		end);
		self:thread(function(self)
			while true do
				local noLongerTriggering = self:waitFor("-trigger");
				if noLongerTriggering == triggeredBy then
					watchDirectionThread:stop();
					break
				end
			end
		end);
	end
end

TeleportTouchTrigger.init = function(self, physicsBody, shape)
	TeleportTouchTrigger.super.init(self, physicsBody, shape);
end

TeleportTouchTrigger.onBeginTouch = function(self, component)
	self:getEntity():signalAllScripts("+trigger", component:getEntity());
end

TeleportTouchTrigger.onEndTouch = function(self, component)
	self:getEntity():signalAllScripts("-trigger", component:getEntity());
end

Teleport.init = function(self, scene, options)
	assert(options.targetMap);
	assert(options.targetX);
	assert(options.targetY);

	Teleport.super.init(self, scene);
	local physicsBody = self:addComponent(PhysicsBody:new(scene:getPhysicsWorld()));
	self:addComponent(TeleportTouchTrigger:new(physicsBody, options.shape));
	self:addComponent(ScriptRunner:new());
	self:addScript(Script:new(teleportScript));

	self._targetMap = options.targetMap;
	self._targetX = options.targetX;
	self._targetY = options.targetY;

	local map = scene:getMap();
	local mapWidth = map:getWidthInPixels();
	local mapHeight = map:getHeightInPixels();

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
