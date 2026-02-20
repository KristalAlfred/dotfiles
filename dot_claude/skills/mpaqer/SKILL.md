---
name: mpaqer
description: API reference for the mpq CLI — read, list, extract, create, and verify MPQ archives used by WoW 3.3.5. Use when working with MPQ archives, WoW patch files, extracting DBC files, or creating patch archives to inject content into the WoW client.
---

# mpaqer — MPQ Archive CLI

Binary name: `mpq`
Source: `/Users/alfred/git/mpaqer`
Build: `cargo build --release` — binary lands at `target/release/mpq`

MPQ is the compressed archive format used by World of Warcraft 3.3.5 (WOTLK). This CLI reads and creates MPQ archives.

## Commands

### info

Show archive header metadata.

```
mpq info <archive>
mpq info -v <archive>   # verbose: occupied hash entries, existing blocks
```

Output: format version, sector size, hash/block table positions, known file count, attributes summary.

### list

List files in an archive.

```
mpq list <archive>
mpq list -l <archive>                        # long: size, compressed size, flags
mpq list --filter "DBFilesClient\*" <archive>
mpq list --listfile names.txt <archive>      # supply external listfile
```

Flags column: `C` = compressed, `I` = implode, `E` = encrypted, `K` = key v2, `S` = single unit.

If the archive has no internal `(listfile)`, file names will be unknown. Use `--listfile` to provide one.

### extract

Extract files from an archive.

```
mpq extract <archive>                              # extract all known files
mpq extract <archive> -o out/                      # output directory (default: .)
mpq extract <archive> "DBFilesClient\Spell.dbc"    # extract one file
mpq extract <archive> -o out/ --overwrite          # overwrite existing
mpq extract <archive> --listfile names.txt         # supply external listfile
```

Backslash separators in MPQ paths are converted to forward slashes on disk. Directory structure is preserved under the output directory.

If no file names are known and none are specified, the command errors — you must provide names explicitly or via `--listfile`.

### verify

Verify CRC32 and MD5 integrity against the `(attributes)` file.

```
mpq verify <archive>                   # verify all known files
mpq verify <archive> "Units\Human.m2"  # verify one file
```

Exits with status 1 if any file fails. Files missing from the archive are skipped (not counted as failures).

### create

Create a new MPQ archive from a directory. All files in the directory tree are added; subdirectory structure is preserved using backslash separators.

```
mpq create out.mpq --from my-mod/
```

A `(listfile)` is always generated. An `(attributes)` file with CRC32/MD5 is generated unless `--no-attributes` is passed.

**Options:**

| Flag | Default | Description |
|------|---------|-------------|
| `--from <dir>` | required | Source directory |
| `--sector-shift N` | `3` (4096 bytes) | Sector size = 512 << N |
| `--compression-level 0-9` | `6` | zlib compression (0 = store) |
| `--no-compress` | off | Store all files raw (overrides level) |
| `--no-attributes` | off | Skip `(attributes)` verification metadata |

Sector shift reference: 3 → 4096 B, 4 → 8192 B, 5 → 16384 B.

## WoW Client Integration

WoW 3.3.5 loads MPQ archives in a defined order. Patch archives override base archives:

```
Data/common.MPQ        ← lowest priority
Data/expansion.MPQ
Data/lichking.MPQ
Data/patch.MPQ
Data/patch-2.MPQ
Data/patch-3.MPQ       ← highest priority (highest number wins)
```

To inject custom content, create a patch archive with a number higher than the highest existing patch. Files inside must use the **exact internal paths** that WoW expects — these use backslash separators and match the directory layout within the base archives.

Common internal path prefixes:

- `DBFilesClient\Spell.dbc`
- `DBFilesClient\Item.dbc`
- `Interface\GlueXML\GlueStrings.lua`
- `Interface\AddOns\...`

## Limitations

- Cannot modify existing archives in-place
- Write compression is zlib only (no bzip2, LZMA, etc.)
- No encryption on write
- To "update" an archive: extract → modify → create new

## DBC Injection Workflow

Typical workflow when working with dbcaptain to inject modified DBC files:

```bash
# 1. Extract base DBCs from an existing patch
mpq extract "Data/patch-3.MPQ" --filter "DBFilesClient\*" -o base/

# 2. Modify DBCs with dbcaptain (apply, create, etc.)

# 3. Stage modified files preserving internal path structure
mkdir -p patch_content/DBFilesClient
cp modified/Spell.dbc patch_content/DBFilesClient/

# 4. Create the patch archive
mpq create "Data/patch-4.MPQ" --from patch_content/

# 5. Verify the result
mpq list "Data/patch-4.MPQ"
mpq verify "Data/patch-4.MPQ"
```

The directory structure under `patch_content/` maps directly to internal MPQ paths (with backslashes). If your files need to be at `DBFilesClient\Spell.dbc` inside the archive, they must be at `patch_content/DBFilesClient/Spell.dbc` on disk.
