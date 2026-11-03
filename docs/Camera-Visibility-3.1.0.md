# Camera visibility 3.1.0

Source audit: 3.0.9 listened to LTM only in Freecam and had no ordinary alpha repair. v2.4.7 thirdPart sampled accessory alpha at enable, so a previously hidden Handle had no visible baseline.3.0.3 repaired that with an unsafe zero-alpha fallback for every accessory, revealing hidden meshes.3.0.7 excluded tools/helpers but still treated invisible Accessory Handles as visible. These are distinct code paths, not verified live FTAP traces.

AvatarVisibility now starts before camera toggles and records direct canonical body parts, direct Accessory/Hat Handles and Head decal/texture alpha. Invisible accessory/decal records stay unknown until actually visible; no zero-alpha accessory fallback. Only body has a canonical zero fallback. No texture, mesh, clothing or server mutation.

One owner evaluates current mode and proximity. Far third/free restores observed alpha and LTM, close third hides head/accessories and yields body to first-person fade. Other intentional noncamera alpha layers block repair. Property callbacks use a reentry guard. Frame calls also reconcile modes/current character. Character replacement/removal disconnects stale listeners and releases patches; disable stops repairs, unload disconnects all cache listeners.

Tests use actual source with mock engine APIs. They cover late LTM and ordinary alpha, hiding before mode activation, invisible accessory/decals,150 Freecam switches,360 long third-person cycles, near camera pitch,12 respawns, disable and unload. Rendering and real FTAP controller behavior still require user testing. No claim that arbitrary deleted/mutated assets can be recreated, or that already-hidden unknown accessories at initial script startup can be safely identified.
