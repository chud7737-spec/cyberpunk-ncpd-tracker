# NCPD Tracker Research for Cyberpunk 2077 (2.31)

## APIs and Systems

### 1. MappinSystem
- **Game.GetMappinSystem()**: VERIFIED
  - Used to register and unregister map pins in the runtime.
- **RegisterMappin**: LIKELY
  - Creating a custom marker requires creating `gamemappinsMappinData` or similar object, setting `mappinType` (e.g. `TweakDBID.new('Mappins.QuestDynamicMappin')` or `Mappins.PointOfInterest_icon`), setting `variant`, and passing a `Vector4` position.
- **UnregisterMappin**: LIKELY
  - Typically done by passing the `NewMappinID` returned by `RegisterMappin`.

### 2. Quest & Journal State
- **JournalManager (Game.GetJournalManager())**: VERIFIED
  - Useful for querying the state of journal entries (`GetEntryState()`).
  - Entries for NCPD activities are often under minor activities or point of interests.
- **QuestSystem (Game.GetQuestsSystem())**: VERIFIED
  - Contains `GetFact` which can read quest facts.
  - NCPD quests often set specific facts when completed (e.g., `ma_wat_kab_05_finished`).
- **finishedQuests**: UNKNOWN
  - There isn't a simple `.finishedQuests` array directly accessible from a global table. It is better to use `JournalManager` state or `GetFact` for specific quests to determine if an activity is completed.
- **How is NCPD completion determined?**: LIKELY
  - Either by checking the `JournalEntryState` of the specific minor activity (if it is `Succeeded` or `Inactive` / not active but was active).
  - Or by checking specific facts `GetFact("ma_wat_kab_05_completed")` / `GetFact("ma_wat_kab_05_done")`.
  - Alternative: `Game.GetMappinSystem()` might have a way to query POI mappin phase, but vanilla mappins might be hidden.

### 3. Creating and Removing Markers
- **Creating**: `Game.GetMappinSystem():RegisterMappin(mappinData, position)` (NEEDS IN-GAME TEST for exact syntax).
- **Removing**: `Game.GetMappinSystem():UnregisterMappin(mappinId)` (NEEDS IN-GAME TEST).

### 4. Coordinates
- **Extracting Original Position**: VERIFIED
  - Coordinates can be extracted from game files (streaming sectors, quest files) using WolvenKit CLI or by parsing dumped JSON resources.
  - We can dump minor activities `.quest` or `.spawner` files and parse the `Vector3`/`Vector4` positions.
- **Runtime extraction**: LIKELY
  - We can't easily iterate all *unloaded* original mappins in runtime because MappinSystem only holds active/registered mappins.
  - Thus, offline extraction to `data/ncpd.json` is required.

### 5. Dependencies
- **Cyber Engine Tweaks (CET)**: VERIFIED (Required for core mod logic, UI, and Mappin System interaction).
- **redscript / Codeware**: LIKELY (Might be needed if CET alone cannot instantiate certain custom Mappin variants, but we will start with pure CET to minimize dependencies).
- **ArchiveXL / TweakXL**: NOT NEEDED (We are not adding new game records, just using existing map pin variants).

### 6. Known Limitations
- The exact name of the quest facts for every NCPD is required if we use the `GetFact` method.
- If we use `JournalManager`, we need the exact `JournalEntry` paths.
- Some NCPDs are strictly tied to Street Cred requirements or other main quest progress (Phantom Liberty). If forced to show on map, they might just be empty locations until unlocked. Our mod acts as "READ ONLY", so it will just show a marker, but the player might arrive and find nothing.
