# Local mannequin physics

## Evidence collected on 2026-10-24

A read-only Xeno diagnostic inspected the running FTAP client's player character and several existing NPC models. It recorded instance properties; it did not execute the game's server scripts or force other characters into ragdoll. The raw diagnostic stays outside this repository.

Confirmed R6 structure: six Motor6D joints, five BallSocketConstraint joints, four welded RagdollLimbPart colliders, a Humanoid.Ragdolled flag and a disabled root-to-torso WeldHRP. Standing models had motors enabled and sockets disabled. The Resonance client code independently references these same objects when manipulating ragdoll.

| Joint | UpperAngle | Twist limits | Twist range | MaxFrictionTorque |
| --- | ---: | --- | --- | ---: |
| Neck | 45 | enabled | -70…70 | 20 |
| Shoulders | 70 | disabled | -30…30 stored | 20 |
| Hips | 80 | enabled | -15…15 | 20 |

Observed socket radius was 0.15 and restitution 0. Arm colliders were 0.75 × 0.75 × 0.75; leg colliders were 1.125 × 0.75 × 0.75. They were massless and non-queryable, with density 0.01, friction 0.3, elasticity 0.5 and both weights 1. The implementation reads actual attachment frames, collider offsets and properties from the current character when available; the saved NPC profile is the fallback.

Observed sounds include RagdollHit (`96626016`, speed 2, volume 0.25, distance 5–200), and Scream (different assets/pitches on different actors, including `89342465` and `149649817`, distance 15–200). Live template settings take priority.

## Local implementation and deliberate differences

- Created models are client-only R6 actors. Only their own joints, physics and audio are changed. No ragdoll/grab server remotes are called.
- Clicking a limb attaches local alignment constraints to that limb. All body assemblies receive the throw velocity.
- The humanoid's neck requirement and GettingUp state are managed locally to prevent accidental death or immediate rigid recovery. Self-collision constraints isolate the actor's body parts.
- Collider touch events generate local impact audio; this differs from FTAP's separate hitbox/controller arrangement. Fast motion and throws trigger screams with cooldowns.
- Local recovery requires low speed, nearby ground and a settling interval; it cannot recover while held. Body pose is realigned before rigid joints resume.
- These audio/recovery triggers are our implementation. The exact server-side conditions and timing were not obtained and are not claimed to match FTAP one-to-one.

## Validation boundary

Luau compilation and mocked integration cover rig construction, copied reference remapping, joint/collider state transitions, holding, recovery, fall detection, selected-limb grabbing, whole-body throwing, sound cooldown/mute, cancellation and cleanup. They do not simulate the Roblox physics solver or prove visual/audio equivalence in live FTAP. The user must test version 1.6.0 in the game.
