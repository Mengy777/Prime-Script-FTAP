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

## 2.2.4 — experimental approach, client-only

F5 or its settings action saves the current avatar root CFrame and moves that same avatar to anchored ground/Terrain found up to 80 studs below the camera (ray starts 8 studs above it). Surface normal must point upward; seated, ragdolled, anchored and dead characters are rejected. Destination must be finite and within 5000 studs. The avatar is visible to other players; this does not implement replication concealment or modify native server checks.

The camera is held in interaction mode so the user can attempt the game's normal mouse action. On a normal LMB begin/end pair the same character returns after 0.2 seconds and flight resumes. F5/F3/F4/disable/unload also cancel/return as appropriate. Return never targets a replacement or dead character, zeroes physical velocity rather than applying stale momentum, and an old delayed release cannot affect a newer trip. No automatic retry or positive server-success claim is made.

Native server acceptance and actual grab behavior cannot be proven by mocked physics. The test can fail in live FTAP even if local movement is visible. It is intentionally an action, not an automatically enabled/restored profile flag. Prior 2.2.2/2.2.3 behavior remains unchanged until the user starts this action.

## 2.2.5 — direct controls (supersedes F3/F5)

E now releases panel suppression/cursor for native toy selection; E again restores flight. F4 exits either mode. LMB in flight raycasts from the camera, excludes own character/visual objects, requires a movable BasePart, then uses the existing grounded approach near the hit position. This is a pre-interaction attempt triggered by the click, not confirmation that the game has grabbed anything. Native handler order and replication may require another click or reject the action; simulations cannot establish acceptance. Camera look and flight remain active during approach. Release returns the same living character with delay and per-release token guards. Anchored scenery, invalid surfaces, seats/ragdoll and oversized destinations remain excluded. There are no server changes or invisibility guarantees.

## 2.2.6 — visibility-driven menus and immediate release

The first E only releases the activation guard; subsequent presses pass untouched to native game code. The cursor/flight pause follows actual visibility of tracked panels and their GUI ancestors, so selecting a toy or closing by a native button does not leave a phantom toggle. This is an inspected hierarchy heuristic, still requiring live verification against FTAP.

A high-priority CAS primary-button callback performs the approach attempt before normal input listeners and returns Pass. Raycast hits can be character parts, props, anchored surfaces or Terrain. The avatar is placed one body-clearance distance along the hit normal. The former anchored-target exclusion and second floor ray are removed. Release and window focus loss return immediately, retaining same-avatar/alive checks. No deferred release callbacks remain. The ordinary game handler and server can still decline the action; local input order is not proof of replication/server acceptance.

## 2.2.7 — shell visibility and sideways clearance

ScreenGui.Enabled is not evidence that a toy panel is open. Only visible tracked GuiObject panels with visible ancestors and on-screen/nonzero geometry hold cursor mode. E-close clears the interaction request even if a persistent shell stays enabled. Native close clears it as the panel disappears. Tests retain a shell enabled across ten open/close cycles and move a visible panel offscreen. Exact live FTAP panel identity remains a heuristic; no runtime hierarchy inspection was performed.

Approach offsets horizontally perpendicular to the camera ray by at least 6 studs, plus the existing surface-normal body clearance. Near-vertical views use a fixed horizontal fallback. This avoids placing the avatar directly on the original target ray; it does not guarantee collision-free placement for every surrounding map geometry or unusually large avatar accessory. Immediate same-character release return remains unchanged.

## 2.2.8 — RMB toggle, native LMB

The user confirmed both 2.2.7 fixes live, but the game still rejected a grab. A message establishes rejection, not its precise check/timing. The new explicit experiment uses RMB to approach and RMB again to return, separating movement from a later ordinary LMB grab. No mouse release triggers return and no synthetic grab is emitted. Empty-space return works because an existing trip is checked before raycast validation. Flight consumes RMB; menus pass it through. Window focus loss/disable/unload still restore the saved living character. This change provides manual preparation time, not proof that the server accepted relocation or will allow interaction.
