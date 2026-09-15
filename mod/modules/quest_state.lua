local Logger = require("modules/logger")
local QuestState = {}

QuestState.STATE_COMPLETED = "COMPLETED"
QuestState.STATE_NOT_COMPLETED = "NOT_COMPLETED"
QuestState.STATE_UNKNOWN = "UNKNOWN"

-- Reference to the quest system, populated when a save is loaded
local qs = nil

function QuestState.Init()
    qs = Game.GetQuestsSystem()
    if qs then
        Logger.Debug("QuestSystem initialized.")
    else
        Logger.Error("Failed to get QuestSystem. Is player in game?")
    end
end

function QuestState.GetState(entry)
    if not qs then
        qs = Game.GetQuestsSystem()
    end

    if not qs then return QuestState.STATE_UNKNOWN end

    local factName = entry.fact_name
    if not factName or factName == "" then
        Logger.Debug("No fact_name for " .. entry.id .. ", returning UNKNOWN")
        return QuestState.STATE_UNKNOWN
    end

    local factVal = qs:GetFact(factName)
    if factVal and factVal > 0 then
        -- We assume fact > 0 means the activity was completed
        return QuestState.STATE_COMPLETED
    end

    return QuestState.STATE_NOT_COMPLETED
end

return QuestState
