require( "src/utils/OOP" );
local Colors = require( "src/resources/Colors" );
local CollisionFilters = require( "src/scene/CollisionFilters" );

local Entity = Class( "Entity" );



Entity.init = function( self, scene )
	assert( scene );
	self._scene = scene;
end



-- PHYSICS BODY COMPONENT

Entity.addPhysicsBody = function( self, bodyType )
	assert( not self._body );
	self._body = love.physics.newBody( self._scene:getPhysicsWorld(), 0, 0, bodyType );
	self._body:setFixedRotation( true );
	self._body:setUserData( self );
	self:setDirection( 0, 1 );
	self:setSpeed( 0 );
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
	
	self._angle = math.atan2( yDir8, xDir8 );
end

Entity.setSpeed = function( self, speed )
	self._baseSpeed = speed;
end

Entity.getDirection4 = function( self )
	return self._dir4;
end

Entity.setPosition = function( self, x, y )
	self._body:setPosition( x, y );
end



-- COLLISION COMPONENT

Entity.addCollisionPhysics = function( self )
	assert( self._body );
	assert( not self._collisionFixture );
	local collisionShape = love.physics.newCircleShape( 1 );
	self._collisionFixture = love.physics.newFixture( self._body, collisionShape );
	self._collisionFixture:setFilterData( CollisionFilters.SOLID, CollisionFilters.GEO + CollisionFilters.SOLID, 0 );
	self._collisionFixture:setFriction( 0 );
	self._collisionFixture:setRestitution( 0 );
end

Entity.setCollisionRadius = function( self, radius )
	assert( radius > 0 );
	assert( self._collisionFixture );
	self._collisionFixture:getShape():setRadius( radius );
end



-- HITBOX COMPONENT

Entity.addHitboxPhysics = function( self, shape )
	assert( self._body );
	self:removeHitboxPhysics();
	self._hitboxFixture = love.physics.newFixture( self._body, shape );
	self._hitboxFixture:setFilterData( CollisionFilters.HITBOX, CollisionFilters.WEAKBOX, 0 );
	self._hitboxFixture:setSensor( true );
end

Entity.removeHitboxPhysics = function( self )
	if self._hitboxFixture then
		self._hitboxFixture:destroy();
	end
	self._hitboxFixture = nil;
end




-- WEAKBOX COMPONENT

Entity.addWeakboxPhysics = function( self, shape )
	assert( self._body );
	self:removeWeakboxPhysics();
	self._weakboxFixture = love.physics.newFixture( self._body, shape );
	self._weakboxFixture:setFilterData( CollisionFilters.WEAKBOX, CollisionFilters.HITBOX, 0 );
	self._weakboxFixture:setSensor( true );
end

Entity.removeWeakboxPhysics = function( self )
	if self._weakboxFixture then
		self._weakboxFixture:destroy();
	end
	self._weakboxFixture = nil;
end



-- SPRITE COMPONENT

Entity.addSprite = function( self, sprite )
	self._sprite = sprite;
	assert( self._sprite );
end

Entity.setAnimation = function( self, animationName )
	assert( self._sprite );
	self._sprite:setAnimation( animationName );
end



-- CONTROLLER COMPONENT

Entity.addController = function( self, controllerClass, ... )
	self._controller = controllerClass:new( self, ... );
	assert( self._controller );
end

Entity.signal = function( self, signal, ... )
	if not self._controller then
		return;
	end
	self._controller:signal( signal, ... );
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
		local animationWasOver = self._sprite:isAnimationOver();
		self._sprite:update( dt );
		if not animationWasOver and self._sprite:isAnimationOver() then
			self:signal( "animationEnd" );
		end
	end
	if self._body then
		local speed = self._baseSpeed;
		local angle = self._angle;
		local dx = math.cos( angle );
		local dy = math.sin( angle );
		self._body:setLinearVelocity( speed * dx, speed * dy );
	end
end

Entity.draw = function( self )
	if self._sprite and self._body then
		self._sprite:draw( self._body:getX(), self._body:getY() );
	end
	if gConf.drawPhysics then
		local alpha = 255 * 0.6;
		if self._collisionFixture then
			love.graphics.setColor( Colors.cyan:alpha( alpha ) );
			self:drawShape( self._collisionFixture:getShape() );
		end
		if self._hitboxFixture then
			love.graphics.setColor( Colors.strawberry:alpha( alpha ) );
			self:drawShape( self._hitboxFixture:getShape() );
		end
		if self._weakboxFixture then
			love.graphics.setColor( Colors.ecoGreen:alpha( alpha ) );
			self:drawShape( self._weakboxFixture:getShape() );
		end
	end
end

Entity.drawShape = function( self, shape )
	love.graphics.push();
	love.graphics.translate( self._body:getX(), self._body:getY() );
	if shape:getType() == "polygon" then
		love.graphics.polygon( "fill", shape:getPoints() );
	elseif shape:getType() == "circle" then
		local x, y = shape:getPoint();
		love.graphics.circle( "fill", x, y, shape:getRadius(), 16 );
	end
	love.graphics.pop();
end

Entity.destroy = function( self )
	if self._body then
		self._body:destroy();
	end
end

Entity.getScene = function( self )
	return self._scene;
end



return Entity;
