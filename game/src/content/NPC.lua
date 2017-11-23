require( "src/utils/OOP" );
local Assets = require( "src/resources/Assets" );
local Actions = require( "src/scene/Actions" );
local Script = require( "src/scene/Script" );
local Controller = require( "src/scene/component/Controller" );
local Sprite = require( "src/scene/component/Sprite" );
local Entity = require( "src/scene/entity/Entity" );
local HUD = require( "src/ui/hud/HUD" );

local NPC = Class( "NPC", Entity );


local script = function( self )
	while true do
		local player = self:waitFor( "interact" );
		HUD:getDialog():open( self, player );
		HUD:getDialog():say( "The harvest this year was meager, there is no spare bread for a stranger like you. If I cannot feed my children, why would I feed you? Extra lines of text to get to line four, come on just a little more." );
		HUD:getDialog():say( "Now leave this town before things go awry, please." );
		HUD:getDialog():close();
	end
end



-- PUBLIC API

NPC.init = function( self, scene )
	NPC.super.init( self, scene );
	local sheet = Assets:getSpritesheet( "assets/spritesheet/Sahagin.lua" );
	self:addSprite( Sprite:new( sheet ) );
	self:addPhysicsBody( "static" );
	self:addLocomotion();
	self:setMovementSpeed( 40 );
	self:addCollisionPhysics();
	self:setCollisionRadius( 4 );
	self:addScriptRunner();
	self:addController( Controller:new( self, script ) );
end



return NPC;
