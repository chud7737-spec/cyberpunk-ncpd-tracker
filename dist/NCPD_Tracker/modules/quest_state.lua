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

local function MapJournalState(state)
    if state == nil then
        return QuestState.STATE_UNKNOWN
    end

    if state == gameJournalEntryState.Succeeded then
        return QuestState.STATE_COMPLETED
    end

    if state == gameJournalEntryState.Active then
        return QuestState.STATE_NOT_COMPLETED
    end

    return QuestState.STATE_UNKNOWN
end

function QuestState.GetState(entry)
    if not journalManager then
        journalManager = Game.GetJournalManager()
    end

    if not journalManager then
        return QuestState.STATE_UNKNOWN
    end

    if not entry.journal_path or entry.journal_path == "" then
        return QuestState.STATE_UNKNOWN
    end

    local success, result = pcall(function()
        local journalEntry = journalManager:GetEntryByString(
            entry.journal_path,
            entry.journal_class or "gameJournalEntry"
        )

        if not journalEntry then
            return nil
        end

        return journalManager:GetEntryState(journalEntry)
    end)

    if not success then
        Logger.Error("Journal state lookup failed for " .. tostring(entry.id) .. ": " .. tostring(result))
        return QuestState.STATE_UNKNOWN
    end

    return MapJournalState(result)
end

function QuestState.Probe(entry)
    if not entry then
        Logger.Error("Probe: entry is nil.")
        return false
    end

    Logger.Info("--- NCPD PROBE: " .. tostring(entry.id) .. " ---")

    if not journalManager then
        journalManager = Game.GetJournalManager()
        if not journalManager then
            Logger.Error("No JournalManager available for probe.")
            return false
        end
    end

    if not entry.journal_path or entry.journal_path == "" then
        Logger.Info("Journal Path: UNKNOWN")
        Logger.Info("Probe result: UNKNOWN")
        return false
    end

    Logger.Info("Journal Path: " .. tostring(entry.journal_path))

    local jEntry = nil
    pcall(function()
        jEntry = journalManager:GetEntryByString(entry.journal_path, entry.journal_class or "gameJournalEntry")
    end)

    if not jEntry then
        Logger.Info("Journal Entry: NOT FOUND")
        return false
    end
    Logger.Info("Journal Entry: FOUND")

    local jClass = entry.journal_class or "gameJournalEntry (default)"
    Logger.Info("Journal Class: " .. jClass)

    local jHash = nil
    pcall(function() jHash = journalManager:GetEntryHash(jEntry) end)
    Logger.Info("Journal Hash: " .. tostring(jHash))

    local jState = nil
    pcall(function() jState = journalManager:GetEntryState(jEntry) end)
    Logger.Info("Journal State: " .. tostring(jState))

    local mappedState = MapJournalState(jState)
    Logger.Info("Mapped Completion State: " .. tostring(mappedState))

    local mappinSystem = Game.GetMappinSystem()
    if mappinSystem and jHash then
        local poiHash = nil
        pcall(function() poiHash = journalManager:GetPointOfInterestMappinHashFromQuestHash(jHash) end)
        Logger.Info("POI Hash: " .. tostring(poiHash))
    end

    return true
end

return QuestState
