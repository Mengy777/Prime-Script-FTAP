# 3.1.2 — reference-backed head appearance / no Freecam teleport

User removed approach/return entirely. VisualExpansion no longer contains those helpers, character PivotTo, throw momentum edits, RMB input fallback or return-on-exit. CAS passes RMB to native game handling; camera movement and E menu stay.

Prior visibility snapshots cannot infer alpha for an already-hidden accessory without exposing arbitrary invisible accessories. AvatarVisibility now requests Humanoid:GetAppliedDescription and Players:CreateHumanoidModelFromDescriptionAsync once per character/appearance load. The temporary reference is never parented to Workspace. Head-attached accessories only (Hair/Hat/FaceFront/FaceCenter attachment) contribute metadata, keyed by accessory name and mesh. Matching existing Handles gain authentic alpha. Waist/torso attachments do not qualify. Head decals match class/name; their original reference Texture can be patched in far/free modes. Main avatar body/clothing/humanoid are not rebuilt or ApplyDescription'd.

Description/model are disposed after success, failure and stale completion. Generation invalidates response after character replacement/unload/appearance completion. On API failure keep snapshot behavior, warn and retry after15s. Close first-person releases face patches as before; actual appearance assets cannot be synthesized if missing/deleted or identity no longer matches. No claim of live Roblox rendering success.

Tests: initially hidden native hair/face-mask plus classic face replaced from a mock reference; waist keyboard/torso overlay remain invisible; one reference request,30 mode switches, immediate alpha/Texture writes, disposal and completion after unload. Native-RMB/no-character-motion tests replace old teleport scenarios. Actual source is tested against mocked APIs, not FTAP servers.

Primary API documentation: [Humanoid.GetAppliedDescription](https://create.roblox.com/docs/reference/engine/classes/Humanoid#GetAppliedDescription), [Players.CreateHumanoidModelFromDescriptionAsync](https://create.roblox.com/docs/reference/engine/classes/Players#CreateHumanoidModelFromDescriptionAsync).
