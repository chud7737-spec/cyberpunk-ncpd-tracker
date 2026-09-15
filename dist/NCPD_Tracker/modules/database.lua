local Logger = require("modules/logger")
local Database = {}

Database.entries = {}

function Database.Load()
    Logger.Info("Loading NCPD database...")
    local file = io.open("data/ncpd.json", "r")
    if not file then
        Logger.Error("Could not find data/ncpd.json!")
        return false
    end

    local content = file:read("*a")
    file:close()

    local success, parsed = pcall(json.decode, content)
    if success and type(parsed) == "table" then
        Database.entries = parsed
        Logger.Info("Database loaded: " .. tostring(#Database.entries) .. " entries.")
        return true
    else
        Logger.Error("Failed to parse data/ncpd.json. Ensure it's valid JSON.")
        return false
    end
end

function Database.GetAll()
    return Database.entries
end

function Database.GetById(id)
    for _, entry in ipairs(Database.entries) do
        if entry.id == id then
            return entry
        end
    end
    return nil
end

return Database
