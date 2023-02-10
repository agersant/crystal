---
nav_exclude: true
---

# crystal.log.debug

Prints a message to the log at the [debug](api/log/verbosity) level.

## Usage

```lua
crystal.log.debug(message)
```

### Arguments

| Name      | Type     | Description                      |
| :-------- | :------- | -------------------------------- |
| `message` | `string` | The message to print in the log. |

### Example

```lua
crystal.log.debug("Handling jump input");
```