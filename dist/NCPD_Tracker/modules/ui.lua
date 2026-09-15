local Logger = require("modules/logger")
local Tracker = require("modules/tracker")
local QuestState = require("modules/quest_state")
local Mappins = require("modules/mappins")
local Database = require("modules/database")

local UI = {}
UI.isOpen = false
local testMarkerStatus = "NONE"

function UI.Init()
    registerForEvent("onDraw", function()
        if UI.isOpen then
            UI.Draw()
        end
    end)

    registerForEvent("onOverlayOpen", function()
        UI.isOpen = true
    end)

    registerForEvent("onOverlayClose", function()
        UI.isOpen = false
    end)
end

function UI.Draw()
    ImGui.Begin("NCPD Tracker")

    ImGui.Text("NCPD Трекер")
    ImGui.Separator()

    -- Stats
    ImGui.Text("Всего: " .. tostring(Tracker.stats.total))
    ImGui.Text("Завершено: " .. tostring(Tracker.stats.completed))
    ImGui.Text("Осталось: " .. tostring(Tracker.stats.remaining))
    ImGui.Text("Неизвестно: " .. tostring(Tracker.stats.unknown))

    ImGui.Separator()
    if ImGui.Button("Обновить состояние") then
        Tracker.Update()
    end

    ImGui.Separator()
    ImGui.Text("NCPD DEBUG")

    if ImGui.Button("Тестовая метка возле игрока") then
        local success = Mappins.CreateTestMappin()
        if success then
            testMarkerStatus = "CREATED"
        else
            testMarkerStatus = "ERROR"
        end
    end

    if ImGui.Button("Удалить тестовую метку") then
        local success = Mappins.RemoveTestMappin()
        if success then
            testMarkerStatus = "REMOVED"
        else
            testMarkerStatus = "ERROR"
        end
    end

    ImGui.Text("Test marker status: " .. testMarkerStatus)
    ImGui.Separator()

    local entry = Database.GetById("ma_wat_kab_05")
    if entry and entry.journal_path and entry.journal_path ~= "" then
        if ImGui.Button("Проверить Journal (ma_wat_kab_05)") then
            QuestState.Probe(entry)
        end
    else
        ImGui.Text("Journal probe unavailable: verified journal path not found.")
    end

    ImGui.End()
end

return UI
