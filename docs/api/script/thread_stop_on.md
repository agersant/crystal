---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Thread:stop_on

Stops this thread whenever its parent [Script](script) receives a specific signal.

## Usage

```lua
thread:stop_on(signal)
```

### Arguments

| Name     | Type     | Description                         |
| :------- | :------- | :---------------------------------- |
| `signal` | `string` | Signal which will stop this thread. |

## Examples

```lua
local script = crystal.Script:new();

script:run_thread(function(self)
  self:stop_on("death");
  self:stop_on("stun");
  self:stop_on("silence");
  self:wait(2);
  print("Casting Fireball");
end);

script:update(0.5); -- 1.5s left to wait before cast completes
script:signal("stun"); -- Fireball thread stops
script:update(1.5); -- Nothing happens
```
