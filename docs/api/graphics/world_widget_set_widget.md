---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# WorldWidget:set_widget

Sets the widget managed by this component.

## Usage

```lua
world_widget:set_widget(widget)
```

### Arguments

| Name     | Type                             | Description                |
| :------- | :------------------------------- | :------------------------- |
| `widget` | [Widget](/crystal/api/ui/widget) | Widget to manage and draw. |

## Examples

```lua
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.WorldWidget);
entity:set_widget(crystal.Widget:new());
```
