# Technical Audit of First Implementation

## 1. Dummy Extractor
**OLD BEHAVIOR:** `tools/extract_ncpd.py` was a dummy script that generated a hardcoded `sample_data` list and marked it as `verified: True` with source `"Game resources"`.
**WHY WRONG:** It fabricated data and falsely claimed it was verified, breaking the rule against faking data to simulate completeness.
**NEW BEHAVIOR:** The extractor must be a real parser that takes actual input (e.g., WolvenKit JSON dumps) and parses it.
**VERIFICATION SOURCE:** CDPR Modding Documentation, WolvenKit structure.

## 2. Fabricated Coordinates
**OLD BEHAVIOR:** The database contained coordinates like `{"x": -1189.5, "y": 1422.3, "z": 12.1}` that were guessed/invented.
**WHY WRONG:** Coordinates must be extracted directly from game archives (`.quest`, `.spawner`, streaming sectors, etc.).
**NEW BEHAVIOR:** Coordinates will only be included if actually parsed from game files; otherwise, `position: null`.
**VERIFICATION SOURCE:** Game files parsing.

## 3. Guessed Quest Facts
**OLD BEHAVIOR:** `quest_state.lua` relied on `Game.GetQuestsSystem():GetFact(factName)` using guessed fact names like `ma_wat_kab_05_done`.
**WHY WRONG:** There is no universal naming convention for FactsDB in Cyberpunk 2077. Relying on guessed facts is unreliable and fabricated.
**NEW BEHAVIOR:** Use actual completion tracking via save parsing (`finishedQuests`), JournalManager, or only use facts if empirically proven by CDPR's quest reference.
**VERIFICATION SOURCE:** cp2077-tracker source code and save file structure.

## 4. Incorrect Classification
**OLD BEHAVIOR:** IDs like `ma_wat_nid_01` were manually classified as `assault_in_progress`.
**WHY WRONG:** CDPR's official quest IDs reference defines it differently (e.g., Suspected Organized Crime Activity).
**NEW BEHAVIOR:** Activity types must strictly match official data sources.
**VERIFICATION SOURCE:** CDPR Quest IDs Reference.

## 5. Generated Names
**OLD BEHAVIOR:** Generated generic names like "Reported Crime: Kabuki 05".
**WHY WRONG:** The game has actual localized strings and names for these activities (e.g., "Reported Crime: Protect and Serve").
**NEW BEHAVIOR:** Use real names or leave as `null`.
**VERIFICATION SOURCE:** In-game localization files / journal entries.

## 6. Approximate Mappin API
**OLD BEHAVIOR:** `mappins.lua` used an approximation for CET, with comments like "Needs IN-GAME TEST" but claiming to work.
**WHY WRONG:** Misrepresents the state of the API.
**NEW BEHAVIOR:** Investigate actual working open-source MappinSystem implementations for 2.x, update the code, and keep `NEEDS_IN_GAME_TEST` if it cannot be completely verified without the game.
**VERIFICATION SOURCE:** CET documentation, working open-source mod examples.

## 7. Fake Delay
**OLD BEHAVIOR:** `init.lua` used `CName.add("DelayNCPDTracker")` to simulate a delay.
**WHY WRONG:** This does not create a delay in CET Lua; it merely registers a string as a CName.
**NEW BEHAVIOR:** Use real lifecycle events or CET timers.
**VERIFICATION SOURCE:** CET API Documentation.
