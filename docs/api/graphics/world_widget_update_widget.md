---
parent: crystal.graphics
grand_parent: API Reference
nav_exclude: true
---

# WorldWidget:update_widget

Updates and computes layout for the widget managed by this component. This must be called every frame that this WorldWidget will be drawn.

{: .note}
When using a [DrawSystem](draw_system), you never have to call this function yourself.

## Usage

```lua
world_widget:update_widget(dt)
```

### Arguments

| Name | Type     | Description            |
| :--- | :------- | :--------------------- |
| `dt` | `number` | Delta time in seconds. |
