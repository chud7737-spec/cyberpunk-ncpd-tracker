# NCPD Tracker (Cyberpunk 2077)

This is a CET (Cyber Engine Tweaks) mod for Cyberpunk 2077 v2.31 that shows all uncompleted NCPD activities on the map.

It is completely read-only and does not modify the save game or quest states. It simply reads the completion status of the NCPD activities and adds custom markers to the map if they are not yet completed.

Check [README_RU.md](README_RU.md) for full instructions in Russian.

## Architecture

The mod uses standard CET `Game.GetMappinSystem()` and `Game.GetQuestsSystem():GetFact()` to determine completion and add map markers.
All coordinates and fact names for NCPD activities are stored in `data/ncpd.json`, which was extracted offline.
