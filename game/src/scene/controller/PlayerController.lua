require( "src/utils/OOP" );
local Input = require( "src/input/Input" );
local Actions = require( "src/scene/Actions" );
local InputDrivenController = require( "src/scene/controller/InputDrivenController" );
local Script = require( "src/scene/controller/Script" );
local CombatLogic = require( "src/scene/combat/CombatLogic" );
local PlayerDirectionControls = require( "src/scene/controller/PlayerDirectionControls" );

local PlayerController = Class( "PlayerController", InputDrivenController );



-- CONTROLS

local walkControls = function( self )
	local controller = self:getController();
	local entity = controller:getEntity();
	while true do
		if controller:isIdle() then
			local left = controller:getInputDevice():isCommandActive( "moveLeft" );
			local right = controller:getInputDevice():isCommandActive( "moveRight" );
			local up = controller:getInputDevice():isCommandActive( "moveUp" );
			local down = controller:getInputDevice():isCommandActive( "moveDown" );
			if left or right or up or down then
				controller:doAction( Actions.walk( entity:getAngle() ) );
			else
				controller:doAction( Actions.idle );
			end
		end
		self:waitFrame();
	end
end

local attackControls = function( self )
	while true do
		self:waitForCommandPress( "attack" );
		if self:isIdle() then
			self:doAction( Actions.attack );
		end
		self:waitFrame();
	end
end

local skillControls = function( skillIndex )
	return function( self )
		local controller = self:getController();
		local entity = controller:getEntity();
		local useSkillCommand = "useSkill" .. skillIndex;
		while true do
			self:waitForCommandPress( useSkillCommand );
			local skill = entity:getSkill( skillIndex );
			if skill then
				skill:use();
			end
		end
	end
end	



-- PUBLIC API

PlayerController.init = function( self, entity, playerIndex )
	PlayerController.super.init( self, entity, playerIndex );
	self:addScript( CombatLogic:new( self ) );
	self:addScript( PlayerDirectionControls:new( self ) );
	self:addScript( Script:new( self, walkControls ) );
	for i = 1, 4 do
		self:addScript( Script:new( self, skillControls( i ) ) );
	end
end



return PlayerController;
