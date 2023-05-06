---
parent: crystal.input
grand_parent: API Reference
nav_order: 1
---

# crystal.input.add_mouse_target

Advanced
{: .label .label-yellow}

Registers a recipient for mouse interactions and its bounding box. After the next frame update, the `recipient` passed in to this function may become the [current_mouse_target](current_mouse_target). The list of available mouse targets is cleared each frame, which means this function should be called every frame as long as the interactive object is on screen. When multiple bounding boxes are overlapping, mouse targets added last take precedence.

Coordinates passed into this function should be positions in the game window, comparable with the output of [love.mouse.getPosition](https://love2d.org/wiki/love.mouse.getPosition).

{: .note}
This function should rarely be needed, as Crystal [UI elements](/crystal/api/ui) offer a higher level API to implement mouse interactions.

## Usage

```lua
crystal.input.add_mouse_target(recipient, left, right, top, bottom)
```

### Arguments

| Name        | Type     | Description                                                                           |
| :---------- | :------- | :------------------------------------------------------------------------------------ |
| `recipient` | `table`  | Any table representing the object at this location which can interact with the mouse. |
| `left`      | `number` | Left edge of the interactive object bounding box.                                     |
| `right`     | `number` | Right edge of the interactive object bounding box.                                    |
| `top`       | `number` | Top edge of the interactive object bounding box.                                      |
| `bottom`    | `number` | Bottom edge of the interactive object bounding box.                                   |

For recipients that need finer hit detection than a bounding box or conditional activation, the `recipient` table may implement an `overlaps_mouse` method. If this method exists and the mouse is within the bounding box, `overlaps_mouse` will be called with the following arguments after `self`:

- A `player_index` number identifying the [player](player) operating the mouse
- Mouse x position from [love.mouse.getPosition](https://love2d.org/wiki/love.mouse.getPosition)
- Mouse y position from [love.mouse.getPosition](https://love2d.org/wiki/love.mouse.getPosition)

If `overlaps_mouse` returns `true`, the `recipient` will become the current mouse target. If it returns `false`, other mouse targets at this location will be considered.

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

This example registers an interactive mouse object with a circular hitbox.

```lua
local circle = {
  x = 50,
  y = 50,
  radius = 20,
  overlaps_mouse = function(self, player_index, mouse_x, mouse_y)
    return math.distance(self.x, self.y, mouse_x, mouse_y) < self.radius;
  end
};

crystal.input.add_mouse_target(circle, 30, 70, 30, 70);
```
