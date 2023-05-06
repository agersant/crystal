---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:set_relative_position

Advanced
{: .label .label-yellow}

Sets this element's position relative to its parent top-left corner.

When implementing custom [Wrapper](wrapper) / [Container](container) elements, you have to call this method on their children from [Wrapper:arrange_child](wrapper_arrange_child) / [Container:arrange_children](container_arrange_children) .

## Usage

```lua
ui_element:set_relative_position(left, right, top, bottom)
```

### Arguments

| Name     | Type     | Description                                                            |
| :------- | :------- | :--------------------------------------------------------------------- |
| `left`   | `number` | Position of the element's left edge relative to its parent left edge.  |
| `right`  | `number` | Position of the element's right edge relative to its parent left edge. |
| `top`    | `number` | Position of the element's top edge relative to its parent top edge.    |
| `bottom` | `number` | Position of the element's bottom edge relative to its parent top edge. |
