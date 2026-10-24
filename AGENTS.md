# Prime Visuals maintenance

- Use the existing Obsidian UI and Lucide icons. Home stays first and Settings stays last.
- Every functional or UI update must bump `VERSION` in `PrimeVisuals.lua` and prepend a dated entry to `CHANGELOG.md` in the same commit. Use semantic versioning from 1.0.0 onward. The user requested removal of the in-menu Changelog; keep history only in the repository, not in the runtime UI or a dormant Lua history table.
- History entries below 1.0.0 are retrospective development milestones, not original numbered releases. Do not invent original dates or describe failed experiments as successful fixes.
- Author credit is the Roblox username `876osamuha`. Do not invent a paid license, lifetime entitlement or license verification backend.
- The View section was confirmed by the user. Preserve native third-person rotation via RMB and live distance adjustment. Forced mouse-lock/orbit implementations caused a sensitivity regression and were removed.
- Preserve full reset/unload cleanup and original game state. Performance statistics must be measured, not placeholders presented as real values.
- Validate with Luau compilation and relevant simulated regression checks. Distinguish simulation results from live FTAP verification.
- The user authorized publishing each requested script update to this repository through Git. Keep the permanent loader path `PrimeVisuals.lua` stable and synchronize the development TXT/Lua copies.
