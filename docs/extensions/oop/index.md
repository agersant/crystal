---
parent: Lua Extensions
has_children: false
has_toc: false
---

# OOP (Object Oriented Programming)

Most of Crystal features use classes, and expects your own game code to work the same way. The concept of classes in Crystal is implemented using Lua metatables.

## Defining classes

Classes are defined by calling the global `Class` and specifying a unique name. Objects are instantiated using `:new()`:

```lua
local Monster = Class("Monster");

local werewolf = Monster:new();
local vampire = Monster:new();
```

Classes can have arbitrary methods:

```lua
local Monster = Class("Monster");

Monster.roar = function(self, noise)
  print(noise);
end

local monster = Monster:new();
monster:roar("Grrrr"); -- Prints "Grrrr"
```

Classes can define a constructor by implementing a `.init` method:

```lua
local Monster = Class("Monster");

Monster.init = function(self, name)
  self.name = name;
end

local werewolf = Monster:new("Rufus");
local vampire = Monster:new("Dracula");
print(werewolf.name); -- Prints "Rufus"
print(vampire.name); -- Prints "Dracula"
```

## Inheritance

Classes can inherit from other classes to share functionality. This is done by passing a second parameter to `Class()`. The class to inherit from can be specified as a direct reference or as a `string` (which may be convenient to skip `require` statements).

```lua
local Monster = Class("Monster");
local Vampire = Class("Vampire", Monster);
local Werewolf = Class("Werewolf", "Monster");
```

Methods or constructor from the base class can be called via `.super`:

```lua
local Monster = Class("Monster");
Monster.init = function(self, food)
  self.food = food;
end

local Werewolf = Class("Werewolf", Monster);
Werewolf.init = function(self)
  Werewolf.super.init(self, "meat");
end

local werewolf = Werewolf:new();
print(werewolf.food); -- Prints "meat"
```

## Checking classes at runtime

You can check if an object or a class inherits from a class, via a direct reference or with a class name:

```lua
local Door = Class("Door");
local Monster = Class("Monster");
local Dragon = Class("Dragon", Monster);

print(Door:inherits_from(Monster)); -- Prints "false"
print(Dragon:inherits_from(Monster)); -- Prints "true"
print(Dragon:inherits_from("Monster")); -- Prints "true"
print(Monster:inherits_from(Monster)); -- Prints "true"

local my_dragon = Dragon:new();
print(dragon:inherits_from(Door)); -- Prints "false"
print(dragon:inherits_from(Monster)); -- Prints "true"
```

You can access the class of any object by calling `:class()`:

```lua
local Monster = Class("Monster");
local dragon = Monster:new();
print(dragon:class() == Monster); -- Prints "true"
```

Class names are also available:

```lua
local Monster = Class("Monster");
local dragon = Monster:new();
print(dragon:class_name()); -- Prints "Monster"
```

You an also retrieve a class by name:

```lua
local Monster = Class("Monster");
print(Class:by_name("Monster") == Monster); -- Prints "true"
```

## Placement New

When you call `MyClass:new()` to create an object, a new table is created and becomes the object. In some rare situations, it is preferable to turn an already existing table into the instantiated object.

An example use case for this is the implementation of [ECS:spawn](/crystal/api/ecs/ecs_spawn). Entities about to be spawned need to be added to various bookkeeping structures before their constructor runs.

The syntax for placement new is:

```lua
local Monster = Class("Monster");
Monster.init = function(self, name)
  print("I am " .. name);
  print("Food is " .. self.food);
end

local monster = { food = "carrots" }; -- Can be filled various fields
Monster:placement_new(monster, "Rufus"); -- Prints "I am Rufus" and "Food is carrots"
```

## Aliasing

{: .warning}
Use this feature with restraint or not at all. Inappropriate usage can make your code slow and difficult to read.

It is possible to create transparent links from method of one object to another. This is the mechanism which allows you to call any [Component](/crystal/api/ecs/component) method directly on the [Entity](/crystal/api/ecs/entity) that owns said component.

In the example below, we define a `Bear` class where each instances owns a `Honeypot` object. We alias the bears to their respective honeypots, so that honeypot methods can be called from the bear objects.

```lua
local Honeypot = Class("Honeypot");
Honeypot.init = function(self)
  self.amount = 0;
end
Honeypot.fill = function(self)
  self.amount = 1;
end

local Bear = Class("Bear");
Bear.init = function(self)
  self.honeypot = Honeypot:new();
  self:add_alias(self.honeypot);
end

local bear = Bear:new();
bear.honeypot:fill(); -- Regular method call
bear:fill(); -- Aliased method call
```

Alias relationships can be removed using `remove_alias`:

```lua
bear:remove_alias(bear.honeypot);
bear:fill(); -- Error
```

Note that aliasing is transitive:

```lua
local A = Class("A");
local B = Class("B");
local C = Class("C");
C.hello = function()
  print("Hello");
end

local a = A:new();
local b = B:new();
local c = C:new();

a:add_alias(b);
b:add_alias(c);
a:hello(); -- Prints "Hello"
```

{: .warning}
When a single object has aliases towards multiple objects that share method names, method calls can be ambiguous. Ambiguous calls will cause runtime errors in [non-fused](https://love2d.org/wiki/love.filesystem.isFused) builds. The best way to avoid such situations is to avoid short generic method names on objects that are used as aliasing targets.

{: .warning}
Calling aliased methods is slightly slower than calling regular methods. In performance critical code sections, it may be preferable to call methods on the objects they belong to.
