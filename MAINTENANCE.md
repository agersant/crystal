# Making a release

- Update `CHANGELOG.md`, commit and push
- On Github, navigate to the `Make Release` workflow: https://github.com/agersant/crystal/actions/workflows/release.yml
- Click on the `Run workflow` dropdown and type in the user-facing version number. Click the `Run workflow` button.
- After the workflow completes, promote the release from draft to published.

# Updating LÖVE version

- Update `build.ps1` to download the desired LÖVE version
- Commit and push changes to the `crystal` repository
