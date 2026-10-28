# Experimental graphics 2.3.2

This is an original implementation of two native client effects inspired by the concepts reviewed in Graphics-Research.md. It does not copy NaNo/Photon code, load foreign scripts, replace Roblox shaders, or claim RTX/native SSR. It changes spatial illumination using additional PointLights and draws Beam shafts; existing color/fog controls remain independent.

## Bounce lighting

Fixed screen samples raycast native geometry. Lit surfaces contribute color-weighted bounce lights; sun visibility and normal incidence reject shadowed/back-facing contributions. A cache of real local lights (maximum128, nearest16 checked/sample, at most2 shadow rays) can contribute separately. Neon receives an explicitly approximate emissive contribution. PointLights have no shadows; this is not a physically accurate multi-bounce transport solver and light can bleed through walls.

Quality controls pool size and sample frequency: Low12/2/.16s, Balanced24/4/.12s, High40/6/.10s, Ultra64/8/.09s (lights/samples/interval). Sampling checks a 3ms CPU budget but cannot guarantee GPU frame time. Nearby six-stud cells share samples, points fade and expire, moved/deleted surfaces lose stale samples. Cached lights are initially scanned on enable; descendants events maintain the cache. No per-frame whole-world scan or coroutine per ray exists.

## Sun shafts

4–24 face-camera Beams use golden-angle horizontal spacing around the camera, sun direction and raycast-clipped lengths. They are removed when sun.Y<=.08. They are stylized beam approximations, not full volumetric scattering; in interiors or certain camera/sun angles they may be subtle or invisible. Test outdoors during daylight first. No automatic time-of-day or preset modification is made.

## Lifecycle and verification

Both effects default off and use owned invisible, non-colliding/non-queryable carriers. Settings use the existing shared registry and all profile operations (353 keys). Default startup does no effect raycasts or map-light scan. Main teardown removes jobs/cache/probes/shafts/root. Simulations execute the real module and check bounds, paths, night gating, cleanup, restoration after folder destruction, persistence and no animation disk writes. These tests do not prove real FTAP rendering, interaction with quality settings, or FPS.

User checklist XG-01…XG-08 is pending. Existing Lighting editor and camera functions were not functionally modified. Existing deferred Character/ESP/FTAP checks remain deferred.
