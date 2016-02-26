require( "src/utils/OOP" );

local Entity = Class( "Entity" );



Entity.init = function( self, scene )
	assert( scene );
	self._scene = scene;
end



-- PHYSICS COMPONENT

Entity.addPhysicsBody = function( self, bodyType )
	self._body = love.physics.newBody( self._scene:getPhysicsWorld(), 0, 0, bodyType );
	self:setDirection( 0, 1 );
end

Entity.getZ = function( self )
	assert( self._body );
	return self._body:getY();
end

Entity.setDirection = function( self, xDir8, yDir8 )
	assert( self._body );
	assert( xDir8 == 0 or xDir8 == 1 or xDir8 == -1 );
	assert( yDir8 == 0 or yDir8 == 1 or yDir8 == -1 );
	assert( xDir8 ~= 0 or yDir8 ~= 0 );
	
	if xDir8 == self._xDir8 and yDir8 == self._yDir8 then
		return;
	end
	
	if xDir8 * yDir8 == 0 then
		if xDir8 == 1 then
			self._dir4 = "right";
		elseif xDir8 == -1 then
			self._dir4 = "left";
		elseif yDir8 == 1 then
			self._dir4 = "down";
		elseif yDir8 == -1 then
			self._dir4 = "up";
		end
	else
		if xDir8 ~= self._xDir8 then
			self._dir4 = yDir8 == 1 and "down" or "up";
		end
		if yDir8 ~= self._yDir8 then
			self._dir4 = xDir8 == 1 and "right" or "left";
		end
	end
	
	self._xDir8 = xDir8;
	self._yDir8 = yDir8;
	self._xDir4 = self._dir4 == "left" and -1 or self._dir4 == "right" and 1 or 0;
	self._yDir4 = self._dir4 == "up" and -1 or self._dir4 == "down" and 1 or 0;
	
	local angle = math.atan2( yDir8, xDir8 );
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
