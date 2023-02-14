---
parent: API Reference
has_children: true
has_toc: false
---

# crystal.const

While iterating on a feature, it is convenient to rapidly adjust constants and see how it changes the end result. This is especially true when working on particle effects or fine tuning gameplay mechanics.

This module exposes an easy way to define and adjust such constants. Values can be adjusted via the [console](/crystal/tools/console) or using a MIDI controller to map constants to physical knobs with [Live Tune](/crystal/tools/live_tune).

## Functions

| Name                           | Description                                               |
| :----------------------------- | :-------------------------------------------------------- |
| [crystal.const.define](define) | Defines a new constant.                                   |
| [crystal.const.get](get)       | Reads the value of a constant.                            |
| [crystal.const.set](set)       | In development builds only, sets the value of a constant. |
