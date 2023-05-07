---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Container:arrange_children

Advanced
{: .label .label-yellow}

Computes and sets the relative positions of child elements.

This method is called during [update_tree](ui_element_update_tree) and is responsible for giving each child of this container its position by calling [UIElement:set_relative_position](ui_element_set_relative_position).

You should never have to call this method, but you should override it when implementing custom containers. The implementation often makes use of information supplied by the child element [joints](joint).

## Usage

```lua
container:arrange_children()
```
