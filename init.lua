-- Force Alt-Tab (Cmd+Tab) to always unhide apps on macOS
-- https://github.com/burtond/force-alt-tab
--
-- Problem: On macOS, Cmd+Tab to a hidden app doesn't always bring it forward.
-- You have to press Cmd+Option while releasing Tab, or click the dock icon.
--
-- Solution: This script watches for app activation and automatically unhides
-- the app and raises all its windows.

require("hs.ipc")

local unhideTimer = nil

local appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
    if eventType == hs.application.watcher.activated then
        -- Small delay to let the switch complete
        if unhideTimer then unhideTimer:stop() end
        unhideTimer = hs.timer.doAfter(0.05, function()
            local app = hs.application.frontmostApplication()
            if app then
                app:unhide()
                -- Raise all windows to bring them forward
                local wins = app:allWindows()
                for _, win in ipairs(wins) do
                    win:raise()
                end
            end
        end)
    end
end)
appWatcher:start()

-- Restart appWatcher after wake from sleep (in case it stops)
local sleepWatcher = hs.caffeinate.watcher.new(function(event)
    if event == hs.caffeinate.watcher.systemDidWake then
        appWatcher:stop()
        appWatcher:start()
    end
end)
sleepWatcher:start()
