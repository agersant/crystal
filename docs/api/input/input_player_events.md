---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputPlayer:events

Returns a list of actions pressed or released this frame, in the order they were emitted.

Actions being pressed are represented by events prefixed with `+`, like `"+jump"`. Actions being released are represented by events prefixed with `-`, like `"-jump"`.

{: .note}
If you are using an [ECS](/crystal/api/ecs/ecs) with an [InputSystem](input_system), there is little reason to call this method yourself.

## Usage

```lua
input_player:events()
```

### Returns

| Name     | Type    | Description                |
| :------- | :------ | :------------------------- |
| `events` | `table` | List of events as strings. |

## Examples

```lua
local player = crystal.input.player(1);
player:set_bindings({ space = { "jump" }, });
love.keypressed("space", "space", false);
love.keyreleased("space", "space");
for _, event in ipairs(player:events()) do
  print(event); -- Prints "+jump" followed by "-jump"
end
```
