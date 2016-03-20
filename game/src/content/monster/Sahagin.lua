require( "src/utils/OOP" );
local Sprite = require( "src/graphics/Sprite" );
local Assets = require( "src/resources/Assets" );
local Entity = require( "src/scene/entity/Entity" );

local Sahagin = Class( "Sahagin", Entity );



-- PUBLIC API

Sahagin.init = function( self, scene )
	Sahagin.super.init( self, scene );
	local sheet = Assets:getSpritesheet( "assets/spritesheet/sahagin.lua" );
	self:addSprite( Sprite:new( sheet ) );
	self:addPhysicsBody( "dynamic" );
	self:addLocomotion();
	self:addCollisionPhysics();
	self:addCombatComponent();
	self:setCollisionRadius( 4 );
	self:setUseSpriteHitboxData( true );
end



return Sahagin;
