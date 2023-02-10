---
nav_exclude: true
---

# crystal.log.set_verbosity

Sets the verbosity cutoff below which log messages are ignored.

## Usage

```lua
crystal.log.set_verbosity(verbosity)
```

### Arguments

| Name        | Type                             | Description                                             |
| :---------- | :------------------------------- | ------------------------------------------------------- |
| `verbosity` | [`Verbosity`](api/log/verbosity) | Most verbose message level that will appear in the log. |

### Example

```lua
crystal.log.set_verbosity("error"); -- Ignore all `debug`, `info` and `warning` messages.
```
