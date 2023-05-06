---
parent: crystal.input
grand_parent: API Reference
nav_order: 1
---

# crystal.input.current_mouse_target

Advanced
{: .label .label-yellow}

Returns the [mouse target](add_mouse_target) the mouse pointer is currently on top of.

{: .note}
This function should rarely be needed, as Crystal [UI elements](/crystal/api/ui) offer a higher level API to implement mouse interactions.

## Usage

```lua
crystal.input.current_mouse_target()
```

### Returns

| Name        | Type             | Description                                                                                                                                                |
| :---------- | :--------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `recipient` | `table` \| `nil` | A `recipient` table that was previously registered via [add_mouse_target](add_mouse_target). `nil` if the mouse is not currently on top of a mouse target. |

## Examples

This example defines a scene with an interactive mouse object in the top left of the game window.

```lua
local Scene = Class("MyScene", crystal.Scene);

Scene.init = function(self)
  self.clickable_box = { name = "Cardboard box" };
end

Scene.update = function(self)
  local under_mouse = crystal.input.current_mouse_target();
  if under_mouse then
    print(under_mouse.name); -- Prints "Cardboard box" while the mouse is within the top left of the game window
  end
end

Scene.draw = function(self)
  crystal.input.add_mouse_target(self.clickable_box, 0, 100, 0, 100);
end
```
