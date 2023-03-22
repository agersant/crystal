---
parent: crystal.test
grand_parent: API Reference
---

# crystal.TestContext

Context object exposing functionality available during tests.

## Properties

| Name      | Type     | Description                                |
| :-------- | :------- | :----------------------------------------- |
| test_name | `string` | Name of the test currently being executed. |

## Methods

| Name                                      | Description                                                              |
| :---------------------------------------- | :----------------------------------------------------------------------- |
| [expect_frame](test_context_expect_frame) | Compares the latest frame drawn by `love.draw`() with a reference image. |
