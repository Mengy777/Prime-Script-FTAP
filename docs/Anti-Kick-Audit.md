# FTAP Anti-Kick source review

Reviewed 2026-10-26. Source files were read as text, never executed.

## Resonance

Saved source: `Resonanse-current.lua`, upstream previously supplied by the user: https://raw.githubusercontent.com/aslan90101/resonance/refs/heads/main/Resonanse.lua

Lines 33075 onward: `fn21` waits for own PCLD, `fn22` spawns NinjaShuriken and checks ownership through SNO; the Shuriken branch attaches StickyPart to own HumanoidRootPart.RagdollTouchedHitbox via PlayerEvents.StickyPartEvent. The surrounding runtime waits for a live character and pauses inside another player's plot. It checks StickyWeld.Part1 when maintaining the attachment. Other selectable anti-kick implementations were not merged or enabled blindly.

## Wraith source

User source: https://doitenroi.win/paste/DctRKW/raw; saved `DctRKW-source.txt`.

Lines 9255–9360: fn20 watches the local player's spawned-toy folder and owned plot folder, then invokes MenuToys.SpawnToyRemoteFunction. Lines 30588–30880: fn77 destroys only its tracked toy; fn78/79 check StickyWeld; fn81 requests ownership with GrabEvents.SetNetworkOwner, removes TouchInterest and attaches to the player's RagdollTouchedHitbox using StickyPartEvent. Source attachment returns a surviving weld, which is weaker than confirming Part1, so the adapter requires Part1 == own hitbox before reporting Attached.

## Implementation decision

Both Shuriken branches share a gameplay-object mechanism. Neither is a general interception of server Kick nor a ban reversal. No claim is made that blackholes caused the reported disconnects or that this mechanism guarantees immunity.

`lib/AntiKick.lua` adapts the compact Wraith mechanism, retaining Resonance's character/plot/attachment guards. It does not copy the complete foreign loader, hooks, combat functions or permanent busy loops. There is one in-flight spawn, retry backoff and an explicit idle/spawn/owner/attach/active state machine. No other player's character is targeted. Existing ESP for anti-kick items remains separate.

Tests execute the real module against simulated remotes; server enforcement, network ownership permissions and actual resistance to attacks need live FTAP verification. InvokeServer requests already dispatched cannot be revoked by unloading the client script.
