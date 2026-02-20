---
name: dbcaptain
description: >
  API reference for dbcaptain, a CLI for reading, writing, creating, and merging WoW 3.3.5a DBC
  files. Use when working with DBC files, WoW spells, items, tables, schemas, or any task that
  involves manipulating WoW 3.3.5 game data files. Covers all commands: read, create, merge,
  apply, export, diff, validate, schema, copy-entry.
---

# dbcaptain Reference

CLI tool for WoW 3.3.5a DBC files. Source and workspace: `/Users/alfred/git/dbcaptain`.

## Invocation

```nushell
# Via cargo (always works, no install required)
cargo run --manifest-path /Users/alfred/git/dbcaptain/Cargo.toml -p dbcaptain -- <command>

# If installed
dbcaptain <command>
```

---

## Commands

### `schema <Table>`

Print all field names and types for a table.

```nushell
cargo run ... -- schema Spell
cargo run ... -- schema SpellDuration
```

### `read <file> --schema <Table>`

Dump records as a table (default), JSON, TOML, or CSV.

```nushell
cargo run ... -- read Spell.dbc --schema Spell
cargo run ... -- read Spell.dbc --schema Spell --id 133
cargo run ... -- read Spell.dbc --schema Spell --format json
cargo run ... -- read Spell.dbc --schema Spell --format toml
cargo run ... -- read Spell.dbc --schema Spell --format csv
```

Flags: `--id <u32>` filters to a single record. `--format table|json|toml|csv`.

### `create <input.toml> <output.dbc> --schema <Table>`

Build a DBC from a TOML file containing `[[entries]]`.

```nushell
cargo run ... -- create my_spells.toml CustomSpell.dbc --schema Spell
```

### `merge <base.dbc> <patch.dbc> <output.dbc> --schema <Table>`

Merge two DBCs; patch entries override base entries by ID.

```nushell
cargo run ... -- merge base/Spell.dbc patch/Spell.dbc out/Spell.dbc --schema Spell
```

### `apply <bundle.toml> --base-dir <dir> --output-dir <dir>`

Multi-table bundle: create + merge in one step. For each table in the bundle, if
`<base-dir>/<Table>.dbc` exists the patch is merged into it; otherwise the patch becomes
the output directly.

```nushell
cargo run ... -- apply my_mod.toml --base-dir dbc/base --output-dir dbc/out
```

### `export <file> --schema <Table> --format json|csv`

Bulk export all records to JSON or CSV.

```nushell
cargo run ... -- export Spell.dbc --schema Spell --format json
cargo run ... -- export Spell.dbc --schema Spell --format csv
```

### `diff <a.dbc> <b.dbc> --schema <Table>`

Show record-level differences between two DBC files.

```nushell
cargo run ... -- diff base/Spell.dbc patched/Spell.dbc --schema Spell
```

### `validate <file> --schema <Table>`

Check that a DBC's header matches the schema (field count, record size).

```nushell
cargo run ... -- validate Spell.dbc --schema Spell
```

### `copy-entry <file> --schema <Table> --id <ID> [-o output.toml]`

Extract one record as a create-compatible TOML snippet. Omit `-o` to print to stdout.

```nushell
cargo run ... -- copy-entry Spell.dbc --schema Spell --id 133
cargo run ... -- copy-entry Spell.dbc --schema Spell --id 133 -o fireball_template.toml
```

---

## TOML Entry Format (`create` and `copy-entry` output)

```toml
[[entries]]
ID = 90001
Name = "Custom Spell"           # StringRef / LocaleString: plain string
SchoolMask = "Frost | Arcane"   # Flags: pipe-separated names OR raw integer
Dispel = "Magic"                # Enum: label name OR raw integer
BaseDuration = 5000             # uint32 / int32: integer
Radius = 10.0                   # float32: number
```

Rules:
- Field names must match schema field names exactly (case-sensitive).
- **ID** is required when the first schema field is named `ID`.
- **Flags** fields: `"FlagA | FlagB"` string OR raw integer. Use `schema` command to see valid
  names.
- **Enum** fields: label string like `"Weapon"` OR raw integer.
- **LocaleString**: provide a single string — it populates the enUS slot.
- **float32**: accepts integers too (`10` is valid for a float field).
- Omitted fields default to `0` / empty string.

---

## Apply Bundle Format

```toml
[bundle]
name = "My Mod"          # optional metadata, ignored by apply

[Spell]
[[Spell.entries]]
ID = 90001
Name = "Custom Spell"
SchoolMask = "Frost | Arcane"

[SpellDuration]
[[SpellDuration.entries]]
ID = 200
BaseDuration = 5000
PerLevel = 0
MaximumDuration = 30000
```

- `[bundle]` section is optional.
- Each top-level key must be a valid schema name.
- Each section must have at least one `[[<Table>.entries]]` item.
- Tables are processed independently; missing base DBC is fine (creates from scratch).

---

## Common Workflow: Adding a New Spell

```nushell
# 1. Inspect the schema
cargo run ... -- schema Spell

# 2. Copy an existing spell as a starting template
cargo run ... -- copy-entry base/Spell.dbc --schema Spell --id 133 -o fireball.toml

# 3. Edit fireball.toml — change ID, Name, etc.

# 4a. Quick path: create-only DBC (no base merge)
cargo run ... -- create fireball.toml CustomSpell.dbc --schema Spell

# 4b. Or merge into an existing base
cargo run ... -- merge base/Spell.dbc CustomSpell.dbc out/Spell.dbc --schema Spell

# 4c. Or use apply for multi-table mods
cargo run ... -- apply my_mod.toml --base-dir dbc/base --output-dir dbc/out

# 5. Verify the result
cargo run ... -- validate out/Spell.dbc --schema Spell
cargo run ... -- read out/Spell.dbc --schema Spell --id 90001
```

---

## Available Schemas (244 total)

Use `cargo run ... -- schema <Name>` to inspect any table.

**Spell system:**
Spell, SpellDuration, SpellCastTimes, SpellRange, SpellRadius, SpellIcon, SpellVisual,
SpellVisualKit, SpellMissile, SpellRuneCost, SpellShapeshiftForm, SpellDispelType,
SpellMechanic, SpellFocusObject, SpellItemEnchantment, SpellItemEnchantmentCondition

**Items:**
Item, ItemClass, ItemSubClass, ItemDisplayInfo, ItemSet, ItemBagFamily, ItemExtendedCost,
ItemLimitCategory, ItemRandomProperties, ItemRandomSuffix

**Characters:**
ChrClasses, ChrRaces, CharTitles, CharBaseInfo, CharSections, CharHairGeosets,
CharHairTextures, CharacterFacialHairStyles

**World / zones:**
AreaTable, AreaTrigger, AreaPOI, WorldMapArea, WorldMapContinent, WorldMapOverlay,
Map, DungeonMap, WMOAreaTable, LiquidType, Light

**Creatures / NPCs:**
CreatureDisplayInfo, CreatureDisplayInfoExtra, CreatureModelData, CreatureType,
CreatureFamily, CreatureSoundData, NpcSounds, UnitBlood

**Talents / progression:**
Talent, TalentTab, SkillLine, SkillLineAbility, SkillRaceClassInfo, SkillTiers,
TotemCategory, Achievement, Achievement_Category, Achievement_Criteria

**Miscellaneous:**
Faction, FactionGroup, FactionTemplate, CurrencyTypes, GemProperties, ScalingStatValues,
ScalingStatDistribution, SpellShapeshiftForm, Vehicle, VehicleSeat, BattlemasterList,
Holidays, LFGDungeons, PvpDifficulty, RandPropPoints, SoundEntries
