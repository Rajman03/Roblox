-- UILibrary/Notification.lua
-- Prosta, łatwa w modyfikacji biblioteka powiadomień.
--
-- UŻYCIE:
--   local N = require(script.Parent.Notification)
--   N.show(screenGui, T, {
--       Title    = "Włączono",    -- nagłówek (string)
--       Content  = "God Mode",   -- treść (string)
--       Duration = 3,             -- czas w sekundach (number, opcjonalne, domyślnie 3)
--       Type     = "success",     -- "success" | "error" | "info" | "warning" (opcjonalne)
--   })
--
-- Type zmienia kolor paska bocznego:
--   success  → zielony
--   error    → czerwony
--   warning  → pomarańczowy
--   info     → kolor Accent z motywu (domyślny)

local TweenService = game:GetService("TweenService")

local TYPE_COLORS = {
    success = Color3.fromRGB(34,  197, 94),
    error   = Color3.fromRGB(239,  68, 68),
    warning = Color3.fromRGB(234, 179,  8),
    info    = nil,  -- użyje T.Accent
}

local N = {}

-- Jeden holder na całe screenGui
local holders = {}  -- [screenGui] = Frame

local function getHolder(screenGui)
    if holders[screenGui] and holders[screenGui].Parent then
        return holders[screenGui]
    end
    local U = require(script.Parent.Util)
    local h = U.new("Frame", {
        Name        = "NotifHolder",
        AnchorPoint = Vector2.new(1, 1),
        Position    = UDim2.new(1, -18, 1, -18),
        Size        = UDim2.new(0, 290, 1, -36),
        BackgroundTransparency = 1,
        ZIndex      = 600,
    }, screenGui)
    local l = U.vlist(h, 8)
    l.VerticalAlignment = Enum.VerticalAlignment.Bottom
    holders[screenGui] = h
    return h
end

function N.show(screenGui, T, cfg)
    local U    = require(script.Parent.Util)
    local dur  = cfg.Duration or 3
    local bar  = TYPE_COLORS[cfg.Type or "info"] or T.Accent

    local holder = getHolder(screenGui)

    -- Karta powiadomienia
    local card = U.new("Frame", {
        Size             = UDim2.new(1, 0, 0, 0),   -- zaczyna od 0 → animacja wjazdu
        BackgroundColor3 = T.Surface,
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex           = 600,
    }, holder)
    U.corner(card, 10)
    U.stroke(card, T.Border)

    local inner = U.new("Frame", {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundTransparency = 1,
        ZIndex = 601,
    }, card)

    -- Kolorowy pasek boczny
    local accent = U.new("Frame", {
        Size             = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = bar,
        BorderSizePixel  = 0,
        ZIndex           = 602,
    }, inner)
    U.corner(accent, 2)

    -- Teksty
    local textArea = U.new("Frame", {
        Position = UDim2.new(0, 12, 0, 0),
        Size     = UDim2.new(1, -12, 1, 0),
        BackgroundTransparency = 1,
        ZIndex   = 602,
    }, inner)
    U.pad(textArea, 10, 10, 0, 8)

    local titleLbl = U.new("TextLabel", {
        Size           = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text           = cfg.Title or "",
        TextColor3     = T.Text,
        Font           = Enum.Font.GothamBold,
        TextSize       = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex         = 603,
    }, textArea)

    U.new("TextLabel", {
        Position       = UDim2.new(0, 0, 0, 22),
        Size           = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text           = cfg.Content or "",
        TextColor3     = T.TextSub,
        Font           = Enum.Font.Gotham,
        TextSize       = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped    = true,
        ZIndex         = 603,
    }, textArea)

    -- Pasek postępu (na dole karty)
    local progressBg = U.new("Frame", {
        AnchorPoint      = Vector2.new(0, 1),
        Position         = UDim2.new(0, 0, 1, 0),
        Size             = UDim2.new(1, 0, 0, 3),
        BackgroundColor3 = T.Border,
        BorderSizePixel  = 0,
        ZIndex           = 602,
    }, inner)
    local progressBar = U.new("Frame", {
        Size             = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = bar,
        BorderSizePixel  = 0,
        ZIndex           = 603,
    }, progressBg)

    -- Wjazd
    TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundTransparency = 0,
    }):Play()

    -- Odliczanie paska
    TweenService:Create(progressBar, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0),
    }):Play()

    -- Wyjazd
    task.delay(dur, function()
        if not card.Parent then return end
        TweenService:Create(card, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1,
        }):Play()
        TweenService:Create(titleLbl, TweenInfo.new(0.2), { TextTransparency = 1 }):Play()
        task.wait(0.22)
        TweenService:Create(card, TweenInfo.new(0.16, Enum.EasingStyle.Quad), {
            Size = UDim2.new(1, 0, 0, 0),
        }):Play()
        task.wait(0.18)
        pcall(function() card:Destroy() end)
    end)
end

return N
