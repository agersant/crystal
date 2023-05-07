---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Wrapper:set_child

Sets the child element wrapped by this wrapper.

## Usage

```lua
wrapper:set_child(child)
```

### Arguments

| Name    | Type                    | Description    |
| :------ | :---------------------- | :------------- |
| `child` | [UIElement](ui_element) | Child element. |

## Examples

```lua
local rounded_corners = crystal.RoundedCorners:new();
local image = rounded_corners:set_child(crystal.Image:new());
assert(rounded_corners:child() == image);
```
