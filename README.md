# NCPD Tracker (Cyberpunk 2077) - PROTOTYPE

**Note: This is currently a Diagnostic Prototype / Development build.**

This is a CET (Cyber Engine Tweaks) mod for Cyberpunk 2077 v2.31 intended to diagnose APIs for showing uncompleted NCPD activities on the map.

It is completely read-only and does not modify the save game or quest states. It simply reads the completion status of the NCPD activities and adds custom markers to the map if they are not yet completed.

Check [README_RU.md](README_RU.md) for full instructions in Russian.

## Current Prototype Limitations

*   **Diagnostic Only:** This build is specifically designed to test `JournalManager` and `MappinSystem` APIs in-game. It includes a debug overlay to spawn test markers and probe data.
*   **Completion Detection:** Currently returns `UNKNOWN` because finding exact Journal Entry paths for every NCPD activity requires in-game extraction. The mod will not display markers for `UNKNOWN` states to remain safe.
*   **Coordinates:** We need to parse real coordinates from a WolvenKit JSON dump. Currently the database only holds 5 verified NCPD records, but all have `null` positions.
*   **Extractor Stub:** The `tools/extract_ncpd.py` script is currently a development stub and NOT implemented.
*   **Mappin API:** The `RegisterMappin` API syntax is approximated and requires strict in-game testing to ensure it creates the marker without crashing.

## Architecture

The mod uses standard CET `Game.GetMappinSystem()` and `Game.GetJournalManager()` to determine completion and add map markers safely.
