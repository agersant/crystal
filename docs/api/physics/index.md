---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.physics

## Overview

This module contains [components](/crystal/api/ecs/components) to facilitate positioning and moving entities, as well as detecting collisions or overlaps between them. These components are based on LOVE's physics module which itself relies on Box2D. Box2D is designed to support games with realistic physics and complex interactions. This module hides a lot of said functionality and tries to simplify the execution of more traditional 2D game physics.

One important difference between LOVE physics and this module is that Crystal [bodies](body) never rotate. Their rotation field is useful to keep track of which direction a character is facing, but has no effect on the actual physics simulation (ie. [colliders](collider) and [sensors](sensor) components do not rotate).

Several functions in this module rely on [categories](https://love2d.org/wiki/Fixture:setCategory). Categories are used to describe what type of object a [Collider](collider) or [Sensor](sensor) represents. Some example categories could be characters, level obstacles, invisible triggers or destructible objects. The list of valid categories must be defined once during game startup via [crystal.configure](/crystal/api/configure).

## Examples

This example defines an entity with a position in the world, the ability to move and a circular collision box.

```lua
local Hero = Class("Hero", crystal.Entity);
Hero.init = function(self)
  self:add_component(crystal.Body, "dynamic");
  self:add_component(crystal.Movement);
  self:add_component(crystal.Collider, love.physics.newCircleShape(10));
end

local ecs = crystal.ECS:new();
ecs:add_system(crystal.PhysicsSystem);

local hero = ecs:spawn(Hero);
```

## Classes

| Name                                    | Description                                                                                                        |
| :-------------------------------------- | :----------------------------------------------------------------------------------------------------------------- |
| [crystal.Body](body)                    | A [Component](/crystal/api/ecs/component) representing an entity's position in space and other physics parameters. |
| [crystal.Collider](collider)            | [Component](/crystal/api/ecs/component) allowing an entity to collide with others.                                 |
| [crystal.Movement](movement)            | [Component](/crystal/api/ecs/component) allowing an entity to move of its own volition.                            |
| [crystal.PhysicsSystem](physics_system) | [System](/crystal/api/ecs/system) system powering the components in the crystal.physics module.                    |
| [crystal.Sensor](sensor)                | [Component](/crystal/api/ecs/component) allowing an entity to detect collision with others without blocking them.  |
