---
parent: crystal.log
grand_parent: API Reference
---

# crystal.log.warning

Prints a message to the log at the [warning](verbosity) level.

## Usage

```lua
crystal.log.warning(message)
```

### Arguments

| Name      | Type     | Description                      |
| :-------- | :------- | -------------------------------- |
| `message` | `string` | The message to print in the log. |

### Example

```lua
crystal.log.warning("Could not find valid target for Fireball spell");
```
