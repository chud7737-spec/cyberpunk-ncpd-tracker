# NCPD Tracker (Cyberpunk 2077) - PROTOTYPE

**Note: This is currently a Prototype / Development build.**

This is a CET (Cyber Engine Tweaks) mod for Cyberpunk 2077 v2.31 that shows all uncompleted NCPD activities on the map.

It is completely read-only and does not modify the save game or quest states. It simply reads the completion status of the NCPD activities and adds custom markers to the map if they are not yet completed.

Check [README_RU.md](README_RU.md) for full instructions in Russian.

## Current Prototype Limitations

*   **Completion Detection:** Currently returns `UNKNOWN` because finding exact Journal Entry paths for every NCPD activity requires in-game extraction. The mod will not display markers for `UNKNOWN` states to remain safe.
*   **Coordinates:** We need to parse real coordinates from a WolvenKit JSON dump. Currently the database is empty or only holds null values for positions.
*   **Mappin API:** The `RegisterMappin` API syntax is approximated and requires strict in-game testing to ensure it creates the marker without crashing.

## Architecture

The mod uses standard CET `Game.GetMappinSystem()` and `Game.GetJournalManager()` to determine completion and add map markers safely.
All coordinates and journal paths for NCPD activities will be stored in `data/ncpd.json`, which will be extracted offline using `tools/extract_ncpd.py` on WolvenKit dumps.
