# ToyCollection3.1.4

Local native-GUI sorting only. No game remotes, toy spawns, favorite BoolValue writes or cloned/reparented buttons. Existing callbacks/viewport rendering remain game-owned.

Toggle defaultOFF at Settings Interface, parameters use existing floating feature panels. Four persisted controls: toyCollectionEnabled, toyCollectionOrder (hidden CSV28 slots), toyCollectionSlot and toyCollectionToy. MajorInterface adds the normal optional bind,401 persisted keys total. Assign swaps an existing preference rather than duplicating it. Reset restores starter preferences.

Starter slots: Rocket1, BlackCrystal2, CreatureBlobman3, TetracubL4, FoodCakePink5, Cube6, trumpet7, ocarina8, donut9 and secondary candidates. PalletLightBrown26 supersedes user's earlier24. Remaining slots fill from available native cards, preserving reserved matches. No empty fake cards are created if fewer than26/28 owned toys exist.

GUI hierarchy is not directly available in this environment. Adapter examines UIGridLayout groups; identities come from toy attributes, card names, labels and preview model names. Requires multiple known toy identities plus YourToys/owned context, or strong toy-menu context; excludes shop/store/Prime scopes. Aliases are provisional where exact game IDs weren't supplied. Dirty rebuilds are coalesced on heartbeat, not whole-GUI every frame. Original/latest external native LayoutOrder/SortOrder are restored on disable/unload. Card visibility and descendant changes trigger reconciliation.

Tests cover representative native image-button grid, priorities with missing items, exact pallet26, no extra/deleted/reparented cards, unchanged favorite values, native order writes, editor swaps, recreated menu, disable/unload and autosave cold restore. Mock GUI inheritance extended for real GuiButton/ImageButton/ViewportFrame semantics. These are not live FTAP render/input tests. Actual Your Toys structure, thumbnails, exact aliases, menu dimensions and cursor alignment need user verification.
