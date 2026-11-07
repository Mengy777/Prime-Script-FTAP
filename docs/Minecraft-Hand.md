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

## 3.2.3ab — follow-up

Walking phase now uses min(horizontalSpeed,24)/10.6666667 rather than /4 (about2.67x slower at16studs/s). Sword geometry uses horizontal runs of identical nontransparent RGBA texels from original diamond_sword.png, extruded to1/16 depth; native Model pivot/scale update only when equipped. No image generation or invented pixels.

Item transform references reviewed directly: ItemRenderer.transformFirstPersonItem/doItemUsedTransformations in Java1.8.9, and https://github.com/InventivetalentDev/minecraft-assets/blob/1.21.5/assets/minecraft/models/item/handheld.json . Shape/colors are original; transform is adapted across versions/engines, not a verified universal1:1 port.

RMB ContextActionService action sends a normal virtual LMB press/release only when native Mouse.Target points to a world BasePart other than own avatar. An injection guard and short-lived expected-event queue pass synchronous/deferred synthetic events through the Minecraft LMB sink; physical LMB still animates. VirtualInputManager falls back to executor mouse1press/mouse1release if available. No direct game remotes are invoked; normal FTAP range/ownership validation remains. Events are paired on release/focus loss/disable, including if CurrentCamera vanishes. Actual injection timing and native grab-line behavior cannot be established by mocks and need user verification.
