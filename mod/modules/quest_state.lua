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

    -- In Cyberpunk, minor activities are tracked in the journal.
    -- We can query the state of the specific entry.
    -- However, the exact Journal Entry path requires IN-GAME extraction for each ID.
    -- For now, if we don't have the exact path or it's unverified, return UNKNOWN to be safe.

    local journalPath = entry.journal_path
    if not journalPath then
        Logger.Debug("No journal_path for " .. entry.id .. ", returning UNKNOWN")
        return QuestState.STATE_UNKNOWN
    end

    -- NEEDS_IN_GAME_TEST: The exact API for fetching Journal Entry state from path string.
    -- Usually: journalManager:GetEntryState(journalManager:GetEntryByString(journalPath, "gameJournalEntry"))
    -- Since we don't want to fake it or crash, we return UNKNOWN if we can't safely resolve it.

    local success, state = pcall(function()
        local jEntry = journalManager:GetEntryByString(journalPath, "gameJournalEntry")
        if not jEntry then return nil end
        return journalManager:GetEntryState(jEntry)
    end)

    if success and state ~= nil then
        -- state enum in CET usually matches gameJournalEntryState (e.g. Succeeded = 3)
        -- NEEDS_IN_GAME_TEST for exact enum match
        if tostring(state) == "Succeeded" or state == 3 then
            return QuestState.STATE_COMPLETED
        else
            return QuestState.STATE_NOT_COMPLETED
        end
    end

    return QuestState.STATE_UNKNOWN
end

return QuestState
