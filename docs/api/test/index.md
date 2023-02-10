---
parent: API Reference
has_children: true
---

# crystal.test

With games having many moving parts and Lua being a dynamic language, the best way to know your code is correct is to run it. As the game grows, it can be difficult or tedious to manually validate that everything is working as intended. Tests are a great way to automate these verifications, and to avoid surprise breakages during actual playtests.

Tests can be defined in any `.lua` file that is part of your games. For example, you could implement and test a class performing addition this way:

```lua
local Adder = Class("Adder");

Adder.add = function(self, a, b)
	return a + b;
end

crystal.test.add("Can add numbers", function()
	local adder = Adder:new();
	assert(adder:add(4, 6) == 10);
end);

return Adder;
```

Tests are executed when the game is executed with the `/test` command line argument (for example `../bin/lovec.exe . /test`). The console output for this would be:

```
Running tests

Adder.lua:
  Can add numbers ... ok

Test result: ok. 1/1 tests passed.
```

{: .note }
Tests are not limited to validating individual classes or functions. They have access to the entire `crystal` and `love` APIs, including spawning scenes and simulating player input. Since the main game loop is not running during tests, you must manually advance the game simulation by calling `update(dt)` on your scene or `love.update(dt)`.

## Functions

| Name                                                | Description                                                             |
| :-------------------------------------------------- | :---------------------------------------------------------------------- |
| [crystal.test.add()](add)                           | Defines a test.                                                         |
| [crystal.test.is_running_tests()](is_running_tests) | Returns whether the game is running its test suite or running normally. |

## Classes

| Name                        | Description                                                   |
| :-------------------------- | :------------------------------------------------------------ |
| [TestContext](test_context) | Context object exposing functionality available during tests. |
