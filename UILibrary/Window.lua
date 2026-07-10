-- UILibrary/Window.lua
-- Okno w stylu Rayfield: lewa kolumna z tabami, prawa z zawartością.
-- Brak cienia (brak artefaktów). Przycisk "X" działa.
-- Hotkey panelu działa globalnie (nie blokuje gameProcessed).

local UIS     = game:GetService("UserInputService")
local Players = game:GetService("Players")
local lp      = Players.LocalPlayer

local W = {}

function W.create(cfg, getT)
    local U     = require(script.Parent.Util)
    local E     = require(script.Parent.Elements)
    local Notif = require(script.Parent.Notification)

    local T = getT()

    -- ── ScreenGui ────────────────────────────────────
    local gui = U.new("ScreenGui", {
        Name = "AdminUI", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true, DisplayOrder = 10,
    }, lp:WaitForChild("PlayerGui"))

    -- Overlay dla dropdownów
    local overlay = U.new("Frame", {
        Name = "Overlay", Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, ZIndex = 300,
    }, gui)

    -- ── Okno główne ─────────────────────────────────
    -- ClipsDescendants=true żeby sidebar nie wychodził poza okno
    local main = U.new("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position    = UDim2.new(0.5, 0, 0.5, 0),
        Size        = UDim2.new(0, 540, 0, 380),
        BackgroundColor3 = T.Bg,
        ClipsDescendants = true,
        ZIndex = 10,
    }, gui)
    U.corner(main, 12)

    -- Obwódka jako osobna ramka NAD main (ClipsDescendants nie obcina dzieci screenGui)
    local borderFrame = U.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position    = UDim2.new(0.5, 0, 0.5, 0),
        Size        = UDim2.new(0, 540, 0, 380),
        BackgroundTransparency = 1,
        ZIndex = 9,
    }, gui)
    U.corner(borderFrame, 12)
    U.stroke(borderFrame, T.Border, 1)

    -- ── Topbar ──────────────────────────────────────
    local topbar = U.new("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = T.Surface, ZIndex = 11,
    }, main)
    U.corner(topbar, 12)
    -- Zakryj dolne zaokrąglenia topbara
    U.new("Frame", {
        Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = T.Surface, BorderSizePixel = 0, ZIndex = 11,
    }, topbar)
    -- Separator poziomy
    U.new("Frame", {
        Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.Border, BorderSizePixel = 0, ZIndex = 12,
    }, topbar)

    -- Lewa sekcja topbara: ikona + tytuł
    local titleArea = U.new("Frame", {
        Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1, ZIndex = 12,
    }, topbar)
    U.hlist(titleArea, 10)

    -- Kolorowa "ikona" — kwadrat z zaokrągleniami
    local iconBox = U.new("Frame", {
        Size = UDim2.new(0, 28, 0, 28), BackgroundColor3 = T.Accent, ZIndex = 13,
    }, titleArea)
    U.corner(iconBox, 7)
    U.new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        Text = "A", TextColor3 = T.White, Font = Enum.Font.GothamBold,
        TextSize = 15, ZIndex = 14,
    }, iconBox)

    U.new("TextLabel", {
        Size = UDim2.new(1, -38, 1, 0), BackgroundTransparency = 1,
        Text = cfg.Name or "Admin Panel",
        TextColor3 = T.Text, Font = Enum.Font.GothamBold, TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
    }, titleArea)

    -- Przycisk X — prawa strona topbara
    local closeBtn = U.new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = T.SurfaceAlt,
        Text = "X", TextColor3 = T.Muted,
        Font = Enum.Font.GothamBold, TextSize = 13,
        AutoButtonColor = false, ZIndex = 13,
    }, topbar)
    U.corner(closeBtn, 7)
    closeBtn.MouseEnter:Connect(function()
        U.tw(closeBtn, { BackgroundColor3 = Color3.fromRGB(200, 45, 45), TextColor3 = getT().White }, 0.1)
    end)
    closeBtn.MouseLeave:Connect(function()
        U.tw(closeBtn, { BackgroundColor3 = getT().SurfaceAlt, TextColor3 = getT().Muted }, 0.1)
    end)

    U.makeDraggable(main, topbar)
    -- Synchronizuj pozycję obwódki z oknem
    main:GetPropertyChangedSignal("Position"):Connect(function()
        borderFrame.Position = main.Position
    end)

    -- ── Lewa kolumna z tabami ────────────────────────
    local sidebar = U.new("ScrollingFrame", {
        Position = UDim2.new(0, 0, 0, 51), Size = UDim2.new(0, 148, 1, -51),
        BackgroundColor3 = T.Surface, BorderSizePixel = 0,
        ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 11,
    }, main)
    U.pad(sidebar, 8, 8, 8, 8)
    U.vlist(sidebar, 3)

    -- Separator pionowy między sidebariem a zawartością
    U.new("Frame", {
        Position = UDim2.new(0, 148, 0, 51), Size = UDim2.new(0, 1, 1, -51),
        BackgroundColor3 = T.Border, BorderSizePixel = 0, ZIndex = 11,
    }, main)

    -- ── Obszar zawartości ────────────────────────────
    local contentArea = U.new("Frame", {
        Position = UDim2.new(0, 149, 0, 51), Size = UDim2.new(1, -149, 1, -51),
        BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 11,
    }, main)

    -- ── Hotkey panelu ────────────────────────────────
    local panelKey = cfg.Hotkey or Enum.KeyCode.RightShift
    local visible  = true

    local toggleBar = U.new("TextButton", {
        Name = "ToggleBar",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 10),
        Size = UDim2.new(0, 190, 0, 44),
        BackgroundColor3 = T.Surface,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 25,
    }, gui)
    U.corner(toggleBar, 18)
    U.stroke(toggleBar, T.Border, 1)

    U.new("Frame", {
        Size = UDim2.new(0, 4, 0, 20),
        Position = UDim2.new(0, 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = T.Accent,
        BorderSizePixel = 0,
        ZIndex = 26,
    }, toggleBar)

    U.new("TextLabel", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 24, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = "☰",
        TextColor3 = T.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        ZIndex = 26,
    }, toggleBar)

    local toggleTextLabel = U.new("TextLabel", {
        Name = "ToggleText",
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 54, 0, 0),
        BackgroundTransparency = 1,
        Text = "Open Admin UI",
        TextColor3 = T.Text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 26,
    }, toggleBar)

    toggleBar.MouseEnter:Connect(function()
        U.tw(toggleBar, { BackgroundColor3 = T.SurfaceAlt }, 0.1)
    end)
    toggleBar.MouseLeave:Connect(function()
        U.tw(toggleBar, { BackgroundColor3 = T.Surface }, 0.1)
    end)

    -- Ustawia widoczność WSZYSTKICH elementów GUI naraz:
    -- main (okno), borderFrame (obwódka), overlay (dla dropdownów)
    local function updateToggleText()
        if toggleTextLabel then
            toggleTextLabel.Text = visible and "Close Admin UI" or "Open Admin UI"
        end
    end

    local function setVisible(v)
        visible = v
        main.Visible = v
        borderFrame.Visible = v
        overlay.Visible = v
        toggleBar.Visible = true
        updateToggleText()
    end

    closeBtn.MouseButton1Click:Connect(function()
        setVisible(false)
    end)

    toggleBar.Activated:Connect(function()
        setVisible(not visible)
    end)
    toggleBar.MouseButton1Click:Connect(function()
        setVisible(not visible)
    end)
    toggleBar.TouchTap:Connect(function()
        setVisible(not visible)
    end)

    setVisible(true)

    UIS.InputBegan:Connect(function(input, _gp)
        -- gp celowo ignorujemy — hotkey działa zawsze
        if input.KeyCode == panelKey then
            setVisible(not visible)
        end
    end)

    -- ── Pomocna funkcja powiadomień dla Elements ─────
    local function sendNotif(title, content, ntype)
        Notif.show(gui, getT(), {
            Title    = title,
            Content  = content,
            Duration = 2,
            Type     = ntype,
        })
    end

    -- ── System zakładek ──────────────────────────────
    local tabs      = {}
    local activeTab = nil

    local function setActive(tabObj)
        if activeTab == tabObj then return end
        if activeTab then
            activeTab.frame.Visible = false
            activeTab.line.Visible  = false
            U.tw(activeTab.btn, { BackgroundColor3 = getT().TabInactive }, 0.12)
            U.tw(activeTab.lbl, { TextColor3 = getT().Muted }, 0.12)
        end
        activeTab = tabObj
        tabObj.frame.Visible = true
        tabObj.line.Visible  = true
        U.tw(tabObj.btn, { BackgroundColor3 = getT().TabActive }, 0.12)
        U.tw(tabObj.lbl, { TextColor3 = getT().Text }, 0.12)
    end

    -- ── Window API ───────────────────────────────────
    local winObj = {}

    function winObj:CreateTab(name)
        local ct = getT()

        -- Przycisk zakładki w sidebarze
        local btn = U.new("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = ct.TabInactive,
            Text = "", AutoButtonColor = false, ZIndex = 12,
        }, sidebar)
        U.corner(btn, 8)

        -- Pionowa linia akcentu (lewa krawędź)
        local line = U.new("Frame", {
            Size = UDim2.new(0, 3, 0.55, 0),
            AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = ct.TabLine, BorderSizePixel = 0,
            Visible = false, ZIndex = 13,
        }, btn)
        U.corner(line, 2)

        local lbl = U.new("TextLabel", {
            Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -14, 1, 0),
            BackgroundTransparency = 1,
            Text = name, TextColor3 = ct.Muted,
            Font = Enum.Font.GothamSemibold, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
        }, btn)

        -- ScrollingFrame zawartości
        local cf = U.new("ScrollingFrame", {
            Name = name .. "_content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3, ScrollBarImageColor3 = ct.Border,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false, ZIndex = 12,
        }, contentArea)
        U.pad(cf, 12, 16, 12, 12)
        U.vlist(cf, 6)

        local tabObj = { btn = btn, lbl = lbl, frame = cf, line = line }
        table.insert(tabs, tabObj)

        btn.MouseButton1Click:Connect(function() setActive(tabObj) end)
        btn.MouseEnter:Connect(function()
            if activeTab ~= tabObj then U.tw(btn, { BackgroundColor3 = getT().SurfaceAlt }, 0.1) end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab ~= tabObj then U.tw(btn, { BackgroundColor3 = getT().TabInactive }, 0.1) end
        end)

        if #tabs == 1 then setActive(tabObj) end

        -- Przekaż sendNotif do Elements → Toggle go używa
        return E.make(cf, getT, sendNotif, overlay)
    end

    -- Publiczne Notify — łatwe API: Window:Notify({Title, Content, Duration, Type})
    function winObj:Notify(ncfg)
        Notif.show(gui, getT(), ncfg)
    end

    function winObj:SetPanelHotkey(key)
        panelKey = key
    end

    return winObj
end

return W
