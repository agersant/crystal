---
parent: crystal.log
grand_parent: API Reference
nav_order: 1
---

# crystal.log.fatal

Prints a message to the log at the [fatal](verbosity) level.

## Usage

```lua
crystal.log.fatal(message)
```

### Arguments

| Name      | Type     | Description                      |
| :-------- | :------- | :------------------------------- |
| `message` | `string` | The message to print in the log. |

## Examples

```lua
crystal.log.fatal("Division by 0");
```
