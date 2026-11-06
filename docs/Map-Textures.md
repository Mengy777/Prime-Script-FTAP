# Map textures — 3.2.2a

20 authored texture themes;41 choices in the texture library (33 Roblox PBR sets +8 authored pattern images). Classic native materials and their8 previous palettes are a separate editing mode.

## Sources and scope

- Official Roblox map IDs: https://create.roblox.com/docs/parts/materials#asset-and-property-reference . Color/normal/metalness/roughness IDs taken from the current base-material table on2026-11-06; see tools/map_material_ids.json. These images are referenced on Roblox, not redistributed.
- MaterialVariant behavior: https://create.roblox.com/docs/reference/engine/classes/MaterialVariant . Each variant keeps its target native BaseMaterial; the script does not set global material overrides or change part physical properties.
- Eight new512×512 grayscale/recolorable PNGs were authored procedurally for this project: checker, grid, circuit, hex, clouds, rose, candy, stars. Reproducible generator: tools/generate_map_textures.py (Pillow). No Minecraft textures or third-party texture pack were copied.
- Themes are original combinations inspired by broad visual styles, not exact reconstructions of another game or unknown third-party preset. Minecraft is explicitly deferred until a reference is supplied.

## Themes

| Theme | Grass / lush grass / rock | Tile size |
| --- | --- | --- |
| Dreamcore | Dream checker / Soft clouds / Marble | 14 |
| Rainbow World | Dream checker / Hologram hex / CeramicTiles | 12 |
| Rose Quartz | Rose pattern / Fabric / Marble | 10 |
| Neon Tokyo | Arcade grid / Circuit traces / Asphalt | 16 |
| Cyberpunk | Circuit traces / Hologram hex / CorrodedMetal | 14 |
| Vaporwave | Dream checker / Candy stripes / Plaster | 16 |
| Cotton Clouds | Soft clouds / Fabric / Limestone | 18 |
| Candyland | Candy stripes / Dream checker / Marble | 10 |
| Liminal Hotel | Carpet / Rose pattern / Concrete | 8 |
| Lunar Outpost | Pavement / Arcade grid / Rock | 12 |
| Frozen Palace | Glacier / Ice / Granite | 12 |
| Volcanic Forge | CrackedLava / Basalt / Basalt | 10 |
| Emerald Ruins | LeafyGrass / Grass / Cobblestone | 10 |
| Atlantis | CeramicTiles / Hologram hex / Limestone | 14 |
| Solar Desert | Sandstone / Ground / Limestone | 10 |
| Space Arcade | Pixel stars / Arcade grid / Rubber | 16 |
| Monochrome Lab | Dream checker / Metal / Granite | 10 |
| Royal Amethyst | Marble / Rose pattern / Slate | 10 |
| Enchanted Grove | Grass / LeafyGrass / Rock | 10 |
| Retro Playground | Brick / Candy stripes / Cobblestone | 12 |

## Editing

Graphics → Map surfaces → feature settings → Custom textures → theme → Apply map palette. Choose a surface below to edit its texture, scale1–64, optional tint/rainbow or Custom image ID. Changes apply live and persist in autosave/named configurations. Built-in templates stay available for reapplication. Switching to Classic materials restores independent saved native-material settings. Reset clears both visible effects; disable/unload restores originals.

## Lifecycle / limits

Local MaterialVariant instances are shared per category/native material, updated in place on preset changes, and removed on disable/unload. Existing variants are retained. Mesh texture IDs and native decals/SurfaceAppearance are restored through property layers; no native object is destroyed. No per-part six-face overlays or repeated menu-open scene scans. Late parts/map replacement are handled by the existing map adapter.

Authored PNGs download lazily from the matching Git tag into executor-relative PrimeVisuals/Assets and are cached. Binary length/header checked; HTTP/request fallback, two bounded attempts and late-unload cancellation. Executors without local image asset APIs use documented Roblox image fallbacks with a notice. Normal Roblox asset permissions and actual MaterialVariant rendering still need in-game verification. Textured native ocean parts are separate from Terrain realistic water.

Validation:40 scenario scripts /122 groups, zero failures in simulated APIs. Material/decoration restoration, all20 themes, persistence, bounded allocations, asset cache/fallback and user-unload cancellation tested. This is not a live-render or FPS measurement.
