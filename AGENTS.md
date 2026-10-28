# Prime Visuals / Prime Vortex — project memory

Updated 2026-10-28. Read before modifying this repository. Verify details against code, Git and CHANGELOG.md; do not reconstruct algorithms from feature names.

## Current checkpoint

- Prime Visuals is a personal Roblox **Fling Things and People (FTAP)** project. Author Roblox username: **876osamuha**. GitHub owner: **Mengy777**.
- Repository: https://github.com/Mengy777/Prime-Script-FTAP ; branch `main`.
- Published runtime target: **2.2.6**, tag `v2.2.6`. Next normal runtime version: **2.2.7**. Consult Git for the release commit.
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

- Default-on `antiKickEnabled` is persisted; currently **301 settings** overall (Smooth camera removed in 2.2.1).
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
- Smooth camera was removed by user request. Spectate camera behavior, original thirteen collection skies and sky reset are approved; 2.2.1 Freecam rework, new Spectate picker and seven additional skies require live verification. See docs/View-2.2.1.md.
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
