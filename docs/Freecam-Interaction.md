# Freecam interaction — 2.2.2

## Implemented

F3 (or the Freecam settings action) switches between flight and interaction. Flight preserves the 2.2.1 game-panel guard. Interaction freezes the camera without moving the character, releases the cursor, passes native game controls and temporarily removes panel suppression. Wheel input is left to menus rather than adjusting camera speed. The compact HUD shows the mode shortcut and E menu hint. Exit/reload/unload restores the normal UI/input lifecycle.

This is a client UI/input improvement only. It does not extend server spawn/grab range, move a hitbox, teleport a player or hide the character from other players. A server rejection can still occur for actions too far from the character.

## Reference inspection, not transplanted functionality

The previously saved Resonance source was inspected at lines 20949–21086 (Desync support and update), 35551–35569 (Position Desync UI), 18767 onward (Teleport), and 19201 onward (Grab). Its own Position Desync tooltip describes the avatar staying still for other players while the server still sees movement. The code depends on executor-specific hidden-property/flag APIs and changes replication settings. It does not establish that teleport/grab checks are bypassed. The Teleport helper itself sets a CFrame and optionally resets velocity, rather than providing a verified server exemption.

The Wraith source was searched for invisibility and grab behavior; matching names also cover reveal-invisible visuals and invisible grab lines, which are not a proof of global avatar invisibility. No game server scripts were available or examined in this update. Do not call the inspected third-party client source the game's server code, or treat a user-reported error as a verified server implementation.

No replication changes or server-visibility claims were added. Further work on ordinary Freecam/menu behavior can be validated separately from the unimplemented remote-interaction proposal.

## Verification

Actual VisualExpansion code runs in a simulated environment. Coverage: manual game panel opening allowed in interaction mode, camera remains still with movement keys, wheel does not change speed, F3 restores flight/cursor locking/panel suppression, and ordinary disable/unload remains functional. These tests do not prove actual Roblox menu hierarchy or server interaction behavior.

## 2.2.3 controls polish

F4 and the HUD close button disable Freecam through the same setting callback as its normal toggle. F3 frees the cursor to reach the button. HUD handlers are released on reconstruction. Wheel delta zero does nothing; multi-step scroll scales the speed accordingly within the existing 10–600 range and does not emit duplicate setting updates at the limits. Added simulated checks cover repeated F4 exits and the close button, verifying restored movement/camera and removed movement bindings. This update does not implement the separate distant-interaction proposal.
