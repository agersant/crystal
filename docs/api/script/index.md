---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.script

## Overview

### Signals

### Working with Scripts and Entities

## Classes

| Name                                  | Description                                                                                                           |
| :------------------------------------ | :-------------------------------------------------------------------------------------------------------------------- |
| [crystal.Behavior](behavior)          | [Component](/crystal/api/ecs/component) which can attach a premade script to an entity.                               |
| [crystal.Script](script)              | Logical grouping of [threads](thread).                                                                                |
| [crystal.ScriptRunner](script_runner) | [Component](/crystal/api/ecs/component) which allows an entity to run scripts.                                        |
| [crystal.ScriptSystem](script_system) | [System](/crystal/api/ecs/system) which makes [ScriptRunner](script_runner) and [Behavior](behavior) components work. |
| [crystal.Thread](thread)              | A piece of logic that can run over multiple frames.                                                                   |
