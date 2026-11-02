# FTAP Anti-Kick source review

## Lifecycle revision2.4.6 — 2026-11-02

User reports protection stops after repeated deaths/movement, often with a character-wait status. Code inspection found a spawn deadline conditioned on not-busy (hung InvokeServer could block forever), stale completion writing shared busy/pending, and hitbox lookup restricted to direct children of HRP. Current code cancels the local task when possible, invalidates generations, checks token before touching shared operation state, detects replaced character components, and uses recursive exact-name BasePart lookup. Missing hitbox has its own status; no invented fallback attachment is used. Lost active weld can reattach the existing owned toy before recreating it. Settings button calls Restart and does not enable a disabled function.

Real module tests cover30 complete character replacements, delayed/nested hitboxes, lost weld without new spawn, a suspended InvokeServer coroutine followed by successful retry, stale completion during a newer generation and manual restart. Existing tests cover hide/cleanup and ownership/weld confirmation. This is simulated lifecycle evidence, not a real FTAP attack-resistance test. Cancelling a local coroutine does not revoke an already-dispatched request or guarantee no late server object appears. Live AK-246 remains pending; no broader immunity/anti-ban claim.

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
