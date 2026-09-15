local Logger = require("modules/logger")
local Tracker = require("modules/tracker")
local QuestState = require("modules/quest_state")
local Mappins = require("modules/mappins")

local UI = {}
UI.isOpen = false

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
    ImGui.Text("Показать:")

    Tracker.filters.assault = ImGui.Checkbox("Нападения", Tracker.filters.assault)
    Tracker.filters.organized = ImGui.Checkbox("Организованная преступность", Tracker.filters.organized)
    Tracker.filters.reported = ImGui.Checkbox("Заявленные преступления", Tracker.filters.reported)

    ImGui.Separator()
    if ImGui.Button("Обновить метки") then
        Tracker.Update()
    end

    ImGui.Separator()
    ImGui.Text("NCPD DEBUG")
    if ImGui.Button("Тестовая метка возле игрока") then
        Mappins.CreateTestMappin()
    end
    if ImGui.Button("Удалить тестовую метку") then
        Mappins.RemoveTestMappin()
    end
    if ImGui.Button("Проверить Journal (ma_wat_kab_05)") then
        -- This requires exact journal path to work. Passing nil to show the probe failing gracefully.
        QuestState.Probe("ma_wat_kab_05", nil)
    end

    ImGui.End()
end

return UI
