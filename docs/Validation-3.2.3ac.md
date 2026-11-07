# 3.2.3ac validation — 2026-11-07

- All main/lib Lua files compiled with luau-web.
- tests/sim/minecraft_mode.py passed: original numeric pose/FOV invariance, sword selection/swing, normal pickup, empty-sky no-op, deferred native input, UI pass-through, focus/camera loss and cleanup.
- Added active local GrabParts constraint + owned beam: sky RMB passes native throw Begin; removal of constraint before End still passes release, with no synthetic LMB click.
- Empty/stale/foreign grab remains sunk with no synthetic sky click.
- User confirmed3.2.3ab native pickup/line works. New native throw has not been tested in live FTAP; mocks do not establish server physics or actual runtime input timing.
