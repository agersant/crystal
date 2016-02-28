require( "src/utils/OOP" );
local Sprite = require( "src/graphics/Sprite" );
local Assets = require( "src/resources/Assets" );
local Entity = require( "src/scene/entity/Entity" );

local Warrior = Class( "Warrior", Entity );



-- PUBLIC API

Warrior.init = function( self, scene )
	Warrior.super.init( self, scene );
	local sheet = Assets:getSpritesheet( "assets/spritesheet/duran.lua" );
	self:addSprite( Sprite:new( sheet ) );
	self:addPhysicsBody( "dynamic" );
	self:addCollisionPhysics();
	self:setCollisionRadius( 6 );
	self:setUseSpriteHitboxData( true );
	
	local shape = love.physics.newRectangleShape( 0, -20, 8, 24 );
	self:addWeakboxPhysics( shape );
end



return Warrior;
