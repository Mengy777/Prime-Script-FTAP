# Minecraft hand rendering — 3.2.3c

The user rejected both approximate world-space cuboid placement and a magnified reference sprite. The replacement uses an isolated ViewportFrame with Camera70, native Part geometry 4x12x4 pixels at 1/16 unit per pixel, six Decals and original classic Steve skin UVs. No world-space geometry or avatar modifications are made. Fixed camera projection preserves FOV independence without stretching individual axes.

## Sources inspected

- https://github.com/Marcelektro/MavenMCP-1.8.9/blob/master/src/main/java/net/minecraft/client/renderer/ItemRenderer.java — renderPlayerArm transform sequence, attack offsets.
- https://github.com/Marcelektro/MavenMCP-1.8.9/blob/master/src/main/java/net/minecraft/client/renderer/EntityRenderer.java — setupViewBobbing.
- https://github.com/Marcelektro/MavenMCP-1.8.9/blob/master/src/main/java/net/minecraft/client/model/ModelBiped.java — arm geometry/pivot and idle oscillation.
- https://github.com/Marcelektro/MavenMCP-1.8.9/blob/master/src/main/java/net/minecraft/client/model/ModelBox.java — UV face ordering.
- https://create.roblox.com/docs/reference/engine/classes/ViewportFrame — native independent camera and part rendering.

`tools/build_minecraft_hand.py` extracts and orients six skin faces for Roblox. Nearest-neighbor expansion preserves each original texel; it does not fabricate HD detail. Original skin copyright/provenance remains in assets/minecraft/NOTICE.md.

Walking uses measured horizontal root velocity (fallback to MoveDirection). Java distance units/tick state are adapted to Roblox studs and frame delta. Equip rise takes .25s; cosmetic click swing takes .35s. Vertical movement tilt uses smoothed root velocity. Camera pitch/yaw lag follows the source 0.1 angle-difference multiplier, with frame-rate independent catch-up and wrapped yaw. Following the user’s follow-up, a mode-scoped ContextActionService LMB binding at priority10000 sinks Begin/Change for cosmetic swings; End/Cancel and UI clicks pass. It is unbound on disable/unload. No remote calls, combat, block placement or item-use animations are added. Native Crosshairs and the optional custom crosshair are hidden during this mode, then restored; original Minecraft HUD crosshair used instead. Native game listeners that ignore processed input require live verification. Minecraft eating/mining/sword/blocking animations remain outside this empty-hand prototype.

Tests use numeric rigid-transform math, not mocked no-op multiplication, for FOV invariance and click pose changes. Compilation/simulations cannot verify Roblox Decal appearance, actual GPU anti-aliasing, licensing of player-provided assets or exact visual parity. User live comparison is pending.
