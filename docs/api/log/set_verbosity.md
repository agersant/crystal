---
parent: crystal.log
grand_parent: API Reference
nav_order: 1
---

# crystal.log.set_verbosity

Sets the verbosity cutoff below which log messages are ignored.

## Usage

```lua
crystal.log.set_verbosity(verbosity)
```

### Arguments

| Name        | Type                     | Description                                             |
| :---------- | :----------------------- | :------------------------------------------------------ |
| `verbosity` | [`Verbosity`](verbosity) | Most verbose message level that will appear in the log. |

## Examples

```lua
crystal.log.set_verbosity("error"); -- Ignore all `debug`, `info` and `warning` messages.
```
