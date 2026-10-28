# Lighting editor — 2.3.1

The original Pale Frost, Dreamy Night and Tokyowami scene definitions are retained. Their settings action imports a copy into manual controls, disables the source scene and Fullbright and opens the manual inspector. Color/Light/Air/Effects/Focus pages expose 38 additional persisted values (339 registered settings total). Advanced environment/Atmosphere/DOF groups default off so an old manual-lighting config does not opt into them.

Manual recipes are saved through the existing autosave and five full-config slots. This release does not introduce an independent lighting-only library. Old configs fill new keys with defaults; there is no schema bump or identifier rename.

The copied sky of Tokyowami belongs to the normal custom-sky lifecycle, including resolved-face profile persistence; Reset sky restores it independently. Reset filters restores manual controls and overrides, not a separately selected sky or unrelated feature. The three source definitions remain reusable after manual edits. Custom scenes replace only owned effect instances and temporarily patch game properties/effect states; no game script is disabled. Existing shared maintenance recreates missing owned effects.

Rendering references: [SunRaysEffect](https://create.roblox.com/docs/reference/engine/classes/SunRaysEffect), [BloomEffect](https://create.roblox.com/docs/reference/engine/classes/BloomEffect). Original scenes sometimes specify Bloom sizes above the native range; imported editable values clamp to 56. SunRays spread uses the current client's native default when a scene omits it.

Validation executes actual main/module code under mocked Roblox APIs: three-scene field/effect comparisons, source independence, boolean false handling, original atmosphere/posteffect restoration, disabling advanced groups, recovery after deletion without config writes, all 339 keys, cold startup and legacy profiles. Luau compiler plus navigation/native-click/startup/long-session/camera/profile/sky regressions also passed. This proves code-level behavior only; actual rendering and panel usability still require user confirmation. The checklist LIT-01…LIT-13 is pending.

Remove haze temporarily overrides manual Atmosphere/fog. Disabled/detached owned atmospheres are removed from its hidden-instance list before disposal, avoiding later resurrection of destroyed objects. Turning haze removal off reapplies active manual settings immediately. Numeric values copied from the game are clamped to the registered editor ranges before staging. The simulation covers atmosphere/haze toggles and restoration.

## User acceptance — 2026-10-28

After receiving the release test list, the user explicitly approved the entire Lighting subpage, including the new editor. LIT-01…LIT-13 are accepted by this section-level user report; no individual engine observations are invented. Earlier pending statements describe pre-acceptance release status. Other Graphics subpages remain separate.
