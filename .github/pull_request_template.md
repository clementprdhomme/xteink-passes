## What and why

<!-- What the change does, and the issue it closes if any (Closes #…) -->

## Checklist

- [ ] `luacheck src` reports nothing
- [ ] Tested in the Studio preview with the X4 Pro and the X4 Classic profiles
- [ ] Every text the user sees is a message in `lang/en.tsv`, and every `lang/<locale>.tsv` is updated
- [ ] The README, CONTRIBUTING.md and the About texts (`about.*` in `lang/en.tsv`) describe the app as it is
- [ ] For a release: `APP.VERSION` in `src/constants.lua` matches `version` in `src/manifest.json`
