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

## 3.2.3ac
RMB passes native throwing only when a live GrabPart constraint has an owned local beam, reusing main ownGrabBeam resolver. Gesture is latched through release even if the constraint disappears; focus loss clears the latch. No grab input is synthesized for a throw. Empty-sky pickup behavior unchanged.

## 3.2.3bc
Native FTAP MenuGui/Menu effective visibility (not E press parity or enabled ScreenGui alone) controls pointer release. A zero-size modal TextButton unlocks first-person input while menu is visible; explicit layered MouseBehavior/MouseIconEnabled changes restore on exit. Either Shift is consumed by a mode-only sprint action. Active sprint captures current Humanoid WalkSpeed and patches1.3x; release, menus, focus loss, death, respawn and disable restore baseline. Hand bob/lean increases gently; FOV untouched. Native E action remains untouched.

## 3.2.3abc — supersedes sprint

Shift sprint is removed completely; native FTAP crouch input is untouched. No Humanoid WalkSpeed writes remain in MinecraftMode.

Physical LMB hit uses one 8stud raycast from the real camera, excluding own character, and verifies actual hit is within8studs of character head/root. It only attempts unanchored non-character world assemblies. ApplyImpulse uses mass-normalized6stud/s base delta velocity times persisted hand strength0–5 (default1), doubled when slot9 is selected. Swing cadence limits attempts to one per .35s animation. UI/freecam/spectate/death cases are excluded.

No direct game remote calls, SetNetworkOwner or ownership acquisition. Client-owned/free local assemblies can react; server/other-client-owned assemblies may ignore the local request. This limitation follows native Roblox ApplyImpulse authority: https://create.roblox.com/docs/reference/engine/classes/BasePart#ApplyImpulse . Simulation checks exact impulse ratios and routing, not actual FTAP replication/physics.

## 3.2.3abcf — automatic native-contact experiment

User live report: own spawned objects are visibly pushed for other players, another player's grab stops that effect, and manual local line contact restores it until the next foreign grab. This is consistent with an ownership transition, but identity was not measured directly.

New persisted `minecraftHitMethod`: Native contact (test) default; Local impulse retained as an explicit comparison path. Native mode checks the same nearby raycast/Mouse.Target, refuses pre-existing manual grabs, sends ordinary native LMB grab press/release, observes active local GrabParts constraint + shared ownGrabBeam resolver, then sends ordinary LMB drop. Only after the same grab disappears is the impulse attempted. No game remotes or ownership APIs are called. A transient native grab line can be visible.

A .6s acquisition/.35s release deadline cancels without impulse if native state is not confirmed. Wrong target, menus, death/respawn, focus loss and disable cancel pending work and release synthetic buttons. Existing RMB actions cancel the automatic attempt before resuming normal manual logic. Only one attempt may be pending. The short .1s hit gate is independent from visual swing duration.

Impulse uses horizontal aiming direction (vertical look fallback forward), mass*(18horizontal+4up)*strength; sword strength2x. This improves ground contact without inventing network authority. Selected strength and direction are captured at click time. Characters are eligible if native FTAP contact accepts them; anchored parts and own avatar assembly excluded.545settings.

Mock checks cover successful local-constraint handshake, no hit before confirmed drop, exactly one hit, timeout without impulse, cancellation, normal manual grab/throw and2x ratio. Shared physics/ownership persistence is NOT established by mocks; peer-view testing after foreign contact remains required.

Native contact follow-up: hold until local grab is confirmed, wait .12–.35s based on available GetNetworkPing before releasing to allow normal game contact to settle. First try button-up release, then a second native click for toggle-style drop if still held. This is a bounded input state machine, not proof that the server granted lasting ownership.
