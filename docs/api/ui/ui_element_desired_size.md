---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# UIElement:desired_size

Advanced
{: .label .label-yellow}

Returns this element's desired size, as last computed by [compute_desired_size](ui_element_compute_desired_size).

You may call this on child elements while implementing custom [Wrapper](wrapper) or [Container](container) element types.

## Usage

```lua
ui_element:desired_size()
```

### Returns

| Name     | Type     | Description     |
| :------- | :------- | :-------------- |
| `width`  | `number` | Desired width.  |
| `height` | `number` | Desired height. |
