# 3.2.2abc — 2026-11-07

- Added a dedicated Favorites sidebar section with a star icon immediately after Home, localized as «Избранное» in Russian. Prepared the normal two-column navigation route for future selected features.
- Section starts empty; existing functions, settings and profiles are unchanged. XLPQ research remains stopped at the user's request.

# 3.2.2bc — 2026-11-06

- Removed empty Prime Vortex sidebar category and unused navigation route. Freecam stays in View; standalone Vortex launcher unchanged.

# 3.2.2ac — 2026-11-06

- Added optional compact keyboard/mouse input display under Personalization. WASD/E/Space/Shift/Ctrl only; mouse left/right/middle buttons and separate wheel directions, smoothly animated press/release.
- Drag to reposition; configurable size, background opacity and pressed/text/background colors with existing rainbow controls. Autosave/config slots preserve appearance and position. Default disabled; no input sinking/game bindings. Focus loss clears held keys; unload removes screen and listeners.
- Compilation and mocked input/config/lifecycle regressions checked; actual appearance and interaction need live FTAP confirmation.

# 3.2.2ab — 2026-11-06

- Optional player join/leave notifications in Settings > Interface; disabled by default, persisted in profiles. Display name and username, Russian/English messages, no initial roster spam; listeners disconnect on unload.

# 3.2.2c — 2026-11-06

- Removed custom map textures, texture presets/editor, binary downloads and PBR library. Standard Roblox materials/colors and classic palettes retained. Old texture config keys are ignored without discarding other settings.

# 3.2.2b — 2026-11-06

- Removed the rejected8 generated textures, their generator, old Roblox-map catalogue and all20 custom themes from the current release. Classic native materials and8 approved palettes remain.
- Downloaded35 external PBR materials from3 libraries:20 Poly Haven,7 ambientCG,8 TextureCan.110 original1K map files (83.4MiB), covering albedo, OpenGL normal, roughness and optional metalness. Source/licence/byte count/SHA256 manifest and reproducible fetch/build tools included.
- Rebuilt20 themes with20 different principal ground materials and supporting surface assignments; presets preserve natural albedo instead of recoloring one pattern. Compact per-surface editing and autosave retained. Removed style names migrate to Original and old theme selections migrate to the corresponding new recipe, preserving unrelated saved settings. Minecraft deferred, shaders unchanged.
- Rebuilt image transport for multi-map PBR: three-worker lazy queue, JPEG/PNG support, verified local cache, HTTP/request retry and cancellation. Wait for all required maps before replacing a surface. Failed assets keep the native surface rather than silently using generic stock maps; Retry texture loading added. Restore original colors/decorations on pending/failure. Remove eight known rejected generated cache files when supported.
-586 settings retained. All Lua compile;40 scenarios /123 groups pass, including required-map readiness, no fake fallback, bounded download workers, retry, persistence and restore. Every downloaded file hash/dimension verified. Actual FTAP lighting/PBR rendering and executor local-URI compatibility remain for user testing.

# 3.2.2a — 2026-11-06

- Separated the map editor into Classic materials and Custom textures. Original material/color keys and8 palettes retained, default Classic mode preserves previous configuration. Shared compact settings show only selected mode/surface fields, plus a texture preview.
- Added20 editable texture themes across41 texture choices: Dreamcore, Rainbow World, Rose Quartz, Neon Tokyo, Cyberpunk, Vaporwave, Cotton Clouds, Candyland, Liminal Hotel, Lunar Outpost, Frozen Palace, Volcanic Forge, Emerald Ruins, Atlantis, Solar Desert, Space Arcade, Monochrome Lab, Royal Amethyst, Enchanted Grove, Retro Playground.
-33 documented Roblox PBR sets plus8 new authored512px procedural patterns. Texture mode uses local MaterialVariant instances with native BaseMaterial, does not change part materials/physics or global overrides. Per-surface image/style, tile scale1–64, tint/rainbow; configuration persistence. Existing mesh textures/decals/SurfaceAppearance temporarily layered away and restored, not destroyed.
- Lazy pinned PNG downloads with local cache, bounded binary transport/request fallback and unload cancellation. If custom file APIs/images fail, use Roblox texture fallbacks and report once. Shared variants updated in place; streaming/map replacement/recreation handled.
- Added66 persisted keys (586 total). All Lua compile;40 simulation scenarios /122 groups passed. Actual PBR/image rendering and asset access await user confirmation. Other3.2.2 features and shaders unchanged. Minecraft intentionally not included pending reference.

# 3.2.2 — 2026-11-06

- Expanded Custom Line with opt-in advanced styling: width .05–10, texture length .1–30, signed curve -20–20, transparency0–1, pulsing with speed .1–5 and strength0–1. Separate property layer restores native geometry/transparency when advanced mode, line, ownership or script is disabled. Native line geometry remains unchanged by default; own-beam origin filtering retained.
- Added eight authored, editable map palettes: Obsidian, Cyber Violet, Arctic, Sakura, Solar Ember, Moonstone, Emerald, Candy Circuit. Apply writes eight material/color combinations through existing persisted setters and enables map appearance. No sky, lighting, avatar or toy changes. Manual surface editing/reset still works.
- Added six dependency-free built-in crosshair styles with compact settings preview: Precision dot, Halo, Tactical cross, Diamond sight, Target ring, Corner brackets. Preserve Custom image as the migration/default mode; size, tint, rainbow, respawn recovery and native crosshair restoration remain. Primitive geometry reused on tint/rainbow changes.
- Added independent volume multiplier0–2 and playback-speed multiplier.25–3 to all twelve replacement categories and the blackhole card. Defaults1 preserve native volume/pitch. Track native tuning changes, restore layers, keep mute authoritative and refresh immediately on unmute. Existing SoundIds/selection retained. Multipliers also work with Original audio; enable Custom game sounds to apply.
- Sound preview no longer stops after eight seconds; it runs to natural completion or Stop/unload/replacement. Category tuning updates the current matching preview live. Clearing own-grab replacement stops its local feedback.
- Skip own-grab polling without an assigned grab replacement. Snow emission curves/ranges only rebuild when settings change or emitters need recovery; color-only updates change tint, while positioning remains animated. Added four common modules to the bounded four-worker bootstrap prefetch queue.
- 520 persisted keys (+38). All Lua files compile;39 isolated scenario scripts /118 groups passed in mocks, including mutes, long-session listener bounds, geometry restore, map palettes, reticle reuse, preview and snowfall write counts. Additional loading/startup checks passed after extending prefetch. Rendering, sound availability and actual FPS are pending user testing; no shader rework in this update.

# 3.2.1abcf — 2026-11-05

- Graphics → Map surfaces: default-off local material/color editor for Snow, Sand, Grass, LushGrass, Rock, WasteGrass, Ocean and Dirt. Select a surface, choose Original or one of 23 native materials, optionally set color/rainbow. Reset/disable/unload restores property layers independently. Static Workspace.Map parts only; does not rewrite terrain voxels, toys or avatars.
- Cached map-part classification uses native names/ancestors, falling back to original materials. Observe streaming/new descendants and map replacement; no repeated map scan on menu opening or every frame. Color rows now support hiding with their surface selector.
- Custom game sounds: independent Original / Custom ID / researched Creator Store presets for all twelve categories, including new own-grab audio. 23 category presets plus two options in the existing blackhole sound card. Preview/stop buttons, one preview at a time, eight-second cap and delayed load-failure notice. Custom IDs remain stored when choosing presets.
- Grab sound: replace recognized own native Grab/GrabSound, otherwise local feedback on a valid own-beam/weld grab transition. Foreign origins excluded; sustained hold does not retrigger, released/disabled welds ignored. No server state changes. Actual FTAP audio naming/asset delivery requires live confirmation.
- 482 persisted settings (+65), backward-compatible keys/default Custom for existing audio IDs. Added actual-module map/audio lifecycle and config tests; full simulation results in docs/Simulation-3.2.1abcf.md. Simulation does not prove Roblox sound permissions, audible quality or live map-category coverage.

# 3.2.1abc — 2026-11-05

- Added Personalization sidebar before the empty Vortex/Settings entries. Moved fixed toy collection from Settings and coin icon from FTAP; moved audio mute/blackhole audio cards from FTAP. Existing keys/configs retained.
- Added default-off local SoundId replacement by11 categories: ambience, boombox/jukebox, screams, explosions, soundwaves, rhythm makers, instruments, own footsteps/jump/death, or exact sound name. Each category keeps its own audio ID/Roblox URL; blank/clear restores current native sound. New/recreated sounds tracked; original volume/playback/remote state untouched.
- Added native top notifications for selected toggles, applied/reset sky, successful mannequin creation/avatar update, and audio setup. Existing config reports retained. Success notices optional via Settings → Action notifications; no slider/profile-restore flood and repeated identical actions debounced. Errors remain visible.
- Added17 persisted settings (417 total), audio/notification/navigation/config tests. Roblox audio asset permission/availability and actual audible results require live testing.

# 3.2.1bc — 2026-11-05

- Improved third-person/Freecam cold-start appearance recovery. Incomplete applied descriptions or default face data can fall back to the player's UserId HumanoidDescription, rather than permanently accepting missing hair/classic face as final.
- Match genuine head accessories by normalized mesh asset ID as well as original name; mesh fallback requires a head attachment, excluding invisible waist/torso helpers. Head decal name matching is case-insensitive.
- Keep useful partial references and retry incomplete/failed reference data after15s. Temporary descriptions/models remain unparented/cleaned, generation guarded; no whole-avatar ApplyDescription or accessory insertion.
- Tests cover third-person active at construction, incomplete applied description, hidden renamed hair and custom face, waist exclusion, model cleanup and no per-frame API calls. Existing camera/near/Freecam checks retained; actual startup screenshot cause remains unobserved directly.

# 3.2.1ac — 2026-11-05

- Restricted Custom Line styling to the local player's beam origin rather than every Beam under GrabParts. Foreign-character origins are excluded even when their grabbed target is the local avatar; unknown/unassigned origins stay native.
- Native standalone BeamPart origin uses conservative attribution: local avatar must be within8 studs and at least.5stud closer than every other live avatar. Camera/own-character origins are direct matches. Ambiguous close-range origins stay unmodified.
- Ownership change restores previous texture/color/speed immediately; regular recovery rechecks late/recreated beams. Preserve rainbow, death/reload recovery and native remote-player updates.
- Added multi-player origin-isolation regression and updated old fixtures to identify local source attachments. Live own/foreign line appearance remains pending user check.

# 3.2.1ab — 2026-11-05

- Corrected holding-object deferral: retained Part1 alone is no longer accepted. Require a live GrabPart/WeldConstraint, enabled/active state, both endpoints and an actual GrabPart-to-world-part connection.
- Disabled/inactive constraints, detached Part0 and removed targets no longer indefinitely extend spawn grace. Preserve normal1.5s release grace and ongoing genuine-hold deferral; character identity changes clear stale grace.
- Compile plus AntiKick lifecycle/release variants, long-session and startup failure simulations passed. No change to attachment/remotes or protection-strength claim; live hold/release confirmation pending.

# 3.2.1c — 2026-11-05

- Removed the initial white Omega glyph and later symbol replacement. Bootstrap now draws the menu's geometric32-segment Omega immediately, with saturated color from construction and smooth rotation/hue in the existing single render callback.
- No HTTP/module dependency for the loading symbol, no second emblem connection or geometry rebuild after Obsidian loads. Existing short fades/parallel downloads preserved.
- Compile, loader/cooperative HTTP tests and startup failure suite passed. Added assertions that Omega is colored/rotating before HTTP completion and retains the same instance afterward. Live smoothness pending.

# 3.2.1b — 2026-11-05

- Rebuilt bootstrap loading screen: pure black backdrop, white Builder Sans status/dots, exact Arcade rainbow menu wordmark and rotating geometric Omega, thin progress bar; short .14s entrance/.18s exit, no minimum display delay.
- Fullscreen backdrop is a plain Frame; only the small central card uses CanvasGroup. Reuse brand modules without external icon/image assets; cleanup animations/tweens on failure and early unload.
- Prefetch15 common module sources with four workers, execute constructors in original dependency order. First failed prefetched request counts toward existing three-attempt retry budget; no duplicate successful fetch. Reuse compiled function factories within the same script session.
- Network/download progress advances independently of construction and completes only after initialization. No fake percentage, server-speed or live timing claims.
- Startup failure suite and cooperative delayed-transport/loader presentation tests passed; full simulation report records regressions. Actual Xeno startup duration/appearance pending user test.

# 3.2.1a — 2026-11-05

- Replaced plane2→Campfire, helicopter3→Poison Mushroom, Boombox5→Hot Sauce, basketball6→white Toilet in the fixed27-toy set.
- Other slots, Decoy22/pallet23/Blobman24, prepared native ordering and performance behavior unchanged. Existing enabled profiles use the updated fixed set automatically.
- IDs verified against the captured owned catalogue; regression checks27 unique available items and exact replacement slots. Actual live placement awaits user check.

# 3.2.1 — 2026-11-04

- Added default-off FTAP → Game interface → Custom coin icon. Replaces only native MenuGui/TopRight/CoinsFrame/CoinsDisplay/CoinImage with an original code-drawn black concave sparkle (⟡), thin animated single-hue rainbow contour and soft glow.
- Native coin count, layout, purchase button and store price icons untouched. No currency/remote changes, fonts/images/network assets required for symbol. Geometry scales with native icon; original image transparency restored on disable/unload.
- Constant-depth native path lookup twice per second only while enabled; animation30Hz skips hidden ancestors. Rebind replaced HUD/removed overlay; persist switch and optional bind (400 settings).
- Simulations cover default-off, numeric text updates, shop exclusion, animation, deletion/recreation, restore and autosave. Live FTAP placement/appearance await user confirmation.

# 3.2.0 — 2026-11-04

- Removed the in-script toy collection editor, catalogue, previews, slot picker, assignment and starter-reset actions. Keep only the collection enable/disable toggle and the fixed current27-toy set (pallet23).
- Deleted editor runtime/preview/migration code and three persisted editor settings. Old profiles ignore removed keys while retaining collection enable state and other settings;398 settings remain.
- Kept native prepared order/instant repair, smaller rainbow markers and disable/unload restoration. Native100-cycle no-wholeGUI-scan check retained; actual FTAP check pending.

# 3.1.9 — 2026-11-04

- Replaced Katana10/ Kunai11/ Tetracube I19/ T20 with Snowball10/ Glass Box11/ Burger19/ Ladder20. Central FloatingIsland21/Decoy22/pallet23/Blobman24 and rocket14 unchanged.
- Migrate those four exact IDs in saved collections in place, preserving all other slots. Starter retains27 verified owned toys; burger is an explicit exception to the previous cake-only food preference.
- No menu sorting, previews or performance behavior changed. Compilation/simulated checks recorded separately; placement ergonomics need live confirmation.

# 3.1.8 — 2026-11-04

- Rebuilt the27-item starter set using verified owned toy IDs: Decoy You22/pallet23/Blobman24; black crystal13/rocket14/Tetracube L15. Added Floating Island21, DiscoColorBall25, Light Ball26 and blue Jukebox27.
- Food reduced to pink cake; musical instruments to Acoustic Guitar, Trumpet and Ocarina. Removed couches, Tetracube O and filler food/instruments. Remaining slots use aircraft, fireworks, ninja props and Tetracubes I/T.
- Recognize the previous starter signature (Donut/Melodica/ShoppingCart) and replace it with the new starter in saved control state; independently customized collections without that signature stay unchanged. Restore starter button always applies this new set.
- Retained3.1.7 prepared-order performance/lifecycle. Tests verify27 unique owned IDs, exclusions and central priorities; live ergonomics pending.

# 3.1.7 — 2026-11-04

- Prepared and locked native toy order: reopening or native favorite-order writes no longer wait for a rebuild; synchronous property repair retains latest native values for disabling.
- Native fast path reads only the owned card container, caches identities, and skips whole-PlayerGui scans/diagnostic serialization. Visibility changes no longer rebuild the native set; structural changes and script-editor changes still update it.
- Editor previews created only while its window is visible; reuse catalogue page across slot selection. Removed duplicate hidden-dropdown preview creation. Rainbow markers update at10Hz and pause with the native menu hidden.
- Collection now27 slots, pallet23. Previous28-slot orders migrate pallet26→23 while retaining other entries by swap; hidden legacy slot range remains compatible with saved profiles.
- Favorite markers reduced to65% of previous size. Added100-cycle regression for immediate order locking, no whole-GUI scans or preview clones on unchanged openings; real frame-time result needs user testing.

# 3.1.6 — 2026-11-04

- Fixed owned toy-grid recognition against the actual captured MenuGui/Menu/TabContents/Toys/Contents hierarchy (195 cards). Shop, destruction and template tabs excluded.
- Replaced visible slot slider/dropdown/Assign workflow with a28-slot preview board: click a slot then click a catalogue card to assign immediately. Search,18-card catalogue pages and duplicate-slot swapping; saved config identifiers retained.
- Matched captured native IDs for dark crystal, cube and common starter toys; pallet remains slot26. Native favorite-star image/bounds preserved.
- Protected optional preview cloning, excluded generated UI changes from native rebuild events, and isolated the editor layout. Added a sanitized195-ID fixture and real editor click-callback checks. Live FTAP confirmation pending.

# 3.1.5 — 2026-11-04

- Replaced manual toy-name input with a searchable click-select catalogue built from native toy cards; optional3D previews in virtualized dropdown rows. Preserve saved toy-selection/order keys.
- Extended native-menu adapter to viewport-only cards and manually positioned grids, in addition to UIGridLayout/UIListLayout. Original positions restored on disable/unload.
- Custom collection cards receive black star fill and smoothly cycling colored outline; use original favorite-star bounds/image when detected.
- Integrated automatic local toy-menu diagnostics; no separate executor command required. Actual FTAP hierarchy/cursor placement still pending live verification.

# 3.1.4 — 2026-11-04

- Added optional custom28-slot ordering inside the native Your Toys grid. Starter priorities include Rocket, black crystal, Blobman, Tetracub L, cake, cube, trumpet and ocarina; standard pallet reserved at26. Missing choices are filled from available native cards.
- Settings → Interface switch with position/name editor, assignment and starter reset. Order and editor settings persist in autosave/profiles. Off by default.
- Preserve native cards, callbacks and favorite values; restore native ordering on disable/unload, handle menu recreation and favorite-order writes.
- Adaptive GUI detection still needs live FTAP verification; tests use representative native UI fixtures.

# 3.1.3 — 2026-11-03

- Moved Freecam into View → Camera tools alongside Spectate; Prime Vortex category stays present and empty.
- Kept setting/bind identifiers and camera behavior unchanged; removed repeated speed hint.

# 3.1.2 — 2026-11-03

- Removed Freecam character teleport completely: RMB approach/return, fallback listeners, raycasts, PivotTo/velocity edits and related hints. RMB remains native; Freecam exit/focus loss never repositions the character.
- Avatar visibility can restore initially hidden hair/head accessories from a native reference model built from the current HumanoidDescription. Match head attachments and accessory name/mesh; exclude waist/torso references.
- Restore original Head decal texture from reference in far/free camera modes. Reference is unparented, disposed after extracting metadata; stale completions after unload/respawn discarded. Snapshot-only fallback if API fails.
- Added reference recovery/cleanup tests and replaced teleport tests with no-movement/native-RMB checks. Live validation pending.

# 3.1.1 — 2026-11-03

- Freecam RMB now has UIS input fallback alongside CAS, deduplicating the same InputObject. Preserve native throw while holding and shared menu/focus gates.
- Refresh toy-menu state on press and clear input state on exit/focus loss. Visibility implementation unchanged.
- Simulations cover UIS-only processed delivery, CAS→UIS and UIS→CAS ordering, existing approach/return/throw. Live acceptance pending; reported cause not independently observed.

# 3.1.0 — 2026-11-03

- Rebuilt avatar visibility for third person and Freecam around one early snapshot and shared ownership. Removed duplicate per-mode part caches/listeners.
- Recover observed hair, face decals and body alpha after late game writes to Transparency or LocalTransparencyModifier; preserve invisible accessories without inventing alpha0.
- Explicit mode/near transitions release previous patches; clean character replacement, descendant removal and unload; preserve intentional effect layers. First-person body fade remains near only. Camera movement/controls unchanged.
- Regression expanded to real hidden accessory handles, ordinary-alpha hides before enable and during Freecam,150 switches, hidden decals, disable, and existing360-cycle third-person/respawn tests. Live validation pending. Unknown already-hidden accessories at startup and deleted assets remain outside snapshot recovery.

# 3.0.9 — 2026-11-03

- Freecam repairs late LocalTransparencyModifier changes through scoped property listeners, including changes after its frame callback. No ordinary Transparency reconstruction.
- Listeners disconnect on mode exit, character replacement, removal and unload. Third-person code unchanged.

# 3.0.8 — 2026-11-03

- Restored thirdPart and Freecam visibleFreeBody implementations from v2.4.7; removed newer shared appearance-alpha reconstruction and its module.
- Invisible accessory handles no longer receive the zero-alpha fallback introduced in3.0.3. Existing camera controls/UI retained.
- Regression includes genuinely invisible Accessory Handles, not only tools/helpers. Live acceptance pending.

# 3.0.7 — 2026-11-03

- Third-person/Freecam visibility repairs now target canonical avatar body and accessory handles only. Tools and helper geometry retain game visibility.
- Appearance alpha recovery no longer tracks arbitrary character descendants.

# 3.0.6 — 2026-11-03

- Reapplying enabled protection no longer overwrites active status with Waiting for character. Active weld confirmation refreshes Attached status.
- No additional toy spawn for repeated enabled-setting callbacks.

# 3.0.5 — 2026-11-03

- Header wordmark shifted beyond the sidebar divider.
- Protection waiting watchdog rebinds stale character state every 8 seconds.
- New protection spawns wait while holding an object and for 4 seconds after leaving a foreign plot; game cooldown remains respected.

# Prime Visuals — Changelog

Версии 0.x ниже — ретроспективная нумерация этапов из переписки и истории Git. Исходные номера и даты выпусков до 1.0.0 не фиксировались. Эксперименты и неудачные исправления отмечены явно. Начиная с 1.0.0 версии ведутся при каждом обновлении.

## 3.0.4 — Цветной пиксельный wordmark · 2026-11-03

- Общий Wordmark для шапки и HUD: шрифт Arcade, фиксированные разные цвета букв и тонкая радужная линия. Буквы не анимируются; Omega сохраняет вращение/переливание.
- Надпись шапки выравнивается в своём слоте, её фирменный шрифт не сбивается выбором общего шрифта меню.
- Omega экранной панели увеличена20→26px. Ширина бренда/FPS измеряется TextService, FPS расположен через7px после текста; убраны фиксированные пустые интервалы и запас справа. Есть резервный расчёт при недоступности измерения.
- Сохранение позиции/drag не изменены. Тесты проверяют постоянство цветов,13 цветных символов, подчёркивание и плотную геометрию; внешний вид ожидает оценки в Roblox.

## 3.0.3 — Волосы/лицо и видимость во Freecam · 2026-11-03

- Новый AvatarAppearance: ранний общий кэш видимости до включения камер, аксессуары/лицевые декали и смена персонажа.
- Третье лицо восстанавливает известную прозрачность волос; для уже скрытого Handle предусмотрен fallback. Неизвестные helper-части не проявляются. Прозрачность лица восстанавливается без подмены Texture/создания аватара.
- Freecam восстанавливает обычную Transparency вместе с LTM, в том числе после позднего скрытия. Учитываются другие слои эффектов, очистка и респавн.
- Тест: скрытые до включения волосы/face,150 переключений Freecam с ожиданием и повторным скрытием, helper/unload. Живое подтверждение ожидается; восстановление удалённых ассетов не заявляется.

## 3.0.2 — Компактная перемещаемая панель · 2026-11-03

- Экранная Prime Visuals: высота30px вместо36, компактные Omega/заголовок/метрики и скругление9px.
- Перетаскивание мышью/касанием с порогом3px; drag не считается кликом открытия меню. Положение сохраняется паройX/Y при завершении, не на каждом движении.
- Добавлен hudOffsetX, диапазон координат расширен; исходный hudOffsetY совместим со старыми конфигами. Позиция восстанавливается при запуске и не сбрасывается обновлением FPS. При меньшем viewport отображение ограничивается его краями.
- Компиляция и симуляция drag/commit/cold restore/метрик пройдены; реальный вид и input требуют пользовательской оценки.396 сохраняемых настроек.

## 3.0.1 — Правый Ctrl для меню · 2026-11-03

- Меню по умолчанию открывается/закрывается на RightControl; переназначение и конфиги сохранены.
- Нетронутый пустой бинд3.0.0 мигрирует на стандартный. Явное очищение/переназначение сохраняется; занятая другой функцией клавиша не отбирается.
- Проверены4 варианта миграции, управление клавишей, компиляция и конфиги.

## 3.0.0 — Major Update 3 · 2026-11-02

- Новый централизованный модуль биндов:121 назначение, keyboard/mouse, захват, конфликты, сохранение/восстановление; по умолчанию пусто. Параметры доступны у выключенных функций.
- Все карточки каждого раздела объединены в одном окне без верхних подстраниц. Главная сохранена.
- Omega: вращение и радужный цвет в шапке и новой экранной панели. Жирный увеличенный заголовок. Феникс остаётся на Home.
- Экранная панель с FPS/временем/числом игроков, выключением/прозрачностью/положением. Запасная кнопка открытия при отключённом HUD и пустых биндах.
- Четыре темы, пользовательские цвета, шрифты и прозрачность меню, всё в конфиге.395 настроек с сохранением257 прежних ключей.
- Плавная полноэкранная загрузка с реальными этапами, cleanup при ошибке. Кэш factory и сокращённая навигация; ограничение частоты обновления тем/метрик.
- Сохранены существующие игровые функции и их cleanup; не заявляется гарантированное отсутствие багов или измеренный прирост FPS. Полный отчёт и ограничения: [Major-3.0.md](docs/Major-3.0.md).

## 2.4.7 — Freecam в разделе Prime Vortex · 2026-11-02

- В Prime Visuals добавлен временный отдельный раздел Prime Vortex перед Настройками. Freecam со скоростью и подсказками перенесена туда из Обзора.
- Spectate остаётся в Обзоре; взаимное выключение камер и существующие бинды сохранены. Ключи/значения конфигов и runtime-логика не изменены,257 настроек.
- Отдельный PrimeVortex.lua не изменён: это только организация функций внутри текущего Visuals. Проверены компиляция, навигация/поиск, профили и сценарии Freecam. Новое расположение ожидает пользовательской проверки.

## 2.4.6 — Восстановление защиты после смертей · 2026-11-02

- Anti-Kick отслеживает замену Character/HRP/Humanoid/хитбокса и очищает устаревшую операцию. Хитбокс ищется также среди потомков персонажа; отдельный статус отличает отсутствие хитбокса от отсутствия живого персонажа.
- Тайм-аут создания работает и при зависшем InvokeServer. Локальная coroutine отменяется при очистке, busy сбрасывается, запоздалое завершение не трогает pending нового поколения. Уже отправленный серверный запрос отменить этим нельзя.
- При потере weld сначала повторно прикрепляется сохранившийся свой сюрикен с подтверждённым PartOwner. Новый предмет создаётся при необходимости; активность по-прежнему подтверждается weld.Part1.
- В Настройках/Защите добавлена кнопка «Восстановить защиту». Повторная попытка не включает выключенную пользователем функцию. Скрытие toy, запрет действий на чужом участке, backoff и очистка сохранены.
- Тесты:30 замен персонажа с поздними/вложенными хитбоксами, зависшая coroutine, восстановление weld, старый ответ после нового поколения, ручной restart. Компиляция и общий suite пройдены; эффективность против конкретных чужих методов отключения не гарантируется, серия смертей в FTAP требует подтверждения.

## 2.4.5 — Ровная компоновка главной · 2026-11-02

- Профиль занимает всю левую колонку; увеличенный портрет запрашивается в420×420, версия остаётся под данными игрока.
- Феникс перемещён наверх правой колонки, статистика — прямо под него с промежутком8px. Обе колонки доходят до общего нижнего края.
- Размеры зависят от доступной высоты и DPI; при раскрытии подробностей статистика получает дополнительное место за счёт карточки феникса. Новых подписей, прокрутки и настроек нет.
- В Obsidian добавлена необязательная FixedHeight для этих трёх карточек; остальные карточки сохраняют прежнее поведение. Проверены компиляция, существующие сценарии и геометрия Home на420/480/540 высоты при DPI1/1.5/2. Визуальная оценка настоящего Roblox ожидается.

## 2.4.4 — Удалены ESP объектов и предметов · 2026-11-02

- По просьбе пользователя полностью удалены вкладки ESP/Объекты и ESP/Предметы, их controls и runtime-обработчики: детекторы/PCLD, Sticky, Blackholes ESP, Blobman/Gucci, защитные и боевые предметы.
- Удалено94 настройки; осталось257. Старые конфиги игнорируют удалённые ключи, остальные параметры сохраняются. Убрана миграция предметного master2.4.3.
- ESP игроков, скелеты/рамки, инструменты игрока, самоподсветка персонажа, отдельные визуальные эффекты FTAP/чёрных дыр и настоящая защита Anti-Kick не удалялись.
- Тесты удалённых функций заменены проверкой отсутствия вкладок/контролов и совместимости старых профилей. Длительное восстановление ESP проверяется на персонажах игроков вместо удалённого серверного детектора.

## 2.4.3 — Единое меню предметов · 2026-11-02

- ESP → Предметы: один главный переключатель и окно параметров с вкладками Типы/Оформление/Цвета. Детекторы остаются в Объектах; раскрытие невидимых персонажей перенесено в Инструменты.
- Выбор Blobman/Gucci по отдельности, пяти типов предметов защиты, пяти типов боевых предметов. Старые категории и настройки сохранены внутри общего окна.
- Общая дальность, отдельное включение заливки/подписей/иконок, прежний размер иконок, цвета блобманов/защитных предметов и новый собственный цвет/радуга боевых предметов. Для собственного цвета выключить «Исходные цвета предметов». Иконки предусмотрены для боевых предметов; для других объектов доступны подписи/подсветка.
- Выключение главной функции сохраняет выбор типов; старые профили без нового master автоматически выводят его из прежних категорий. Реестр351 ключ (+15), инвентарь обновлён.
- Компиляция,23 симуляционных сценария/83 группы, сохранения и миграция проверены. Новая структура и параметры ждут игровой проверки.

## 2.4.2 — Пропущенные переводы · 2026-11-02

- ESP Objects/Tools теперь «Объекты»/«Инструменты»; дополнены пропущенные подписи параметров, редактирования пресета, защиты и подсказка Freecam.
- Новые текстовые элементы/окна переводятся сразу при создании после выбора русского, без повторного переключения языка.
- Добавлен перевод составных статусов Anti-Kick: ожидание, подготовка, крепление, ошибки и пауза на чужом участке. Переключение назад на английский сохраняет исходные строки.
- Ключи336 настроек, ники/ID, названия проектов и конфиги не переименованы. Добавлена симуляция реальных вкладок, поздних элементов, статусов,10 переключений RU/EN и холодного восстановления русского.

## 2.4.1 — Компактная главная без лишних подписей · 2026-11-01

- Главная пересобрана в две компактные колонки без отдельной прокрутки страницы: профиль/версия и феникс слева, статистика справа.
- Удалены Quick access, слоган, перечисление Camera/Sky/Lighting, повторные подписи в баннере и сам широкий баннер. Уменьшена высота портрета, феникс занимает свою карточку целиком.
- Основные6 метрик сессии отделены от12 подробных показателей: подробности заменяют основные строки, а не удлиняют страницу. Добавлены здоровье/максимум, WalkSpeed, координаты, viewport, PlaceId, минимум/максимум секундного FPS и максимальное время кадра. Недоступные значения показаны как «—».
- Убраны отдельные пояснения про пустой ник манекена и защитный toy; рабочие подсказки управления оставлены. Сохранения/игровые функции не изменены.
- Пройдены компиляция и mock-тесты; реальное размещение при разных размерах экрана/DPI требует визуальной проверки пользователя.

## 2.4.0 — Восстановление прозрачности тела · 2026-11-01

- После аудита записей прозрачности добавлено восстановление обычной Transparency своего аватара при отдалении. До этого камера восстанавливала исключительно LocalTransparencyModifier; если тело скрывалось через Transparency, исправление не помогало.
- Запоминается известная прозрачность каждой видимой части, включая полупрозрачные аксессуары. Для стандартных R6/R15 частей тела предусмотрен нулевой fallback, если они уже скрыты в момент обнаружения. Неизвестные изначально невидимые helper-части не проявляются.
- Слой thirdAlpha не перекрывает другие зарегистрированные эффекты Transparency; вблизи снимается, голова/волосы остаются скрыты слоем2.3.9. Чувствительность, wheel zoom и интерфейс не изменены.
- Обработчики обеих прозрачностей и слои очищаются при удалении частей, смене персонажа, выключении и unload. Добавлены360 циклов (720 секунд модельного времени) без респавна, обычная Transparency=1 и поздние записи, helper/аксессуары и уже скрытый торс после замены персонажа.
- Реальный источник изменения Transparency на сервере/клиенте FTAP не установлен без live-трассировки; длительная игровая проверка исправления ожидается.

## 2.3.9 — Волосы при наклоне от первого лица · 2026-10-31

- Исправлена регрессия2.3.8: порог определения первого лица относительно головы расширен до2 studs, учитывая смещение камеры при наклоне.
- Вблизи голова и аксессуары скрываются через отдельный локальный слой thirdNear; при отдалении он снимается и возвращается thirdBody. Настоящая Transparency не меняется, функция видимого тела в первом лице сохранена.
- Добавлена защита от повторного входа при смене слоёв. Сигналы и оба слоя очищаются при смене персонажа/выключении/unload.
- Симуляция: 60 циклов по трём направлениям смещения камеры, поздние записи видимости головы/волос, восстановление при отдалении; прежние150 циклов сохранены. Внешний вид в игре ожидает проверки.

## 2.3.8 — Видимость тела после первого лица · 2026-10-31

- Режим первого/третьего лица определяется по фактическому расстоянию от камеры до головы, с резервной проверкой Focus. Устаревший Focus больше не удерживает тело скрытым при отдалении камеры.
- Добавлены отслеживаемые обработчики LocalTransparencyModifier: поздние записи игровой камеры корректируются после перехода в третье лицо. Первое лицо, Freecam/Spectate, настоящая Transparency и слои намеренных эффектов не перезаписываются этим обработчиком.
- Обработчики частей очищаются при их удалении, замене персонажа, выключении и unload; смена персонажа отслеживается и в первом лице.
- В симуляцию добавлены 150 циклов приближения/отдаления с устаревшим Focus и поздним скрытием тела. Реальное длительное поведение FTAP ожидает подтверждения пользователя.

## 2.3.7 — Новая главная страница · 2026-10-31

- Полноширинный тёмный баннер с фиолетовым градиентом, крупным названием, версией, автором и PNG феникса.
- Компактный профиль и отдельная колонка статистики, улучшенные размеры текста, контраст значений и интервалы.
- Быстрые переходы к обзору, графике и настройкам; подробная статистика раскрывается отдельно. Русские подписи сохранены, без новых игровых настроек и записей конфигов при навигации.
- Компиляция и симуляции проверены; внешний вид в настоящем Roblox ожидает оценки пользователя.

## 2.3.6 — Перенос тела Freecam после броска · 2026-10-31

- Переход и возврат Freecam перемещают всю модель персонажа через PivotTo, включая отдельные физические сборки рагдолла; скорости всех BasePart обнуляются. Раньше перемещался только HumanoidRootPart.
- Убрана блокировка нового перехода по флагу Ragdolled. Проверки живого/актуального персонажа, сиденья и Anchored сохранены.
- Временно заблокированный возврат сохраняет исходную точку для следующего ПКМ; смерть/замена персонажа и завершение Freecam очищают состояние.
- Добавлена симуляционная регрессия: 12 циклов с разнесённым телом, остаточной скоростью, локальной видимостью и повторным возвратом после Anchored. Реальное поведение FTAP после броска требует подтверждения пользователя.

## 2.3.5 — Плавающие параметры и новая навигация · 2026-10-29

- Окна параметров функций теперь перемещаются за заголовок независимо от основного меню, открываются поверх него и запоминают положение в конфиге. Позиция ограничена экраном с учётом DPI; палитры и списки остаются доступны, закрытие снаружи/Escape сохранено.
- Верхние переключатели всех категорий получили единую панель, Lucide-иконки, плавный индикатор выбранной страницы и подсветку наведения. Упорядочены отступы и страницы параметров.
- Добавлено короткое плавное появление окна и панелей без искусственного ожидания; ускорены переходы категорий. Убран постоянный пересчёт/принудительное позиционирование панелей, повторные UI-анимации отменяются перед новыми.
- Игровые эффекты не изменены, реестр остаётся 336 ключей. Проверены Luau-компиляция и симуляции нативных кликов/перетаскивания/DPI/закрытия, сохранения позиций, поиска, профилей, старта и редактора освещения. Внешний вид и поведение в Roblox предстоит оценить пользователю.

- По дополнительному запросу усилен стенд: два независимых клиента, очередь серверных событий с задержками, полный перебор 336 настроек, настоящие модули манекенов и единый запуск всех сценариев. Подробный отчёт: [Simulation-2.3.5](docs/Simulation-2.3.5.md). Это модель событий, не настоящий сервер FTAP.

## 2.3.4 — Анимации убраны из Visuals · 2026-10-29

- Убраны карточка анимаций персонажа, воспроизведение, 46 определений и три настройки. Перенос в Prime Vortex отложен; Vortex не изменён.
- Прочие эффекты персонажа сохранены. Старые конфиги игнорируют удалённые ключи; реестр содержит 336 настроек.

## 2.3.3 — Удаление экспериментальной графики · 2026-10-28

- По просьбе пользователя целиком удалена Graphics → Experimental: отражённый свет, Beam-лучи, их модуль, обработчики, параметры и счётчики эффектов. Вернулась прежняя навигация Lighting / Weather / Water & FPS.
- Одобренные пресеты, ручной редактор освещения, небо, погода и камера сохранены. Реестр снова содержит 339 настроек; старые конфиги с 14 экспериментальными ключами загружаются без сброса остальных значений.
- Пройдены Luau-компиляция и проверки удаления UI/зависимости, совместимости старого конфига, редактора, навигации и профилей. История эксперимента сохранена только в документации/Git.

## 2.3.2 — Экспериментальный свет и солнечные лучи · 2026-10-28

- Добавлена Graphics → Experimental: отдельные выключенные по умолчанию «Отражённый свет» и «Объёмные солнечные лучи». Это самостоятельная реализация на штатных локальных PointLight/Beam, без внешнего рендера, скрытых свойств и исполнения стороннего загрузчика.
- Свет: лучевые выборки поверхностей, проверка солнца/препятствий, учёт цвета поверхности, Neon и настоящих ламп; ограниченный переиспользуемый набор 12/24/40/64 источников для Low/Balanced/High/Ultra. Параметры силы/радиуса/дальности, включение локальных ламп. Старые точки затухают/удаляются; на шаг выделен ограниченный объём запросов и CPU-времени.
- Солнечные лучи: 4–24 Beam, ограниченные препятствиями, без лучей при солнце ниже горизонта. Настраиваются количество, длина, область, ширина, видимость, цвет/радуга. Это визуальная имитация, не физический объёмный рендерер.
- Не изменяются настройки Lighting и материалы игры. Все объекты локальны, не сталкиваются/не участвуют в raycast. Совместимость с пресетами и сохранением проверена в симуляции; включённые эффекты восстанавливаются после удаления папки, отключение/выгрузка очищают их.
- Добавлены 14 сохраняемых параметров (всего 353). Пройдены Luau-компиляция, целевые симуляции ограничений/освещения/лучей/очистки и регрессии редактора, UI/кликов, профилей, старта, камеры и длительной сессии. Рендеринг, реальная польза и FPS в FTAP требуют живой проверки пользователя.

## 2.3.1 — Редактор пресетов и расширенный ручной свет · 2026-10-28

- В параметрах готовых сцен добавлена «Редактировать выбранный пресет». Копирует выбранный Pale Frost/Dreamy Night/Tokyowami в ручные параметры, выключает исходную сцену/Fullbright и открывает ручную панель. Оригинальные определения не изменяются.
- «Свои настройки цвета» разделены на пять страниц: цвет, свет, воздух, эффекты, фокус. Добавлены 38 сохраняемых параметров: атмосфера, туман, Ambient/Outdoor/ColorShift, время/наклон солнца, тени, мягкость, diffuse/specular, яркость цветокоррекции, размер/порог Bloom, ширина лучей, DOF и замена игровых фильтров. Имеющиеся цвета поддерживают одноцветную радугу.
- Дополнительные группы включаются отдельно; их отключение, Reset filters и выгрузка восстанавливают исходные свойства. Ручные эффекты обслуживаются существующим механизмом восстановления. Скопированное небо Tokyowami становится обычным пользовательским небом и сбрасывается через Reset sky.
- Свои варианты сохраняются автоматически и в существующих пяти слотах полных конфигов; отдельного хранилища только освещения не добавлялось. Старые ключи/конфиги совместимы; новые группы в старых сохранениях выключены.
- Реестр вырос с 301 до 339 ключей. Добавлены проверки фактического копирования сцен, независимости правок, сброса, восстановления удалённых эффектов без записи конфигов, холодного старта, старых профилей и ошибки загрузки нового модуля. Пройдены Luau-компиляция и регрессии UI/кликов/профилей/камеры/длительной сессии. Качество рендеринга и удобство нового редактора требуют живого теста.

## 2.3.0 — Четыре замены в коллекции неба · 2026-10-28

- Пользователь подтвердил Blue Horizon, Purple Nebula и Pink Morning. Их данные, исходные 13 наборов и одобренный Camera/Freecam не менялись.
- Vaporwave заменён на Rainbow Galaxy (4943578383), Lavender Gradient — на Purple Radiance (Purple Sky 570559352), Rose Gradient — на Dark Matter (110290405998332), Golden Hour — на Milky Way (545702970). Два последних — точные модели по ссылкам пользователя. Всего остаётся 20 вариантов.
- Purple Radiance использует ранее проверенные шесть face-ID. Три остальные модели разрешаются существующим защищённым загрузчиком Sky при применении: копируются только свойства Sky, весь загруженный пакет уничтожается без помещения в игру. Успешные результаты кэшируются; ошибка сохраняет текущее небо.
- Старые выбранные названия в автосохранении/слотах/импорте переводятся в новые без потери остальных настроек. Разрешённые грани сохраняются в конфиге и восстанавливаются без повторного поиска модели.
- Превью и названия проверены через публичные Roblox API. Доставка моделей вне клиента требует авторизации, поэтому реальные текстуры трёх моделей в FTAP ещё нужно подтвердить. Симуляция проверяет IDs, шесть граней, очистку, кэш, отказ, профиль и миграцию; не заменяет живой тест ассетов.

## 2.2.9 — Native throws and player names in Freecam · 2026-10-28

- RMB checks FTAP's local GrabParts/GrabPart/WeldConstraint.Part1. While holding a live target it passes through to the native throw; no approach/return occurs. Native routing is latched across release even when throwing destroys the weld. Empty-handed RMB retains approach/return.
- Other player Humanoids use native Subject name display with extended distance during Freecam, retaining their own display text/occlusion. Values restore on disable/unload and replaced Humanoids are cleaned up. Players are refreshed twice per second, not through world scans.
- Added actual-module simulations for throwing without avatar return, release after weld removal, native name properties and restoration. Real engine name rendering and live throw behavior still require confirmation.

## 2.2.8 — Separate Freecam approach and grab · 2026-10-28

- RMB now toggles own-avatar approach / return. First press uses the current target and preserves the >=6-stud lateral clearance; the next press returns to the saved position even when aiming at empty space.
- LMB is left to native game interaction and no longer starts approach or returns on release. Releasing RMB also leaves the avatar at the chosen position.
- Updated HUD/settings hints. Menu interaction retains ordinary RMB handling; flight consumes RMB to avoid conflicting native secondary actions. Focus loss, disable and unload retain restoration.
- Luau compilation and simulated repeated cycles, release behavior, native LMB independence, empty-space return, camera rotation and lifecycle checks passed. Server acceptance of a later native grab remains a live-test question.

## 2.2.7 — Freecam pause and target clearance · 2026-10-28

- Persistent Enabled ScreenGui shells no longer count as open toy panels. E-close explicitly clears the interaction request; native panel close also clears it. Zero-sized/offscreen panels and hidden ancestors do not hold the flight pause.
- Avatar approach adds at least 6 studs of horizontal clearance perpendicular to the camera view, in addition to surface clearance, keeping the avatar away from the original target ray. Immediate release return is preserved.
- Added simulations for persistent enabled GUI shells, repeated E/native closes, offscreen tweened panels and lateral target-ray clearance. Live FTAP behavior still requires confirmation.

## 2.2.6 — Freecam menu synchronization and immediate return · 2026-10-28

- E now passes to the native game handler. The first explicit E releases the activation-only panel guard; cursor/flight state follows actual tracked menu visibility, including close-after-spawn, rather than a second alternating toggle.
- Primary-click approach runs in a high-priority ContextActionService callback before ordinary input listeners and passes the click onward. Raycast accepts players/body parts, moving props, anchored parts and Terrain. Destination is offset from the hit surface; no separate ground-under-target requirement.
- Mouse release returns the same living avatar immediately, without the previous 0.2-second delay. Focus loss, disable and unload also restore position. Freecam rotation/flight remain available while holding.
- This is client-side visible avatar movement, not a guarantee of server acceptance. No live Roblox test was performed. Real Luau compilation and simulations cover repeated menu cycles, native close, ignored E, immediate release, repeat clicks, anchored targets and focus-loss return.

## 2.2.5 — Freecam interaction controls · 2026-10-28

- Removed F3/F5 preparation. E switches native toy-menu/cursor access and flight; F4 exits in either mode.
- LMB on a movable raycast target automatically approaches solid ground near that target with the visible own avatar. Camera mouse look and flight remain available during the attempt. Release returns the same living avatar after 0.2 seconds.
- Preserved seat/ragdoll/ground/distance checks, unload/disable restoration and stale-release protection, including repeated clicks during the return delay. No remote hooks, concealment or server-acceptance guarantee.
- Verified with real Luau compilation and Freecam/lifecycle/profile/camera simulations; native input ordering and game acceptance require live testing.

## 2.2.4 — Экспериментальное приближение персонажа к Freecam · 2026-10-27

- В настройках Freecam добавлена кнопка «Тест: подойти / вернуть [F5]». F5 сохраняет положение своего персонажа, ищет твёрдую землю под камерой и однократно переносит персонажа туда, открывая режим курсора для обычных игровых действий.
- После нажатия/отпускания ЛКМ возвращает персонажа и продолжает полёт с задержкой 0.2 с; F5 отменяет тест сразу. F3/F4, выключение Freecam и выгрузка используют общий возврат. Отложенный callback старой попытки не влияет на следующую.
- Нет переноса при смерти, сидении, закреплённом корне, активном ragdoll, отсутствии твёрдой поверхности или слишком далёкой/некорректной точке. Новый персонаж после смерти не переносится в старую точку.
- Это реальное перемещение видимого персонажа, а не скрытый дальний захват: серверная обработка и реакция игры не подтверждены. Скрипт не добавляет невидимость для других игроков, не меняет игровые remote-проверки или сетевые настройки и не повторяет отклонённые перемещения автоматически.
- Пройдены Luau-компиляция и симуляции Freecam/профилей/UI/камеры/длительной сессии. Проверены подготовка, возврат на отпускании, отмена, старый callback, отсутствие земли, сиденье и выключение. Работоспособность обычного захвата после перемещения требует живого теста.

## 2.2.3 — Выход и управление Freecam · 2026-10-27

- F4 выключает Freecam без поиска переключателя в меню. На компактной панели добавлен крестик; его можно нажать после освобождения курсора через F3. Оба способа используют общий штатный путь отключения и сохраняют состояние переключателя.
- Подсказки панели показывают F3/F4 для текущего режима. При пересоздании HUD отключается старый обработчик крестика.
- Колёсико учитывает величину прокрутки, игнорирует нулевые события и не записывает повторное значение при достижении 10/600. Режим предметов продолжает оставлять прокрутку игровому UI.
- Симуляция проверяет четыре повторных цикла выхода F4, крестик в режиме предметов, восстановление камеры/движения и отсутствие оставшейся привязки клавиш; также нулевой и двойной шаг колеса. Пройдены Luau-компиляция и проверки профилей/UI. Живой FTAP требует проверки пользователем.
- Эта правка относится только к камере и управлению; дальность игровых действий и положение персонажа не изменяются.

## 2.2.2 — Меню предметов в Freecam · 2026-10-27

- F3 переключает Freecam между полётом и режимом предметов: камера останавливается, курсор освобождается, штатные игровые клавиши/меню снова доступны. E открывает обычное меню предметов; повторный F3 возвращает полёт и закрывает отслеживаемые игровые панели.
- Доступна также кнопка «Предметы / полёт [F3]» в настройках Freecam. Подсказки на компактной панели переключаются вместе с режимом; колёсико в режиме предметов не меняет скорость камеры.
- Выключение/выгрузка отключает переключатель режима и восстанавливает UI/мышь. Сохранены защита от самопроизвольного открытия игровых панелей в режиме полёта, скорость 10–600 и видимость тела.
- Серверная дальность действий, положение персонажа и репликация не изменяются. Перенос хитбокса, телепортация при захвате и невидимость для других игроков не реализованы; исследованный Position Desync не подтверждает защиту от серверных проверок.
- Пройдены Luau-компиляция и симуляции режимов Freecam, предметного меню, профилей, UI, камеры и длительной сессии. Реальные действия через штатное меню FTAP требуют проверки пользователем.

## 2.2.1 — Переработка Freecam и раздела View · 2026-10-27

- Freecam: мышь вращает камеру без ПКМ, WASD перемещает, Пробел поднимает и Q опускает; вертикальное движение относительно мира. Колёсико/ползунок задают скорость 10–600, Shift/Ctrl изменяют скорость в этих же пределах. Пауза без остаточного движения при меню, вводе текста и потере фокуса окна.
- Восстанавливается локальная видимость своего тела/головы/аксессуаров, включая поздние детали и нового персонажа. Подавлена конкуренция с настройкой тела от первого лица. Физический персонаж камерой не перемещается.
- Защита от открытия игрового меню при самой активации: до смены CameraType отслеживаются закрытые крупные игровые панели и именованные меню предметов; попытки открытия подавляются до выхода. UI Prime Visuals исключён, исходная видимость восстанавливается. Это устраняет также известный конфликт E; точное поведение актуального GUI FTAP требует живой проверки.
- Справа компактная панель Prime Visuals с брендовой иконкой, текущей скоростью и подсказками; скрывается в меню/на паузе и восстанавливается после потери GUI.
- Spectate: вместо ручного username — список игроков с DisplayName (@Username) и headshot, обновляющийся при входе/выходе игроков. Старый строковый ключ профиля сохранён, включая offline-значения.
- Smooth camera удалена по отзыву пользователя. Старые профильные ключи игнорируются без отказа конфига; теперь 301 настройка.
- Коллекция расширена с 13 до 20 шестигранных наборов: Blue Horizon, Purple Nebula, Vaporwave, Pink Morning, Lavender Gradient, Rose Gradient, Golden Hour. Старые наборы и сброс неба сохранены.
- Пройдены Luau-компиляция и симуляции камеры/визуалов/UI/профилей/старта/длительной сессии. Симуляция воспроизводит открытие игровой панели на CameraType.Scriptable без E. Реальная загрузка новых текстур и поведение сервера/UI FTAP требуют пользовательской проверки.

## 2.2.0 — Приближение камеры колёсиком · 2026-10-26

- При включённом третьем лице доступен штатный зум Roblox от 0.5 до 80: колёсиком можно перейти в первое лицо и отдалиться обратно. Лимиты больше не фиксируют камеру на одной дистанции.
- Ползунок Distance немедленно задаёт выбранную дистанцию однократным ограничением; после этого диапазон зума снова свободен. Периодическое обслуживание не возвращает выбранную дистанцию и не мешает колёсику.
- Вблизи (расстояние камеры до Focus меньше 1) отключается принудительное раскрытие головы/аксессуаров; настройка тела от первого лица снова действует. При отдалении восстановление видимости скина продолжает работать. Поворот без ПКМ сохранён.
- Оригинальные CameraMode и пределы зума восстанавливаются на выключении/выгрузке. Проверки в симуляции и Luau-компиляция; реальный зум Roblox требует пользовательской проверки.

## 2.1.9 — Невидимый защитный сюрикен · 2026-10-26

- Защитный предмет Anti-Kick полностью скрывается локально: LocalTransparencyModifier=1 для всех BasePart, прозрачные Decal/Texture. Поздние детали и повторные изменения видимости учитываются при обслуживании активной защиты.
- Удалено прежнее полупрозрачное оформление 0.9. Weld, положение, масса, владение и механика прикрепления не меняются; отображение скрывается только на клиенте.
- Расширена симуляция Anti-Kick: невидимость, поздняя деталь/декаль, восстановление локальной прозрачности и сохранение привязки. Пройдены симуляция и Luau-компиляция; живой FTAP проверяется пользователем.

## 2.1.8 — FTAP Anti-Kick · 2026-10-26

- Settings → General → Protection: включённый по умолчанию Anti-Kick с сохранением переключателя в профилях. Это предметная защита из исследованных исходников; перехватов Kick, скрытия от античита и отмены серверного бана нет.
- Сохранена общая механика Resonance/Wraith: собственный NinjaShuriken, проверка PartOwner и прикрепление StickyPart к собственному RagdollTouchedHitbox. Основа — более компактная ветка Wraith; подтверждение StickyWeld, ожидание персонажа и ограничения чужого участка сверены с Resonance.
- Конечный автомат с интервалом 0.1 с вместо постоянных yield-циклов: только один запрос создания одновременно, ограничение частоты запросов владения, пауза/повтор при отказе и восстановление после смерти/удаления предмета. Статус Attached выставляется только после подтверждённого weld.
- Выключение/выгрузка удаляют созданный защитный предмет и отключают соединения. Уже отправленный серверный запрос нельзя отменить на клиенте; эффективность против конкретной атаки и поведение сервера требуют проверки FTAP.
- Пройдены симуляции AntiKick, профилей, камеры/UI и Luau-компиляция. Симуляции подтверждают жизненный цикл, но не доказывают предотвращение кика реальным сервером.

## 2.1.7 — Третье лицо без удержания ПКМ · 2026-10-25

- Поворот использует штатный CameraInput.togglePan: один обработчик Roblox, без дополнительного вращения CFrame и без записи MouseDeltaSensitivity.
- Свободное вращение приостанавливается при открытом меню, вводе текста, Freecam, Spectate, camera noclip и Scriptable-камере. Исходное состояние pan и MouseBehavior восстанавливаются при выключении, паузе и выгрузке.
- Сохранены дистанция, штатные столкновения камеры и постоянное восстановление видимости персонажа. При недоступном модуле камера сохраняет управление через ПКМ.
- Проверки в симуляции и Luau-компиляция; чувствительность и поведение в FTAP требуют пользовательской проверки.

## 2.1.6 — Видимость своего персонажа от третьего лица · 2026-10-25

- При включении третьего лица локальная прозрачность тела, головы и аксессуаров снимается сразу и поддерживается после штатного обновления Roblox-камеры. Учтены поздняя загрузка аксессуаров и смена персонажа; полного сканирования модели каждый кадр нет.
- «Тело от первого лица» временно не накладывает свою полупрозрачность в третьем лице и продолжает работать после возврата. Настоящая Transparency частей, пользовательские эффекты и намеренно скрытый HumanoidRootPart не перезаписываются.
- Сохранены нативные поворот через ПКМ и живая дистанция. MouseBehavior/MouseDeltaSensitivity новым исправлением не изменяются. На выключении/выгрузке соединения и render-binding удаляются, локальные значения восстанавливаются.
- Добавлена симуляция third_person_visibility.py: исходный LTM=1, 100 повторных записей скрытия, поздний аксессуар, 12 смен персонажа, взаимодействие с первым лицом и unload. Пройдены Luau-компиляция и регрессии конфигов/камеры/эффектов/длительной сессии. Живой FTAP требует проверки пользователем.

## 2.1.5 — Восстановление кликов · 2026-10-25

- Исправлена причина отказа большинства переключателей после 2.1.4: обработчики Switch/Checkbox вызывали MouseIsOverFrame без координат. Исправлены оба вызова; у самого hit-test добавлена безопасная обработка отсутствующей точки.
- Закреплённая панель снова зарегистрирована как область взаимодействия Obsidian: выпадающие меню и палитры не теряют допустимого владельца при перемещении окна/изменении масштаба. Перетаскивание панели отдельно не включалось.
- Текстовые поля скрипта принимают ввод при потере фокуса, включая переход к кнопке действия; Enter также работает, Escape отменяет редактирование. Live-поле неба сохранено.
- Добавлен tests/sim/native_clicks.py: исполняются реальные обработчики MouseButton1Click/InputBegan/FocusLost из Obsidian с настоящим hit-test, а не только SetValue в макете. На коде 2.1.4 тест воспроизвёл ошибку nil Mouse; после исправления проходят клики Switch/Checkbox, кнопка настроек, обычные/отключённые действия, ввод и перетаскивание/ручной ввод ползунка.
- Пройдены Luau-компиляция, проверки UI, конфигов, повторного запуска, новых эффектов и длительной сессии в симуляции. Проверка в живом Roblox остаётся пользовательской. Расположение меню и 302 настройки сохранены.

## 2.1.4 — Упрощённая навигация и настройки · 2026-10-25

- Семь основных разделов сохранены, внутри добавлены короткие подстраницы: View — Camera/Sky; Graphics — Lighting/Weather/Water & FPS; Character — Appearance/Movement/Mannequins; ESP — Players/Objects/Tools; FTAP — Grab line/Crosshair/Blackholes/Audio; Settings — General/Profiles. На экране показывается одна тема, мелкие карточки объединены. Вытаскивание карточек в отдельные плавающие окна отключено.
- У каждой функции с параметрами есть видимая кнопка с иконкой ползунков. ПКМ сохранён. Настройки закреплены внутри основного окна и следуют за ним; проверены вычисления границ для DPI 1/1.5/2. Выключение функции, смена страницы, Escape и клик снаружи закрывают панель; клики в её dropdown/color-picker не закрывают её.
- У сложных ESP-панелей параметры разделены на General/Appearance. Радуга расположена рядом с соответствующим цветом вместо отдельной длинной строки. Сохранена защита ColorPicker: отказ цветового виджета не уничтожает встроенный независимый переключатель радуги.
- Основной шрифт заменён на Builder Sans, строки переключателей получили более свободный интервал. Функции переименованы понятнее без смены идентификаторов, добавлены короткие подсказки по наведению. Русский перевод дополнен; поиск учитывает русские подписи/подсказки, регистр кириллицы и скрытые подстраницы. При отсутствии результатов показывается короткое сообщение.
- На Home убраны устаревший статус проверки и строка про систему ключей. Основная статистика видна сразу, технические подробности открываются отдельно. В Configs убрана постоянная строка пути — кнопка копирования сохранена.
- Алгоритмы визуальных эффектов и 302 идентификатора настроек сохранены. Навигация не записывает конфиг; вычисляемая позиция закреплённых панелей не засоряет автосохранение. Старые координаты плавающих панелей принимаются без ошибки.
- Проверены Luau-компиляция, 12 наборов симуляций, настоящая логика панелей Obsidian в моделируемом UI API, конфиги и регрессии эффектов. Проверки внутри живого Roblox не выполнялись. Подробнее: [docs/Validation-2.1.4.md](docs/Validation-2.1.4.md).

## 2.1.3 — Пакет визуальных систем из DctRKW · 2026-10-25

- Выполнен статический разбор фактических визуальных обработчиков внешнего исходника, включая зависимости за пределами Visuals. Полная матрица сравнения, SHA-256 снимка, номера строк, точные параметры и отличия интеграции: [docs/Visual-Source-Audit.md](docs/Visual-Source-Audit.md). Внешний скрипт не выполнялся.
- Добавлены 22 отдельные системы: круг прыжка, след персонажа, четырёхслойная пыль смерти, трёхслойный снег, Box/Skeleton ESP, трассировка цели, Self/Blobman/Anti-kick/Combat ESP, раскрытие невидимых персонажей, три сцены освещения, Fullbright, плавная камера, Freecam, Spectate, внешний вид океана/тела, анимированная картинка чёрной дыры, оценка позиции по истории клиента и анимации персонажа. В пакет входят 42 исходных эмоции/танца и четыре поиска штатных FTAP-анимаций, 13 наборов skybox faces.
- Существующий Players ESP получил HP, дистанцию, фон, дальность и дополнительные шрифты. PCLD обнаруживает PartESP и вложенные детекторы, добавлена дальность. Custom line получила ручной градиент начала/конца; её проверенный менеджер респавна сохранён. Native third person, FOV, Realistic Water и старые функции не заменялись чужими менее обратимыми реализациями.
- Новые параметры используют общие панели по ПКМ, русский перевод, ручные/радужные цвета, автосохранение, слоты/импорт/экспорт, reset и unload. Начальные переключатели новых эффектов выключены. У Server Position явно указано, что это клиентская оценка, а не измеренная позиция сервера.
- Перенос адаптирован к восстановлению состояния: без удаления оригинального океана/суставов, массовой остановки чужих AnimationTrack, вызовов игровых remotes, зависимости от Drawing API и бесконечных неуправляемых циклов. Ошибки одного нового рендерера изолированы от остальных.
- Проверены Luau-компиляция и регрессии профилей/запуска/старых функций, плюс новая симуляция геометрии R6/R15, эффектов смерти, повторных респавнов, анимаций, камеры, неба, ESP, живых параметров, восстановления и выгрузки. Проверка GPU, доступности Animation ID и настоящего FTAP — пользователем. Подробности: [docs/Validation-2.1.3.md](docs/Validation-2.1.3.md).

## 2.1.2 — Защита запуска и длительной сессии · 2026-10-25

- Загрузчики модулей Visuals и Vortex делают до трёх попыток при HTTP/синтаксической ошибке и исключении компилятора; кэшируют только успешно выполненный исходник. Runtime-ошибки модуля не запускают его повторно вслепую. PNG также имеет ограниченные повторные попытки.
- Необязательное оформление изолировано: сбой скачивания, компиляции или конструктора не прерывает меню. Удаляются частично созданные элементы, восстанавливается штатный значок. При обязательном сбое очищаются библиотека, GUI, события, ввод и эффекты, показывается понятное сообщение. Obsidian передаёт ссылку на частично созданный GUI для ранней очистки.
- Ответ модуля после выгрузки отменяется до выполнения. Запуск Vortex из Settings возвращает Visuals при неудаче и не дублирует уже показанное сообщение. Vortex обновлён до 0.2.2.
- Custom Line больше не выбирает только первый GrabParts: учитываются дубликаты, вложенные и переименованные области, новые и переподключённые Beam. Обработчики не пересоздаются при каждом изменении параметра; мёртвые связи и записи освобождаются, исходные свойства возвращаются при выключении.
- Событийное обнаружение дополнено редкой проверкой известных областей; целый Workspace сканируется только при включении/перезапуске линии. Отдельная ошибка Beam не отключает менеджер, временный конфликт свойств повторно проверяется. Информация о захваченном объекте также не привязана к первой устаревшей папке.
- Общие обработчики защищены от повторного входа и после временной ошибки продолжают работу с ограничением частоты попыток/уведомлений вместо вечного отключения.
- Раз в секунду проверяются только включённые эффекты: камера, ESP, небо, облака, шейдеры, частицы, шляпа, прицел и информация о захвате. Удалённые объекты пересоздаются, параметры камеры восстанавливаются, конфиги не записываются на каждом таком восстановлении. Нативное управление камерой через ПКМ сохранено.
- Симуляции: 60 смертей, старые/новые GrabParts, вложенность и переименование, шесть минут таймеров, переписывание свойств и повторный запуск без перезахода; 12 циклов удаления эффектов; HTTP/компиляция/runtime/GUI-сбои; все 178 настроек и регрессии. Это воспроизведения в симуляции, не подтверждение live FTAP. Отчёт: docs/Validation-2.1.2.md.

## 2.1.1 — Видимые PNG и компактные значки · 2026-10-25

- Исправлена реальная причина отсутствия большого превью Visuals: карточка переносится в видимую пользовательскую колонку Home до скрытия штатных колонок. Высота превью увеличена до 240 пикселей.
- Оригинальные PNG с GitHub теперь статичны: один ImageLabel, без цветных наложений, больших запасных контуров и аур. Убрана зависимость видимости от IsLoaded; у назначенного изображения сразу нулевая прозрачность. Добавлен резервный бинарный HTTP-транспорт и отдельный ключ кэша.
- Верхняя эмблема Visuals заменена простым радужным кристаллом из восьми линий; Vortex — красным вращающимся вихрем из шести линий, без радуги. Подробные иллюстрации не используются в маленьких значках.
- Vortex обновлён до 0.2.1 и подхватывается из Settings вместо старой версии 0.2.0. Картинки не генерировались заново и не уменьшались: сохранены исходные прозрачные PNG 1254×1254.
- Проверены видимая иерархия Home, вывод PNG при ложном IsLoaded, кэш/HTTP, статичность иллюстраций, вращение/радуга значков, очистка и регрессии конфигов/визуальных функций в симуляции. Live-проверка executor остаётся за пользователем.
- Следующие обычные выпуски идут по запрошенной схеме 2.1.2 … 2.1.9, затем 2.2.0.

## 2.1.0 — Иллюстрированные анимированные эмблемы · 2026-10-25

- Prime Visuals получил собственную иллюстрацию кристаллического феникса: прозрачный PNG 1254×1254, крупное превью на Home и уменьшенная эмблема в шапке вместо P. Добавлены плавный цветной блик и мягкая аура.
- Запрошенный фикс запуска 2.0.1 включён сразу в 2.1.0: после автозагрузки, загрузки слота и отмены скрипт открывается на Home. Сохранённые визуальные настройки и положения панелей восстанавливаются; навигация по вкладкам больше не записывает неизменённый профиль.
- Prime Vortex обновлён до 0.2.0: собственный обсидиановый демон с рогами, высококачественное превью и знак в шапке. При запуске из Settings старая оболочка 0.1.0 заменяется новой.
- Общий AnimatedEmblem загружает PNG из закреплённого тега, проверяет и кэширует байты по имени с хешем содержимого. Свечение/переливы ограничены 30 Гц, при скрытом окне приостанавливаются; поздняя загрузка после выгрузки не меняет GUI и не пишет кэш.
- При отсутствии API локальных изображений/файлов остаётся собственный чёткий нативный контур эмблемы. Новых игровых функций нет. Подробности генерации и точные промпты: docs/Art-Prompts.md.
- Проверены Luau-компиляция, PNG/CRC/альфа, кэш и его повреждение, отложенное IsLoaded, скрытие/выгрузка и совместимость с конфигами. Это симуляции; фактическое отображение в FTAP/Xeno требует пользовательской проверки.

## 2.0.0 — Major Update: локальные профили и конфиги · 2026-10-25

- Автоматическое сохранение и восстановление всех 178 зарегистрированных настроек: переключателей, чисел, цветов, текстов, выбранных вариантов и поднастроек. Сохраняются ручные цвета под радугой, выбранные игроки ESP, параметры скайбокса и его шесть текстур, вкладка и позиции окна/панелей.
- Settings дополнен пятью именованными слотами, сохранением/загрузкой/удалением, сводкой отличий, подтверждением занятого слота и отменой последней загрузки в текущей сессии.
- Экспорт переносимого JSON, импорт из PrimeVisuals/Imports и копирование относительного пути. Автосохранения и слоты разделены по Roblox UserId.
- Двухфайловый журнал с проверкой записи и выбором последней корректной ревизии. Ошибки записи не уничтожают предыдущую копию; предусмотрены повторные попытки с увеличением задержки. Повреждённые автоматические данные не затираются простым запуском/закрытием.
- Изменения объединяются через 0,4 секунды; анимации не вызывают запись. Финальное состояние сохраняется при выгрузке, включая закрытие во время начатой записи. JSON проверяется как данные: схема, типы, диапазоны, размер и допустимый путь импорта.
- Полный сброс очищает последний автоматический профиль, сохраняя именованные слоты. Восстановление параметров выполняется до включения соответствующих эффектов; кнопки действий автоматически не воспроизводятся.
- Must-fix: исходный FOV теперь восстанавливается отдельно у каждой камеры; сохранённый выбор ESP переживает отсутствие игрока; программные setters восстанавливают флаг подавления и откатывают значение при ошибке callback; сброс неба/времени не активирует прежние дефолты при следующем входе.
- Проверки: Luau-компиляция, все 178 параметров, 8 случайных полных профилей (1 424 варьируемых значения), 20 повторных запусков, пять слотов, обмен между аккаунтами, отмена/подтверждения, повреждения/обрывы/сбои записи и расширенные регрессии. Это симуляции, не live-проверка FTAP/Xeno.
- Добавлены воспроизводимые конфигурационные тесты и документация: docs/Configs.md, docs/Validation-2.0.md. Основное оформление меню и проверенные игровые функции сохранены.

## 1.9.0 — Радужные цвета во всех цветовых настройках · 2026-10-25

- Добавлены 18 отдельных переключателей Rainbow рядом с цветами шейдеров, облаков, частиц, воды, прицела, чёрных дыр, а также контура, текста и обводки текста всех категорий ESP. Существующие режимы радуги линии, персонажа, шляпы и заливки ESP сохранены.
- Каждый новый режим плавно меняет один цвет по всему спектру. Выключение возвращает ручной цвет; ручной выбор или программный сброс отключают соответствующую радугу.
- Общий обработчик ограничен 30 обновлениями в секунду, пропускает отключённые функции и отключается при выгрузке. Для графических эффектов изменяется цвет без пересоздания объектов, обработчиков или геометрии воды.
- Новые подписи доступны на русском. Исходный раздел FTAP подтверждён пользователем; новые радужные режимы требуют проверки в игре.

## 1.8.2 — Запуск без заставки и надёжная выгрузка · 2026-10-25

- Полностью удалены загрузочный экран Prime Visuals, прогресс и искусственная задержка 3–5 секунд. Окно открывается после фактической сборки интерфейса; сброс использует тот же путь.
- Очистка ресурсов регистрируется до сборки UI и эффектов: ошибка посреди инициализации больше не оставляет уже созданные эффекты и обработчики.
- Ошибка отдельного шага очистки не прерывает остальные шаги. Поздние асинхронные ошибки не отправляют уведомления в уже выгруженный интерфейс.
- Сохранены игровые функции, оформление меню и запуск Prime Vortex из Settings.

## 1.8.1 — Запуск Prime Vortex из настроек · 2026-10-25

- Последней кнопкой Settings добавлен запуск Prime Vortex, с переводом на русский. Отдельный загрузчик вводить не требуется.
- Повторное нажатие открывает уже запущенное окно; параллельные загрузки блокируются. Prime Visuals сворачивается при переходе, его эффекты остаются активными.
- При ошибке загрузки окно Prime Visuals восстанавливается, доступна повторная попытка. Prime Vortex остаётся отдельной UI-оболочкой без новых игровых функций.

## 1.8.0 — Фирменная иконка Prime Visuals · 2026-10-25

- Собственный геометрический знак: огранённый призматический щит с внутренней монограммой P, радужным переливом, мягким свечением и проходящим бликом.
- Иконка рисуется элементами UI в штатном месте заголовка, масштабируется вместе с Obsidian и не требует внешней картинки.
- Анимация ограничена 30 обновлениями в секунду, при скрытом меню приостанавливается и отключается при выгрузке. Игровые функции и размеры окна сохранены.

## 1.7.2 — Отдельная UI-оболочка Prime Vortex · 2026-10-25

- Добавлен отдельный PrimeVortex.lua версии 0.1.0: пустая чёрно-красная Rage UI на Obsidian, без игровых функций. История Vortex ведётся в VORTEX_CHANGELOG.md.
- Prime Visuals сохраняет поведение 1.7.1; изменён только номер версии согласно правилам публикации репозитория.

## 1.7.1 — Линия после респавна и текстовые подписи ESP · 2026-10-25

- Custom line повторно применяется после CharacterAdded и пересоздания GrabParts/Beam. Изменения Texture/Color/TextureSpeed игровым скриптом восстанавливаются по событиям свойств, без постоянного сканирования карты.
- Обработчики линии отключаются перед повторным применением, выключением и выгрузкой. Возврат к исходным параметрам сохранён.
- Убраны портреты голов из ESP над персонажами, восстановлены обычные текстовые ники без смещения. В меню выбора сохранены DisplayName (@Username) и портреты голов.

## 1.7.0 — Радужная линия и портреты игроков · 2026-10-25

- FTAP → Custom line → Rainbow: вся линия одного цвета, который плавно меняется по радуге. Анимация до 30 Гц только для существующих линий; сегментация и пространственный градиент не меняются.
- При выключении Rainbow возвращается выбранный цвет; при выключении Custom line — исходные параметры игры. Созданные после включения линии автоматически подхватываются.
- ESP Players: список выбора показывает DisplayName (@Username) с портретами голов через встроенные FormatListValue/ValueImages Obsidian. Ключи выбора остаются уникальными username; вход/выход игроков обновляет подписи и изображения.
- Над отмеченными игроками тоже показываются DisplayName (@Username) и маленький портрет головы. Выключение Name скрывает подпись вместе с портретом.
- Изменения клиентские: покупка и права игрового геймпасса не меняются.

## 1.6.1 — Изоляция сбоев ColorPicker · 2026-10-24

- Ошибки AddLabel/AddColorPicker и отсутствие/неверная регистрация ColorPicker перехватываются для конкретного контрола вместо остановки сборки всего меню.
- Резервный контрол хранит внутренний цвет и поддерживает программный сеттер: Reset filters и другие вызовы setters продолжают обновлять состояние и при необходимости применять эффект. Это не пустой no-op.
- Ошибка SetValueRGB при программном обновлении также переводит контрол в резервный режим с восстановлением флага suppressed, не блокируя остальные настройки.
- По возможности удаляется неисправный/частично созданный контрол. Диагностика пишет ключ в warn; уведомление в UI показывается один раз за запуск, без потока сообщений.

## 1.6.0 — Ragdoll манекенов по параметрам FTAP · 2026-10-24

- После чтения структур настоящих персонажей и NPC FTAP добавлены пять BallSocketConstraint, переключение Motor6D/корневого WeldHRP, Ragdolled и отдельные коллайдеры конечностей. Приоритет имеют параметры текущего игрового R6-персонажа; резервный профиль снят с NPC FTAP.
- Захват крепится к детали, по которой попал луч, а не всегда к HumanoidRootPart. Тело сгибается при захвате, остаётся в ragdoll после броска; скорость броска задаётся всем физическим частям тела.
- Манекены теперь создаются в R6, как персонажи FTAP. Применение скина к лежащему манекену учитывает уровень пола.
- Добавлены локальные крики и удары с настройками существующих звуков FTAP; защита от частого повтора и отдельное отключение. Алгоритм запуска звуков и восстановления локальный, серверные условия FTAP не заявляются идентичными.
- Восстановление после приземления и успокоения выравнивает тело перед включением жёстких суставов. При выключении, смене скина и удалении отключаются обработчики физики и звуков.
- Добавлены переключатели физики и звуков в панели манекенов по ПКМ. Меню и остальные визуальные системы сохранены.
- Компиляция и модельные проверки пройдены. Новая версия не запускалась в живом FTAP: после снятия исходных параметров пользователь запретил управление экраном.

## 1.5.0 — Локальные манекены · 2026-10-24

- Character → «Локальные манекены»: создание серого R6-манекена или аватара по уникальному Roblox-нику. Ник читается без Enter; внешний вид загружается через Players API.
- Замена внешности последнего манекена с сохранением позиции, возврат к серому виду, удаление последнего/всех. До 10 моделей, без ИИ и автоматических анимаций.
- Локальная физика и отдельный захват только своих моделей: ЛКМ взять/отпустить, ПКМ бросить, колесо — расстояние, удерживать R — вращение. Серверные события FTAP не вызываются.
- Загрузка отменяется при удалении/выключении/выгрузке; захват отпускается при открытии меню, потере фокуса и удалении персонажа. Выключение и Reset/Unload удаляют модели и обработчики.
- Нужна проверка Players API и физики в живом FTAP; компиляция и модельные проверки не подтверждают игровую работу.

## 1.4.2 — Закрытие по актуальным границам панели · 2026-10-24

- При нажатии проверяются фактические AbsolutePosition/AbsoluteSize панели после перемещения и масштабирования; используется позиция события ввода.
- Нажатия внутри панели и её открытого списка/палитры не закрывают настройки. ЛКМ, ПКМ и касание снаружи закрывают их; строка функции больше не считается частью панели.
- Повторный ПКМ по строке открытой функции закрывает панель без немедленного повторного открытия.

## 1.4.1 — Заметные и перемещаемые панели · 2026-10-24

- Панели параметров выделены фиолетовой рамкой с мягким контуром и отдельной шапкой с акцентным названием функции.
- Добавлено перетаскивание за заголовок через штатный MakeDraggable Obsidian. Положение каждой панели запоминается до выгрузки скрипта.
- Первое открытие — рядом с курсором, а не справа от всей строки функции; повторное — в сохранённом месте с ограничением по границам экрана.

## 1.4.0 — Настройки функций по ПКМ · 2026-10-24

- Параметры функций перенесены из основных разделов в отдельные панели на нативных контролах Obsidian. ПКМ по включённой функции открывает её настройки; для выключенной панель недоступна.
- Перенесены настройки третьего лица, тела, шейдеров, солнца, облаков, частиц, воды, FPS, материалов персонажа, шляпы, четырёх категорий ESP, линии, прицела, изображений/цвета чёрных дыр и их звука.
- Панель закрывается крестиком, Escape, кликом снаружи, выключением функции, сменой вкладки и скрытием меню. Длинные панели прокручиваются; списки и выбор цвета открываются поверх и не закрывают родительскую панель.
- Самостоятельные функции без переключателя (FOV, загрузка неба, время) и общие настройки остаются доступны напрямую. Алгоритмы визуальных функций и их значения сохранены.
- UI-библиотеки загружаются по тегу текущей версии, чтобы новая версия скрипта использовала соответствующую библиотеку без старого кеша main.

## 1.3.0 — Выбор игроков для ESP · 2026-10-24

- В ESP → Visibility добавлены «Все игроки» и компактный мультивыбор по уникальным Roblox-никам. По умолчанию сохранена подсветка всех; при выключении «Все игроки» подсвечиваются только выбранные.
- Выбор сразу применяется к подсветке и подписям персонажей, сохраняется при респавне. Список обновляется при входе и выходе игроков, ушедшие игроки удаляются из выбора и отметок.
- Серверные детекторы, Sticky и Blackholes остаются независимыми категориями. Добавлены русские подписи новых контролов.

## 1.2.1 — Повторная переработка Realistic Water · 2026-10-24

- Повторно сверена реализация Resonance: прямое FillRegion с сеткой 4, блоками 128, полным объёмом исходных плит и смещением −4. Убран Lua-перебор вокселей и искусственное ограничение глубины 32.
- Исходные плиты скрываются все перед заполнением. Их CanCollide сохраняется, как в Resonance; состояние плавания управляется отдельно.
- Для сброса сохранены нативные CopyRegion/PasteRegion: восстановление исходного Terrain вместо удаления всей области в Air. Это намеренное отличие от очистки Resonance.
- Проверки компиляции и модельные проверки не являются подтверждением работы в живом FTAP; требуется игровой тест.

## 1.2.0 — Исправления графики и стартовая загрузка · 2026-10-24

- Исправлен сброс фильтров и всех цветовых контролов: используется настоящий ColorPicker из реестра Obsidian вместо возвращаемой родительской подписи.
- Terrain Water заменён на Realistic Water для океана FTAP: блоки до 128 студов, слой воды до 32 студов, постепенная обработка и сохранение исходного Terrain. Убран поток предупреждений о больших областях.
- Режим Non-swimmable отключает плавание, не создавая невидимую твёрдую поверхность; исходная коллизия и состояние плавания восстанавливаются.
- Добавлен стартовый экран Obsidian с автором @876osamuha, версией и прогрессом на случайные 3–5 секунд. Сброс настроек не повторяет вступление.
- Удалены неиспользуемые UI-хелперы и переменные, очередь воды обрабатывается без сдвига массива, геометрия свечения обновляется по событиям вместо каждого кадра.
- По просьбе пользователя Changelog полностью убран из меню и runtime-кода. История обновлений остаётся только в этом файле.

## 1.1.1 — Последовательный перелив свечения · 2026-10-24

- Исправлено свечение: весь контур одновременно одного цвета, который плавно проходит радугу от красного и обратно за 18 секунд.
- Убран одновременный многоцветный градиент; мягкость, следование за окном и очистка сохранены.

## 1.1.0 — Радужное свечение окна · 2026-10-24

- Добавлено мягкое радужное свечение по внешнему контуру окна с плавным переливом цветов.
- Свечение следует за перетаскиванием и масштабом UI, скрывается вместе с меню и удаляется при сбросе или полном закрытии.

## 1.0.0 — Главная и история версий · 2026-10-24

- Добавлена первая вкладка «Главная»: аватар, приветствие, ник игрока и автор @876osamuha.
- Добавлены сведения о сборке, статус доступа, статистика производительности и сессии.
- Добавлен развёрнутый Changelog; введена постоянная нумерация будущих обновлений. Обзор подтверждён пользователем.

## 0.31.0 — Возврат стабильной камеры

- Удалено принудительное вращение без ПКМ; возвращено прежнее третье лицо с ПКМ.
- Изменение дистанции на ходу сохранено. Пользователь подтвердил нормальную чувствительность и весь раздел «Обзор».

## 0.30.0 — Экспериментальная орбитальная камера

- Проверено отдельное управление третьим лицом через Scriptable без изменения CameraMode.
- Пользователь снова сообщил о высокой чувствительности. Эксперимент впоследствии удалён.

## 0.29.0 — Попытка восстановления чувствительности

- Добавлено сохранение чувствительности перед третьим лицом и восстановление после переключения.
- Симуляция прошла, но тест пользователя не подтвердил исправление в FTAP.

## 0.28.0 — Исправления Обзора

- Load начал принимать ID и ссылку без Enter. Солнце и облака автоматически скрываются при загрузке кастомного неба и возвращаются вручную.
- Добавлено вращение третьего лица без ПКМ. Позднее выявлен и устранён откатом связанный сбой чувствительности.

## 0.27.0 — Переход на Obsidian

- Самодельный UI заменён настоящими Obsidian Library и Lucide Icons из актуального Resonance.
- Перенесены контролы, цвета, списки, ползунки, выбор цвета и локализация. Название закреплено рядом со значком.

## 0.26.0 — Навигация иконками

- Добавлена узкая панель только с иконками и названиями по наведению. Обновлены шапка и карточки.
- Этот вариант иконок не устроил пользователя и был заменён при переходе на Obsidian.

## 0.25.0 — Полное закрытие

- Добавлена кнопка полного закрытия с очисткой UI, обработчиков и визуальных объектов.
- Пользователь подтвердил повторный запуск загрузчика без перезахода в игру.

## 0.24.0 — Полный сброс

- Добавлен полный сброс эффектов и настроек с восстановлением исходных свойств игры.
- FOV перестал применяться при запуске до первого изменения пользователем.

## 0.23.0 — GitHub и загрузчик

- Скрипт опубликован в Mengy777/Prime-Script-FTAP и переведён на постоянный loadstring-загрузчик.
- Устранён мешавший загрузке UTF-8 BOM. Настроены обновления через Git.

## 0.22.0 — Дистанция камеры на ходу

- Дистанция третьего лица теперь меняется ползунком в обе стороны без выключения режима.
- Оба предела зума синхронизированы с выбранной дистанцией.

## 0.21.0 — Группировка и русский язык

- Функции сгруппированы в Обзор, Графику, Персонажа, ESP, FTAP и Настройки.
- Настройки поставлены последними; добавлены русский язык и сворачивание групп.

## 0.20.0 — Расширение визуальных функций

- Добавлены освещение, частицы, вода, упрощение графики, эффекты персонажа и коническая шляпа.
- Добавлены категории ESP, оформление линии захвата, прицел, визуалы чёрных дыр и звуковые настройки.

## 0.19.0 — Шрифты и плотность

- Улучшены шрифты, размеры контролов и читаемость интерфейса.

## 0.18.0 — Чёрный интерфейс и постоянный размер

- Убраны лишние подсказки и подписи; введены чёрные поверхности и цветные края.
- После нескольких корректировок выбран размер окна примерно как у Resonance, без изменения размера между разделами.

## 0.17.0 — Упрощение неба

- После успешного теста примерно двадцати скайбоксов временно убраны отдельные настройки времени и размера солнца.

## 0.16.0 — Загрузка модели скайбокса

- Добавлена загрузка скайбокса по ID модели или ссылке Creator Store с извлечением шести текстур.
- Загруженные модели не запускаются: копируются только свойства Sky, после чего модель удаляется.

## 0.15.0 — Единое поле для неба

- Пересмотрены пресеты и заменён неудобный ввод отдельных текстур единым полем.

## 0.14.0 — Первые настройки неба

- Добавлены пресеты неба, время суток, размер солнца и восстановление исходного неба.

## 0.13.0 — Удаление Freecam

- Экспериментальная свободная камера полностью вырезана по просьбе пользователя.

## 0.12.0 — Исправление отделения Freecam

- Исправлен тест Freecam: камера отделяется от персонажа, а персонаж остаётся на месте.

## 0.11.0 — Эксперимент Freecam

- Добавлен временный тест свободной камеры; первая реализация ошибочно перемещала персонажа.

## 0.10.0 — Иконка и оформление Prime

- Создана иконка Prime Visuals и обновлено оформление меню под новое название.

## 0.9.0 — Prime Visuals и Prime Vortex

- Mengy’s Visual переименован в Prime Visuals. Для отдельного проекта Prime Vortex создан пустой TXT.

## 0.8.0 — Курсор меню без лагов

- После нескольких попыток исправлен курсор меню: простой крестик вместо активного прицела взаимодействия.
- Убраны тяжёлые попытки поиска и переноса элементов игрового прицела.

## 0.7.0 — Фиолетовое оформление по референсу

- Переработаны открытие, навигация и оформление по визуальным референсам Resonance.

## 0.6.0 — Первое наполнение вкладок

- Заполнены первые визуальные разделы; проведена оценка UI и намечена его переработка.

## 0.5.0 — Первые вкладки

- Меню разделено на несколько вкладок вместо одной панели FOV.

## 0.4.0 — Эксперимент расширенного FOV

- Проверена идея расширенного диапазона и изменения матрицы камеры; расширенный режим затем удалён.
- Рабочий диапазон оставлен 30–120.

## 0.3.0 — Перетаскивание и ползунок

- Добавлены перетаскивание меню, ползунок FOV с изменением на ходу и ручной ввод числа.
- Временно добавлен переключатель расширенного диапазона FOV.

## 0.2.0 — Mengy’s Visual

- Скрипт получил название Mengy’s Visual и стал основой будущего визуального хаба.

## 0.1.0 — Первый FOV-скрипт

- Создан первоначальный скрипт для FTAP/Xeno с изменением FOV.
- Добавлены меню, разблокировка курсора и хранение полного кода в TXT для последующих обновлений.
