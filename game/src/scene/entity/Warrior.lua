require( "src/utils/OOP" );
local Sprite = require( "src/graphics/Sprite" );
local Assets = require( "src/resources/Assets" );
local Character = require( "src/scene/entity/Character" );

local Warrior = Class( "Warrior", Character );



-- PUBLIC API

Warrior.init = function( self, scene )
	Warrior.super.init( self, scene );
	local sheet = Assets:getSpritesheet( "assets/spritesheet/duran.lua" );
	self:addSprite( Sprite:new( sheet ) );
end



return Warrior;
