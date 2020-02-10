require("engine/utils/OOP");
local Actions = require("engine/scene/Actions");
local Controller = require("engine/scene/behavior/Controller");
local TableUtils = require("engine/utils/TableUtils");

local PlayerController = Class("PlayerController", Controller);

-- CONTROLS
local waitForCommandPress = function(self, command)
	if self:isCommandActive(command) then
		self:waitFor("-" .. command);
	end
	self:waitFor("+" .. command);
end

local addDirectionControls = function(self)
	self:thread(function(self)
		while true do
			waitForCommandPress(self, "moveLeft");
			self._lastXDirInput = -1;
		end
	end);

	self:thread(function(self)
		while true do
			waitForCommandPress(self, "moveRight");
			self._lastXDirInput = 1;
		end
	end);

	self:thread(function(self)
		while true do
			waitForCommandPress(self, "moveUp");
			self._lastYDirInput = -1;
		end
	end);

	self:thread(function(self)
		while true do
			waitForCommandPress(self, "moveDown");
			self._lastYDirInput = 1;
		end
	end);

	self:thread(function(self)
		local entity = self:getEntity();
		while true do
			if self:isIdle() then
				local left = self:isCommandActive("moveLeft");
				local right = self:isCommandActive("moveRight");
				local up = self:isCommandActive("moveUp");
				local down = self:isCommandActive("moveDown");
				if left or right or up or down then
					local xDir, yDir;
					if left and right then
						if self._lastXDirInput then
							xDir = self._lastXDirInput;
						else
							local angle = entity:getAngle();
							xDir = math.cos(angle) > 0 and 1 or -1;
						end
					else
						xDir = left and -1 or right and 1 or 0;
					end
					assert(xDir);
					if up and down then
						if self._lastYDirInput then
							yDir = self._lastYDirInput;
						else
							local angle = entity:getAngle();
							yDir = math.sin(angle) > 0 and 1 or -1;
						end
					else
						yDir = up and -1 or down and 1 or 0;
					end
					assert(yDir);
					entity:setDirection8(xDir, yDir);
				end
			end
			self:waitFrame();
		end
	end);
end

local walkControls = function(self)
	local entity = self:getEntity();
	while true do
		if self:isIdle() then
			local left = self:isCommandActive("moveLeft");
			local right = self:isCommandActive("moveRight");
			local up = self:isCommandActive("moveUp");
			local down = self:isCommandActive("moveDown");
			if left or right or up or down then
				self:doAction(Actions.walk(entity:getAngle()));
			else
				self:doAction(Actions.idle);
			end
		end
		self:waitFrame();
	end
end

local addInteractionControls = function(self)
	self._contacts = {};

	self:thread(function()
		while true do
			local contactEntity = self:waitFor("+touch");
			self._contacts[contactEntity] = true;
			self:thread(function()
				repeat
					local dropEntity = self:waitFor("-touch");
				until dropEntity == contactEntity
				self._contacts[contactEntity] = nil;
			end);
		end
	end);

	self:thread(function()
		local player = self:getEntity();
		while true do
			waitForCommandPress(self, "interact");
			if self:isIdle() then
				local contactCopy = TableUtils.shallowCopy(self._contacts);
				for entity, _ in pairs(contactCopy) do
					entity:signal("interact", player);
				end
			end
		end
	end);
end

local playerControllerScript = function(self)
	addDirectionControls(self);
	addInteractionControls(self);
	self:thread(walkControls);
end

-- PUBLIC API

PlayerController.init = function(self)
	PlayerController.super.init(self, playerControllerScript);
end

return PlayerController;
