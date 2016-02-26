require( "src/utils/OOP" );
local Sprite = require( "src/graphics/Sprite" );
local Assets = require( "src/resources/Assets" );
local Entity = require( "src/scene/entity/Entity" );

local Character = Class( "Character", Entity );



-- PUBLIC API

Character.init = function( self, scene )
	Character.super.init( self, scene );
	self:addPhysicsBody( "dynamic" );
	self._state = "idle";
	self._walkSpeed = 144;
end


Character.update = function( self, dt )
	Character.super.update( self, dt );
	
	if self._state == "idle" then
		self._body:setLinearVelocity( 0, 0 );
	elseif self._state == "walk" then
		local angle = self._body:getAngle();
		local dx = math.cos( angle );
		local dy = math.sin( angle );
		self._body:setLinearVelocity( self._walkSpeed * dx, self._walkSpeed * dy );
	end
	
	-- TODO TMP
	local animName = self._state .. "_" .. self._dir4;
	self._sprite:setAnimation( animName );
end

Character.idle = function( self )
	if self._state ~= "idle" then
		self._state = "idle";
	end
end

Character.walk = function( self )
	if self._state ~= "walk" then
		self._state = "walk";
	end
end


return Character;
