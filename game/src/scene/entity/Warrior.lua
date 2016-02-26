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
end



return Warrior;
