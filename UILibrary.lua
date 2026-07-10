-- =====================================================
-- UILibrary.lua  (ModuleScript → ReplicatedStorage)
-- Główny punkt wejścia. Deleguje do podmodułów w UILibrary/:
--
--   Themes.lua       — kolory (edytuj żeby zmienić motyw)
--   Util.lua         — helpers (new, tw, corner…)
--   Elements.lua     — Section, Toggle, Slider, Dropdown,
--                       Button, Input, Keybind
--   Window.lua       — okno, topbar, zakładki, hotkey
--   Notification.lua — powiadomienia
--
-- API:
--   UI.setTheme("Default" | "Purple")
--   UI.CreateWindow({ Name, Hotkey }) → Window
--   Window:CreateTab(name)            → Tab
--   Window:Notify({ Title, Content, Duration })
--   Window:SetPanelHotkey(Enum.KeyCode.X)
--   Tab:CreateSection / CreateToggle / CreateSlider /
--       CreateDropdown / CreateButton / CreateInput /
--       CreateKeybind
-- =====================================================

local Themes = require(script:WaitForChild("UILibrary"):WaitForChild("Themes"))
local Win    = require(script:WaitForChild("UILibrary"):WaitForChild("Window"))

local currentTheme = Themes.Default

local function getT()
    return currentTheme
end

local UI = {}

function UI.setTheme(name)
    currentTheme = Themes[name] or Themes.Default
end

function UI.CreateWindow(cfg)
    return Win.create(cfg, getT)
end

return UI
