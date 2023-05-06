---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:first_focusable

Advanced
{: .label .label-yellow}

Returns the first focusable element inside this one (or itself). Only elements which can [receive input](ui_element_can_receive_input) are considered.

It is unlikely you need to override this method when implementing custom elements, but you may have to call it to implement [next_focusable](ui_element_next_focusable).

This method does incur a tree traversal.

## Usage

```lua
ui_element:first_focusable(player_index)
```

### Arguments

| Name           | Type     | Description                                                                          |
| :------------- | :------- | :----------------------------------------------------------------------------------- |
| `player_index` | `number` | Number identifying the [player](/crystal/api/input/player) whose inputs to consider. |

### Returns

| Name      | Type                             | Description                      |
| :-------- | :------------------------------- | :------------------------------- |
| `element` | [UIElement](ui_element) \| `nil` | First focusable element, if any. |
