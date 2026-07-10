-- Modules/Tabs/SettingsTab.lua  (ServerScriptService)

local SettingsTab = {}
SettingsTab.Name  = "Settings"

function SettingsTab.build(send, AdminAction, Config, player, extra)
    local st = extra and extra.state or {}

    -- ── MOTYW ──────────────────────────────────────
    send({ cmd="section", name="Wygląd" })

    -- Aktualny motyw z playerTheme (przekazany przez serwer w extra.currentTheme)
    local currentTheme = (extra and extra.currentTheme) or Config.Theme or "Default"
    send({ cmd="dropdown", id="ThemeSelect",
        name    = "Motyw",
        options = { "Default", "Purple" },
        current = currentTheme,
        action  = "SetTheme",
    })

    -- ── PANEL ──────────────────────────────────────
    send({ cmd="section", name="Panel" })
    send({ cmd="keybind", id="PanelToggle",
        name = "Pokaż / Ukryj panel",
        key  = (Config.HotkeyToggle or Enum.KeyCode.RightShift).Name,
    })
end

return SettingsTab
