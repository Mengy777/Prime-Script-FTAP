# View 2.2.1 — review and live checks

The user approved 2.2.0 wheel zoom, original Spectate camera behavior, the 13 previous skies and Reset sky. They reported a game toy-selection panel opening immediately when Freecam is enabled, even without pressing E. Do not reduce that report to a key conflict.

## Freecam

Mouse look has one camera-only input path, no RMB requirement or sensitivity writes. WASD, world-up Space and world-down Q; wheel speed 10–600, bounded Shift/Ctrl modifiers. The physical character is not translated; its movement controls are temporarily suppressed and restored. Cached local body/accessory visibility is corrected with the existing property-layer system; late parts/respawns are handled.

Before changing camera type, Freecam snapshots recognized toy menus and currently closed large game panels, then listens for visibility changes and late GUI descendants. Prime Visuals and its overlay are excluded. Closed game panels are kept closed until Freecam exits; thus other large game dialogs can also be temporarily suppressed. The actual FTAP hierarchy was not inspected live in this update: this is a generic lifecycle guard, not a claimed exact game-script diagnosis. Connections/original states are restored on exit. The simulation explicitly opens an unnamed game panel when CameraType changes, without any input event.

The compact HUD reports the effective configured movement speed (studs/second), not a measured instantaneous velocity during acceleration. It has the existing PrimeIcon and purple/black styling; menu/focus pause hides it. It recovers if its overlay is destroyed.

## Spectate / compatibility

Player picker reuses the existing native ESP dropdown presentation: DisplayName (@Username), 48px avatar thumbnails, join/leave refresh. The persisted spectateTarget key stays string-typed; saved offline usernames remain loadable. Removed Smooth camera keys are ignored by the existing profile normalization, not executed. All other visual keys remain.

## New skies: provenance

Seven six-face sets were inspected as data in the author's [VISUALBOSS readme](https://github.com/scotdotwtf/VISUALBOSS/blob/main/readme.md), asset section: Blue Horizon (blue*), Purple Nebula (Galaxy), Vaporwave, Pink Morning (pinkful morning), Lavender Gradient (whitie to purple), Rose Gradient (white to pink), Golden Hour (Sunset). Only face IDs are adapted; no foreign loader or runtime code is executed. Gradient skies intentionally repeat a horizontal image on four faces. Existing thirteen sets are unchanged. Asset access/moderation can differ in live Roblox; source presence does not prove texture access.

## User test list

1. Enable Freecam without touching keys: no game selection menu. Close Prime menu, freely mouse-look, fly away and see own avatar.
2. Wheel down/up reaches 10/600; HUD agrees, Space/Q moves vertically; opening Prime menu/chat or alt-tab pauses; return resumes.
3. Disable and reenable, reset, and unload: normal movement/camera/sensitivity/UI restored, HUD disappears; body and overlay recover after respawn.
4. Spectate player list labels/thumbnails, joins/leaves and selection; camera returns correctly and Freecam/Spectate exclude each other.
5. New seven skies load without missing faces; old thirteen and Reset sky retain behavior.
