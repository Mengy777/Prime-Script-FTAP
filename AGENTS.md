# Prime Visuals / Prime Vortex — project memory

Updated 2026-10-28. Read before modifying this repository. Verify details against code, Git and CHANGELOG.md; do not reconstruct algorithms from feature names.

## Current checkpoint

- **Major3 override:**3.0.0 implements docs/Major-3.0.md. All categories use native merged cards without upper section bars; Home layout preserved. Omega replaces header mark. Keybinds/MajorInterface own input/UI with early cleanup.395 settings,121 bind_* keys default empty (no RightShift/3/F4 defaults), mouse1–3 supported. Movement/E/native mannequin controls remain. HUD click or fallback launcher opens menu. Appearance/HUD autosave. Validate bindings before profile mutation and clear router before applying. Tests run via tools/compile.mjs (absolute luau-web path) and tests/run_simulations.py. Prior explicit no-loading/no-new-theme rules are superseded by this user Major3 request. Actual visual/live3.0 approval remains pending; standalone Vortex unchanged.


- **Acceptance override 2026-11-02:** user explicitly accepted ALL current Prime Visuals2.4.4 sections/functions as checked and confirmed. No pending user acceptance items remain for this version. This supersedes older pending/next-ESP/FTAP/UI/system notes below. Record broad acceptance only, not invented per-scenario live evidence. Removed features remain removed. No Vortex/Infinity acceptance implied. Next work follows a new concrete request; future changes get new checks. See docs/Acceptance-2.4.4.md and current header in Testing-Checklist.md. Documentation-only, no runtime bump.

- Prime Visuals is a personal Roblox **Fling Things and People (FTAP)** project. Author Roblox username: **876osamuha**. GitHub owner: **Mengy777**.
- Repository: https://github.com/Mengy777/Prime-Script-FTAP ; branch `main`.
- Published runtime target: **3.2.4g**, tag `v3.2.4g`. Next normal runtime version: **3.2.4h**. Consult Git for the release commit.
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
- Historical version sequence (superseded by suffix scheme below): last digit increments through 9, then carries: `2.1.8 → 2.1.9 → 2.2.0 → 2.2.1`. Do not skip routine versions.
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
- 2.4.7 user requested temporary Prime Vortex category INSIDE Visuals, before Settings. Freecam moved there (Vortex/Freecam route), Spectate remains View; behavior/keys/binds unchanged. This is not a transfer into standalone PrimeVortex.lua, which remains unchanged. New location pending user acceptance.
- 2.4.4 supersedes2.4.3 Objects/Items: user explicitly removed BOTH entire ESP tabs and all their runtime handlers/settings. Removed detectors/PCLD/Sticky/Blackhole ESP + Blob/Gucci/antiKick-item/combat markers; 94 keys removed,257 remain. ESP Players/Tools, self highlight, actual AntiKick protection and FTAP blackhole visuals remain. Old configs ignore removed keys; no object-master migration remains. object_profiles.py now verifies absence/legacy compatibility. Do not restore removed functions from older notes.
- 2.4.3 ESP Items subpage: objectESPEnabled gates existing Blob/AntiKick/Combat managers; types/appearance/colors are pages in one settings window. Existing category keys retained. 15 new persisted keys (351 total): master, category/type options, shared style/distance, item color/rainbow/natural palette. Master-off preserves selections; applyProfile infers master from old category flags ONLY if absent in source payload. object_profiles.py covers legacy migration and off-state persistence. Server detectors remain Objects, Reveal invisible moved Tools. User approved old ESP05…09 on2026-11-02; new UI/options await fresh confirmation.
- 2.4.2 localization: initial bind translates immediately (late-created controls), retains original English source for reversible RU/EN switching. Missing Objects/Tools/parameter/protection labels and Anti-Kick status composition added. tests/sim/localization.py covers actual nav labels, dynamic creation/status and saved Russian; keep identifiers/usernames unchanged.
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
- 2.4.5 Home layout supersedes2.4.1 placement: full-height profile LEFT, phoenix TOP RIGHT, session statistics BELOW phoenix, common lower edge. Fit on parent size/detail-content changes, no per-frame layout job. Portrait420px. Obsidian optional Groupbox.FixedHeight is used only for Home cards. HOME-245 pending visual acceptance; all preexisting2.4.4 functionality remains broadly user-approved.
- 2.4.1 Home supersedes2.3.7 banner/quick links: compact profile with version below, phoenix card in left column, basic session metrics right. No page scrolling/hero slogans/quick access. Session details replace6 basic rows with12 diagnostic rows; never append all to the page. Fits intended normal window; real DPI/visual acceptance pending.
- Subpages: View Camera/Sky; Graphics Lighting/Weather/Water & FPS; Character Appearance/Movement/Mannequins; ESP Players/Objects/Tools; FTAP Grab line/Crosshair/Blackholes/Audio; Settings General/Profiles. Protection is in Settings General.

## Important regressions / current behavior

### Camera — latest behavior supersedes historical RMB-only notes

- FOV **30–120**, live slider and manual input. Do not restore extended FOV/projection experiments.
- Third-person mouse rotation without RMB uses native CameraInput.setTogglePan. No second CFrame rotation and no MouseDeltaSensitivity writes. Pause for menu/text/Freecam/Spectate/Scriptable camera and restore original pan/MouseBehavior. Earlier custom orbit attempts caused excessive first-person sensitivity.
- 2.1.6 fixes local avatar invisibility: track BaseParts in body/head/accessories; maintain LocalTransparencyModifier after camera update; handle late parts/respawn. Exclude HumanoidRootPart, preserve true Transparency and intentional effect layers.
- 2.2.0 opens native wheel zoom **0.5–80**, allowing first person and back out. Distance slider clamps once to the chosen distance, then frees the range. Maintenance must not snap back every second.
- When camera-to-Focus distance is below 1, suspend forced third-person visibility so the head/accessories do not block first person; first-person body setting may operate. Restore visibility on zoom out. Restore original camera mode/zoom limits on disable/unload.
- 2.3.8 supersedes the Focus-only check above: use actual camera-to-Head distance, falling back to Focus if unavailable. Per-part LTM listeners repair late game writes in third person, respect patch layers and skip first person/Freecam/Spectate. Disconnect on removal, character replacement, disable and unload. 150-cycle regression passed in mocks; real user confirmation pending.
- 2.3.9 corrects2.3.8 pitch regression: near radius2 studs and explicit thirdNear LTM=1 for Head/accessories; remove near layer on zoom out before thirdBody restoration. Guard listeners also enforce near head hiding and skip Freecam/Spectate; silence listeners during layer transitions. 60 three-direction pitch cycles added. Real game confirmation pending.
- 2.4.0 additionally repairs ordinary BasePart.Transparency=1 while far, using per-part known visible alpha, or0 fallback ONLY for canonical R6/R15 body names. Invisible unknown helpers remain invisible; other registered Transparency effect layers take precedence. thirdAlpha removed near/disable/character replacement/unload; both property listeners owned/cleaned. This supersedes old blanket rule of never touching actual Transparency for third person. 360-cycle720-second mock regression passed, real FTAP cause/long-session fix still unconfirmed.
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

- 2.4.6 lifecycle fix: detect Character/HRP/Humanoid/hitbox identity changes, recursive exact-name BasePart hitbox lookup; distinct missing-hitbox status. clear cancels local spawn coroutine when supported, resets busy; stale completion checks token before touching shared state. Spawn deadline no longer waits for busy=false. Active owned toy gets one reattach attempt before respawn. API Restart exposed through Settings/Restore protection; respects enabled=false. Tests30 replacements/late nested hitboxes/hung coroutine/stale response/restart. Cannot revoke already-dispatched server requests; no general immunity claim. New live AK-246 check pending.

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
- docs/Settings-Inventory.md is a generated 339-key snapshot at 2.3.3, from the actual registered autosave payload in a mock run. It guards against omitted small settings, not proof of engine behavior. Regenerate when registry keys change.
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

- Latest acceptance 2026-10-28: ocean appearance materials/custom color/rainbow/restore all explicitly approved. User clarified original ocean appearance and Terrain Realistic Water are separate targets with separate color controls; shared material application is not required and must not be treated as a bug. GFX-08/GFX-09 accepted. All Graphics now user-approved at 2.3.1 from accumulated Lighting/editor/Weather/ocean plus historical generic particles/water/FPS approvals. Next untested section: Character new CHR-01…CHR-09 and ANI-01…ANI-46; preserve previous Forcefield/Cone hat approvals and deferred mannequin ragdoll refinement. Documentation-only, runtime unchanged.

- User deferred remaining acceptance tests until later (2026-10-28). Preserve completed View/Graphics approvals; resume new Character checks only when requested, then remaining ledger items. No automatic testing/reminder/development was requested. Unchecked entries remain unchecked; runtime stays 2.3.1.

## Graphics research — 2026-10-28

- User asked to inspect other readable/open-source scripts for graphics improvement beyond color/fog presets. Completed research only, docs/Graphics-Research.md. Runtime 2.3.1 unchanged, tests still deferred.
- Downloaded/decoded NaNo.rbxm outside repo into development work/shader-audit, read 10 source fields without executing them. Photon genuinely raycasts and adds colored PointLights; volumetrics use layered Beams. Source has duplicated light-creation branches, lightLimit10000, serial wait0.1 and weak checks; not a drop-in module. No permissive repository license was returned; no foreign implementation copied into runtime.
- Also read actual Pixel Shader source (GUI-grid renderer), CPU Path Tracer Controller/worker (Actors + EditableImage, author low-resolution benchmark), Radiosity Rendering/Canvas (baked lightmaps). Lumen repository has description/license only, no implementation. Do not claim live FTAP results.
- Best next proposal is an optional, bounded, reversible dynamic bounce-light approximation integrated with current lighting editor. This is a research recommendation, not implemented or authorized as the next runtime change yet. Do not promise RTX/native renderer replacement or texture detail enhancement from grading alone.

## Experimental graphics — 2.3.2

- User explicitly authorized experimental graphics implementation after research. Added original lib/ExperimentalGraphics.lua with two default-off masters giEnabled/shaftEnabled under new Graphics Experimental subpage. No foreign code copied/executed. No GPU shader/RTX/texture-resolution claim.
- GI: fixed quality budgets Low12/2 samples/.16s, Balanced24/4/.12s, High40/6/.10s, Ultra64/8/.09s. Native non-shadow PointLights, six-stud cell dedup/pool reuse, sunlight occlusion/incidence and bounded nearest local-light sampling, Neon approximation, 3ms CPU sampling check, fade/age/distance/moved-source removal. Local-light cache at most128, nearest16 examined and at most2 extra occlusion rays/sample. Scene Lighting/material properties untouched.
- Shafts: 4–24 face-camera Beams, golden-angle offsets around camera, sun direction and geometry-limited length; remove at night (sun.Y<=.08). Parameters length/radius/width/opacity/count/color/rainbow. They are artificial rays, not physical participating media or shadow maps.
- Lifecycle: shared protected named jobs; descendants light cache only when enabled, own root/parts, child light/attachments/beam owned by parent (not separately retained in main owned map), no physics/query collisions. Recover deleted root and clean on disable/unload; main teardown calls Destroy. Settings persist, old configs default effects off. Registry353 keys (+14), inventory/checklist updated.
- Tests: experimental_graphics.py checks no rays while off, per-tick budgets/pool caps, sun/occlusion/local lights, no animation config writes, beam counts/night cleanup, root recovery, no scene-brightness edits, profile restore and unload. Compiler/runtime fixture include new module. Actual FTAP visibility/GPU cost unknown; XG-01…XG-08 await user testing. Prior View/Graphics(2.3.1) approvals remain historical; other acceptance tests stay deferred.

## Experimental graphics REMOVED — 2.3.3 (supersedes 2.3.2 notes)

- User explicitly requested deleting Experimental. Removed entire module, runtime dependency, main lifecycle/count hooks, navigation page/routes and all14 settings. No hidden dormant feature remains. Graphics again has Lighting/Weather/Water & FPS. Approved LightingEditor and original presets remain unchanged.
- Registry339 keys. Existing353-key saves load via normal unknown-key ignoring and retain approved settings. New removed_graphics.py verifies this and absence of module/UI; deleted old experimental simulation/module fixture/compiler entry. Historical research and release docs remain clearly archived.
- XG rows are removed/cancelled, not accepted; no further experiment test requested. Other acceptance tests remain deferred. Runtime2.3.3, next2.3.4.

- Acceptance 2026-10-29: user explicitly approved Character CHR-01…CHR-08, including smooth Jump circle. CHR-09/all46 ANI remain unconfirmed. Animation code uses existing character Animator, falling back to a locally created Animator; do not promise all tracks are local-only or visible to everyone without a second-client test. No runtime change.

- 2.3.4: user requested removing Character animations pending future Vortex work. Removed runtime playback, UI route/card,46 definitions and3 registry keys (336 remain). Old profiles ignore those keys. No Vortex change. Prime Visuals intended scope is local-only visuals; do not restore replicated character animations. CHR-01…08 approved; CHR-09/ANI rows removed, not approved.

- Acceptance 2026-10-29: user explicitly accepted the entire current Character section on2.3.4. Treat as section-level user approval, without invented individual tests. Removed animations remain removed, not tested; deferred mannequin physics fidelity remains backlog. Next acceptance batch: new/improved ESP. Documentation only, no runtime bump.

## UI redesign — 2.3.5, 2026-10-29

- User requested stronger UI/UX: feature settings now independent draggable floats (header LMB/touch), above main controls, native overlay palettes/dropdowns remain above floats. Remembered positions use existing profile ui.panels; clamp to viewport after movement/resize/DPI. No forced main-window following or per-frame layout resize; watcher only checks owner visibility/state and DPI changes. Preserve outside-click/Escape/owner-hide dismissal and enabled-only access.
- All top section bars redesigned as framed segmented controls with Lucide icons, animated shared selection, hover and unified spacing. Offset50 replaces42. Search/translation and setting keys preserved. Window entrance is one short UIScale tween, cancellable on toggle/unload; no artificial delay/loading screen. Main opts in via WindowEntranceEnabled; Vortex entry source unchanged. Main tab/group timings shortened.
- Checked current ScriptBlox Resonanse open-source listing and actual remote source UI configuration without executing foreign code. No gameplay functions copied or changed. Runtime remains336 settings.
- Luau compilation and simulations: actual native header drag, bounds1/1.5/2 DPI, independent position/reopen, child dropdown/outside/Escape/cleanup, profile coordinate cold restore, native controls/clicks, startup failure recovery, lighting editor. Real Roblox appearance/input needs user validation UI-06…UI-09; previous gameplay approvals stay accepted.

## Expanded simulation request — 2026-10-29

- User requested a complete stronger simulation and immediate notification/fixing of any discovered actual bug. Do not equate missing mock APIs with runtime bugs.
- Added tests/run_simulations.py (isolated subprocess suite), controls_matrix.py (336 registry keys, toggles/dropdown entries/numeric endpoints/colors; strict unexpected warning/notice checks), server_model.py + server_integration.py. Server model uses independent Lua VMs/scenes/filesystems, canonical roster, deterministic latency/jitter, reliable ordered event delivery and connection epochs. This is explicitly not Roblox/FTAP server code/protocol/physics.
- Strengthened mocks: empty Multi dropdown is{}, actual Mannequins/MannequinRagdoll modules loaded, ancestor lookup/Touched API; controls fixture supplies fromOrientation. Prior mock-only false alarms disappeared. Remaining expected matrix warnings: no local-image API (artwork fallback) and absent native CameraInput (RMB fallback), separately covered by emblems/third_person_pan.
- Server integration tests include two-client local effect isolation, selected-player leave/rejoin, stale-session event rejection,25 delayed respawns plus beam removal/recreation, real mannequin/R6 modules for spawn/avatar replacement/limit/error retention, local grab/rotation-input/scroll/throw/focus-loss and cleanup. No real ragdoll trajectory, arbitrary uploaded-asset availability, server authority or anti-kick guarantee asserted.
- Final simulation results in docs/Simulation-2.3.5.md; manual UI acceptance remains pending, gameplay acceptances retained. No runtime gameplay bug identified by these scenarios.

- Acceptance 2026-10-29: user approved the 2.3.5 UI update after the release checklist. UI-06…UI-09 accepted as a section-level report; do not invent individual observations or extend to untested ESP/FTAP/system items. Next pending batch: new/improved ESP. Documentation only; runtime remains2.3.5.

- Acceptance2026-11-02: user explicitly confirmed all10 ESP Players checks (Box/Skeleton/independent highlight, HP/distance/range, font/background, selected2 vs all, behind-camera safety, respawn and disable cleanup). ESP-01…04 accepted on2.4.2; do not invent separate R6/R15 tests. Next pending ESP Objects05…09, then Tools10…13 and FTAP/system. Documentation only.

- Acceptance2026-11-02: user explicitly approved Home2.4.5 composition. HOME-245 accepted by overall visual approval, without invented per-DPI testing. Earlier broad2.4.4 acceptance retained; no pending requested acceptance items. Runtime unchanged.

- 3.0.1 overrides empty menu default: bind_menu=RightControl; other activation bindings empty. Migrate untouched empty/missing old menu assignment only, preserve explicit clears/rebinds and occupied RightControl. Four migration cases tested.

- 3.0.2 compact HUD30px,9px corners, LMB/touch drag with3px threshold and click suppression. Persist hudOffsetX/Y once at release/focus loss, keep desired saved coordinates, viewport-clamp display. Cache both coordinates before invoking setters to avoid X callback resetting Y.396 settings, hud_drag.py verifies exact cold restore and FPS update stability. Live visual/input approval pending.

- 3.0.3: AvatarAppearance records known body/accessory/head decal alpha early. Canonical body/Accessory Handle fallback0 if already hidden; unknown helpers preserved. Third person consumes shared cache; Freecam restores ordinary alpha and late LTM writes. No Texture replacement or avatar recreation. Signal cleanup on removal/replacement/unload. avatar_modes.py covers early hidden hair/face +150 delayed Freecam cycles. Live approval pending.

- 3.0.4 Wordmark module styles nativeWindow.TitleLabel and HUD title with Arcade, fixed per-letter rich colours and static rainbow underline. Omega still animates; HUD icon26px. TextService measurement + fallback packs FPS7px after brand and8px end padding. Brand font protected from general menu font registry updates. No settings/gameplay changes; wordmark.py and hud_drag.py cover static colours/spacing/persistence; visual acceptance pending.

- 3.0.5: header spacer keeps brand beyond sidebar divider. Protection waiting watchdog clears stale bindings every8s; no fabricated character/hitbox. Spawn defers while holding +1.5s and4s after foreign plot exit. This creates an unprotected interval; no server cooldown/limit bypass. Simulated coverage does not prove live protection.

- 3.0.6 protection SetEnabled is idempotent; repeated true callback previously replaced Attached status with Waiting while active phase never refreshed it. Confirmed active weld now refreshes Attached. User accepted header3.0.5; preserve it. Live protection acceptance still pending.

- 3.0.7 camera visibility allowlist: canonical body, Accessory/Hat handles and head/accessory decals only. Exclude tools/helper geometry from alpha recovery and third/free LTM forcing. Regression includes hidden keyboard Tool and torso helper. Live screenshot cause not proven; no mesh/avatar deletion.

- 3.0.8 supersedes3.0.3/.7 appearance repair: user requested v2.4.7 camera rollback. thirdPart and visibleFreeBody restored verbatim from tagv2.4.7; shared AvatarAppearance removed, no forced alpha fallback for invisible accessory Handles/decals. thirdGuard native pan/wheel/near behavior unchanged. New regression uses invisible ACCESSORIES (earlier test only tools missed this). Simulated checks do not prove live screenshot cause; approval pending.

- User tentatively accepted third-person3.0.8; preserve it. 3.0.9 Freecam-only scoped LTM listeners repair writes after frame callback, no alpha reconstruction. clearFreeVisibility disconnects on exit/replacement/unload; per-part removal cleanup next update. Simulation late writes150cycles and disable pass; actual grab/rotation still requires live confirmation.

- 3.1.0 supersedes prior3.0.8/.9 visibility internals: one early AvatarVisibility cache owns third/free transparency. Removed duplicate thirdGuard and Freecam per-part repair. Canonical direct body fallback0 only; Accessory/Hat Handle and Head decals require actually observed alpha<1. NEVER give invisible accessory Handles fallback0 (3.0.3 regression keyboard/torso). Restore LTM and observed alpha with signal reentry guard, preserve other feature alpha layers, release on mode/near change; head/accessories hidden near. Early cache starts before camera toggles, remains while modes off to observe avatar. Character replacement/removal/unload disconnect. First-person body fade released for far/free modes. Manual cam controls/transforms unchanged. New avatar_modes covers ordinary alpha (previous3.0.9 test missed), customface, invisible accessories/decals and150 switches. Unknown already-hidden accessories at startup/deleted assets cannot be reconstructed from unseen baseline. Actual FTAP cause still not observed; do not equate simulation with live fix.

- User accepted Freecam visibility/no gray block on3.1.0, but reports RMB approach stopped.3.1.1 adds UIS RMB fallback to existing CAS, same-InputObject dedupe, shared UI/focus/holding gates and press/release native throw decision. Refresh toy UI gate at press. Stop clears/release disconnects fallback. Actual missed-input cause unproven; preserve AvatarVisibility. Test both delivery orders/processed input and existing throw/return.

- 3.1.2 user explicitly REMOVED all Freecam character teleport/approach. Delete RMB callbacks/fallback, move/return helpers, movement momentum edits and approach hints. RMB native Pass whether holding or not; no character transforms on exit/focus loss. Do not restore this from old memory. Freecam movement/E/speed remain. User still reports bald/custom-face loss; visibility3.1.0 only partial acceptance (body/no gray). AvatarVisibility now uses async GetAppliedDescription + CreateHumanoidModelFromDescriptionAsync, temporary model NEVER parented, destroyed along with description, generation-guarded. Only reference-matched head accessory Handles (head attachments + name/mesh) get unseen baseline; torso/waist accessories excluded. Head decal texture repair from reference with own cameraFace patch. Handles already invisible at script startup now covered. Refresh reference on CharacterAppearanceLoaded. No reference accessory insertion/deletion or whole-avatar ApplyDescription. Failures retain snapshot and retry15s. Actual deleted assets/mismatched names/mesh/reference API availability still limit repair; real FTAP acceptance pending.

- Acceptance2026-11-03 on3.1.2: user explicitly confirmed hair stays visible in BOTH third person and Freecam even after time spent playing. Do not reopen this as unconfirmed. This does not separately confirm custom face, initial-hidden startup, wheel near/far, teleport removal/native throw, death/reload or other remaining3.1.2 checks. Documentation only; runtime remains3.1.2.

- 3.1.3 user requested Prime Vortex category EMPTY. Freecam moved back to View/Camera tools, shared card with Spectate. Preserve stable freeCameraEnabled/freeCameraSpeed/bind keys, config/lifecycle/visibility. Empty Vortex sidebar entry retained. Standalone Vortex unchanged. Supersedes2.4.7 temporary placement. Removed duplicate Wheel-speed label. Navigation tests cover empty Vortex and View tools; live placement pending.

- 3.1.4 local ToyCollection module reorders native Your Toys UIGridLayout children, never reparent/clone cards or invoke toy/favorite remotes. Settings Interface toggle defaultOFF; parameter editor slot1..28/toy name/assign/reset; hidden serialized28-slot order + enable/editor state autosave.401 total settings (+4 plus toggle bind). Starter Rocket1/BlackCrystal2/Blobman3/TetracubL4/Cake5/Cube6/Trumpet7/Ocarina8, PalletLightBrown26 per latest explicit user correction (not24). Missing preferred items filled from remaining native order without consuming reserved pallet. Name/label/model/attribute aliases; scope YourToys/owned-toys paths or toy-menu with8 known cards; excludes store/shop and Prime UI. Dirty-event coalescing .2s; no continuous scans. Preserve native favorite/order writes for disable, observe replacement menus; unload restores SortOrder/LayoutOrder. Actual native FTAP hierarchy not available: adaptive detection and aliases require live confirmation. Do not claim pixel cursor alignment verified.

- 3.1.5 supersedes3.1.4 collection adapter: user reported no effect, wants click-select large list and black favorite star with animated rainbow contour. GUI screenshot has viewport thumbnails/no captions; do not infer hierarchy verified. Adapter now discovers viewport-card sibling groups and supports direct Position ordering plus grid/list LayoutOrder. Names from preview models/ObjectValues etc; native Title Your Toys context. Dynamic searchable Dropdown replaces manual input while preserving toyCollectionToy Input profile schema; optional Obsidian ValuePreviews renders owned viewport clones in virtual rows. Existing native star primitive bounds/image copied for black fill + single-hue cycling outline; fallback bottom-right25px when no native star identified; no native favorite flag changes. Integrated ToyMenuDiagnostics captures local PlayerGui toy roots automatically on enabled collection rebuild, throttled by structural changes/2s, into executor workspace PrimeVisuals/ToyMenu-Diagnostics.json. User explicitly declined separate diagnostic script; NEVER ask to run it separately again. On future failure read C:/Users/User/AppData/Local/Xeno/workspace/PrimeVisuals/ToyMenu-Diagnostics.json directly before more fixes. Actual game capture not yet available; static screenshots and mock tests are not live proof.401 settings unchanged.

- 3.1.6 actual diagnostic capture read from Xeno (10018 nodes,195 owned cards). Exact target MenuGui/Menu/TabContents/Toys/Contents/UIGridLayout; previous heuristic missed it. Exact adapter now first; explicitly exclude ToyShop/Shop/ToyDestroy/ToyTemplates. Actual card Frames contain ViewItemButton/ViewportFrame and Favorite ImageLabel rbxassetid://10045503805, Size .711,.711, anchor/position1,1. Native BombDarkMatter maps black crystal, TetracubeO cube. Visual28-slot editor replaces visible dropdown/slider/Assign: click slot, catalogue card;18 previews/page/search. Stable4 keys/401 total retained; legacy controls hidden for schema compatibility. Clone failures fallback; remove inherited label UIListLayout before absolute-position editor, inherit overlay ZIndex. Generated PV_ descendants do not trigger native rescans. Sanitized195-ID/order fixture only; never publish full personal diagnostic.31 scenario scripts/99 check groups expected; verify report. Live ordering/appearance awaits user confirmation.

- User accepted3.1.6 native collection actually works.3.1.7 requested optimization: exact native container only, no wholeGUI scan/diagnostic when found, cached identities and synchronous LayoutOrder/SortOrder repair; native Visible changes preserve prepared ranking without rebuild. Editor preview lazy while ancestor hidden, page reuse, removed hidden dropdown previews; animation10Hz paused native menu hidden. Collection27; PALLET23 supersedes26. Migrate old28-slot pallet26 by swap23/26, discard28; Assign also migrates. Keep legacy hidden slider max28 to validate old saves, manager clamps27. Marker65% source bounds. Config401keys retained.100-cycle count regression checks no repeated fullGUI scans/clones and instantaneous native write repair. Do not claim liveFPS improvement from mock counts. Remaining freezes outside module not diagnosed. Version3.1.7 live checks pending.

- User confirmed3.1.7 freezes disappeared.3.1.8 curated starter27 all verified owned IDs, grid9columns: row1 UFO/Plane/Helicopter/PaperPlane/Boombox/Basketball/Balloon/Sparkler/SmokeBomb; row2 Katana/Kunai/AcousticGuitar/DarkMatter/Rocket/TetracubeL/Trumpet/Ocarina/Cake; row3 TetracubeI/T/FloatingIsland/YouDecoy/Pallet/Blobman/DiscoColorBall/LightBall/JukeboxBlue. Prioritize22/24 besidepallet23 and14above. No TetracubeO/couches or otherfood/instruments. UpgradeOrder replaces previous starter if it contains Donut+Melodica+ShoppingCart, updates persisted control value; other customorders retained. Restorestarter always newset. No server calls or performance rewrite. Actual DiscoCube label ambiguous: only native DiscoColorBall exists in capturedcatalogue; state this rather than inventing anID.

- 3.1.9 user screenshot removes Katana/Kunai/TetracubeI/T. Replace slots10Snowball(BallSnowball),11GlassBoxGray,19FoodHamburger,20LadderLightBrown. Burger explicitly supersedes cake-only rule; keepcake too. Central priorities unchanged. UpgradeOrder maps those four exact saved IDs in place rather than resetting other slots.27items/performance unchanged.

- 3.2.0 user REMOVED ability to edit collection in-game. Only toggle and fixed3.1.9 set remain. Removed entire editor/catalogue/preview/assignment/reset/upgrade APIs and3 editor settingkeys;398settings. Old profiles ignore those keys, always use current curated27set. Keep native fastpath/fixedorder/smallstars/disable restore. Do not restore editor without newrequest.

- Latest user version scheme:3.2.1→3.2.1a→3.2.1b→3.2.1c→3.2.1ab→3.2.1ac→3.2.1bc→3.2.1abc→3.2.1abcf→3.2.2, repeat suffix order for each base. No new Major Update branding; detailed reports retained. Do not use alphabet a…z or50-number series proposed then rejected.
- 3.2.1 new CoinIcon module, defaultOFF FTAP/Gameinterface coinIconEnabled +bind (400keys). Actual local diagnostic verifies MenuGui/TopRight/CoinsFrame/CoinsDisplay/CoinImage, native texture8659337867, amount sibling Coins; store CoinImage instances explicitly not targeted. Code-only concave ⟡ black48spans +8x3stroke layers, native scaling, singleHSVhue8s cycle at30Hz. Child overlay retains source image box/layout and CoinsButton, patches ImageTransparency only. Fixedpath retry.5s enabledonly; hiddenGUI animation skip, overlay/menu recovery, ownedcleanup. No currencytext/serverchanges/assets. Unit and config tests coin_icon.py; real rendering/placement pending.

- User explicitly accepted3.2.1 coin icon works.3.2.1a(2026-11-05): replace plane2 with Campfire, helicopter3 FoodMushroomPoison, Boombox5 FoodHotSauce, basketball6 ToiletWhite.27fixedset; allother slotsunchanged inclpallet23. IDs capturedownedverified; no editor restoration or perfchanges. Live replacement approval pending.

- 3.2.1b bootstrap rework: fullscreen plainFrame pureblack, compact CanvasGroup card, whiteBuilderSans status+dots/progress, actualWordmark Arcade24+PrimeIcon Omega (earlyfallbackwhiteglyph). Fade .14/.18, no minimum wait. Four task.defer workers download15common sourcefiles; loadUIModule waits on its record, initialfailure isattempt1; constructors sequential and cancellationchecked beforeexecute/cache. Functionfactory cache expanded (modulesreturnfactories, Librarytable always reconstructed). IntroClose cancels card/backgroundtweens and both renderconnections; normalshutdown nowclosesintro too. No fullscreenCanvasGroup or extra moduleHTTPforbranding. loading.py uses cooperative yieldedHTTP scheduler to testboundedconcurrency/no duplicatefetch and nativepresentation/earlyunload. Actual speed dependsnetwork, notmeasuredinXeno. Preserve retries/cleanup and lazyMannequins. Nextsuffixc.

- 3.2.1c loaderfix: userreports whiteglyph→rainbow swap/hitch. Inline bootstrap uses same32-segment PrimeIcon geometry andinitialHSVcolor BEFOREHTTP; single existing rendercallback rotates35deg/s +12s hue. Removed glyph and latePrimeIconconstructor/secondconnection; sameinstance retainedthroughstartup. Wordmarkstillreusesmodule. Cooperative loading.py checkscoloredrotatingOmega whileHTTPpending andidentityafterfinish. No fullsuite rerun forscopedbootstrap change; compile/loading/startupfailurechecks pass. Nextsuffixab peruserscheme.

- User confirmed3.2.1c loading.3.2.1ab fixes lingering holdingstatus: old detector trusted any retainedPart1. Now require GrabPartBasePart +WeldConstraint enabled/active(notfalse), validPart0/Part1joinGrabPart and liveotherBasePart. Release casesdisabled/inactive/nilPart0/deletedtarget covered; trueholdcontinuesdefer,1.5sgracepreserved. Charidentitychangeresetsoldgrace. No inputbuttonheuristic/forcedtimeoutspawn/gameobject deletion. Compile AntiKick/longsession/startupchecks; exactlivecause stillrequiresuserconfirmation. Nextac.

- 3.2.1ac fixesCustomLine touchingotherplayers: ownGrabBeam checksAttachment0START origin localchar/currentcamera, rejectsforeignchar. StandaloneBeamPart fallbackworldposition: nearestlocalbody<=8 and .5closer thanallothers; ambiguous/unassignedskip. Never inferowner fromtargetAttachment1. enforce/observebothfilter, originchange4thsignal releasespatchimmediately; recoveryrechecks. Longsession/serverfixtures nowhaveproperlocalsourceattachments; line_ownership.py testsforeigntargetingself/nativeupdates/unowned/spatialforeign/reassignment. Nativeunknownhierarchylimit: ambiguousorigin defaults togameappearance, notblanketapply. No change to serverstates. Nextbc.

- 3.2.1bc userreports bald/defaultface atstartup savedthirdperson. AvatarVisibility fallback GetHumanoidDescriptionFromUserIdAsync when appliedreference missingmatchingheadaccessories/defaultFace0. Referenceonly temporarymodels; merge verifiedheads, fallbackface replacesapplieddefault onlypositiveuserFace. Normalize meshID URLs, headattachment+meshfallback forrenamedhair, lowercasematchheaddecals. Incomplete reference retries15s, generation/disposal preserved. Neverexposewaisthelpers via matchingmesh. avatar_cold_reference.py constructoractiveThirdcase + lifecycle oldtests. Cannotrecoverdeletedaccessories justfromreferences; no liveproofyet. Nextabc.

- Acceptance2026-11-05: user says temporarily count3.2.1bc startup hair/custom-face bug fixed. Record provisional user acceptance of that reported cold-start issue only. Do not infer independent long-session/death/Freecam/near-wheel tests or approval of3.2.1ab/3.2.1ac. Runtime unchanged; next3.2.1abc.

- 3.2.1abc Personalization/Персонализация sidebar beforeemptyVortex/Settings: collection fromSettings, coinfromFTAP, Audio(mutes/blackholes/customaudio) fromFTAP. Home/appearance/cameraunchanged. New SoundOverrides factory patchesONLYSoundId onWorkspace/PlayerGui/SoundService matched11categories(existing7mutes +ownRunning/Jumping/Died +exactname), percategoryIDfields, blankclear; new/renamed/replacedSounds, periodictrackedonly. RestorelatestnativeSoundId afterexternalwrites, ignoreown deferredsignal, preservemutevolume/otherlayers. No audio assetavailability guarantee. Successnotices selected11toggles(user UI+bind), skyapply/reset, mannequinrealcompletion viaSuccesscallback, soundconfigured; optionaluiActionNotifications defaulttrue, no profile/slidernotices, .5sduplicategate. Errorsalwaysvisible. Noextra noticeUIlibrary.417keys (+17 incl2binds). mainbuildnear200locals: notification state usesstartupclosures, neverputnonfunctions inmaintenance. tests/sim/sound_overrides.py/action_notifications.py; mocks updated417. Versionnextabcf.

- 3.2.1abcf: MapAppearance factory owned by VisualExpansion lifecycle. Graphics card Map surfaces, master off, selector8 classes; per-class Original/native Material + optional Color/Rainbow. Only Workspace.Map BaseParts classified by known name/ancestor or ORIGINAL material; never toys/avatars/terrain voxel rewrite. Separate mapMaterial/mapTint patch layers; static classification, streaming events, root identity check1s without repeated scans, unload must call mapAppearance:Destroy in FINAL reassigned expansion teardown. ColorPicker wrapper exposes label SetVisible for selector rows. Named classes require actual FTAP confirmation; fallback material groups may be broader than semantic named regions.
- Audio presets: SoundPresets.lua researched Creator Store list,23 entries across12 categories +2 Blackholes. Per-category replacePreset* defaults Custom to preserve old IDs, Original restores; own Grab/GrabSound native replacement OR own-beam+activeweld local feedback transition when no recognized native audio. Native names/asset accessibility not verified in FTAP. One local preview8s, load warning4s, stop/disable/unload destroys. Preview never changes loop/volume/playback of game sounds. Existing bhSound has bhSoundPreset dropdown; latest-request guard retained. 482 persisted keys; new live checks listed first in docs/Testing-Checklist.md. Next3.2.2.

- Acceptance 2026-11-06: user broadly confirms latest update 3.2.1abcf works well (map surfaces, grab sound and audio presets). Mark release user-accepted; do not invent separate per-asset, per-surface, respawn or long-session measurements. No runtime change/version bump; next remains3.2.2. Reference collection remains filenames-only until requested.

- 3.2.2 user requested ALL five proposed improvements, shaders explicitly NEXT, unchanged now. lineAdvanced opt-in false, lineWidth/TextureLength/Curve/Alpha/Pulse/PulseSpeed/PulseAmount in existing line settings. startup.LineShape is separate lineShape patch layer, restored on disable/reassignment/unload; own-only filter remains. Ten per-beam listeners now expected, not four. No default line geometry overwrite. CrosshairStyles.lua builds six reticles; crossStyle default Custom image preserves old crossImage. Native Obsidian preview row, cached geometry keyed by parent, color/rainbow update without recreation. MapPresets.lua eight authored8-surface palettes via mapPreset+Apply, still editable and independent of shaders/sky.
- Audio gain/speed multipliers per12categories (replaceGain*/replaceSpeed*) +bhSoundGain/Speed. Defaults1; native SoundId/playback position untouched unless selected replacement; mutes remain authoritative through IsMuted and immediate Refresh on mute/unmute. soundVolume/soundSpeed layered baseline listeners avoid own writes. Preview follows selected category tuning, natural completion/manualstop rather than8scap. Grab polling skipped when no values.Grab; clearing stops owned feedback. Snow caches noncolor settings and verifies emitter identities/Enabled; same settings perform no Size/Speed sequence writes, color-only updates tint. Four common modules added to four-worker prefetch.520 persisted keys. tests/sim/visual_upgrades.py plus prior actual-module checks;39scripts118groups +final startup/loading pass. Live user acceptance pending. Next3.2.2a; don't begin shader work until user proceeds.

- 3.2.2a: user asked separate classic and custom map textures +20 themes, editable compact UI. mapMode defaults Classic materials (retains previous palettes/keys), Custom textures independent mapTexture<surface>Style/Image/Scale/Tint/Color/ColorRainbow; mapTexturePreset selects20 authored combinations. One existing Apply map palette button routes by mode, preview+selectedsurface only. MapTextureCatalog.lua41 styles:33 official Roblox PBR asset sets +8 authored512PNG assets/map-textures generated by tools/generate_map_textures.py. References/provenance in docs/Map-Textures.md/tools/map_material_ids.json; never claim Minecraft or exact game-copy. Minecraft still deferred: user searching reference, explicitly requested finishing the20others now.
- MapTextures.lua shares MaterialVariant percategory/nativeBaseMaterial, preserves native BasePart.Material/physicalproperties/globalMaterialService settings. Hides/restores MeshPart.TextureID, Decal/Texture transparency and SurfaceAppearance.Parent through mapTexture layer; never destroys native objects. Clears own variants on modechange/off/unload, keeps foreign variants, recovers deleted own variants. AuthoredPNG lazy cache PrimeVisuals/Assets, pinned tag URL, length/headervalidation, HTTP/request fallback2attempts; unsupportedlocalassets use documented Robloxfallback+onceNotice. No overlays perface/scanning perframe.586 settings. tests/sim/map_textures.py +full40scripts122groups pass. Live rendering pending. Only existing3.2.2 map palettes received positive user feedback; do not infer approval of other four3.2.2 improvements, which user is testing. Next3.2.2b; shaders not started.

- 3.2.2b SUPERSEDES3.2.2a custom textures: user rejected generated squares/recolored themes, explicitly requested full removal and real detailed external PBRs from several libraries. Deleted8 PNGs/old generator/stock-map catalogue/20oldthemes. Classic materials/palettes preserved. New35 materials(20PolyHaven/7ambientCG/8TextureCan),110 downloaded1K map files83.4MiB in assets/map-pbr; fullmanifestsource/hash/licenseCC0 in tools/pbr-texture-manifest.json, themesjson +build/fetch helpers.20newrecipes use20distinctmaintextures andwhiteTint (naturalalbedo). docs/Map-Textures.md/preview contact sheet describeactualsources. Never call these original Minecraft or claim live-renderverified.
- MapTextures multi-map schema style.Maps[ColorMap/NormalMap/RoughnessMap/MetalnessMap]={File,Bytes}; allrequiredmapsready beforeapply, no genericRobloxfallback. SharednativeMaterialVariant+restore path retained. Queue3workers, JPEG/PNGcache PrimeVisuals/Assets/pbr-*, max2HTTPattempts/requestfallback, latecancel, asyncreadycoalescing; retryFailedbutton. Assetready callback refreshesmap+preview; pending/error restores nativecolor/decoration.35setsfrom3libraries verifiedlocalhash/dimensions;40scripts124groupsincl3-workercooperativeHTTPandreadiness/retry.586keysunchanged;removed style aliases migrate to Original and old theme aliases to new recipes without rejecting unrelated config settings. Failedusercached8generatedfilesdeletedonlybyexactknownpathsifisfile/delfileavailable. Next3.2.2c; Minecraft/shaders untouched. User testing other3.2.2 features remains pending.

## 3.2.2c removal override
User removed all custom map textures/editor/themes. MapTextures/MapTextureCatalog, PBR assets and import tools removed. Standard Roblox materials and classic map palettes remain. Legacy texture profile keys are ignored as unknown; do not restore this feature.

3.2.2ab: playerSessionNotifications defaultfalse in Settings/Interface, persists with bind; join/leave bilingual displayname(@username), no roster replay/self notices, lifecycle-managed listeners.522 settings.

## 3.2.2ac input display
InputOverlay.lua: Personalization/Input display toggle defaultoff; spatial WASD/E/Space/Shift/Ctrl + mouse L/R/middle and wheel directions. Read-only UIS input, processed events observed, dual modifier held state, exponential Color3 lerp, focus-loss clear. Drag commits final XY once, scale/opacity/3colors and their rainbow options persist. ScreenGui ResetOnSpawn=false, IgnoreGuiInset; viewport-clamped position. Cleanup in BOTH early and final VisualExpansion teardown.537 keys. No live rendering test.

## 3.2.2bc navigation override
User removed empty Prime Vortex category from Visuals. Freecam stays View. Standalone Vortex and Settings launcher unchanged. Proposed future mixed-function category name: Hybrids; do not add empty placeholder until actual feature request.

## 3.2.2abc Favorites
User explicitly requested a new Favorites section and confirmed it should start empty for future special features. Star sidebar tab immediately after Home; Russian name «Избранное». Native two-column Navigation route is prepared, with no filler cards, duplicate controls, new settings or background jobs. Existing features remain in their approved locations. All Lua compilation, UI navigation/Home/localization simulations and an ad-hoc tab-switch check passed; live appearance awaits user confirmation. XLPQ research remains stopped by user request; do not resume it while working on Visuals.

## 3.2.2abcf Minecraft prototype
Favorites now contains Minecraft (explicit user request). Only first-mode presentation implemented: Steve textured arm, movement bob, nine slots/diamond sword at9. No added grabbing/damage/spawning; full visual/block mode explicitly deferred until user provides it. Renderer only active when enabled, assets are bundled pixel runs from referenced Minecraft textures; no network/image-asset dependency. Camera-facing local noncolliding/nonqueryable Part lives directly under Workspace so replacing/destroying CurrentCamera cannot destroy it. Death hides presentation; fresh humanoid/camera is resolved on each active frame. No avatar transparency/skin edits or physics changes. Native E remains untouched;1–9 merely observe unprocessed keyboard input. Four settings plus standard bind =>542. camThird guard is in updateThirdPerson so UI, bindings and config callbacks cannot turn third person on while Minecraft is active; checkbox normalizes false. No automatic re-enable on exit; manual/binds work normally again. Minecraft cleanup included in early/final VisualExpansion teardown. All Lua compile;43sim/122groups pass, plus targeted camera replacement after final renderer ownership change. Live appearance pending. XLPQ remains stopped.

- 3.2.3c replaces rejected sprite/world-space arm with independent ViewportFrame Camera70, six classic Steve UV face PNGs generated losslessly by tools/build_minecraft_hand.py. Java1.8.9 transform order and bob/attack equations source-reviewed; Roblox movement/timing adapted, no promise of universal 1:1 rendering. World FOV does not affect it. No physics changes; user follow-up adds mode-scoped high-priority LMB sink for cosmetic swing only, allowing UI/release events, restoring on exit. Original Minecraft crosshair replaces native/custom crosshair during mode. HUD preserved. XLPQ remains stopped.

- 3.2.3ab: slower capped walking bob; slot9 local extruded original-color diamond sword; RMB normal input remap to native LMB only with real Mouse.Target, no range/ownership bypass or direct remote calls. LMB injection guard, focus/disable release, executor fallback+notice. Live interaction not yet confirmed. Next3.2.3ac.

- 3.2.3bc: native MenuGui/Menu effective visibility owns cursor; zero-size modal button unlocks first-person pointer, independent minecraftPointer/minecraftLook layers restored on exit. Shift CAS action replaces crouch with hold sprint1.3x captured Humanoid WalkSpeed, suspended in menus and restored on release/focus/disable. No new keys. Live E/crouch behavior pending. Next3.2.3abc.

- 3.2.3abc supersedes3.2.3bc Shift sprint: removed entirely, native FTAP crouch untouched. Hand hit strength0–5(default1), sword2x; one local ApplyImpulse per swing on first <=8stud non-character/unanchored raycast hit. No ownership override/remotes; native authority can ignore client impulse.544keys. Live physical effect pending; do not claim server-authoritative hits. Next3.2.3abcf.

- 3.2.3abcf native-contact hit EXPERIMENT: default minecraftHitMethod Native contact (test), normal native grab/drop input before impulse, matched local live constraint required. No ownership override/remotes. User confirmed manual line contact restores shared hits after foreign grabs; automation not yet live-confirmed. Stronger horizontal18+up4 base, sword2x; short .1s hit gate,545keys. Transient line visible; timeout/cancel means no impulse. Next3.2.4. XLPQ stays stopped.

- 3.2.4 user confirmed3.2.3abcf auto-contact actually throws objects strongly, but needed3–4clicks. New FIFO per-valid-click queue, next-Heartbeat up/down priming (avoids duplicate physical-down suppression), short60ms forwarded tokens, faster30–120ms settle, safe early release and independent attempts. Hand20/sword40,545keys. Deduplicating input mock proves3burstclicks→3hits. Live cadence recheck pending. Next3.2.4a.

- Acceptance: user fully confirmed Minecraft mode3.2.4 before InputOverlay update. Treat as complete unless new requested changes/bugs. No new MC gameplay edits in3.2.4a.
- 3.2.4a InputOverlay: R atx36 left ofWx80; generated full mouse PNG and5code-native masks, no mouse text/arrow widgets. Lazy enable-only asset cache with PNG length/signature checks, unbranded no-text fallback, retry after toggle if failure. Old keys545/settings/drag geometry preserved; observational input only. Native art rendering pending user acceptance. Next3.2.4b.

- Acceptance: user confirmed InputOverlay3.2.4a R key/new mouse fully.
- 3.2.4b: dedicated Shaders/sun sidebar after Graphics, owns logical Lighting tab; Navigation routes Lighting card left and Lighting presets right. All existing manual editor5pages,3presets/edit/reset/Fullbright transferred. Graphics retains weather/water/FPS/surfaces. No runtime algorithms/settings/schema changed,545keys. Focused nav/localization/lighting/cold-restore tests plus all-Lua compile passed. New layout pending acceptance; next3.2.4c.

## 2026-11-08 — shader catalog 3.2.4c

- 45 source scenes total (3 legacy + 42 imported). lib/ShaderCatalog.lua is data-only and pinned/preloaded with the runtime. Source hashes/ranges and the two Fosfor compatibility repairs: docs/Shader-Catalog-Sources.json. Rebuild via tools/import_shader_catalog.py <catalog-findings.json> using the original local research manifest; never execute source collection loaders.
- Scene presets card has collection filter + searchable dropdown + edit action. visualPreset/visualPresetEnabled retained; shaderCollection adds one persisted value (546 total). Filtering retains active selection; registry always validates against the full catalog, including profile restore while browsing another collection.
- Imported presets disable manual lighting to avoid stacking; temporary property layers restore foreign effects/clouds. Foreign atmospheres are detached and restored, not destroyed. PresetHasSky covers all catalog skies and Silent Target's no-sky Arctic; main sky maintenance must respect it. Adaptive uses Prime UI accent and checks changes on existing half-second maintenance.
- All files compile; tests/sim/shader_catalog.py exercises every imported definition, source anchors, foreign restoration, sky values/exclusivity, cloud restoration, accent changes, stricter dropdown filtering, restart/unload. Full simulation report: docs/Simulation-3.2.4c.md. Live visual/asset access/FPS validation is pending; do not assert pixel identity across game state or claim imported parameters escape Roblox clamps.
- Current real repo: D:/Projects/Prime-Script-FTAP/Repository; development outputs: ../Codex workspace/outputs. Simulation deps: ../Codex workspace/work/python-tools via PYTHONPATH.

## 2026-11-08 — shader card panel 3.2.4d

- lib/ShaderBrowser.lua builds the embedded 384px native UIPassthrough panel inside Scene presets: seven horizontally scrollable collection buttons, search, two-column card grid with internal vertical scrolling, count/empty state, selected footer. 45 cards reuse source names/palette values; no fake rendered thumbnails. Click calls existing setters and enables the preset.
- Keep visualPreset and shaderCollection registered but hidden (SetVisible(false)); all profile/setter behavior and 546 setting values unchanged. ShaderBrowser is preloaded/tag-pinned; owned instances and connections use VisualExpansion create/connect, including startup-failure/unload cleanup. Cached Refresh runs on UI interaction and existing half-second maintenance only while the menu is open; no new per-frame job/save/world scan.
- Theme via GetScheme, EN/RU localization, UTF-8-safe ASCII/Cyrillic search (avoid locale-dependent string.lower over UTF-8). tests/sim/shader_browser.py checks interaction, persistence and dead handlers after unload. Regression report: docs/Simulation-3.2.4d.md. Live Roblox visual layout acceptance pending.

## 2026-11-09 — shader browser usability 3.2.4e

- User asks for faster, scoped work/checks and concise reports. ShaderBrowser now 442px, all seven categories in 4-column/two-row grid, responsive one-column readable rows below 360px and two columns above. Clear search, previous/next within filtered results, auto-scroll selected row and enable/disable footer. Same 45 presets/546 settings.
- Short cancelable TweenService color/stroke/press-scale/filter-entry animations. Browser Destroy cancels active tweens in both VisualExpansion cleanup paths; native user scroll unchanged. Targeted shader_browser.py/shader_catalog.py plus compile pass; live UI acceptance pending. No full unrelated suite rerun for this layout change.

## 2026-11-09 — separate Wraith-style shader catalog 3.2.4f

- Main UI remains Obsidian. Shaders has Open shader catalog; lib/WraithCatalogUI.lua owns a separate 880x590 modal shell adapted to Wraith.dev's NeverLose-style palette/sidebar. Explicitly NOT the complete third-party UI engine. Source reference: Wraith.dev.txt CreateWindow 10081+, equivalent Wraith.txt 3981+. No source loaders/gameplay/config engine imported.
- ShaderBrowser hosts full-size in this shell, sidebar uses parameter themes (not source names), 1/2/3-column responsive grid. Sort Name/Time/Brightness/Saturation with direction; missing fields last. Theme derived from raw lighting/CC/Atmosphere parameters. Source identities retained internally via ShaderId attribute and original registry keys. 45 presets/546 persisted settings unchanged; filter/sort session-local.
- Shell uses same GUI parent as Obsidian and higher DisplayOrder; modal backdrop blocks underlying clicks. Opens only while main menu is open; closes on main-menu hide. CatalogCursor temporarily disables Obsidian's custom cursor so native cursor is visible on top; restores original flag on close/destroy. No second keybind/config engine.
- Short tweens, viewport fit and generation-guarded delayed close; cleanup in both VisualExpansion teardown paths. Edit closes catalog and opens existing native lighting editor. Tests: shader_browser.py (thematic filters, ascending/descending parameter order), shader_window.py (open/reopen/hide/editor/cursor/viewport/unload), shader_catalog.py, ui_navigation.py, startup_resilience.py, controls_matrix.py; compilation passed. Live appearance/input acceptance pending.

## 2026-11-09 — direct full-page catalog 3.2.4g (supersedes popup)

- User explicitly rejected the separate window and visible Lighting/Lighting presets cards. WraithCatalogUI.lua now builds PV_ShaderPage directly under categoryTabs.Shaders.Container, filling its area. Both legacy tab.Sides are hidden; registry/config callbacks retained internally (546 keys). No modal ScreenGui/open action/cursor override. Other tabs remain unchanged.
- Catalog uses Gotham/GothamMedium (not main Builder Sans), neutral dark palette, sidebar with scrollable parameter themes and larger full-width sort choices. Same 45 definitions and direction/search/next/previous. Existing lib filename retained for dependency compatibility; this is now page presentation, not a foreign runtime.
- shader_window.py now verifies full-page parent/size, hidden native columns, absence of popup/open action, font replacement, navigation and unload. Targeted shader_browser/catalog/ui_navigation and compilation pass. Live layout acceptance pending.
