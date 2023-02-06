[![Actions Status](https://github.com/agersant/crystal/workflows/Build/badge.svg)](https://github.com/agersant/crystal/actions) [![codecov.io](http://codecov.io/github/agersant/crystal/branch/master/graphs/badge.svg)](http://codecov.io/github/agersant/crystal)

# Crystal

🚧 Not ready for production. 🚧

Opinionated gamedev framework built on top of Love2D.

## Build instructions

1. Install the stable version of the [Rust compiler](https://www.rust-lang.org/learn/get-started) (pick MSVC toolchain if prompted)
2. Clone this repository and submodules
3. From the top level of this repository, execute `.\build.ps1`. This downloads the correct version of Love2D and compiles crystal native libraries.
4. From the top level of this repository, execute `.\bin\love.exe game` to launch the game
