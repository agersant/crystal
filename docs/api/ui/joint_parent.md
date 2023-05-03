---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Joint:parent

Returns the container or wrapper the child element is in.

## Usage

```lua
joint:parent()
```

### Returns

| Name      | Type                                                                         | Description        |
| :-------- | :--------------------------------------------------------------------------- | :----------------- |
| `element` | [Container](/crystal/api/ui/container) \| [Wrapper](/crystal/api/ui/wrapper) | Parent UI element. |

## Examples

```lua
local overlay = crystal.Overlay:new();
local image = overlay:add_child(crystal.Image:new());
assert(image:joint():child() == image);
assert(image:joint():parent() == overlay);
```
