local Logger = require("modules/logger")
local QuestState = require("modules/quest_state")
local Mappins = require("modules/mappins")
local Tracker = require("modules/tracker")
local UI = require("modules/ui")

local isGameLoaded = false
local updateTimer = 0

registerForEvent("onInit", function()
    Logger.Init()
    Logger.Info("Mod loaded.")

    Tracker.Init()
    UI.Init()
end)

registerForEvent("onUpdate", function(delta)
    if not isGameLoaded then return end

    updateTimer = updateTimer + delta
    -- Poll every 5 seconds for completion state changes
    if updateTimer >= 5.0 then
        updateTimer = 0
        Tracker.Update()
    end
end)

-- Called when a save is loaded or main menu is loaded
registerForEvent("onSessionStart", function()
    Logger.Info("Session started (save loaded).")
    isGameLoaded = true

    -- Delay initialization slightly to let engine settle
    CName.add("DelayNCPDTracker")
end)

registerForEvent("onSessionEnd", function()
    Logger.Info("Session ended.")
    isGameLoaded = false
    Tracker.OnUninit()
end)

-- Workaround to initialize when game fully loads
Observe('PlayerPuppet', 'OnGameAttached', function(self)
    Logger.Info("Player attached, initializing systems...")
    QuestState.Init()
    Mappins.Init()
    Tracker.Update()
end)

return {
    description = "NCPD Tracker - displays uncompleted NCPD activities on map"
}
