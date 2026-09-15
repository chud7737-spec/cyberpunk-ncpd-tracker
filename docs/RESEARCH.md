# NCPD Tracker Research for Cyberpunk 2077 (2.31)

## APIs and Systems

### 1. Game.GetMappinSystem()

**STATUS:** LIKELY
**SOURCE:** Cyberpunk 2077 NativeDB / CET Documentation (common knowledge)
**EVIDENCE:** `Game.GetMappinSystem()` is the standard class in REDengine to interact with `gameMappinSystem`.

### 2. RegisterMappin / UnregisterMappin

**STATUS:** NEEDS_IN_GAME_TEST
**SOURCE:** REDengine Native API
**EVIDENCE:** The function exists in `gameMappinSystem` but the exact data structure required (`gamemappinsMappinData`) and its enum values (e.g. `gamedataMappinVariant.UndiscoveredVariant`) need strict in-game validation to ensure no crashes occur.

### 3. Quest Completion State

**STATUS:** LIKELY (via JournalManager) / VERIFIED (via Savefile metadata.json)
**SOURCE:** cp2077-tracker source code (https://github.com/defessler/cp2077-tracker)
**EVIDENCE:** `metadata.json` inside save files stores a space-separated `finishedQuests` list. However, CET cannot natively parse `metadata.json` from the active save folder safely without external Python scripts. Therefore, in Lua, the best approach is to check the `JournalManager` for specific minor activity completion states rather than relying on guessed facts (since FactsDB hashes names at runtime and does not follow a strict `{id}_done` pattern).

### 4. Coordinates extraction

**STATUS:** VERIFIED
**SOURCE:** WolvenKit
**EVIDENCE:** Coordinates must be extracted using WolvenKit from `minor_activities` `.quest` or `.spawner` files. Manual guessing of coordinates is invalid. We will provide a tool `tools/extract_ncpd.py` that can parse WolvenKit JSON dumps.

### 5. NCPD IDs and Classifications

**STATUS:** VERIFIED
**SOURCE:** CDPR Modding Community Quest IDs Reference, cp2077-tracker
**EVIDENCE:** IDs like `ma_wat_kab_05` represent actual quests (e.g., "Reported Crime: Protect and Serve"). Classification must be strict and based on reference documents.

## POI Hash Mapping & Mappin Saved State
**STATUS:** NEEDS_IN_GAME_TEST
**SOURCE:** REDengine Native API (`gameMappinSystem`, `gameJournalManager`)
**EVIDENCE:**
There is a potential read-only path to check completion without hardcoded coordinates:
1. Get Journal Entry (e.g. `JournalManager.GetEntryByString`)
2. Get Quest Hash (`JournalManager.GetEntryHash`)
3. `JournalManager.GetPointOfInterestMappinHashFromQuestHash(questHash)` -> `poiHash`
4. `MappinSystem.GetPointOfInterestMappinSavedState(poiHash, out phase, out variant, out active)`
If this chain works, we can determine state and potentially even runtime position (`GetQuestMappinPosition`) without `ncpd.json` positions.

## Mappin Phases
**STATUS:** NEEDS_IN_GAME_TEST
**SOURCE:** `gamedataMappinPhase` Enum
**EVIDENCE:** The enum contains `CompletedPhase`, `DefaultPhase`, `DiscoveredPhase`, `UndiscoveredPhase`. We need in-game testing to verify if `CompletedPhase` reliably maps to actual completion for NCPD minor activities.

## Custom Marker Creation & mappinData.active
**STATUS:** NEEDS_IN_GAME_TEST
**SOURCE:** CET community examples
**EVIDENCE:** When constructing `gamemappinsMappinData.new()`, setting `mappinData.active = true` is often required for the marker to actually render. `Mappins.PointOfInterest_icon` requires verification as a valid `TweakDBID`.

## CET Lifecycle
**STATUS:** VERIFIED
**SOURCE:** CET Documentation
**EVIDENCE:** `onSessionStart` and `onSessionEnd` are not valid CET events. The correct way to detect in-game state is polling `Game.GetPlayer()` in `onUpdate`, combined with events like `onInit`, `onDraw`, etc.
