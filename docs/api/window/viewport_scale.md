---
parent: crystal.window
grand_parent: API Reference
nav_order: 1
---

# crystal.window.viewport_scale

Returns the scaling factor applied to the game viewport within [draw](crystal.window.draw).

## Usage

```lua
crystal.window.viewport_scale()
```

### Returns

| Name    | Type     | Description                                     |
| :------ | :------- | :---------------------------------------------- |
| `scale` | `number` | Scaling factor applied when upscaling the game. |

## Examples

```lua
crystal.window.draw(function()
  local scale = crystal.window.viewport_scale();
  love.graphics.setPointSize(scale * 4);
  love.graphics.points(100, 100);
end);
```
