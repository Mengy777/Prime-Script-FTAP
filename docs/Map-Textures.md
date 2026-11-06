# Downloaded PBR map library — 3.2.2b

Powered by Poly Haven. Materials also supplied by ambientCG and TextureCan.

The rejected procedural images, Roblox-base-map catalogue and its20 themes were removed from the current release. They are replaced by35 downloaded external PBR materials from3 libraries and20 newly assembled themes. All110 original map files are stored in assets/map-pbr (83.4MiB total). Source images are1K (1024px longest edge), not upscaled. Normal maps are OpenGL tangent-space maps as expected by Roblox.

## Sources / rights

- Poly Haven: https://polyhaven.com/license — CC0; API used only during asset import, not by the running script.
- ambientCG: https://docs.ambientcg.com/license/ — CC0, including raw-file redistribution.
- TextureCan: https://www.texturecan.com/terms/ — CC0; project redistribution explicitly permitted.
- Roblox normal-map convention: https://create.roblox.com/docs/reference/engine/classes/MaterialVariant#NormalMap .
- Each source URL, archive member, filename, byte count and SHA256 recorded in tools/pbr-texture-manifest.json. Reproduce downloads with tools/fetch_pbr_assets.py; regenerate Lua catalogue from manifest/themes with tools/build_pbr_catalog.py. No third-party scripts/loaders are executed.

## Theme recipes

The principal ground material is different in all20 themes. Natural albedo is preserved: presets set tint to white, not20 different recolors of one texture. Other surfaces use supporting materials; ocean remains original unless edited separately.

| Theme | Main ground | Walls / accent |
| --- | --- | --- |
| Alpine Expedition | Detailed Snow | Cliff Rock / Mossy Rock |
| Forest Sanctuary | Forest Floor | Mossy Rock / Lush Forest Ground |
| Tropical Coast | Coastal Sand | Weathered Rock / Old Cobblestone |
| Dreamcore Atrium | White Veined Marble | Detailed White Plaster / Pink Granite |
| Medieval Town | Old Cobblestone | Weathered Brick / Aged Timber |
| Industrial Hangar | Industrial Steel | Worn Concrete / Blue Steel |
| Abandoned Factory | Weathered Brick | Aged Tiles / Mossy Brick |
| Cyberpunk Station | Blue Steel | Black Veined Marble / Sculpted Silver Plates |
| Timber Lodge | Aged Timber | Weathered Rock / Brown Leather |
| Volcanic Citadel | Volcanic Stone | Cliff Rock / Black Veined Marble |
| Emerald Temple | Jade Marble | Mossy Brick / Veined Stone Tiles |
| Rose Quartz Palace | Pink Terrazzo | White Veined Marble / Pink Granite |
| Deep Rock Cavern | Cliff Rock | Mossy Rock / Weathered Rock |
| Modern Art Gallery | Veined Stone Tiles | Detailed White Plaster / Terrazzo |
| Terracotta Courtyard | Terracotta | Orange Brick / Coastal Sand |
| Urban District | Road Asphalt | Worn Concrete / Decorative Steel |
| Armored Foundry | Sculpted Silver Plates | Decorative Steel / Industrial Steel |
| Festive Workshop | Festive Gilded Paper | Aged Timber / Terracotta |
| Rainbow Atelier | Colorful Spangles | White Veined Marble / Pink Terrazzo |
| Blue Porcelain Garden | Blue Decorative Ceramic | Mossy Brick / Blue Ceramic |

## Material provenance

| Material | Library | Source |
| --- | --- | --- |
| Weathered Rock | Poly Haven | [rocky_terrain](https://polyhaven.com/a/rocky_terrain) |
| Forest Floor | Poly Haven | [forest_ground_04](https://polyhaven.com/a/forest_ground_04) |
| Detailed Snow | Poly Haven | [snow_02](https://polyhaven.com/a/snow_02) |
| Coastal Sand | Poly Haven | [coast_sand_01](https://polyhaven.com/a/coast_sand_01) |
| Natural Marble | Poly Haven | [marble_01](https://polyhaven.com/a/marble_01) |
| Old Cobblestone | Poly Haven | [cobblestone_floor_01](https://polyhaven.com/a/cobblestone_floor_01) |
| Weathered Brick | Poly Haven | [brick_wall_001](https://polyhaven.com/a/brick_wall_001) |
| Industrial Steel | Poly Haven | [metal_plate](https://polyhaven.com/a/metal_plate) |
| Blue Steel | Poly Haven | [blue_metal_plate](https://polyhaven.com/a/blue_metal_plate) |
| Aged Timber | Poly Haven | [old_wood_floor](https://polyhaven.com/a/old_wood_floor) |
| Worn Concrete | Poly Haven | [concrete_floor](https://polyhaven.com/a/concrete_floor) |
| Mossy Rock | Poly Haven | [mossy_rock](https://polyhaven.com/a/mossy_rock) |
| Volcanic Stone | Poly Haven | [volcanic_rock_tiles](https://polyhaven.com/a/volcanic_rock_tiles) |
| Road Asphalt | Poly Haven | [asphalt_01](https://polyhaven.com/a/asphalt_01) |
| Aged Tiles | Poly Haven | [dirty_tiles](https://polyhaven.com/a/dirty_tiles) |
| Blue Ceramic | Poly Haven | [blue_floor_tiles_01](https://polyhaven.com/a/blue_floor_tiles_01) |
| Mossy Brick | Poly Haven | [mossy_brick](https://polyhaven.com/a/mossy_brick) |
| Terracotta | Poly Haven | [terracotta_floor_tiles](https://polyhaven.com/a/terracotta_floor_tiles) |
| Terrazzo | Poly Haven | [terrazzo_tiles](https://polyhaven.com/a/terrazzo_tiles) |
| Brown Leather | Poly Haven | [brown_leather](https://polyhaven.com/a/brown_leather) |
| Cliff Rock | ambientCG | [Rock030](https://ambientcg.com/a/Rock030) |
| Veined Stone Tiles | ambientCG | [Tiles074](https://ambientcg.com/a/Tiles074) |
| Black Veined Marble | ambientCG | [Marble013](https://ambientcg.com/a/Marble013) |
| Decorative Steel | ambientCG | [MetalPlates005](https://ambientcg.com/a/MetalPlates005) |
| Detailed White Plaster | ambientCG | [PaintedPlaster017](https://ambientcg.com/a/PaintedPlaster017) |
| Orange Brick | ambientCG | [Bricks092](https://ambientcg.com/a/Bricks092) |
| Lush Forest Ground | ambientCG | [Ground037](https://ambientcg.com/a/Ground037) |
| Sculpted Silver Plates | TextureCan | [metal_0084](https://www.texturecan.com/details/657/) |
| Festive Gilded Paper | TextureCan | [paper_0037](https://www.texturecan.com/details/658/) |
| Blue Decorative Ceramic | TextureCan | [tiles_0132](https://www.texturecan.com/details/655/) |
| Jade Marble | TextureCan | [marble_0017](https://www.texturecan.com/details/415/) |
| Pink Granite | TextureCan | [marble_0010](https://www.texturecan.com/details/104/) |
| Pink Terrazzo | TextureCan | [marble_0006](https://www.texturecan.com/details/88/) |
| Colorful Spangles | TextureCan | [paper_0019](https://www.texturecan.com/details/302/) |
| White Veined Marble | TextureCan | [marble_0008](https://www.texturecan.com/details/94/) |

## Runtime / editing

Classic native materials and their8 palettes are retained. Custom texture mode has an independent per-surface style, scale, color/rainbow and image-ID editor with preview. Apply a theme, then edit individual surfaces; autosave/named profiles retain changes. Reapply restores the built-in recipe. Source albedo may look plain for some metals: normal/roughness/metalness maps produce their detailed response under lighting.

Each active MaterialVariant receives color, OpenGL normal, roughness and optional metalness maps from the same downloaded material. A material is not substituted until all required files are ready. Missing/unsupported local asset APIs leave native surfaces, show an error and support Retry texture loading. There is no generic Roblox/colored-square fallback.

Three-worker lazy downloads, verified JPEG/PNG header/byte length, executor-relative PrimeVisuals/Assets/pbr-* cache, request fallback and unload cancellation. Only required materials download for the selected visible map categories. The whole library is not fetched at startup. GPU decoding/rendering and actual network latency require in-game testing.

MaterialVariant names are local and unique; original BasePart.Material, physical properties, global material overrides, avatars and toys remain unchanged. Restore native mesh textures, decals, SurfaceAppearance and original variants on mode change/disable/unload. Clean only the eight known rejected generated cache files where executor deletion APIs are available.

Minecraft remains deferred. No shader changes in this release.

Validation:40 isolated scenario scripts /123 groups passed, plus local checks of every source-file SHA256, required maps and image dimensions. Not a live FTAP render or FPS test.
