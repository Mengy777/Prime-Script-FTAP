# 3.2.4b validation — 2026-11-07

Presentation-only category migration. All545 existing persisted keys/defaults retained; LightingEditor.lua and effect/preset runtime unchanged.

Passed:
- tools/compile.mjs: both entrypoints and all lib Lua files.
- tests/sim/ui_navigation.py: dedicated Shaders tab, lighting/preset card routing, weather remains Graphics, no navigation-triggered profile writes, stored inspector coordinates restore and native floating-panel behavior.
- tests/sim/localization.py: Shaders translates to Шейдеры; reversible RU/EN and saved-language behavior.
- tests/sim/lighting_editor.py: all3 scene presets copy/edit/reset, advanced environment/air/Bloom/rays/DOF controls,545-key cold restore, legacy profiles.

No live Roblox visual/layout test performed. New sidebar/category layout awaits user acceptance. No new shaders/effect behavior added.
