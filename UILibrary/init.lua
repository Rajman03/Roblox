-- UILibrary/init.lua
-- Punkt wejścia. require(UILibrary) → ten plik.
-- Podmoduły: script.Themes, .Util, .Elements, .Window, .Notification

local Themes = require(script.Themes)
local Win    = require(script.Window)

local currentTheme = Themes.Default

local UI = {}

-- Zmień motyw przed CreateWindow
-- UI.setTheme("Purple")
function UI.setTheme(name)
    currentTheme = Themes[name] or Themes.Default
end

function UI.CreateWindow(cfg)
    return Win.create(cfg, function() return currentTheme end)
end

return UI
