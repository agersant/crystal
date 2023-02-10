---
parent: API Reference
title: log
---

# crystal.log

Utility functions to emit log messages. Messages appear in both the console attached to the process and in a log file. Log files are located under the game's save directory (as determined by Love 2D), inside a directory named `logs`. Log files are named based on the timestamp they were created at.

## Functions

| Name                                         | Description                                                     |
| :------------------------------------------- | :-------------------------------------------------------------- |
| [crystal.log.debug()](debug)                 | Emits a log message with the `debug` verbosity.                 |
| [crystal.log.error()](error)                 | Emits a log message with the `error` verbosity.                 |
| [crystal.log.fatal()](fatal)                 | Emits a log message with the `fatal` verbosity.                 |
| [crystal.log.info()](info)                   | Emits a log message with the `info` verbosity.                  |
| [crystal.log.set_verbosity()](set_verbosity) | Sets the verbosity cutoff below which log messages are ignored. |
| [crystal.log.warning()](warning)             | Emits a log message with the `warning` verbosity.               |

## Enums

| Name                   | Description                       |
| :--------------------- | :-------------------------------- |
| [Verbosity](verbosity) | Verbosity level of a log message. |
