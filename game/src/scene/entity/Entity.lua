require( "src/utils/OOP" );
local Colors = require( "src/resources/Colors" );
local CollisionFilters = require( "src/scene/CollisionFilters" );
local CombatComponent = require( "src/scene/combat/CombatComponent" );
local Stat = require( "src/scene/entity/Stat" );
local MathUtils = require( "src/utils/MathUtils" );

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
	self:setDirection8( 1, 0 );
	self:setSpeed( 0 );
end

Entity.getZ = function( self )
	assert( self._body );
	return self._body:getY();
end

Entity.setDirection8 = function( self, xDir8, yDir8 )
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

Entity.getDirection4 = function( self )
	return self._dir4;
end

Entity.getPosition = function( self )
	return self._body:getX(), self._body:getY();
end

Entity.setPosition = function( self, x, y )
	self._body:setPosition( x, y );
end

Entity.getAngle = function( self )
	return self._angle;
end

Entity.setAngle = function( self, angle )
	self:setDirection8( MathUtils.angleToDir8( angle ) );
	self._angle = angle;
end

Entity.distanceToEntity = function( self, entity )
	local targetX, targetY = entity:getPosition();
	return self:distanceTo( targetX, targetY );
end

Entity.distance2ToEntity = function( self, entity )
	local targetX, targetY = entity:getPosition();
	return self:distance2To( targetX, targetY );
end

Entity.distanceTo = function( self, targetX, targetY )
	local x, y = self:getPosition();
	return MathUtils.distance( x, y, targetX, targetY );
end

Entity.distance2To = function( self, targetX, targetY )
	local x, y = self:getPosition();
	return MathUtils.distance2( x, y, targetX, targetY );
end



-- LOCOMOTION COMPONENT

Entity.addLocomotion = function( self )
	self._movementStat = Stat:new( 120, 0 );
	self._speed = 0;
end

Entity.getMovementSpeed = function( self, speed )
	return self._movementStat:getValue();
end

Entity.setMovementSpeed = function( self, speed )
	self._movementSpeed:setValue( speed );
end

Entity.setSpeed = function( self, speed )
	self._speed = speed;
end

Entity.findPathTo = function( self, targetX, targetY )
	local startX, startY = self:getPosition();
	return self._scene:findPath( startX, startY, targetX, targetY );
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
	if self._hitboxShape == shape then
		return;
	end
	self:removeHitboxPhysics();
	self._hitboxFixture = love.physics.newFixture( self._body, shape );
	self._hitboxFixture:setFilterData( CollisionFilters.HITBOX, CollisionFilters.WEAKBOX, 0 );
	self._hitboxFixture:setSensor( true );
	self._hitboxShape = shape;
end

Entity.removeHitboxPhysics = function( self )
	if self._hitboxFixture then
		self._hitboxFixture:destroy();
	end
	self._hitboxFixture = nil;
	self._hitboxShape = nil;
end




-- WEAKBOX COMPONENT

Entity.addWeakboxPhysics = function( self, shape )
	assert( self._body );
	if self._weakboxShape == shape then
		return;
	end
	self:removeWeakboxPhysics();
	self._weakboxFixture = love.physics.newFixture( self._body, shape );
	self._weakboxFixture:setFilterData( CollisionFilters.WEAKBOX, CollisionFilters.HITBOX, 0 );
	self._weakboxFixture:setSensor( true );
	self._weakboxShape = shape;
end

Entity.removeWeakboxPhysics = function( self )
	if self._weakboxFixture then
		self._weakboxFixture:destroy();
	end
	self._weakboxFixture = nil;
	self._weakboxShape = nil;
end



-- SPRITE COMPONENT

Entity.addSprite = function( self, sprite )
	self._sprite = sprite;
	assert( self._sprite );
end

Entity.setAnimation = function( self, animationName, forceRestart )
	assert( self._sprite );
	self._sprite:setAnimation( animationName, forceRestart );
end

Entity.setUseSpriteHitboxData = function( self, enabled )
	assert( self._body );
	self._useSpriteHitboxData = enabled;
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

Entity.getAssignedPlayer = function( self )
	if self._controller.getAssignedPlayer then
		return self._controller:getAssignedPlayer();
	end
end



-- PARTY COMPONENT

Entity.addToParty = function( self )
	self._scene:addEntityToParty( self );
end

Entity.removeFromParty = function( self )
	self._scene:removeEntityFromParty( self );
end



-- COMBAT COMPONENT

Entity.addCombatComponent = function( self )
	assert( not self._combatComponent );
	self._combatComponent = CombatComponent:new( self );
end

Entity.inflictDamageTo = function( self, target )
	assert( self._combatComponent );
	self._combatComponent:inflictDamageTo( target );
end

Entity.receiveDamage = function( self, damage )
	assert( self._combatComponent );
	self._combatComponent:receiveDamage( damage );
end

Entity.setTeam = function( self, team )
	assert( self._combatComponent );
	self._combatComponent:setTeam( team );
end

Entity.getTeam = function( self )
	assert( self._combatComponent );
	return self._combatComponent:getTeam();
end



-- CORE

Entity.isUpdatable = function( self )
	return self._controller or self._sprite or ( self.update ~= Entity.update );
end

Entity.isDrawable = function( self )
	return self._sprite or ( self.draw ~= Entity.draw );
end

Entity.isCombatable = function( self )
	return self._combatComponent;
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
		if self._useSpriteHitboxData then
			local hitShape = self._sprite:getTagShape( "hit" );
			if hitShape then
				self:addHitboxPhysics( hitShape );
			else
				self:removeHitboxPhysics();
			end
			local weakShape = self._sprite:getTagShape( "weak" );
			if weakShape then
				self:addWeakboxPhysics( weakShape );
			else
				self:removeWeakboxPhysics();
			end
		end
	end
	if self._body then
		local speed = self._speed;
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
		if self._collisionFixture then
			self:drawShape( self._collisionFixture:getShape(), Colors.cyan );
		end
		if self._hitboxFixture then
			self:drawShape( self._hitboxFixture:getShape(), Colors.strawberry );
		end
		if self._weakboxFixture then
			self:drawShape( self._weakboxFixture:getShape(), Colors.ecoGreen );
		end
	end
end

Entity.drawShape = function( self, shape, color )
	love.graphics.push();
	love.graphics.translate( self._body:getX(), self._body:getY() );
	love.graphics.setColor( color:alpha( 255 * .6 ) );
	if shape:getType() == "polygon" then
		love.graphics.polygon( "fill", shape:getPoints() );
	elseif shape:getType() == "circle" then
		local x, y = shape:getPoint();
		love.graphics.circle( "fill", x, y, shape:getRadius(), 16 );
	end
	love.graphics.setColor( color );
	if shape:getType() == "polygon" then
		love.graphics.polygon( "line", shape:getPoints() );
	elseif shape:getType() == "circle" then
		local x, y = shape:getPoint();
		love.graphics.circle( "line", x, y, shape:getRadius(), 16 );
	end
	love.graphics.pop();
end

Entity.despawn = function( self )
	self._scene:despawn( self );
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
