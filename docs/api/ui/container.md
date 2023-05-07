---
parent: crystal.ui
grand_parent: API Reference
nav_order: 2
---

# crystal.Container

Base class for [UI elements](ui_element) which can contain multiple child elements.

Some example container classes are [HorizontalList](horizontal_list), [VerticalList](vertical_list) and [Overlay](overlay).

## Constructor

```lua
crystal.Container:new()
```

## Methods

| Name                                           | Description                                    |
| :--------------------------------------------- | :--------------------------------------------- |
| [add_child](container_add_child)               | Adds a child element to this container.        |
| [arrange_children](container_arrange_children) | Computes relative positions of child elements. |
| [child](container_child)                       | Returns a child element by index.              |
| [children](container_children)                 | Returns the list of child elements.            |
| [remove_child](container_remove_child)         | Removes a child element.                       |
