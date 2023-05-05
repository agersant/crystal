---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:size

Returns this element's width and height, as computed during [update_tree](update_tree).

{: .warning}
This method will emit an error when called on a freshly created element. You must call `update_tree` on the root of an element before calling this.

## Usage

```lua
ui_element:size()
```

### Returns

| Name     | Type     | Description               |
| :------- | :------- | :------------------------ |
| `width`  | `number` | Element width in pixels.  |
| `height` | `number` | Element height in pixels. |

## Examples

```lua
local items = crystal.VerticalList:new();
local sword = items:add_child(crystal.Image:new(crystal.assets.get("sword.png")));
local potion = items:add_child(crystal.Image:new(crystal.assets.get("potion.png")));
sword:set_image_size(50, 60);
potion:set_image_size(50, 60);

items:update_tree(0);
print(items:size()); -- Prints "50, 120"
```
