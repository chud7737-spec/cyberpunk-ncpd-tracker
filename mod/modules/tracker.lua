local Logger = require("modules/logger")
local Database = require("modules/database")
local QuestState = require("modules/quest_state")
local Mappins = require("modules/mappins")

local Tracker = {}
Tracker.isUpdating = false

-- Filters
Tracker.filters = {
    showAllRemaining = true,
    assault = true,
    organized = true,
    reported = true,
    district_Watson = true,
    district_Westbrook = true,
    district_CityCenter = true,
    district_Heywood = true,
    district_SantoDomingo = true,
    district_Pacifica = true,
    district_Badlands = true
}

-- Stats
Tracker.stats = {
    total = 0,
    completed = 0,
    remaining = 0,
    unknown = 0,
    districts = {}
}

function Tracker.Init()
    Logger.Info("Initializing Tracker...")
    if not Database.Load() then
        Logger.Error("Tracker initialization failed: Database load error.")
        return
    end
end

function Tracker.Update()
    if Tracker.isUpdating then return end
    Tracker.isUpdating = true

    local entries = Database.GetAll()

    -- Reset stats
    Tracker.stats.total = #entries
    Tracker.stats.completed = 0
    Tracker.stats.remaining = 0
    Tracker.stats.unknown = 0
    Tracker.stats.districts = {}

    for _, entry in ipairs(entries) do
        local dist = entry.district or "Unknown"
        if not Tracker.stats.districts[dist] then
            Tracker.stats.districts[dist] = {total = 0, completed = 0, remaining = 0, unknown = 0}
        end
        Tracker.stats.districts[dist].total = Tracker.stats.districts[dist].total + 1

        local state = QuestState.GetState(entry)

        if state == QuestState.STATE_COMPLETED then
            Tracker.stats.completed = Tracker.stats.completed + 1
            Tracker.stats.districts[dist].completed = Tracker.stats.districts[dist].completed + 1
            Mappins.RemoveMappin(entry.id)

        elseif state == QuestState.STATE_UNKNOWN then
            Tracker.stats.unknown = Tracker.stats.unknown + 1
            Tracker.stats.districts[dist].unknown = Tracker.stats.districts[dist].unknown + 1
            -- We DO NOT show markers for UNKNOWN to be safe.
            Mappins.RemoveMappin(entry.id)

        else
            -- NOT_COMPLETED
            Tracker.stats.remaining = Tracker.stats.remaining + 1
            Tracker.stats.districts[dist].remaining = Tracker.stats.districts[dist].remaining + 1

            -- Apply filters
            local shouldShow = true

            if entry.type == "assault_in_progress" and not Tracker.filters.assault then shouldShow = false end
            if entry.type == "suspected_organized_crime" and not Tracker.filters.organized then shouldShow = false end
            if entry.type == "reported_crime" and not Tracker.filters.reported then shouldShow = false end

            if dist == "Watson" and not Tracker.filters.district_Watson then shouldShow = false end
            if dist == "Westbrook" and not Tracker.filters.district_Westbrook then shouldShow = false end

            if shouldShow then
                Mappins.EnsureMappin(entry)
            else
                Mappins.RemoveMappin(entry.id)
            end
        end
    end

    Tracker.isUpdating = false
end

function Tracker.OnUninit()
    Logger.Info("Uninitializing tracker, cleaning up mappins...")
    Mappins.RemoveAll()
end

return Tracker
