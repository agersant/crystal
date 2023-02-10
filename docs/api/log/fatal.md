---
nav_exclude: true
---

# crystal.log.fatal

Prints a message to the log at the [fatal](api/log/verbosity) level.

## Usage

```lua
crystal.log.fatal(message)
```

### Arguments

| Name      | Type     | Description                      |
| :-------- | :------- | -------------------------------- |
| `message` | `string` | The message to print in the log. |

### Example

```lua
crystal.log.fatal("Division by 0");
```
