local Logger = require("modules/logger")
local Tracker = require("modules/tracker")

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
    ImGui.Text("По районам:")
    for dist, data in pairs(Tracker.stats.districts) do
        ImGui.Text(dist .. ": " .. tostring(data.completed) .. " / " .. tostring(data.total) .. " (Осталось: " .. tostring(data.remaining) .. ", Неизвестно: " .. tostring(data.unknown) .. ")")
    end

    ImGui.Separator()
    ImGui.Text("Показать:")

    Tracker.filters.assault = ImGui.Checkbox("Нападения", Tracker.filters.assault)
    Tracker.filters.organized = ImGui.Checkbox("Организованная преступность", Tracker.filters.organized)
    Tracker.filters.reported = ImGui.Checkbox("Заявленные преступления", Tracker.filters.reported)

    ImGui.Separator()
    ImGui.Text("Районы:")
    Tracker.filters.district_Watson = ImGui.Checkbox("Уотсон", Tracker.filters.district_Watson)
    Tracker.filters.district_Westbrook = ImGui.Checkbox("Уэстбрук", Tracker.filters.district_Westbrook)

    ImGui.Separator()
    if ImGui.Button("Обновить метки") then
        Tracker.Update()
    end

    ImGui.End()
end

return UI
