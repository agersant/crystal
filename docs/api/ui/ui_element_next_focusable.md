---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:next_focusable

Advanced
{: .label .label-yellow}

Returns the next focusable element from this one in the specified direction.

You may override this method when implementing containers that can interpret directional navigation to move focus between elements.

## Usage

```lua
ui_element:next_focusable(from_element, player_index, direction)
```

### Arguments

| Name           | Type                    | Description                                                                          |
| :------------- | :---------------------- | :----------------------------------------------------------------------------------- |
| `from_element` | [UIElement](ui_element) | Child element inside this one to navigate from.                                      |
| `player_index` | `number`                | Number identifying the [player](/crystal/api/input/player) whose inputs to consider. |
| `direction`    | [Direction]             | Navigation direction.                                                                |

### Returns

| Name      | Type                             | Description                                       |
| :-------- | :------------------------------- | :------------------------------------------------ |
| `element` | [UIElement](ui_element) \| `nil` | Next focusable element in this direction, if any. |

## Examples

This example is a slightly simplified version of the `next_focusable` implementation for [HorizontalList](horizontal_list) elements:

```lua
HorizontalList.next_focusable = function(self, from_element, player_index, direction)
  local from_index = table.index_of(self._children, from_element);
  local delta = 0;
  if direction == "down" then
    delta = 1;
  elseif direction == "up" then
    delta = -1;
  else
    return HorizontalList.super.next_focusable(self, from_element, player_index, direction);
  end
  local to_index = from_index + delta;
  to_element = self._children[to_index];
  while to_element do
    local next_focusable = to_element:first_focusable(player_index);
    if next_focusable then
      return next_focusable;
    end
    to_index = to_index + delta;
    to_element = self._children[to_index];
  end
end
```
