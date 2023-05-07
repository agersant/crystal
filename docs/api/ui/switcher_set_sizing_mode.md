---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Switcher:set_sizing_mode

Sets how this switcher's desired size is computed.

- When using the `"active"` sizing mode, the `Switcher`'s desired size is that of its active child. During transitions, the size is interpolated.
- When using the `"largest"` sizing mode, the `Switcher`'s desired size is that of its largest child.

The default mode is `"active"`.

## Usage

```lua
switcher:set_sizing_mode(mode)
```

### Arguments

| Name          | Type                              | Description           |
| :------------ | :-------------------------------- | :-------------------- |
| `sizing_mode` | [SwitcherSizing](switcher_sizing) | Switcher sizing mode. |

## Examples

```lua
local switcher = crystal.Switcher:new();
switcher:set_sizing_mode("largest");
```
