# Updating Love2D version

- Update `build.ps1` to download the desired Love2D version
- Visit https://github.com/love2d/megasource
- Browse the repository at the tag for the desired Love2D version (eg 11.4)
- Take note of the commit hash used by the LuaJIT submodule under `libs/LuaJIT`
- In the `crystal` repository, navigate to `lib/luajit`
- Run `git checkout <commit_hash_used_by_love>`
- Commit and push changes to the `crystal` repository
