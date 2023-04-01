---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# WorldWidget:widget

Returns the widget managed by this component.

## Usage

```lua
world_widget:widget()
```

### Returns

| Name     | Type                             | Description                       |
| :------- | :------------------------------- | :-------------------------------- |
| `widget` | [Widget](/crystal/api/ui/widget) | Widget managed by this component. |

## Examples

```lua
local widget = crystal.Widget:new();
local ecs = crystal.ECS:new();
local entity = ecs:spawn(crystal.Entity);
entity:add_component(crystal.WorldWidget);
entity:set_widget(widget);
assert(entity:widget() == widget);
```
