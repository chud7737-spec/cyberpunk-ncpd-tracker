local Logger = require("modules/logger")
local Mappins = {}

-- A table storing entry_id -> mappin_id
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

    -- If already registered, do nothing
    if Mappins.registered[entry.id] then return end

    if not entry.position or entry.position.x == nil then
        Logger.Debug("Cannot create marker for " .. entry.id .. ", no coordinates.")
        return
    end

    local pos = Vector4.new(entry.position.x, entry.position.y, entry.position.z, 1.0)

    -- We construct a MappinData object.
    -- The exact struct fields might vary in 2.x, this is an approximation for CET.
    -- In actual CET for 2.x, we usually instantiate a PointOfInterestMappinData or generic gamemappinsMappinData.
    -- We use a safe default: Question mark (Undiscovered) or custom pin.

    local mappinData = gamemappinsMappinData.new()
    mappinData.mappinType = TweakDBID.new("Mappins.PointOfInterest_icon")
    mappinData.variant = gamedataMappinVariant.UndiscoveredVariant
    mappinData.visibleThroughWalls = false

    -- Needs IN-GAME TEST: The signature of RegisterMappin
    -- Usually: RegisterMappin(mappinData, position) -> NewMappinID
    local success, mappinId = pcall(function()
        return mappinSystem:RegisterMappin(mappinData, pos)
    end)

    if success and mappinId then
        Mappins.registered[entry.id] = mappinId
        Logger.Debug("Marker created: " .. entry.id)
    else
        Logger.Error("Failed to register mappin for " .. entry.id)
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
    for id, mappinId in pairs(Mappins.registered) do
        Mappins.RemoveMappin(id)
    end
    Mappins.registered = {}
end

return Mappins
