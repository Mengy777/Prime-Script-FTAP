# 2.1.1 verification

The screenshots exposed two gaps in 2.1.0: the new Home card was left in a hidden native side, and assigned artwork was gated behind an IsLoaded flag while transparent. The Home fixture now parents native groupboxes into their real native-side equivalents; the test walks the artwork ancestor chain and rejects hidden parents.

`tests/sim/emblems.py` verifies one opaque static image, no main-image fallback/layers, assignment while IsLoaded is false, compact independent header marks, red rotation versus rainbow, cache reuse, HTTP fallback, errors and late-response cleanup. `home_start.py`, full profile/stress tests and previous visual regression simulations pass. Main scripts and libraries compile with Luau.

Original 1254x1254 RGBA PNGs are unchanged. Actual rendering in the user's executor still needs live confirmation. If asset download/registration fails, a single notification points to the console; a geometric placeholder is no longer presented as the requested illustration.
