---
parent: crystal.log
grand_parent: API Reference
---

# crystal.log.error

Prints a message to the log at the [error](verbosity) level.

## Usage

```lua
crystal.log.error(message)
```

### Arguments

| Name      | Type     | Description                      |
| :-------- | :------- | -------------------------------- |
| `message` | `string` | The message to print in the log. |

### Example

```lua
crystal.log.error("Could not find spawn location for Monster");
```
