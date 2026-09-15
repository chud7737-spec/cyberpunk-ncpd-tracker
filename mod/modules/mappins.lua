local Logger = require("modules/logger")
local Mappins = {}

Mappins.registered = {}
local mappinSystem = nil
local testMappinId = nil

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
        return
    end

    local pos = Vector4.new(entry.position.x, entry.position.y, entry.position.z, 1.0)

    local success, mappinId = pcall(function()
        local mappinData = gamemappinsMappinData.new()
        mappinData.mappinType = TweakDBID.new("Mappins.PointOfInterest_icon")
        mappinData.variant = gamedataMappinVariant.UndiscoveredVariant
        mappinData.visibleThroughWalls = false
        mappinData.active = true

        return mappinSystem:RegisterMappin(mappinData, pos)
    end)

    if success and mappinId then
        Mappins.registered[entry.id] = mappinId
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
    end
end

function Mappins.RemoveAll()
    Logger.Info("Removing all custom mappins...")
    for id, _ in pairs(Mappins.registered) do
        Mappins.RemoveMappin(id)
    end
    Mappins.registered = {}
    Mappins.RemoveTestMappin()
end

function Mappins.CreateTestMappin()
    if not mappinSystem then mappinSystem = Game.GetMappinSystem() end
    if not mappinSystem then return end

    local player = Game.GetPlayer()
    if not player then return end

    local pos = player:GetWorldPosition()
    -- Offset slightly so it's visible
    pos.x = pos.x + 2.0

    local success, mappinId = pcall(function()
        local mappinData = gamemappinsMappinData.new()
        mappinData.mappinType = TweakDBID.new("Mappins.PointOfInterest_icon")
        mappinData.variant = gamedataMappinVariant.UndiscoveredVariant
        mappinData.visibleThroughWalls = true
        mappinData.active = true

        return mappinSystem:RegisterMappin(mappinData, pos)
    end)

    if success and mappinId then
        testMappinId = mappinId
        Logger.Info("Test marker created near player.")
    else
        Logger.Error("Failed to create test marker.")
    end
end

function Mappins.RemoveTestMappin()
    if testMappinId and mappinSystem then
        pcall(function()
            mappinSystem:UnregisterMappin(testMappinId)
        end)
        testMappinId = nil
        Logger.Info("Test marker removed.")
    end
end

return Mappins
