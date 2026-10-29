# Prime Visuals 2.3.5 — simulation report

Run date: 2026-10-29. Actual project source; simulated Roblox APIs, scene graphs, filesystem and event delivery. This is not a live Roblox/FTAP server or a physics/rendering benchmark.

21 scenario scripts; 79 check groups; 0 failures.

## anti_kick.py — PASS (0.18 s)

```text
PASS actual AntiKick module: self-only attachment confirmed, no duplicate spawns, recovery after toy destruction/death, disable-before-async-spawn and unload cleanup
```

## camera_cleanup.py — PASS (0.51 s)

```text
PASS FOV tracks original values for both old/replacement cameras; feature callback failure restores the toggle state
PASS reset sky/time remain native defaults on another simulated server; untouched FOV/time sliders follow its real values
PASS newest JSON with invalid setting ranges is rejected in favor of an older fully valid backup
```

## controls_matrix.py — PASS (3.4 s)

```text
MATRIX 336 controls; exceptions 0 warnings 2 notifications 0
WARNING Prime artwork: [string "PrimeVisuals/AnimatedEmblem"]:72: Executor does not support local image assets
WARNING Prime Visuals: native CameraInput unavailable; third person keeps RMB rotation
PASS all registered controls exercise boolean changes, every dropdown entry, numeric endpoints and colors, then unload; runtime warnings reviewed separately
```

## emblems.py — PASS (0.35 s)

```text
PASS original high-resolution RGBA PNG assets unchanged
PASS opaque static PNG without IsLoaded gate, compact rainbow/spinning header marks, cache/retry transport, hidden pause and unload cleanup
PASS transient PNG download failure succeeds on the third bounded attempt
```

## esp_memory.py — PASS (0.39 s)

```text
PASS native-like dropdown prunes absent rows but saved ESP selection survives leave/reload, reselects returning player and respects explicit deselection
```

## home_start.py — PASS (0.48 s)

```text
PASS legacy saved tab ignored on cold startup, config load and undo; settings/FOV preserved; tab navigation creates no config writes
PASS Home artwork is parented into the visible custom column, not the hidden native side
```

## lighting_editor.py — PASS (0.4 s)

```text
PASS exact copy of all three source scenes, independent edits, original presets unchanged and reset restoration
PASS live advanced environment/atmosphere/Bloom/rays/DOF, boolean false copy, all 336 keys and cold-start restore
PASS legacy profiles missing every new lighting key keep old manual behavior
```

## long_session.py — PASS (0.53 s)

```text
PASS 60 deaths, stale duplicate folders, nested/renamed scopes, delayed rewrites, 6 simulated minutes, listener bounds, grab info and script reload without rejoining
PASS 12 game-driven clearing cycles restore camera/ESP and recreate enabled shaders, particles, hat mesh, crosshair, skybox and clouds; no duplicate config writes
PASS temporary callback error retries with cooldown instead of permanently disabling the feature; unload stops it
```

## native_clicks.py — PASS (0.33 s)

```text
PASS actual Switch/Checkbox MouseButton1Click + settings gear + switch area + disabled guard; callbacks fire exactly once
PASS actual action-button clicks, disabled actions, live text, commit-on-blur/cancel and native slider drag
```

## profiles.py — PASS (2.41 s)

```text
PASS all 336 registered settings round-trip; active FOV/camera/sky/sun/clouds/shaders/water/particles/mutes and manual rainbow color restored
PASS 120 animation ticks cause zero disk writes; 50 edits coalesce to one journal write; unload flushes pending changes
PASS five independent named slots; occupied slot cannot be overwritten on the first click
PASS loading a slot restores actual camera and autosave; undo returns exactly to the previous FOV
PASS JSON export/import between accounts; local autosaves and five slots isolated by UserId
PASS import and deletion require their own confirmation; delete creates a recoverable journal tombstone without old settings
PASS reject malformed/oversized JSON, future schema, wrong types/ranges, invalid sky/UI data and path traversal before replacing slots
PASS corrupt primary recovers from backup; failed/truncated writes preserve the previous config; later retry succeeds
PASS both autosaves corrupt: startup remains usable, effects stay default, damaged files are preserved for recovery
PASS reset replaces autosave with clean game defaults and preserves all named slots across restart
PASS 10 scenario groups; actual main script and actual storage module executed, simulated Roblox/file APIs
```

## removed_graphics.py — PASS (0.34 s)

```text
PASS experiment UI/module removed; old 353-key settings load without reset, preserve manual lighting and resave 336 keys
```

## server_integration.py — PASS (0.75 s)

```text
PASS two independent live-script clients: local lighting/body/line settings do not alter peer scene or authoritative roster
PASS delayed player leave/rejoin restores selected ESP target; queued old-session events are discarded
PASS 25 delayed respawns plus streamed beam destruction/recreation; enabled line and lifecycle recover
PASS actual mannequin/R6 ragdoll modules: spawn/avatar replacement/10-object limit/failure retention/disable; no physical solver or asset appearance assertion
PASS both clients unload independently, restore baseline lighting and keep isolated per-user autosaves
```

## sky_collection.py — PASS (0.93 s)

```text
PASS exact model IDs, six-face extraction, model disposal, success cache, static Purple Radiance and persisted resolved faces
PASS inaccessible model leaves existing sky unchanged
PASS four removed collection names migrate without invalidating saved settings
PASS all 16 retained sky definitions unchanged
```

## startup_resilience.py — PASS (0.68 s)

```text
PASS module HTTP/compile retry and successful-source cache reuse
PASS mandatory HTTP failure: bounded retries, one native message, clean game and no GUI
PASS partial library runtime failure: no unsafe re-execution, tracked GUI/signals/input restored, later startup succeeds
PASS required config module failure cleans partially built effects and preserves stored profiles
PASS optional artwork HTTP/syntax/constructor failures keep menu functional and remove partial decorations
PASS CreateWindow failure is protected before the regular shutdown handler exists
PASS late module response after unloading is cancelled before executing its code
PASS thrown compiler exception is retried without aborting startup
PASS malformed library API and signal registry still cleanly report failure
PASS advanced lighting module HTTP failure cleans partial startup without changing the game
```

## stress.py — PASS (2.45 s)

```text
PASS 8 seeded randomized complete profiles, 2,688 varied setting values; imports, offline-player selections, UI positions/panels, Home startup and cold restart
PASS 20 re-executions in the same simulated game: restored effects remain singular; resolved sky uses no model fetch
PASS journal interruption on first and mirrored write retains a readable old/new profile
PASS expired overwrite confirmation and switching Save/Delete cannot overwrite a slot
PASS UTF-8 config names with Cyrillic/emoji and Russian language survive slot save/export
```

## third_person_pan.py — PASS (0.32 s)

```text
PASS native toggle pan, menu pause, reenable, disable/unload restore, unchanged sensitivity
```

## third_person_visibility.py — PASS (0.29 s)

```text
PASS stale first-person hiding, 100 camera rewrites, accessory loading, 12 respawns, first-person-body coexistence, native live distance, unchanged sensitivity and unload restore
```

## ui_navigation.py — PASS (0.32 s)

```text
PASS actual navigation: short subpages, merged cards, page visibility, readable labels and explanations
PASS inline rainbow survives native swatch failure, fallback and Reset filters
PASS floating inspector coordinates autosave and restore on cold start
PASS navigation creates no profile writes; 336 current settings retained (advanced lighting editor included)
PASS actual Obsidian floating inspector: gear, enabled-only access, viewport bounds/independent position, inside/outside/dropdown clicks, Escape/hidden owner, parameter pages, inline rainbow and full cleanup
PASS actual Unicode casefold for Russian search labels
PASS search reaches unselected subpages; clearing search restores selection; subsection clicks exit search and cleanup restores the original handler
```

## visual_expansion.py — PASS (0.39 s)

```text
PASS source jump-circle ground/radius/fade, native trail parameters, respawn and disable cleanup
PASS exact three snow layers, wind/height/recovery; four source dust layers, death deduplication, 8-second expiry and visibility restoration
PASS R6/R15 projected box/skeleton, near-plane clipping, target marker with absent-target hiding, own highlight, existing ESP health/distance integration
PASS source object matching/icon deduplication, invisibility restore, animated blackhole repair/expiry/live controls, 32-part position ghost; animation controls removed
PASS camera-only freecam translation, original movement/camera restoration, native spectate, shader switching and exact skybox face IDs
PASS ocean/body appearance restore, simultaneous active-feature unload, camera binding removal and original movement restoration
PASS actual autosave/re-execution of enabled expansion features, 12 repeated character replacements and final restore/unload
PASS 20 distinct skies: 17 static six-face sets and 3 exact model references; live assets require Roblox
```

## vortex_startup.py — PASS (0.23 s)

```text
PASS Vortex HTTP/compile retry keeps Visuals global library isolated
PASS mandatory Vortex failure clears partial GUI/signals/input and leaves Visuals intact
PASS Vortex optional artwork failure still opens and closes the main window
PASS Vortex failed window constructor cleans controller and library
PASS deliberate Vortex cancellation during download stays clean and does not emit a fatal-startup notification
```

## write_races.py — PASS (0.31 s)

```text
PASS reentrant write: edits during write are not lost; unload during write queues its final snapshot and cold restart restores it
PASS temporary disk failure retries automatically after recovery without another settings edit
```
