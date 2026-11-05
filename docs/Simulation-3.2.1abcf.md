# Prime Visuals 3.2.1abcf — simulation report

Run date: 2026-11-05. Actual project source; simulated Roblox APIs, scene graphs, filesystem and event delivery. This is not a live Roblox/FTAP server or a physics/rendering benchmark.

38 scenario scripts; 113 check groups; 0 failures.

## action_notifications.py — PASS (0.27 s)

```text
PASS selected user-action notices, slider silence, per-feature debounce, optional disable and no profile-restore flood
```

## anti_kick.py — PASS (0.2 s)

```text
PASS actual AntiKick module: self-only attachment confirmed, no duplicate spawns, recovery after toy destruction/death, disable-before-async-spawn and unload cleanup
```

## avatar_cold_reference.py — PASS (0.17 s)

```text
PASS third-person active at construction: incomplete applied description to UserId fallback, renamed/URL-mesh hair match, face-case match, no waist exposure, two disposed models and no per-frame API calls
```

## avatar_modes.py — PASS (0.8 s)

```text
PASS shared early avatar cache: hair/custom face hidden before enable,150 late ordinary/local alpha writes during Freecam, invisible accessories/decals preserved, mode handoff and disable cleanup
```

## avatar_reference.py — PASS (0.33 s)

```text
PASS avatar reference: initially hidden hair/face mask, original face texture, head-only filtering, one request/character, source model/description cleanup,30 mode switches and unload
PASS reference completion after unload disposes model/description without modifying avatar
```

## camera_cleanup.py — PASS (0.47 s)

```text
PASS FOV tracks original values for both old/replacement cameras; feature callback failure restores the toggle state
PASS reset sky/time remain native defaults on another simulated server; untouched FOV/time sliders follow its real values
PASS newest JSON with invalid setting ranges is rejected in favor of an older fully valid backup
```

## coin_icon.py — PASS (0.28 s)

```text
PASS default-off; exact native HUD-only icon; black concave sparkle and animated contour; balance/button/shop untouched; overlay/menu recovery; disable/unload restore
PASS local autosave/cold restore of optional icon switch
```

## controls_matrix.py — PASS (4.39 s)

```text
MATRIX 482 controls; exceptions 0 warnings 2 notifications 23
WARNING Prime artwork: [string "PrimeVisuals/AnimatedEmblem"]:72: Executor does not support local image assets
WARNING Prime Visuals: native CameraInput unavailable; third person keeps RMB rotation
NOTICE Third-person camera: enabled
NOTICE Third-person camera: disabled
NOTICE Custom coin icon: enabled
NOTICE Custom coin icon: disabled
NOTICE Custom crosshair: enabled
NOTICE Custom crosshair: disabled
NOTICE Boost FPS: enabled
NOTICE Boost FPS: disabled
NOTICE Free camera: enabled
NOTICE Free camera: disabled
NOTICE Custom line: enabled
NOTICE Custom line: disabled
NOTICE Local mannequins: enabled
NOTICE Local mannequins: disabled
NOTICE Sound replacement saved
NOTICE Custom game sounds: enabled
NOTICE Custom game sounds: disabled
NOTICE Custom toy collection: enabled
NOTICE Custom toy collection: disabled
NOTICE Lighting preset: enabled
NOTICE Lighting preset: disabled
NOTICE Realistic water: enabled
NOTICE Realistic water: disabled
PASS all registered controls exercise boolean changes, every dropdown entry, numeric endpoints and colors, then unload; runtime warnings reviewed separately
```

## emblems.py — PASS (0.2 s)

```text
PASS original high-resolution RGBA PNG assets unchanged
PASS opaque static PNG without IsLoaded gate, compact rainbow/spinning header marks, cache/retry transport, hidden pause and unload cleanup
PASS transient PNG download failure succeeds on the third bounded attempt
```

## esp_memory.py — PASS (0.29 s)

```text
PASS native-like dropdown prunes absent rows but saved ESP selection survives leave/reload, reselects returning player and respects explicit deselection
```

## home_start.py — PASS (0.39 s)

```text
PASS legacy saved tab ignored on cold startup, config load and undo; settings/FOV preserved; tab navigation creates no config writes
PASS Home artwork is parented into the visible custom column, not the hidden native side
PASS compact non-scrolling Home, profile/phoenix composition, removed shortcuts and session detail toggle
```

## hud_drag.py — PASS (0.28 s)

```text
PASS rounded compact HUD drag, final-only XY commit, click suppression, exact cold restore and metric refresh
```

## lighting_editor.py — PASS (0.39 s)

```text
PASS exact copy of all three source scenes, independent edits, original presets unchanged and reset restoration
PASS live advanced environment/atmosphere/Bloom/rays/DOF, boolean false copy, all 482 keys and cold-start restore
PASS legacy profiles missing every new lighting key keep old manual behavior
```

## line_ownership.py — PASS (0.23 s)

```text
PASS own-source-only texture/rainbow/speed; foreign line targeting self stays native; unknown/spatial foreign excluded; foreign updates preserved; reassignment restores and local recovery works
```

## loading.py — PASS (0.29 s)

```text
PASS black/white bootstrap, actual Arcade rainbow wordmark/menu Omega, compact CanvasGroup, rotation and early-unload fade cleanup
PASS cooperative delayed transport: bounded parallel downloads, no duplicate successful requests, dependency-order startup and cleanup
```

## localization.py — PASS (0.32 s)

```text
PASS actual Tools label, late-created controls, dynamic protection statuses and ten RU/EN round-trips
PASS saved Russian restored on cold startup; stable settings keys retained
```

## long_session.py — PASS (0.58 s)

```text
PASS 60 deaths, stale duplicate folders, nested/renamed scopes, delayed rewrites, 6 simulated minutes, listener bounds, grab info and script reload without rejoining
PASS 12 game-driven clearing cycles restore camera/ESP and recreate enabled shaders, particles, hat mesh, crosshair, skybox and clouds; no duplicate config writes
PASS temporary callback error retries with cooldown instead of permanently disabling the feature; unload stops it
```

## major3.py — PASS (0.79 s)

```text
PASS Major3 default RightControl menu / other binds empty, bindings execute/pause for UI, conflict rejection, theme/color/HUD cold restore and cleanup
PASS actual key capture mouse3, no trigger during capture, Escape cancellation and disconnected router
PASS menu default migration: untouched empty, explicit clear, occupied RightControl and custom rebind
```

## map_audio_presets.py — PASS (0.36 s)

```text
PASS map category isolation, map-only scope, disabled editing, independent property restore, cached classification, late parts and unload
PASS persisted map restore/reset, per-category presets, custom/Original switching and native audio restoration
PASS independent sound preset selections survive a cold restart
PASS actual grab audio: foreign rejection, valid local weld onset, hold deduplication, release/regrab, preview replacement and unload
```

## native_clicks.py — PASS (0.19 s)

```text
PASS actual Switch/Checkbox MouseButton1Click + settings gear + switch area + disabled guard; callbacks fire exactly once
PASS actual action-button clicks, disabled actions, live text, commit-on-blur/cancel and native slider drag
```

## object_profiles.py — PASS (0.28 s)

```text
PASS removed object/item tabs and controls absent; legacy object keys ignored while FOV preserved
```

## profiles.py — PASS (2.48 s)

```text
PASS all 482 registered settings round-trip; active FOV/camera/sky/sun/clouds/shaders/water/particles/mutes and manual rainbow color restored
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

## removed_graphics.py — PASS (0.28 s)

```text
PASS experiment UI/module removed; old 353-key settings load without reset, preserve manual lighting and resave 482 keys
```

## server_integration.py — PASS (0.5 s)

```text
PASS two independent live-script clients: local lighting/body/line settings do not alter peer scene or authoritative roster
PASS delayed player leave/rejoin restores selected ESP target; queued old-session events are discarded
PASS 25 delayed respawns plus streamed beam destruction/recreation; enabled line and lifecycle recover
PASS actual mannequin/R6 ragdoll modules: spawn/avatar replacement/10-object limit/failure retention/disable; no physical solver or asset appearance assertion
PASS both clients unload independently, restore baseline lighting and keep isolated per-user autosaves
```

## sky_collection.py — PASS (0.69 s)

```text
PASS exact model IDs, six-face extraction, model disposal, success cache, static Purple Radiance and persisted resolved faces
PASS inaccessible model leaves existing sky unchanged
PASS four removed collection names migrate without invalidating saved settings
PASS all 16 retained sky definitions unchanged
```

## sound_overrides.py — PASS (0.28 s)

```text
PASS Personalization routing, category/exact-name audio replacement, live native/new sounds, volume-mute coexistence, clear/latest-native restore and disable/unload
PASS audio replacement configuration cold restore
```

## startup_resilience.py — PASS (0.94 s)

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
PASS Major3 required UI/input module failures clean status panel and fullscreen loading
PASS partial Major3 constructor failure tears down input router, HUD and loading screen
```

## stress.py — PASS (3.72 s)

```text
PASS 8 seeded randomized complete profiles, 3,856 varied setting values; imports, offline-player selections, UI positions/panels, Home startup and cold restart
PASS 20 re-executions in the same simulated game: restored effects remain singular; resolved sky uses no model fetch
PASS journal interruption on first and mirrored write retains a readable old/new profile
PASS expired overwrite confirmation and switching Save/Delete cannot overwrite a slot
PASS UTF-8 config names with Cyrillic/emoji and Russian language survive slot save/export
```

## third_person_pan.py — PASS (0.21 s)

```text
PASS native toggle pan, menu pause, reenable, disable/unload restore, unchanged sensitivity
```

## third_person_visibility.py — PASS (0.46 s)

```text
PASS stale first-person hiding, 100 camera rewrites, accessory loading, 12 respawns, first-person-body coexistence, native live distance, unchanged sensitivity and unload restore
```

## toy_collection.py — PASS (0.31 s)

```text
PASS native toy sorting: rocket/black crystal/blob/Tetracub L priority, pallet23 with missing preferred toys, original instances/favorites, native rewrites, editing, menu recreation and unload
PASS autosave cold restore of collection enabled/order and pallet23
```

## toy_collection_native.py — PASS (0.24 s)

```text
PASS captured native MenuGui/Toys hierarchy and195 real IDs; aliases, pallet23, exact favorite geometry; shop/destroy untouched; restore
PASS fixed27-toy set only: no editor, assignment action or obsolete persisted editor controls
PASS curated replacement slots2/3/5/6 use real unique owned IDs; Decoy22/pallet23/Blob24 preserved
```

## toy_collection_viewports.py — PASS (0.22 s)

```text
PASS viewport-only/manual-position native catalogue, clickable searchable picker/preview factories, pallet23, exact native-star bounds, black fill/animated outline, assignment and restore
PASS integrated automatic local menu diagnostics; no separate script needed
```

## ui_navigation.py — PASS (0.28 s)

```text
PASS merged sections display all cards without section bars; Freecam moved to View camera tools and Prime Vortex remains empty
PASS inline rainbow survives native swatch failure, fallback and Reset filters
PASS floating inspector coordinates autosave and restore on cold start
PASS navigation creates no profile writes; 482 current settings retained (advanced lighting editor included)
PASS actual Obsidian floating inspector: gear, enabled-only access, viewport bounds/independent position, inside/outside/dropdown clicks, Escape/hidden owner, parameter pages, inline rainbow and full cleanup
PASS actual Unicode casefold for Russian search labels
PASS Major3 uses native complete-category search without a subsection filter
```

## visual_expansion.py — PASS (0.34 s)

```text
PASS source jump-circle ground/radius/fade, native trail parameters, respawn and disable cleanup
PASS exact three snow layers, wind/height/recovery; four source dust layers, death deduplication, 8-second expiry and visibility restoration
PASS R6/R15 projected box/skeleton, near-plane clipping, target marker with absent-target hiding, own highlight, existing ESP health/distance integration
PASS player invisibility restore, animated blackhole repair/expiry/live controls, 32-part position ghost; animation controls removed
PASS camera-only freecam translation, original movement/camera restoration, native spectate, shader switching and exact skybox face IDs
PASS ocean/body appearance restore, simultaneous active-feature unload, camera binding removal and original movement restoration
PASS actual autosave/re-execution of enabled expansion features, 12 repeated character replacements and final restore/unload
PASS 20 distinct skies: 17 static six-face sets and 3 exact model references; live assets require Roblox
```

## vortex_startup.py — PASS (0.27 s)

```text
PASS Vortex HTTP/compile retry keeps Visuals global library isolated
PASS mandatory Vortex failure clears partial GUI/signals/input and leaves Visuals intact
PASS Vortex optional artwork failure still opens and closes the main window
PASS Vortex failed window constructor cleans controller and library
PASS deliberate Vortex cancellation during download stays clean and does not emit a fatal-startup notification
```

## wordmark.py — PASS (0.22 s)

```text
PASS shared pixel wordmark: thirteen fixed-colour letters, rainbow underline, enlarged Omega and tight measured FPS spacing
```

## write_races.py — PASS (0.37 s)

```text
PASS reentrant write: edits during write are not lost; unload during write queues its final snapshot and cold restart restores it
PASS temporary disk failure retries automatically after recovery without another settings edit
```
