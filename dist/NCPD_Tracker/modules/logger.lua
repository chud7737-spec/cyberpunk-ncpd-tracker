local Logger = {}

Logger.debugMode = true
Logger.logFile = nil

function Logger.Init()
    -- CET opens file relative to mod dir
    Logger.logFile = io.open("ncpd_tracker.log", "w")
    if Logger.logFile then
        Logger.logFile:write("[NCPD Tracker] Initialized\n")
        Logger.logFile:flush()
    end
end

function Logger.Info(msg)
    local formatted = "[NCPD Tracker] [INFO] " .. tostring(msg)
    print(formatted)
    if Logger.logFile then
        Logger.logFile:write(formatted .. "\n")
        Logger.logFile:flush()
    end
end

function Logger.Debug(msg)
    if not Logger.debugMode then return end
    local formatted = "[NCPD Tracker] [DEBUG] " .. tostring(msg)
    print(formatted)
    if Logger.logFile then
        Logger.logFile:write(formatted .. "\n")
        Logger.logFile:flush()
    end
end

function Logger.Error(msg)
    local formatted = "[NCPD Tracker] [ERROR] " .. tostring(msg)
    print(formatted)
    if Logger.logFile then
        Logger.logFile:write(formatted .. "\n")
        Logger.logFile:flush()
    end
end

function Logger.Close()
    if Logger.logFile then
        Logger.logFile:close()
        Logger.logFile = nil
    end
end

return Logger
