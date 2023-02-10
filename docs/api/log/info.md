---
nav_exclude: true
---

# crystal.log.info

Prints a message to the log at the [info](api/log/verbosity) level.

## Usage

```lua
crystal.log.info(message)
```

### Arguments

| Name      | Type     | Description                      |
| :-------- | :------- | -------------------------------- |
| `message` | `string` | The message to print in the log. |

### Example

```lua
crystal.log.info("Player received 120 damage");
```
