# Research: graphics beyond lighting presets

Date: 2026-10-28. Request: inspect actual publicly available Roblox script implementations for graphics improvements beyond the existing color/fog editor. **Research only**: no foreign loaders executed, no Roblox/desktop control, no runtime changes or live-performance claims. Current runtime remains 2.3.1. Remaining acceptance tests are still deferred.

## Main finding

Additional lights derived from scene sampling are the most plausible next experiment for native gameplay: raycast nearby surfaces, estimate sunlight/local-light exposure, and add a bounded pool of low-intensity colored bounce lights. This changes spatial lighting instead of just color grading. It remains an approximation; its value in FTAP is unverified. Replacing the renderer with GUI/EditableImage path tracing is a different task with significant detail/performance/integration tradeoffs.

## Inspected projects

| Project | Actual inspected code | Assessment for Prime Visuals |
| --- | --- | --- |
| [NaNo Reality Lighting / Photon](https://github.com/666-NEX/NaNo-RL) | Downloaded NaNo.rbxm, decompressed binary LZ4 chunks and read all 10 Source fields as text. Photon source contains camera raycasts, a sun visibility ray, checks against Point/Spot/SurfaceLights, then creates colored PointLight+Attachment on surfaces. Volumetric module builds 150 Beam layers following camera geometry. | Best conceptual match: dynamic approximate bounce lighting, with a separate optional volumetric effect. Not directly integration-ready. |
| [LUAU Pixel Shader](https://github.com/SentientShades/LUAU-Pixel-Shader/blob/main/senti_pixel_shader) | 250×100 GUI Frame grid; every RenderStepped shades alternating cells with raycasts, normal-dot-sun shading, material-specific reflection ray and recursive transparent hits. Uses object Color, not material texture sampling. | Own coarse screen renderer rather than enhancement of native raster output. Cannot claim improved texture fidelity; potentially large CPU/UI cost. |
| [Roblox CPU Path Tracer](https://github.com/cosypa123/roblox-path-tracer) | Controller.lua + RenderWorker.lua, real ray/path shading, EditableImage pixel buffers, parallel Actor workers, reflection/refraction and reconstruction. Controller expects ReplicatedStorage RenderActor template. | Technically substantial, but not a drop-in client visual effect. Author benchmark: 22.6 FPS at 128×72 internal realtime raytraced resolution on i5-11400H; not our measured result. Studio/template/EditableImage support must be resolved before any integration. |
| [Radiosity Engine](https://github.com/Razorboot/radiosity_engine_luau) | Rendering.lua computes direct/indirect light rays; Canvas.lua writes lightmaps via EditableImage/SurfaceGui patches on object faces. README describes baking, block/wedge support and Studio workflow. | Useful for precomputed scene lighting, poorly suited to a constantly changing FTAP map with spawned/thrown objects. Not a ready runtime graphics switch. |
| [Lumen V1.1.1](https://github.com/Elxrth/Lumen-V1.1.1) | Recursive repository listing contains README, LICENSE and .gitignore only. No published implementation to inspect. | Description alone is insufficient; do not present it as reviewed transferable code. |

### Concrete Photon issues in the downloaded source

- lightLimit=10000; there is no small scene-light budget appropriate to our integration.
- The PointLight/Attachment creation branch is duplicated, permitting two lights per successful sample.
- main() begins with task.wait(0.1); StartPhotonEngine calls it in a serial sampling loop with a reentry flag.
- Source comment claims a Terrain branch after a BasePart-only hit check, making that branch ineffective for Terrain.
- Occlusion checking for local shadowed lights uses a truthy ray-hit expression rather than clearly verifying that the obstruction is the light's own target.
- Existing source depends on ReplicatedStorage NaNo/package hierarchy and other ModuleScripts; no matching structures are assumed present in FTAP.
- No clear repository-wide license was returned for NaNo or Pixel Shader. Publicly readable code is not automatically a permissive reuse license. No third-party implementation has been copied into runtime.

## Realistic integration direction (not implemented)

1. Separate optional bounce-light toggle, independent of current scene grading/editor; no default changes.
2. Small reusable light pool (e.g. experimental 24–64 maximum), fixed ray/time budget, refresh near the camera rather than scanning all Workspace every frame.
3. Sample sunlight/local lighting and surface color, reject obstructed samples, decay obsolete lights, track movable targets and Freecam/replaced camera.
4. Keep light strength/radius and quality adjustable; preserve existing fog/sky settings. Restore/remove all owned resources on disable/unload.
5. Judge in actual FTAP at multiple locations with A/B screenshots and frame-time comparison. Do not call this RTX, true screen-space reflections, or proven global graphics improvement before those tests.

Possible volumetric additions should be distinct: beam-based shafts/lens effects add atmosphere, but do not increase geometry or texture resolution. Built-in material quality/reflections already depend on the game's renderer and assets; there is no verified universal Lua texture-resolution upgrader in this research.

## Source snapshots

Sources downloaded only to development work/shader-audit, outside the repository; source/model code was never executed. NaNo was decoded as binary data, not imported/executed in Roblox. Sources are mutable, so checksums below identify the inspected copies.

| Local snapshot | SHA-256 |
| --- | --- |
| `lumen-README.md` | `6f8c6111a42b745f38f2c985684d7600d65cc43f7ba66e72380778dba18dcccf` |
| `nano-script-1.lua` | `5d180ad844e3e30c5ca86d6e78ac47a38802ed029b9af0c41b3b74cef2a0d80d` |
| `nano-script-10.lua` | `53ef4e64f2f4f0de563b5609de536961f39251bd582600144230b7053ce3672f` |
| `nano-script-2.lua` | `1d7c4fef5876e494ab2db118bc284826d8f7054ec8958a8e05b490434962b5ae` |
| `nano-script-3.lua` | `a3fa960f7d7b9b8aa816e80d62ee62ed2981324561e286b7779a58235f693a41` |
| `nano-script-4.lua` | `5f3589133982b19613fbad006f608196b2129d8ea49ca96c3787cbe531002bba` |
| `nano-script-5.lua` | `143aad812f2334225392fb1e2410569e87f981904bf195036daa0656eb9acd9a` |
| `nano-script-6.lua` | `989a5d0cd18e3a7c05a25c6f074b66a9f2869f16a75b0d60767e02de851f4132` |
| `nano-script-7.lua` | `4ec6c2e6b9e09f71006d0c9ff789db405391002e4d8ba7eb15f88ecef01649c6` |
| `nano-script-8.lua` | `055dc8e8ed252d931a052d6f86364230ca8308408d790067e9bc6eaa794e0827` |
| `nano-script-9.lua` | `4e67489bef80b632876c8567e127a5d4d72532a3068c760be99851fcdb292a83` |
| `nano.rbxm` | `e24e3853657caaeb4c18b3375adc0de43c2da82fb9016524d2f446cf909473cf` |
| `path-Controller.lua` | `87dda62231446aaf8d5d5bf4d46c131079771af815f97a3762b67beae8c3de47` |
| `path-README.md` | `3be93b662706223b69e9389061ee2938494ce2b8ffcac851ea699be75df5f715` |
| `path-RenderWorker.lua` | `d7abfb662cd2f9e378460739c56d7dccb1f67fc164ca5135f8640beee5cffc46` |
| `pixel.lua` | `a6066203598f944376f16894cd87d848b53e5079c441251ed1f01ad94ed9e3fe` |
| `radiosity-Canvas.lua` | `94bcec1ffa74283dee159e090c5c36ca6a58bd82595a6fc4a45abf64e35834e7` |
| `radiosity-Rendering.lua` | `f511f8a4080fa44b6e1a8a8d01d918f7fc84c5fea5cd2b8ef2cc1d4ce7bc9f0b` |

Repository revision lookups at review time:

- 666-NEX/NaNo-RL: `7150759988b54780fc27afc62420feba2eb3e202`
- SentientShades/LUAU-Pixel-Shader: `fc86a68afd2dff8d700e43c88ac95b338466606b`
- cosypa123/roblox-path-tracer: `55ff44f5c912fc42ab3733a690ddcab6f6475733`
- Razorboot/radiosity_engine_luau: `1aa2d580689a0640bf764566fde0a016f34e5a5d`
- Elxrth/Lumen-V1.1.1: `7d3104bc96753c3e1dd03dedd5c450427e98c5d3`

## Primary references

- [Photon author's mechanism description](https://devforum.roblox.com/t/i-created-a-simple-rtgi-system-photon-global-illumination/3006223): surface/camera rays, sunlight/local-source checking, temporary PointLights.
- [NaNo author's follow-up](https://devforum.roblox.com/t/nano-reality-lighting-beta/3058803): current release described as beta; author later calls old code poor and discusses a rewrite. That announcement is not evidence that a newer implementation exists in the inspected repository.
- [Pixel source](https://github.com/SentientShades/LUAU-Pixel-Shader/blob/main/senti_pixel_shader).
- [Path tracer Controller](https://github.com/cosypa123/roblox-path-tracer/blob/main/Controller.lua), [worker](https://github.com/cosypa123/roblox-path-tracer/blob/main/RenderWorker.lua), [author benchmarks/setup](https://github.com/cosypa123/roblox-path-tracer/blob/main/README.md).
- [Radiosity source](https://github.com/Razorboot/radiosity_engine_luau/tree/main/RadiosityEngine).
- [Roblox PBR documentation](https://create.roblox.com/docs/art/modeling/surface-appearance): SurfaceAppearance maps and runtime limitations; texture/normal data must actually exist.
