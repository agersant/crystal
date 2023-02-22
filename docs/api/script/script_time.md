---
parent: crystal.script
grand_parent: API Reference
nav_exclude: true
---

# Script:time

Returns the cumulative time passed to all [Script:update](script_update) calls, in seconds.

## Usage

```lua
script:time()
```

### Returns

| Name   | Type     | Description              |
| :----- | :------- | :----------------------- |
| `time` | `number` | Time elapsed in seconds. |

## Examples

```lua
local script = crystal.Script:new();
script:update(0.4);
script:update(0.7);
print(script:time()); -- prints 1.1
```
