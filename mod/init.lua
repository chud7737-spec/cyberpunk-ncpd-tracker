local Logger = require("modules/logger")
local QuestState = require("modules/quest_state")
local Mappins = require("modules/mappins")
local Tracker = require("modules/tracker")
local UI = require("modules/ui")

local currentPlayer = nil
local updateTimer = 0.0

local function EnterGame(player)
    if not player then
        return
    end

    if currentPlayer == player then
        return
    end

    if currentPlayer ~= nil then
        Logger.Info("Player instance changed. Cleaning previous session...")
        Tracker.OnUninit()
    end

    currentPlayer = player
    Logger.Info("Entering game session...")

    QuestState.Init()
    Mappins.Init()

    Tracker.Update()
end

local function LeaveGame()
    if currentPlayer == nil then
        return
    end

    Logger.Info("Leaving game session...")
    Tracker.OnUninit()

    currentPlayer = nil
    updateTimer = 0.0
end

registerForEvent("onInit", function()
    Logger.Init()
    Logger.Info("NCPD Tracker diagnostic prototype loaded.")

    Tracker.Init()
    UI.Init()

    Observe("PlayerPuppet", "OnGameAttached", function(self)
        EnterGame(self)
    end)
end)

registerForEvent("onUpdate", function(delta)
    local player = Game.GetPlayer()

    if player then
        EnterGame(player)

        updateTimer = updateTimer + delta

        if updateTimer >= 5.0 then
            updateTimer = 0.0
            Tracker.Update()
        end
    else
        LeaveGame()
    end
end)

registerForEvent("onShutdown", function()
    LeaveGame()
    Logger.Close()
end)

return {
    description = "NCPD Tracker - diagnostic prototype"
}
