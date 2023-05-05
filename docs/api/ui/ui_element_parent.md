---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:parent

Returns this element's parent, if any.

## Usage

```lua
ui_element:parent()
```

### Returns

| Name             | Type                             | Description              |
| :--------------- | :------------------------------- | :----------------------- |
| `parent_element` | [UIElement](ui_element) \| `nil` | Parent element or `nil`. |

## Examples

```lua
local popup = crystal.Overlay:new();
local title = popup:add_child(crystal.Text:new());
assert(title:parent() == popup);
```
