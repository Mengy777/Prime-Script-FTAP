# Validation — Prime Visuals 2.1.3

Дата: 2026-10-25. Проверены настоящие PrimeVisuals.lua, VisualExpansion.lua, VisualPresets.lua и модули конфигов/эмблем в моделируемом Roblox API. Чужой исходник не выполнялся.

## Компиляция

Luau WASM compiler (`luau-web`) успешно скомпилировал основной скрипт, Vortex, Obsidian, Icons, PrimeIcon, ConfigStore, AnimatedEmblem, Mannequins, MannequinRagdoll, два новых модуля и приватную обёртку Vortex/Obsidian. `git diff --check` пройден.

## Регрессии

Все 11 наборов ниже завершились с exit code 0. Python-тестам нужен `lupa`; запуск из корня репозитория: `python tests/sim/<имя>.py`.

### visual_expansion

```text
PASS source jump-circle ground/radius/fade, native trail parameters, respawn and disable cleanup
PASS exact three snow layers, wind/height/recovery; four source dust layers, death deduplication, 8-second expiry and visibility restoration
PASS R6/R15 projected box/skeleton, near-plane clipping, target marker with absent-target hiding, own highlight, existing ESP health/distance integration
PASS source object matching/icon deduplication, invisibility restore, animated blackhole repair/expiry/live controls, 32-part position ghost and emote assets/repeats/speed/recovery
PASS camera-only freecam translation, original movement/camera restoration, native spectate, shader switching and exact skybox face IDs
PASS ocean/body appearance restore, simultaneous active-feature unload, camera binding removal and original movement restoration
PASS actual autosave/re-execution of enabled expansion features, 12 repeated character replacements and final restore/unload
```

### profiles

```text
PASS all 302 registered settings round-trip; active FOV/camera/sky/sun/clouds/shaders/water/particles/mutes and manual rainbow color restored
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

### stress

```text
PASS 8 seeded randomized complete profiles, 2,416 varied setting values; imports, offline-player selections, UI positions/panels, Home startup and cold restart
PASS 20 re-executions in the same simulated game: restored effects remain singular; resolved sky uses no model fetch
PASS journal interruption on first and mirrored write retains a readable old/new profile
PASS expired overwrite confirmation and switching Save/Delete cannot overwrite a slot
PASS UTF-8 config names with Cyrillic/emoji and Russian language survive slot save/export
```

### esp_memory

```text
PASS native-like dropdown prunes absent rows but saved ESP selection survives leave/reload, reselects returning player and respects explicit deselection
```

### camera_cleanup

```text
PASS FOV tracks original values for both old/replacement cameras; feature callback failure restores the toggle state
PASS reset sky/time remain native defaults on another simulated server; untouched FOV/time sliders follow its real values
PASS newest JSON with invalid setting ranges is rejected in favor of an older fully valid backup
```

### write_races

```text
PASS reentrant write: edits during write are not lost; unload during write queues its final snapshot and cold restart restores it
PASS temporary disk failure retries automatically after recovery without another settings edit
```

### emblems

```text
PASS original high-resolution RGBA PNG assets unchanged
PASS opaque static PNG without IsLoaded gate, compact rainbow/spinning header marks, cache/retry transport, hidden pause and unload cleanup
PASS transient PNG download failure succeeds on the third bounded attempt
```

### home_start

```text
PASS legacy saved tab ignored on cold startup, config load and undo; settings/FOV preserved; tab navigation creates no config writes
PASS Home artwork is parented into the visible custom column, not the hidden native side
```

### startup_resilience

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
```

### vortex_startup

```text
PASS Vortex HTTP/compile retry keeps Visuals global library isolated
PASS mandatory Vortex failure clears partial GUI/signals/input and leaves Visuals intact
PASS Vortex optional artwork failure still opens and closes the main window
PASS Vortex failed window constructor cleans controller and library
PASS deliberate Vortex cancellation during download stays clean and does not emit a fatal-startup notification
```

### long_session

```text
PASS 60 deaths, stale duplicate folders, nested/renamed scopes, delayed rewrites, 6 simulated minutes, listener bounds, grab info and script reload without rejoining
PASS 12 game-driven clearing cycles restore camera/ESP and recreate enabled shaders, particles, hat mesh, crosshair, skybox and clouds; no duplicate config writes
PASS temporary callback error retries with cooldown instead of permanently disabling the feature; unload stops it
```

## Границы проверки

Это не запуск в Roblox/executor и не GPU-сравнение с Wraith. Модель проверяет вызовы API, значения, управление состоянием/ресурсами, повторное выполнение и файловые операции. Проекция и математика камеры в новой симуляции детерминированы и упрощены; она не воспроизводит физику FTAP, репликацию или сетевую задержку. Частицы не отрисовываются видеокартой. Наличие и права Animation/Texture ID и работа конкретного rig проверяются только в живой игре. Замеры улучшения FPS не заявляются.

## Короткая проверка в FTAP

1. **View:** Free camera — персонаж остаётся на месте; WASD/Q/E, ПКМ, колесо, Shift/Ctrl; выключение возвращает обычную камеру и чувствительность. Отдельно Smooth camera и Spectate с username существующего/вышедшего игрока.
2. **Character:** Jump circle, Character trail, Self highlight, Body appearance; несколько смертей. Dust при смерти другого персонажа. Несколько Emote/Dance и родных FTAP poses: доступность, скорость, остановка.
3. **Graphics/View:** по одному Pale Frost/Dreamy Night/Tokyowami, затем выключить; после Tokyowami применить своё небо. Layered snowfall, ветер/высота, Ocean material/color; выключение возвращает обычный вид.
4. **ESP:** Box/Skeleton на R6/R15, выбор отдельных игроков, цель для Trace, Combat Items (включая BananaPeel, который не должен считаться Banana), Blobman/Gucci, Anti-kick предметы, HP/дистанция. Оценку server position оценивать как запаздывающую рамку своего персонажа, а не точную телеметрию сервера.
5. **FTAP/Settings:** градиент линии и возврат к одноцветной радуге после смерти; Animated blackhole image на реальной чёрной дыре. Затем автосохранение/загрузка слота, Reset all settings и Unload script с включёнными новыми эффектами.
