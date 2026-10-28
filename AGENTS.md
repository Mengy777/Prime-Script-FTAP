# Prime Visuals / Prime Vortex — project memory

Updated 2026-10-28. Read before modifying this repository. Verify details against code, Git and CHANGELOG.md; do not reconstruct algorithms from feature names.

## Current checkpoint

- Prime Visuals is a personal Roblox **Fling Things and People (FTAP)** project. Author Roblox username: **876osamuha**. GitHub owner: **Mengy777**.
- Repository: https://github.com/Mengy777/Prime-Script-FTAP ; branch `main`.
- Published runtime target: **2.3.1**, tag `v2.3.1`. Next normal runtime version: **2.3.2**. Consult Git for the release commit.
- Prime Vortex: **0.2.2**, tag `vortex-v0.2.2`: separate black/red UI shell, no gameplay functionality. Do not develop it without a new user request.
- The user is considering a separate script for another game and wants this project preserved for later. No new game/name/project is selected. Do not silently port FTAP remotes or repurpose this repo.
- Documentation-only edits need no runtime version/tag; functional releases do.

## User preferences / workflow

- Reply in Russian, briefly and concretely. The user values fast fixes and dislikes lengthy speculative rewrites and repeated permission requests.
- Publish requested updates through Git: the user has already authorized routine commits/pushes. Keep changes scoped; preserve approved behavior.
- Work through files, shell and simulations. The user asked to retain control of their own desktop: do not take over the screen/Roblox UI without a new request.
- After updates give a short list of changed/new behavior to test. Do not ask to recheck every old approved feature.
- Distinguish source reading, compilation, mocked simulations and live FTAP testing. Never present simulated success as proof of real server protection, rendering, physics or asset access.
- When asked to follow a reference, inspect actual source. Do not invent behavior from function names. Preserve existing vendor notices/licenses; do not claim blanket ownership of foreign code.
- No invented paid licensing/key system, fake statistics or guarantees of anti-ban/immunity.

## Deployment / versioning

- Permanent entry point: `PrimeVisuals.lua`. Never rename or make the user replace the loader on each release.

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Mengy777/Prime-Script-FTAP/refs/heads/main/PrimeVisuals.lua?t="..os.time()))()
```

- `PrimeVortex.lua` can run separately and is launched by a button in the final Settings category.
- Prime Visuals modules/assets are pinned to `refs/tags/v` + VERSION. Publish main and the corresponding complete tag together; otherwise a missing tagged module can kill startup.
- Runtime release: update VERSION and prepend an accurately dated CHANGELOG.md entry in the same commit; compile/test, sync output copies, commit, tag, `git push --atomic origin main vX.Y.Z`, verify raw main and new tagged dependencies with a cache-busting query. Do not force-rewrite release tags.
- User version sequence: last digit increments through 9, then carries: `2.1.8 → 2.1.9 → 2.2.0 → 2.2.1`. Do not skip routine versions.
- Documentation-only changes need no runtime version/tag. No in-menu changelog, dormant Lua history table or loading screen. Pre-1.0 changelog milestones are retrospective, not verified original releases/dates.

## Files / architecture

| File | Role |
| --- | --- |
| PrimeVisuals.lua | Bootstrap, lifecycle, Obsidian UI, controls/setters/spec registry, core camera/sky/graphics/character/ESP/FTAP effects, profile integration. |
| lib/Obsidian.lua | Vendored UI and native click/input/slider handlers, feature panels and search. |
| lib/Icons.lua | Lucide icon data; retain existing notices. |
| lib/Navigation.lua | Subpage presentation, merged cards and bilingual search; must not alter feature state. |
| lib/ConfigStore.lua | Local autosave journals/backups, five named slots, import/export and validation. |
| lib/VisualExpansion.lua | Source-reviewed additional effects, camera tools and ESP, sharing the main registry/lifecycle. |
| lib/VisualPresets.lua | Sky faces and animation definitions. |
| lib/AntiKick.lua | Own protective toy state machine; not a general server-kick interceptor. |
| lib/Mannequins.lua and lib/MannequinRagdoll.lua | Local custom-avatar mannequins, interaction and ragdoll. |
| lib/PrimeIcon.lua and lib/AnimatedEmblem.lua | Icon/artwork animations and fallback. |
| assets/visuals-phoenix-v1.png and assets/vortex-demon-v1.png | High-quality static Home artwork, separate from compact animated header icons. |
| docs/ and tests/sim/ | Source audits, historical validation reports and simulated regression checks. |

### Lifecycle / compatibility

- Keep stable `controls`, `setters` and setting specification keys: visible label changes must not rename persisted identifiers.
- Use layered `patch(feature, object, property, value)` / `unpatch(feature, object?)`; preserve original state and overlapping effects. Reapplying an unchanged value must not reorder unrelated layers.
- Own instances and named `job(...)` connections. Clean up on disable/unload/reload and partial startup failure; handle death, late descendants and replaced cameras/Beams where relevant.
- Avoid untracked endless coroutines and whole-world scans every frame. Animation/navigation must not save profiles every frame.
- Reset replaces autosave and restores defaults while preserving named slots. Unload restores game state and removes owned effects/connections. Anti-Kick is an explicitly requested default-on exception to otherwise untouched visual defaults.
- Startup retry/cache/protected cleanup must remain. Optional artwork or missing ColorPicker must not crash the entire UI; keep usable default values and callable setters.

## UI/UX decisions

- Keep **Obsidian + Lucide + Builder Sans**. No unsolicited library replacement/redesign.
- Sidebar: **Home, View, Graphics, Character, ESP, FTAP, Settings**. Home always opens first; Settings stays last. Sidebar icons have short hover labels, not permanent text.
- Black/dark menu, purple accents. Stable size across tabs (up to 720×600 with viewport fitting), draggable header. Keep Prime Visuals title by its compact animated rainbow icon and large static Home illustration separate.
- Rainbow border means one hue changing smoothly over time, not all rainbow colors simultaneously.
- Open menu uses the native relaxed FTAP crosshair. Do not freeze the aimed state, substitute the standard Roblox cursor or redraw a fake cursor.
- Feature parameters open via visible settings button or RMB on an enabled feature. Panels stay docked within main; outside click/Escape closes them, inside/child popup interactions do not.
- Compact Rainbow toggles sit by their color. Default rainbow behavior is one smoothly changing hue.
- No filler instructions (Right Shift/Drag header), permanent asset IDs, license/test-status clutter or fake session statistics.
- Subpages: View Camera/Sky; Graphics Lighting/Weather/Water & FPS; Character Appearance/Movement/Mannequins; ESP Players/Objects/Tools; FTAP Grab line/Crosshair/Blackholes/Audio; Settings General/Profiles. Protection is in Settings General.

## Important regressions / current behavior

### Camera — latest behavior supersedes historical RMB-only notes

- FOV **30–120**, live slider and manual input. Do not restore extended FOV/projection experiments.
- Third-person mouse rotation without RMB uses native CameraInput.setTogglePan. No second CFrame rotation and no MouseDeltaSensitivity writes. Pause for menu/text/Freecam/Spectate/Scriptable camera and restore original pan/MouseBehavior. Earlier custom orbit attempts caused excessive first-person sensitivity.
- 2.1.6 fixes local avatar invisibility: track BaseParts in body/head/accessories; maintain LocalTransparencyModifier after camera update; handle late parts/respawn. Exclude HumanoidRootPart, preserve true Transparency and intentional effect layers.
- 2.2.0 opens native wheel zoom **0.5–80**, allowing first person and back out. Distance slider clamps once to the chosen distance, then frees the range. Maintenance must not snap back every second.
- When camera-to-Focus distance is below 1, suspend forced third-person visibility so the head/accessories do not block first person; first-person body setting may operate. Restore visibility on zoom out. Restore original camera mode/zoom limits on disable/unload.
- Freecam moves only camera, not character. Freecam/Spectate disable one another. Smooth camera was removed in 2.2.1. Freecam now uses mouse look without RMB, Space/Q and speed 10–600 with a compact branded HUD; Spectate uses the ESP-style player picker. See docs/View-2.2.1.md for the game-menu suppression scope.
- 2.2.2 adds F3 temporary interaction mode: freezes camera movement, frees cursor and allows native game menus/keys; another F3 resumes flight. This does not change server action range or teleport the character. Read docs/Freecam-Interaction.md before extending interaction.
- 2.2.3 adds F4 and HUD close button for standard Freecam exit. Preserve movement/camera/input restoration and disconnect old HUD handlers on recreation; wheel delta 0 is ignored and multi-step input is respected.
- 2.2.4 adds an explicitly experimental F5 action: real, visible own-character movement to solid ground under Freecam, ordinary native interaction, then return on mouse release/cancel/exit. It is not globally invisible or a confirmed distant-grab/server-check solution. Preserve same-character guards and stale-callback protection; docs/Freecam-Interaction.md describes its scope.

### Other delicate systems

- Skybox accepts ID/Creator Store URL and resolves six faces. Load reads current text without Enter. Custom sky hides sun/clouds with manual overrides; Reset restores originals.
- Realistic Water was corrected against actual Resonance code and user-approved. Preserve FTAP conversion/restoration; do not replace with guessed huge terrain regions or spam notifications.
- Custom grab line must survive many deaths, Beam recreation and reload. It once stopped until rejoining; v2.1.2 introduced discovery/recovery. Preserve that manager.
- Player selection shows display name + username and head thumbnails IN THE MENU. Do not put broken head thumbnails in world ESP labels. Preserve selected/all-player filtering.
- Mannequins are local, with avatar-by-username. Their ragdoll differs from FTAP native physics; the user deferred further refinement. Do not claim exact replication.
- ColorPicker failure needs protected creation, valid default controls and callable fallback setters; reset/sky callbacks and independent Rainbow toggle must survive.
- v2.1.5 UI fix: MouseIsOverFrame guards pass coordinates; retain nil-safe helper. Docked panels remain interaction surfaces. Finished inputs commit on blur/Enter, Escape cancels. SetValue-only mocks missed the native click regression; preserve actual-handler tests.

### Anti-Kick 2.1.8 / 2.1.9

- Default-on `antiKickEnabled` is persisted; currently **339 settings** overall (Smooth camera removed in 2.2.1).
- Own NinjaShuriken attaches to own HumanoidRootPart.RagdollTouchedHitbox. Require PartOwner and StickyWeld.Part1 confirmation, own-toy cleanup, retry backoff, death recovery and foreign-plot pause.
- 2.1.9 hides all its BaseParts with LocalTransparencyModifier=1 and Decal/Texture with transparency; retain physical attachment. Do not delete the object just to hide it.
- Attached means confirmed weld, not universal immunity. No Kick hook, anti-cheat concealment or ban reversal. Dispatched InvokeServer cannot be cancelled client-side.
- Effectiveness against a specific attack is unverified. User-reported blackhole kicks/24-hour block do not establish what server check fired. Do not state a speculative cause as fact.
- See docs/Anti-Kick-Audit.md before changing this mechanism.

## Configs

- Automatic local saving of all settings/subsettings, resolved custom sky data, five named slots, import/export/delete/undo/backups.
- Root: executor-workspace-relative `PrimeVisuals/Configs/<Roblox UserId>`; imports: `PrimeVisuals/Imports`. Do not assume these are normal Roblox installation paths.
- Config format `PrimeVisualsConfig`, schema 1. Consult docs/Configs.md before serialization changes. Preserve validation, ranges/types/future schemas, size limits, path traversal checks and backup/write coalescing.
- Keep keys compatible; opening navigation or decorative animation must not create disk-write storms. Never commit personal configs, credentials or tokens.

## Verification status / resume point

- User historically approved Home and original View/Graphics/Character/ESP/FTAP/Settings, plus the major config workflow. This does not imply all later imported functions are tested.
- User confirmed full third-person operation and 2.2.0 wheel zoom. Invisible Anti-Kick and protection effectiveness have no explicit live confirmation.
- Smooth camera was removed by user request. Spectate camera behavior, original thirteen collection skies and sky reset are approved. Later user acceptance confirms the full 2.2.9 Freecam, Camera noclip and the new Spectate picker; Blue Horizon, Purple Nebula and Pink Morning are now approved; all four 2.3.0 replacements and the collection were subsequently approved; this does not extend to other Sky controls. See docs/View-2.2.1.md.
- Resume with the user's concrete request; do not automatically start a redesign, Vortex gameplay or another game's implementation from this memory.

## Testing / release checklist

1. Read relevant code/audits and make a scoped fix.
2. Run real Luau compilation and relevant simulations. Mocks do not prove real Roblox input/rendering/server behavior.
3. Key tests in tests/sim/: profiles.py, stress.py, write_races.py; native_clicks.py, ui_navigation.py; startup_resilience.py, home_start.py; camera_cleanup.py, third_person_pan.py, third_person_visibility.py; long_session.py, visual_expansion.py, esp_memory.py, anti_kick.py. For Vortex also vortex_startup.py.
4. Adding/removing settings may require updating intentional count assertions without weakening compatibility coverage.
5. Runtime release: VERSION + dated changelog; compile/tests; git diff --check; sync copies; commit/tag/atomic push; verify main and tagged dependencies; concise relevant user test list.

### Local workstation conveniences (not portable requirements)

- Repo: C:/Users/User/Documents/Codex/Prime-Script-FTAP . Development workspace: C:/Users/User/Documents/Codex/2026-10-24/new-chat .
- After runtime releases sync development outputs/PrimeVisuals.lua, outputs/Prime Visuals.txt and outputs/Prime Visuals Changelog.md. Repo is the source of truth.
- Existing Luau compiler: development work/compile_obsidian.mjs, using luau-web. It compiles main/Vortex and vendored modules. Add new modules to its inventory.
- Python simulations require lupa, currently available in development work/python-tools. Set PYTHONPATH in each new shell; it does not persist between calls. On another machine locate/install dependencies rather than claiming success.

```powershell
$env:PYTHONPATH='C:/Users/User/Documents/Codex/2026-10-24/new-chat/work/python-tools'
python tests/sim/third_person_visibility.py
node C:/Users/User/Documents/Codex/2026-10-24/new-chat/work/compile_obsidian.mjs
```

## Reference sources / reading order

- Resonance: https://raw.githubusercontent.com/aslan90101/resonance/refs/heads/main/Resonanse.lua . Local review copies: development work/Resonanse-current.lua, Resonanse-aslan.lua and water/visual extracts.
- Additional source: https://doitenroi.win/paste/DctRKW/raw . Saved development work/DctRKW-source.txt; inspect as text, never execute a foreign loader just to analyze it.
- docs/Visual-Source-Audit.md: actual visual-source comparison. docs/Anti-Kick-Audit.md: protective item comparison. docs/Configs.md and docs/MannequinPhysics.md: subsystem details. CHANGELOG.md/Git: exact release history; historical validation reports describe their dated release, not current blanket approval.

- 2.2.5 supersedes F3/F5: E toggles menu/cursor mode directly; LMB raycasts a movable target and attempts visible own-avatar approach near it without pausing camera look/flight. Release returns after 0.2s; token guards handle repeated clicks. User confirmed 2.2.4 approximately works; 2.2.5 native click ordering remains to test.

- 2.2.6 supersedes 2.2.5 input logic: first explicit E releases activation panel guard, then menu visibility determines flight/cursor pause. Native E toggles are never synthesized. High-priority primary-click approach passes through, accepts anchored/Terrain hits, offsets from the hit normal without requiring ground below; release/focus loss returns immediately. Native acceptance remains unverified.

- 2.2.7 corrects persistent menu pause: Enabled ScreenGui shells are guard-only, not visible panels; E-close clears the request, native close/offscreen/hidden panels resume flight. Approach adds >=6 studs sideways perpendicular to the view ray. User confirmed real avatar movement in 2.2.6, but reported stuck flight and avatar target occlusion; these two fixes await live verification.

- User confirmed 2.2.7 menu-pause and target-occlusion fixes. Native grab still rejected; timing is suspected, not proven. 2.2.8 explicitly separates actions: RMB approach/return toggle, LMB wholly native; neither button release returns. Focus loss/disable/unload still return. No automatic grab dispatch or server confirmation was added.

- User confirmed 2.2.8 works live. 2.2.9 adds held-target RMB pass-through using local GrabParts/GrabPart/WeldConstraint.Part1; latch routing across release so weld destruction cannot swallow the native throw. Empty-handed RMB remains approach/return. Native Humanoid name properties use freeNames restoration layer, refresh every 0.5s; no custom ESP labels or health changes. User subsequently approved the complete 2.2.9 Freecam on 2026-10-28.

## User acceptance — 2026-10-28

- User explicitly marked the complete Freecam in 2.2.9 finished/approved after receiving the eight-point checklist: flight/look/speed, native E spawning and resumed flight, sideways RMB approach/return, ordinary LMB grab/release, native held-target RMB throw, player names, F4 restoration and death recovery. Treat this as user-reported acceptance, not an independently observed engine test. Do not reopen Freecam work without a new issue/request.
- User separately reported one failed Blobman kick attempt against them while protection was enabled. Record as one reported successful defensive case, not universal immunity or a verified cause of an attack.
- Runtime remains 2.2.9; this acceptance checkpoint changes documentation only.

- User explicitly confirmed Camera noclip (camera through walls) and the new Spectate player list on 2026-10-28. Camera subpage is now fully accepted by the user. Sky acceptance is tracked per set in docs/Testing-Checklist.md; do not include them in camera acceptance. No runtime change/version bump.

## Mandatory acceptance ledger

- Maintain docs/Testing-Checklist.md for every new/improved runtime feature and its parameters, stable IDs, version, user acceptance or pending/bug/rework/retest/removed status. Add new rows on release and record concrete user feedback after tests. Do not infer acceptance from silence or from simulations. Keep previous approval when changed behavior needs retesting.
- docs/Settings-Inventory.md is a generated 339-key snapshot at 2.3.1, from the actual registered autosave payload in a mock run. It guards against omitted small settings, not proof of engine behavior. Regenerate when registry keys change.
- Current next pending items: Graphics new presets/Fullbright/snow/ocean appearance. Camera and the sky collection have separate user approvals; other Sky controls retain only their own historical acceptance. Older approvals do not close newly added knobs, animations or ESP systems.

## Sky collection checkpoint — 2.3.0

- User approved Blue Horizon/Purple Nebula/Pink Morning. Rejected Vaporwave/Lavender Gradient/Rose Gradient/Golden Hour aesthetically; replace with Rainbow Galaxy/Purple Radiance/Dark Matter/Milky Way, respectively. Preserve 20 entries and 16 unchanged approved definitions.
- New model references: Rainbow Galaxy 4943578383; exact user links Dark Matter 110290405998332 and Milky Way 545702970. Purple Radiance uses known Purple Sky 570559352 six-face data. Previews inspected via public Roblox thumbnails; external model delivery returned 401, so three model face sets are resolved at runtime by the existing safe GetObjects reader, not guessed.
- collectionSky aliases are part of dropdown specs and profile decode. Old saves must migrate without reset; only known aliases map, unknown dropdowns still reject. Resolved faces persist in existing sky payload, successful models cache in memory; failure does not replace current sky.
- Relevant test: tests/sim/sky_collection.py (exact model references, cleanup/cache, failure retention, saved faces, four alias migrations, 16 pinned retained sets). User subsequently approved all four replacements and accepted the sky collection only on 2026-10-28. Camera remains accepted/unchanged.

- Acceptance 2026-10-28: user explicitly approved all 2.3.0 sky replacements after receiving their test list. User clarified this acceptance covers the collection only, not all Sky controls or a new Reset test. Next: Graphics → Lighting, only new/improved GFX-01…GFX-05; do not repeat old approved shader tests. Documentation-only checkpoint, runtime stays 2.3.0.

- Scope correction: latest sky approval is collection-only. Camera approval remains from earlier messages. Do not broaden collection approval to the whole Sky/View category or infer a new Reset test. Preserve historical approvals separately.

- Completeness correction after code-level View audit: Remove haze (SKY-05) and the separate Reset time and sun button (SKY-07) lack individual explicit user confirmation. Ask these before declaring all View accepted. Custom ID/Load, automatic sun/cloud hide/manual override, sun/time and cloud controls have historical approvals; collection separately accepted at 2.3.0. See updated checklist rows SKY-04…SKY-08.

- Latest acceptance: after explicit disambiguation of Remove haze vs Clouds and Reset time and sun vs merely moving sliders, the user confirmed both exact actions. SKY-05/SKY-07 are accepted; all View is now accepted from separate confirmations. Earlier pending-scope notes are superseded by this later reply, not retroactively inferred from collection approval. Next test batch: Graphics → Lighting GFX-01…GFX-05. Runtime unchanged at 2.3.0.

- Latest user acceptance 2026-10-28: Graphics Lighting GFX-01…GFX-05 all approved. Pale Frost/Dreamy Night/Tokyowami strongly liked; Fullbright works alone and with presets, no residual blur/broken colors in combinations. Next untested: Weather snowfall GFX-06/GFX-07, then ocean appearance GFX-08/GFX-09.
- User interest/backlog: more high-quality lighting presets and manual advanced controls to create similarly rich looks. Code comparison confirms presets expose more underlying atmosphere/fog/ambient/shadow/Bloom/DOF properties than current Shaders UI. This conversation records the wish and explanation; no runtime implementation was performed. Preserve approved presets exactly when expanding controls; group advanced settings compactly, support configs/reset/unload, avoid duplicate indistinguishable scenes.

## Lighting editor — 2.3.1

- User requested editing an existing preset and more advanced parameters under manual lighting. Implemented lib/LightingEditor.lua; shared registry now 339 keys (+38). Add module to compiler inventory/test fixture when porting. New tests: tests/sim/lighting_editor.py; updated native-click/navigation/startup tests remain relevant.
- Original three preset definitions remain unchanged in VisualExpansion. Edit selected preset imports a COPY via the main LightingEditor context, disables source preset and Fullbright, stages manual values/rainbows, enables manual light and opens its panel. It does not mutate source tables. Bloom size is clamped to the engine range; missing properties use underlying game/default values.
- Manual panel has Basic/Light/Air/Effects/Focus pages. Advanced environment, Atmosphere and DOF flags default off; legacy manual keys/default behavior remain. Replace game effects suppresses native Lighting PostEffects, preserving state. Native sun-ray spread default is read from an unparented temporary instance.
- Environment/air/game-filter overrides use shaderEnvironment/shaderAir/shaderReplace layers; base brightness/exposure retain shader. Owned Atmosphere is destroyed on disable because it has no Enabled property. Cleanup restores layers and owns all new instances. Existing once-per-second Shaders maintenance repairs enabled effects.
- Copying Tokyowami resolves its static sky into the normal custom sky system and copies sun size/visibility. Manual lighting off/Reset filters do not reset that independent sky: use Reset sky. All color fields support existing owner-aware rainbow controls. Auto/slots/import/export store all values; there is no separate lighting-only preset bank, use existing five full-config slots.
- Prior approval of original presets remains; new manual editor and compatibility require live retest via LIT-01…LIT-13. Next pending: this editor, then Weather snow and ocean appearance. No changes to accepted Freecam.

- Editor respects Remove haze: suppress manual Air while haze flag is active, retain extended fog, immediately resume on haze-off. Disposal removes owned atmospheres from hiddenAtmospheres first. Keep this coordination to avoid recreating hidden atmosphere or reparenting destroyed instances. Covered by lighting_editor.py; needs user interaction check LIT-13.

- Latest acceptance 2026-10-28: user explicitly approved the entire Lighting subpage at 2.3.1, including the new preset editor/advanced manual controls, after the release test list. Mark GFX-01…GFX-05 and LIT-01…LIT-13 accepted by section-level user approval; do not invent per-slider observations. This supersedes pending-editor notes above. Next untested: Graphics → Weather new snowfall GFX-06/GFX-07; then ocean appearance GFX-08/GFX-09. Runtime unchanged (documentation-only acceptance).

- Latest acceptance 2026-10-28: user explicitly approved all snowfall after the six-point Weather checklist. The initial report of no particles and later suspected delay were both retracted; no snow bug/delay remains reported and no snow runtime changes were made. GFX-06/GFX-07 accepted by section-level report. Lighting and Weather are accepted; next untested Graphics items are ocean appearance GFX-08/GFX-09 (materials, custom color/rainbow, restoration/Realistic Water coexistence). Runtime stays 2.3.1.
