local Logger = require("modules/logger")
local Mappins = {}

Mappins.registered = {}
local mappinSystem = nil

function Mappins.Init()
    mappinSystem = Game.GetMappinSystem()
    if mappinSystem then
        Logger.Debug("MappinSystem initialized.")
    else
        Logger.Error("Failed to get MappinSystem.")
    end
end

function Mappins.EnsureMappin(entry)
    if not mappinSystem then
        mappinSystem = Game.GetMappinSystem()
        if not mappinSystem then return end
    end

    if Mappins.registered[entry.id] then return end

    if not entry.position or entry.position.x == nil then
        Logger.Debug("Cannot create marker for " .. entry.id .. ", no coordinates.")
        return
    end

    -- NEEDS_IN_GAME_TEST: Verify coordinate scaling and exactly how MappinData is constructed in 2.31.
    local pos = Vector4.new(entry.position.x, entry.position.y, entry.position.z, 1.0)

    local success, mappinId = pcall(function()
        local mappinData = gamemappinsMappinData.new()
        mappinData.mappinType = TweakDBID.new("Mappins.PointOfInterest_icon")
        mappinData.variant = gamedataMappinVariant.UndiscoveredVariant
        mappinData.visibleThroughWalls = false

        return mappinSystem:RegisterMappin(mappinData, pos)
    end)

    if success and mappinId then
        Mappins.registered[entry.id] = mappinId
        Logger.Debug("Marker created: " .. entry.id)
    else
        Logger.Error("Failed to register mappin for " .. entry.id .. ". Ensure Game.GetMappinSystem API is correctly called.")
    end
end

function Mappins.RemoveMappin(entryId)
    if not mappinSystem then return end

    local mappinId = Mappins.registered[entryId]
    if mappinId then
        pcall(function()
            mappinSystem:UnregisterMappin(mappinId)
        end)
        Mappins.registered[entryId] = nil
        Logger.Debug("Marker removed: " .. entryId)
    end
end

function Mappins.RemoveAll()
    Logger.Info("Removing all custom mappins...")
    for id, _ in pairs(Mappins.registered) do
        Mappins.RemoveMappin(id)
    end
    Mappins.registered = {}
end

return Mappins
