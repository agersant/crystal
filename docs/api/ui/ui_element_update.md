---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:update

Advanced
{: .label .label-yellow}

Runs frame-based logic.

This is called once for every element, within [update_tree](ui_element_update_tree).

## Usage

```lua
ui_element:update(delta_time)
```

### Arguments

| Name         | Type     | Description            |
| :----------- | :------- | :--------------------- |
| `delta_time` | `number` | Delta time in seconds. |

## Examples

This example illustrates how [Widget](widget) elements update their [scripts](/crystal/api/script/script):

```lua
Widget.update = function(self, dt)
  Widget.super.update(self, dt);
  self._script:update(dt);
end
```
