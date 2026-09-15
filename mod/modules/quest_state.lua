local Logger = require("modules/logger")
local QuestState = {}

QuestState.STATE_COMPLETED = "COMPLETED"
QuestState.STATE_NOT_COMPLETED = "NOT_COMPLETED"
QuestState.STATE_UNKNOWN = "UNKNOWN"

local journalManager = nil

function QuestState.Init()
    journalManager = Game.GetJournalManager()
    if journalManager then
        Logger.Debug("JournalManager initialized.")
    else
        Logger.Error("Failed to get JournalManager.")
    end
end

function QuestState.GetState(entry)
    if not journalManager then
        journalManager = Game.GetJournalManager()
    end

    if not journalManager then return QuestState.STATE_UNKNOWN end

    local journalPath = entry.journal_path
    if not journalPath then
        return QuestState.STATE_UNKNOWN
    end

    local success, state = pcall(function()
        local jEntry = journalManager:GetEntryByString(journalPath, "gameJournalEntry")
        if not jEntry then return nil end
        return journalManager:GetEntryState(jEntry)
    end)

    if success and state ~= nil then
        if tostring(state) == "Succeeded" or state == 3 then
            return QuestState.STATE_COMPLETED
        else
            return QuestState.STATE_NOT_COMPLETED
        end
    end

    return QuestState.STATE_UNKNOWN
end

-- Probe function for diagnostic purposes
function QuestState.Probe(id, journalPath)
    Logger.Info("--- PROBING " .. tostring(id) .. " ---")
    if not journalManager then
        journalManager = Game.GetJournalManager()
        if not journalManager then
            Logger.Error("No JournalManager available for probe.")
            return
        end
    end

    Logger.Info("Journal Path: " .. tostring(journalPath))

    if not journalPath then
        Logger.Info("Result: Cannot probe without journalPath.")
        return
    end

    local jEntry = nil
    pcall(function() jEntry = journalManager:GetEntryByString(journalPath, "gameJournalEntry") end)

    if not jEntry then
        Logger.Info("Journal Entry: NOT FOUND")
        return
    end
    Logger.Info("Journal Entry: FOUND")

    local jHash = nil
    pcall(function() jHash = journalManager:GetEntryHash(jEntry) end)
    Logger.Info("Journal Hash: " .. tostring(jHash))

    local jState = nil
    pcall(function() jState = journalManager:GetEntryState(jEntry) end)
    Logger.Info("Journal State: " .. tostring(jState))

    local mappinSystem = Game.GetMappinSystem()
    if mappinSystem and jHash then
        local poiHash = nil
        pcall(function() poiHash = journalManager:GetPointOfInterestMappinHashFromQuestHash(jHash) end)
        Logger.Info("POI Hash: " .. tostring(poiHash))

        -- Needs in-game test to check if GetPointOfInterestMappinSavedState works this way
        Logger.Info("Mappin Saved State probe requires exact out parameters which might not bind in CET Lua easily. Skipping deep state probe.")
    else
        Logger.Info("MappinSystem not available for POI hash check.")
    end
end

return QuestState
