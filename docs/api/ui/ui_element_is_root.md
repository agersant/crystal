---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:is_root

Returns whether this element is the root of its element tree. Roots are defined as elements with no parent.

## Usage

```lua
ui_element:is_root()
```

### Returns

| Name      | Type      | Description                                     |
| :-------- | :-------- | :---------------------------------------------- |
| `is_root` | `boolean` | True if the element is a root, false otherwise. |

## Examples

```lua
local parent = crystal.Overlay:new();
local child = parent:add_child(crystal.Image:new());
print(parent:is_root()); -- Prints "true"
print(child:is_root()); -- Prints "false"
```
