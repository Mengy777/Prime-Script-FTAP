# Minecraft reference textures

Artwork: Mojang Studios / Microsoft, Minecraft Java Edition. Not affiliated with or endorsed by Mojang/Microsoft. Artwork is not our original work or CC0.

Original PNG files obtained from https://github.com/InventivetalentDev/minecraft-assets:
- Classic Steve: 1.12.2/assets/minecraft/textures/entity/steve.png.
- Sword: 1.21.5/assets/minecraft/textures/item/diamond_sword.png.
- HUD: 1.21.5/assets/minecraft/textures/gui/sprites/hud/ — hotbar.png, hotbar_selection.png, heart/container.png, heart/full.png, heart/half.png, food_full.png, food_empty.png, experience_bar_background.png.

MinecraftAssets.lua stores filenames, byte lengths and original right-arm UV coordinates. PNG files are cached locally and displayed pixelated, without procedural recoloring.

steve_hand.png is the exact transparent reference supplied by the user (Minecraft hand artwork); no image generation or alteration was applied.

arm_*.png files are lossless UV extractions from classic steve.png with nearest-neighbor expansion for crisp Decal sampling; no invented colors or extra texture detail. tools/build_minecraft_hand.py reproduces them. Sprite is retained only as historical reference, not loaded at runtime.
Hand transform/bob/attack formula reference: Minecraft Java 1.8.9, ItemRenderer.renderPlayerArm, EntityRenderer.setupViewBobbing, ModelBiped/ModelBox, via https://github.com/Marcelektro/MavenMCP-1.8.9/tree/master/src/main/java/net/minecraft/client . Minecraft/Mojang/Microsoft notices remain applicable; no ownership claimed over original algorithms/artwork.

Crosshair: original 1.21.5/assets/minecraft/textures/gui/sprites/hud/crosshair.png from the same Minecraft asset mirror.
