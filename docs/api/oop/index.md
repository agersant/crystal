---
parent: API Reference
has_children: false
has_toc: false
---

# crystal.oop

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
