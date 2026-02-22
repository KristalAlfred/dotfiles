---
name: wow-modding
description: WoW 3.3.5a (WOTLK) modding overview. Use when working on WoW mod tasks, client patching, texture work, DBC editing, MPQ archives, or AIO plugins. Pulls in relevant sub-skills.
dependencies:
  - mpaqer
  - dbcaptain
  - texprep
  - wow-aio-plugin
---

# WoW 3.3.5a Modding

Project root: `/Users/alfred/git/svartkonst-wow`

## Project Structure

```
data/dbc/          — DBC files (game data tables)
data/sql/          — SQL for auth/world/character databases
modules/           — C++ server modules (mod-*)
client-patching/   — Client-side patches and launcher
tooling/           — Custom CLI tools (texprep, etc.)
```

## Tool Chain

| Tool | Binary | Purpose |
|------|--------|---------|
| dbcaptain | `dbcaptain` | Read, write, merge, diff DBC files |
| mpaqer | `mpq` | Create, extract, verify MPQ archives |
| texprep | `texprep` | Strip/recombine PNG alpha channels for AI texture generation |

## Common Workflows

### Modifying game data (spells, items, etc.)

1. Edit DBC with `dbcaptain`
2. Stage files preserving internal path structure (`DBFilesClient\*.dbc`)
3. Pack into MPQ patch with `mpq create`
4. Deploy to client `Data/` directory

### AI texture generation

1. `texprep strip` to separate RGB from alpha (WoW packs heightmaps/masks in alpha)
2. Run AI generation on the RGB image
3. `texprep apply` to restore original alpha
4. Pack into MPQ patch

### Client-side Lua plugins (AIO)

Use the AIO framework for server-authoritative Lua that runs on the client.
See the `wow-aio-plugin` skill for the full API.

## Key Conventions

- WoW 3.3.5a (WOTLK) — all tooling targets this version
- MPQ internal paths use **backslash** separators (`DBFilesClient\Spell.dbc`)
- Patch archives load in numeric order; highest number wins
- Server uses AzerothCore (C++ with modules in `modules/`)
