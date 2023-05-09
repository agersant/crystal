# Making a release

- Update CHANGELOG.md, commit and push
- On Github, navigate to the Make Release workflow: https://github.com/agersant/crystal/actions/workflows/release.yml
- Click on Run Workflow and type in the user-facing version number. Click `Run workflow`.
- After the workflow completes, promote the release from draft to published.

# Updating LÖVE version

- Update `build.ps1` to download the desired LÖVE version
- Visit https://github.com/love2d/megasource
- Browse the repository at the tag for the desired LÖVE version (eg 11.4)
- Take note of the commit hash used by the LuaJIT submodule under `libs/LuaJIT`
- In the `crystal` repository, navigate to `lib/luajit`
- Run `git checkout <commit_hash_used_by_love>`
- Commit and push changes to the `crystal` repository
