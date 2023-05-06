---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:compute_desired_size

Advanced
{: .label .label-yellow}

Computes and returns the size requested by this element for layout purposes. This is called within [update_tree](ui_element_update_tree).

For leaf elements like [Image](image) or [Text](text), this returns how much space they require to draw.

[Wrapper](wrapper) and [Container](container) elements usually call this method recursively on their children, and combine results with [joint](joint) data to derive the total desired size.

## Usage

```lua
ui_element:compute_desired_size()
```

### Returns

| Name     | Type     | Description     |
| :------- | :------- | :-------------- |
| `width`  | `number` | Desired width.  |
| `height` | `number` | Desired height. |

## Examples

This example is the implementation of `compute_desired_size` for [Overlay](overlay) containers:

```lua
Overlay.compute_desired_size = function(self)
  local width, height = 0, 0;
  for child, joint in pairs(self.child_joints) do
    local child_width, child_height = child:desired_size();
    local padding_left, padding_right, padding_top, padding_bottom = joint:padding();
    local h_align, v_align = joint:alignment();
    if h_align ~= "stretch" then
      width = math.max(width, child_width + padding_left + padding_right);
    end
    if v_align ~= "stretch" then
      height = math.max(height, child_height + padding_top + padding_bottom);
    end
  end
  return math.max(width, 0), math.max(height, 0);
end
```
