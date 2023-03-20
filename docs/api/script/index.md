---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.script

## Overview

This module offers a [coroutine](https://www.lua.org/pil/9.1.html)-based scripting system, which tries to facilitate programming game logic that takes place over time. Some example use-cases for this would be scripted cutscenes or dialogs, turn-based combat logic, complex moves for action-game characters, or UI animations.

### Scripts & Threads

The entry-point into this module is to instantiate a [Script](script). A Script object manages a collection of [threads](thread), which are working concurrently to implement some kind of feature. For example, a character could have a script managing its movement inputs, another one dealing with jump inputs, and a temporary script piloting the character during a cutscene.

Despite their names, Crystal threads are not OS threads. Thinking of them as Lua coroutines is more accurate. Naming them coroutines would have been confusing in a Lua context, hence the more generic `thread` name. Just like the Lua coroutines they rely on, threads are concurrent but not parallel. There is only one thread executing at a given time - but all threads get to run on a given game frame. Let's illustrate this with an example:

```lua
local script = crystal.Script:new();

script:add_thread(function(self)
  while true then
    print("Oink");
    self:wait_frame();
  end
end);

script:add_thread(function(self)
  while true then
    print("Moo");
    self:wait_frame();
  end
end);

script:update(0); -- Prints "Oink" and "Moo" (in any order)
script:update(0); -- Prints "Oink" and "Moo" (in any order)
script:update(0); -- Prints "Oink" and "Moo" (in any order)
```

The example above creates a script and two threads inside it. Each time we call [Script:update](script_update), both threads run code until they run into a blocking statement ([Thread:wait_frame](thread_wait_frame)).

### Signals

Waiting for a frame or a specific duration to pass are not the only ways to block a thread. With signals, threads can block until a specific event occurs.

```lua
local script = crystal.Script:new();

script:run_thread(function(self)
  while true do
    local name = self:wait_for("greet");
    print("Hello " .. name);
  end
end);

script:update(0); -- Nothing happens, script is blocked on the `wait_for` statement
script:signal("greet", "Alvina"); -- Prints "Hello Alvina"
script:signal("greet", "Tarkus"); -- Prints "Hello Tarkus"
script:update(0); -- Nothing happens, script is blocked on the `wait_for` statement
```

The script has a single thread which is repeatedly waiting for the `greet` signal. The `greet` signal is accompanied by some data, the name of the person to greet. Every time the script is unblocked, it prints out a line of text.

{: .note}
Threads can also wait for multiple signals at the same time using [Thread:wait_for_any](thread_wait_for_any). They will resume execution when any of the specified signals is received.

Signals can also be used to stop threads thanks to [Thread:stop_on](thread_stop_on). Building up on the greeting example above:

```lua
local script = crystal.Script:new();

script:run_thread(function(self)
  self:stop_on("bye");
  while true do
    local name = self:wait_for("greet");
    print("Hello " .. name);
  end
end);

script:signal("greet", "Alvina"); -- Prints "Hello Alvina"
script:signal("bye"); -- Thread is stopped
script:signal("greet", "Tarkus"); -- Nothing happens
```

This thread operates the same greeting logic as the previous example. When the `bye` signal is received, the thread is stopped completely.

### Child Threads

Threads are hierarchical, which means they can have child threads, which can themselves have child threads (etc.). Child threads are created by calling [Thread:thread](thread_thread). Whenever a thread completes its execution or is stopped, all its child threads are stopped too.

Let's look at an example of this too:

```lua
local script = crystal.Script:new();
script:add_thread(function(self)
  local meal;
  self:thread(function(self)
    while true do
      self:wait_frame();
      print(meal);
    end
  end);

  meal = "breakfast";
  self:wait(1);
  meal = "lunch";
  self:wait(1);
  meal = "dinner";
  self:wait(1);
end);

-- Advance the script by 0.2s a hundred times
for i = 1, 100 do
  script:update(0.2);
end
```

The script above creates a child thread which prints the current meal every frame, while its parent thread is updating the meal every second. When the parent thread completes (one second after setting the current meal to "dinner"), the child thread also stops.

Make sure to check the [Thread](thread) documentation page to find other useful functionality available in scripts.

### Working with Scripts and Entities

Scripts and Threads can work independently of Entities and Components from the [crystal.ecs](/crystal/api/ecs) module. However, it is very common to write scripts that logically belong to an entity and operate on it. To facilitate this pattern, the `crystal.script` module exposes the [ScriptRunner](script_runner) and [Behavior](behavior) components, and a [ScriptSystem](script_system) to power them.

The documentation pages for these components have more information on how and when to use them.

## Classes

| Name                                  | Description                                                                                                           |
| :------------------------------------ | :-------------------------------------------------------------------------------------------------------------------- |
| [crystal.Behavior](behavior)          | [Component](/crystal/api/ecs/component) which can attach a premade script to an entity.                               |
| [crystal.Script](script)              | Logical grouping of [threads](thread).                                                                                |
| [crystal.ScriptRunner](script_runner) | [Component](/crystal/api/ecs/component) which allows an entity to run scripts.                                        |
| [crystal.ScriptSystem](script_system) | [System](/crystal/api/ecs/system) which makes [ScriptRunner](script_runner) and [Behavior](behavior) components work. |
| [crystal.Thread](thread)              | A piece of logic that can run over multiple frames.                                                                   |
