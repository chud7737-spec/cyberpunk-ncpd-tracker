local Logger = require("modules/logger")
local QuestState = require("modules/quest_state")
local Mappins = require("modules/mappins")
local Tracker = require("modules/tracker")
local UI = require("modules/ui")

local currentPlayerId = nil
local updateTimer = 0.0

local function GetPlayerId(player)
    if not player then
        return nil
    end

    local success, result = pcall(function()
        return tostring(player:GetEntityID().hash)
    end)

    if not success then
        return nil
    end

    return result
end

local function EnterGame(player)
    if not player then
        return
    end

    local playerId = GetPlayerId(player)

    if not playerId then
        Logger.Error("Could not get PlayerPuppet EntityID.")
        return
    end

    if currentPlayerId == playerId then
        return
    end

    if currentPlayerId ~= nil then
        Logger.Info("Player entity changed. Cleaning previous session...")
        Tracker.OnUninit()
    end

    currentPlayerId = playerId
    Logger.Info("Entering game session. Player EntityID: " .. playerId)

    QuestState.Init()
    Mappins.Init()
    Tracker.Update()
end

local function LeaveGame()
    if currentPlayerId == nil then
        return
    end

    Logger.Info("Leaving game session...")
    Tracker.OnUninit()

    currentPlayerId = nil
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
