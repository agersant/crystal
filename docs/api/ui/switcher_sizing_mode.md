---
parent: crystal.ui
grand_parent: API Reference
nav_exclude: true
---

# Switcher:sizing_mode

Returns how this switcher's desired size is computed.

## Usage

```lua
switcher:sizing_mode()
```

### Returns

| Name          | Type                              | Description                                   |
| :------------ | :-------------------------------- | :-------------------------------------------- |
| `sizing_mode` | [SwitcherSizing](switcher_sizing) | How this switcher's desired size is computed. |

## Examples

```lua
local switcher = crystal.Switcher:new();
print(switcher:sizing_mode()); -- Prints "active"
```
