---
name: texprep
description: CLI for splitting and recombining PNG alpha channels when prepping WoW textures for AI image generation. Use when working with texture alpha channels, stripping alpha for AI generation, or recombining generated textures with original alpha data.
---

# texprep — PNG Alpha Channel Splitter/Combiner

Binary: `texprep` (installed via `cargo install --path`)
Source: `/Users/alfred/git/svartkonst-wow/tooling/texprep`

WoW textures encode non-visual data (heightmaps, masks) in the alpha channel. This tool strips alpha before AI generation and re-applies it after.

## Commands

### strip

Split a PNG into RGB and alpha components.

```
texprep strip <input.png>
texprep strip <input.png> -o <output_dir>
```

Produces `<name>_rgb.png` (RGB only) and `<name>_alpha.png` (alpha as grayscale).
If the image has no meaningful alpha (all 255), only the RGB file is created with a warning.

### apply

Recombine an RGB image with a grayscale alpha image.

```
texprep apply <rgb.png> <alpha.png>
texprep apply <rgb.png> <alpha.png> -o <output.png>
```

Produces `<rgb_name>_final.png` by default. Errors if dimensions don't match.

## Typical Workflow

```bash
# 1. Strip alpha before AI generation
texprep strip terrain_texture.png

# 2. Feed terrain_texture_rgb.png to AI tool, get back generated_rgb.png

# 3. Re-apply original alpha
texprep apply generated_rgb.png terrain_texture_alpha.png -o terrain_texture_final.png
```
