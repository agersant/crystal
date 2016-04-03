require( "src/utils/OOP" );
local ComboAttack = require( "src/content/skill/ComboAttack" );
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
	self:addLocomotion();
	self:addCollisionPhysics();
	self:addCombatComponent();
	self:setCollisionRadius( 6 );
	self:setUseSpriteHitboxData( true );
	
	self:addSkill( ComboAttack:new( self ) );
end



return Warrior;
