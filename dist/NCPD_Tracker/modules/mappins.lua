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

local function CreateGenericMappin(position)
    if not mappinSystem then
        mappinSystem = Game.GetMappinSystem()
    end

    if not mappinSystem or not position then
        return nil
    end

    local success, result = pcall(function()
        local data = MappinData.new()

        data.mappinType = TweakDBID.new("Mappins.QuestStaticMappinDefinition")
        data.variant = gamedataMappinVariant.DefaultQuestVariant
        data.active = true

        return mappinSystem:RegisterMappin(data, position)
    end)

    if not success then
        Logger.Error("RegisterMappin failed: " .. tostring(result))
        return nil
    end

    return result
end

function Mappins.EnsureMappin(entry)
    if Mappins.registered[entry.id] then
        return
    end

    if not entry.position then
        return
    end

    local pos = Vector4.new(
        entry.position.x,
        entry.position.y,
        entry.position.z,
        1.0
    )

    local id = CreateGenericMappin(pos)

    if id then
        Mappins.registered[entry.id] = id
        Logger.Debug("Marker created: " .. tostring(entry.id))
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
    Mappins.RemoveTestMappin()
end

function Mappins.CreateTestMappin()
    Mappins.RemoveTestMappin()

    if not mappinSystem then
        mappinSystem = Game.GetMappinSystem()
    end

    if not mappinSystem then
        Logger.Error("Cannot create test marker: MappinSystem unavailable.")
        return false
    end

    local player = Game.GetPlayer()
    if not player then
        Logger.Error("Cannot create test marker: player unavailable.")
        return false
    end

    local playerPos = player:GetWorldPosition()
    if not playerPos then
        Logger.Error("Cannot create test marker: player position unavailable.")
        return false
    end

    local pw = 1.0
    if playerPos.w then
        pw = playerPos.w
    end

    local markerPos = Vector4.new(
        playerPos.x + 3.0,
        playerPos.y,
        playerPos.z,
        pw
    )

    local id = CreateGenericMappin(markerPos)

    if not id then
        Logger.Error("Test marker creation failed.")
        return false
    end

    testMappinId = id

    Logger.Info(
        "Test marker created. Position: "
        .. tostring(markerPos.x) .. ", "
        .. tostring(markerPos.y) .. ", "
        .. tostring(markerPos.z)
    )

    return true
end

function Mappins.RemoveTestMappin()
    if not testMappinId then
        return true
    end

    if not mappinSystem then
        Logger.Error("Cannot remove test marker: MappinSystem unavailable.")
        return false
    end

    local id = testMappinId

    local success, err = pcall(function()
        mappinSystem:UnregisterMappin(id)
    end)

    if not success then
        Logger.Error("Failed to remove test marker: " .. tostring(err))
        return false
    end

    testMappinId = nil
    Logger.Info("Test marker removed.")
    return true
end

return Mappins
