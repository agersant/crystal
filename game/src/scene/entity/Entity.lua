require( "src/utils/OOP" );

local Entity = Class( "Entity" );



Entity.init = function( self, scene )
	assert( scene );
	self._scene = scene;
end



-- PHYSICS COMPONENT

Entity.addPhysicsBody = function( self, bodyType )
	self._body = love.physics.newBody( self._scene:getPhysicsWorld(), 0, 0, bodyType );
	self._direction4 = "right";
end

Entity.getZ = function( self )
	if self._body then
		return self._body:getY();
	end
end

Entity.setDirection = function( self, xDir, yDir )
	assert( self._body );
	assert( xDir == 0 or xDir == 1 or xDir == -1 );
	assert( yDir == 0 or yDir == 1 or yDir == -1 );
	if xDir == 1 then
		self._direction4 = "right";
	elseif xDir == -1 then
		self._direction4 = "left";
	elseif yDir == 1 then
		self._direction4 = "down";
	elseif yDir == -1 then
		self._direction4 = "up";
	end
	local angle = math.atan2( yDir, xDir );
	self._body:setAngle( angle );
end



-- SPRITE COMPONENT

Entity.addSprite = function( self, sprite )
	self._sprite = sprite;
	assert( self._sprite );
end

Entity.setSpriteAnimation = function( self, animationName )
	assert( self._sprite );
	self._sprite:setAnimation( animationName );
end



-- CONTROLLER COMPONENT

Entity.setController = function( self, controller )
	self._controller = controller;
	controller:setEntity( self );
end



-- CORE

Entity.isUpdatable = function( self )
	return self._controller or self._sprite or ( self.update ~= Entity.update );
end

Entity.isDrawable = function( self )
	return self._sprite or ( self.draw ~= Entity.draw );
end

Entity.update = function( self, dt )
	if self._controller then
		self._controller:update( dt );
	end
	if self._sprite then
		self._sprite:update( dt );
	end
end

Entity.draw = function( self )
	if self._sprite and self._body then
		self._sprite:draw( self._body:getX(), self._body:getY() );
	end
end



return Entity;
