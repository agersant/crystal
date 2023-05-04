---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.ui

## Functions

| Name                    | Description                                                |
| :---------------------- | :--------------------------------------------------------- |
| [crystal.ui.font](font) | Returns a registered [font](https://love2d.org/wiki/Font). |

## Classes

### Leaf UI elements

| Name                            | Description                                                        |
| :------------------------------ | :----------------------------------------------------------------- |
| [crystal.Border](border)        | A [UI element](ui_element) which draws a border around itself.     |
| [crystal.Image](image)          | A [UI element](ui_element) which draws a texture or a solid color. |
| [crystal.Text](text)            | A [UI element](ui_element) which draws text.                       |
| [crystal.UIElement](ui_element) | Base class for all UI building blocks.                             |

### Containers & Wrappers

| Name                                      | Description                                                                |
| :---------------------------------------- | :------------------------------------------------------------------------- |
| [crystal.Container](container)            | A [UI element](ui_element) which can contain multiple child elements.      |
| [crystal.HorizontalList](horizontal_list) | A [Container](container) which aligns children horizontally.               |
| [crystal.Overlay](overlay)                | A [Container](container) which aligns children relatively to itself.       |
| [crystal.Painter](painter)                | A [Wrapper](wrapper) which applies a shader to its child.                  |
| [crystal.RoundedCorners](rounded_corners) | A [Painter](painter) which crops the corners of its child.                 |
| [crystal.Switcher](switcher)              | A [Container](container) which draws only one child at a time.             |
| [crystal.VerticalList](vertical_list)     | A [Container](container) which aligns children vertically.                 |
| [crystal.Widget](widget)                  | A [Wrapper](wrapper) which manages a [Script](/crystal/api/script/script). |
| [crystal.Wrapper](wrapper)                | A [UI element](ui_element) which can contain one child element.            |

### Joints

| Name                                                 | Description                                                                                     |
| :--------------------------------------------------- | :---------------------------------------------------------------------------------------------- |
| [crystal.BasicJoint](basic_joint)                    | A [Joint](joint) with common padding and alignment options.                                     |
| [crystal.HorizontalListJoint](horizontal_list_joint) | A [Joint](joint) specifying how elements are positioned in a [HorizontalList](horizontal_list). |
| [crystal.Joint](joint)                               | Defines how a [UI element](ui_element) should be laid out by its parent.                        |
| [crystal.Padding](padding)                           | Utility class storing up/down/left/right padding amounts.                                       |
| [crystal.VerticalListJoint](vertical_list_joint)     | A [Joint](joint) specifying how elements are positioned in a [VerticalList](vertical_list).     |

## Enums

| Name                                        | Description                                  |
| :------------------------------------------ | :------------------------------------------- |
| [HorizontalAlignment](horizontal_alignment) | Distinct ways to align content horizontally. |
| [VerticalAlignment](vertical_alignment)     | Distinct ways to align content vertically.   |
