local Logger = require("modules/logger")
local QuestState = require("modules/quest_state")
local Mappins = require("modules/mappins")
local Tracker = require("modules/tracker")
local UI = require("modules/ui")

local sessionState = "IN_MENU"
local updateTimer = 0

registerForEvent("onInit", function()
    Logger.Init()
    Logger.Info("Mod loaded.")

    Tracker.Init()
    UI.Init()

    -- Safe observer registration
    Observe('PlayerPuppet', 'OnGameAttached', function(self)
        if sessionState ~= "IN_GAME" then
            Logger.Info("Player attached, initializing game systems...")
            QuestState.Init()
            Mappins.Init()
            sessionState = "IN_GAME"
            Tracker.Update()
        end
    end)
end)

registerForEvent("onUpdate", function(delta)
    local player = Game.GetPlayer()

    if player and sessionState == "IN_MENU" then
        -- Failsafe if OnGameAttached didn't fire (e.g. reload script)
        Logger.Info("Player found via update loop, initializing game systems...")
        QuestState.Init()
        Mappins.Init()
        sessionState = "IN_GAME"
        Tracker.Update()
    elseif not player and sessionState == "IN_GAME" then
        Logger.Info("Player not found, returning to menu state...")
        sessionState = "IN_MENU"
        Tracker.OnUninit()
    end

    if sessionState == "IN_GAME" then
        updateTimer = updateTimer + delta
        if updateTimer >= 5.0 then
            updateTimer = 0
            Tracker.Update()
        end
    end
end)

registerForEvent("onShutdown", function()
    Tracker.OnUninit()
end)

return {
    description = "NCPD Tracker - diagnostic prototype"
}
