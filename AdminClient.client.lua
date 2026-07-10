-- =====================================================
-- AdminClient.client.lua  (LocalScript → StarterPlayerScripts)
-- Czysty renderer. Zero logiki gry.
-- Odbiera BuildUI od serwera → rysuje GUI.
-- Gracz bez uprawnień: script:Destroy() natychmiast.
-- =====================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local UIS               = game:GetService("UserInputService")
local lp                = Players.LocalPlayer

local R = ReplicatedStorage:WaitForChild("AdminRemotes", 15)
if not R then script:Destroy(); return end

local CheckAdmin       = R:WaitForChild("CheckAdmin",       15)
local BuildUI          = R:WaitForChild("BuildUI",          15)
local AdminAction      = R:WaitForChild("AdminAction",      15)
local UpdatePlayerList = R:WaitForChild("UpdatePlayerList", 15)
if not (CheckAdmin and BuildUI and AdminAction and UpdatePlayerList) then
    script:Destroy(); return
end

-- ── Weryfikacja ───────────────────────────────────────
if not CheckAdmin:InvokeServer() then
    script:Destroy(); return
end

local Config    = require(ReplicatedStorage:WaitForChild("Config",    10))
local UILibrary = require(ReplicatedStorage:WaitForChild("UILibrary", 10))

-- ── Stan renderera ────────────────────────────────────
local Window     = nil
local currentTab = nil
local toggleRefs = {}   -- [id] = ref z :Toggle()/:Set()
local dropdowns  = {}   -- [id] = ref z :GetCurrent()/:Refresh()
local Window_ref = nil  -- żeby SetPanelHotkey był dostępny

-- ── FLY: jedyna logika klienta ────────────────────────
local flyConn = nil

local function startFlyLoop()
    if flyConn then return end
    local cam = workspace.CurrentCamera
    flyConn = game:GetService("RunService").RenderStepped:Connect(function()
        local d = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then d += cam.CFrame.LookVector  end
        if UIS:IsKeyDown(Enum.KeyCode.S) then d -= cam.CFrame.LookVector  end
        if UIS:IsKeyDown(Enum.KeyCode.A) then d -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then d += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)       then d += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d -= Vector3.new(0,1,0) end
        AdminAction:FireServer("UpdateFlyVelocity", {
            velocity = d.Magnitude > 0 and d.Unit * Config.FlySpeed or Vector3.zero,
            cframe   = cam.CFrame,
        })
    end)
end

local function stopFlyLoop()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
end

-- ── CLICK TO TELEPORT ─────────────────────────────────
-- Zarządzany lokalnie — raycast wymaga kamery klienta
local clickActive = false
local clickConn   = nil

local function setClickTeleport(enabled)
    clickActive = enabled
    if enabled then
        clickConn = UIS.InputBegan:Connect(function(input, gp)
            if gp or not clickActive then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            local cam    = workspace.CurrentCamera
            local ray    = cam:ScreenPointToRay(input.Position.X, input.Position.Y)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            local char = lp.Character
            if char then params.FilterDescendantsInstances = { char } end
            local res = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
            if res then
                AdminAction:FireServer("TeleportToPosition", { position = res.Position })
            end
        end)
    else
        if clickConn then clickConn:Disconnect(); clickConn = nil end
    end
end

-- ── ODBIORNIK BUILDDUI ────────────────────────────────
BuildUI.OnClientEvent:Connect(function(instr)
    local cmd = instr.cmd

    -- init: stwórz okno
    if cmd == "init" then
        -- Zniszcz stare GUI — pełne przebudowanie (np. przy zmianie motywu)
        local oldGui = lp.PlayerGui:FindFirstChild("AdminUI")
        if oldGui then oldGui:Destroy() end
        -- Resetuj stany rendererowania
        stopFlyLoop()
        setClickTeleport(false)

        UILibrary.setTheme(instr.theme or "Default")
        local hotkeyEnum = Enum.KeyCode[instr.hotkey] or Enum.KeyCode.RightShift

        Window = UILibrary.CreateWindow({
            Name   = instr.name or "Admin Panel",
            Hotkey = hotkeyEnum,
        })
        Window_ref  = Window
        toggleRefs  = {}
        dropdowns   = {}
        currentTab  = nil

    -- tab: nowa zakładka
    elseif cmd == "tab" and Window then
        currentTab = Window:CreateTab(instr.name)

    -- section
    elseif cmd == "section" and currentTab then
        currentTab:CreateSection(instr.name)

    -- toggle
    elseif cmd == "toggle" and currentTab then
        local id = instr.id
        local ref = currentTab:CreateToggle({
            Name         = instr.name,
            CurrentValue = instr.value or false,
            Callback     = function(on)
                AdminAction:FireServer(instr.action or id, { enabled = on })
                if id == "Fly" then
                    if on then startFlyLoop() else stopFlyLoop() end
                end
                -- Click to Teleport obsługiwany lokalnie
                if id == "ClickTeleport" then
                    setClickTeleport(on)
                end
            end,
        })
        if id then toggleRefs[id] = ref end

        -- Jeśli toggle odtworzony jako włączony — uruchom efekty lokalne
        if instr.value == true then
            if id == "Fly"           then startFlyLoop()         end
            if id == "ClickTeleport" then setClickTeleport(true)  end
        end

    -- slider
    elseif cmd == "slider" and currentTab then
        currentTab:CreateSlider({
            Name         = instr.name,
            Range        = { instr.min, instr.max },
            Increment    = instr.inc or 1,
            Suffix       = instr.suffix or "",
            CurrentValue = instr.value or instr.min,
            Callback     = function(v)
                AdminAction:FireServer(instr.action or instr.id, { value = v })
            end,
        })

    -- dropdown
    elseif cmd == "dropdown" and currentTab then
        local id  = instr.id
        local ref = currentTab:CreateDropdown({
            Name          = instr.name,
            Options       = instr.options or {},
            CurrentOption = instr.current or (instr.options and instr.options[1]) or "",
            Callback      = function(opt)
                -- Nie wysyłaj jeśli dropdown jest tylko źródłem dla buttonów
                if instr.action and instr.action ~= "_none" then
                    AdminAction:FireServer(instr.action, { targetName = opt, option = opt })
                end
            end,
        })
        if id then dropdowns[id] = ref end

    -- button
    elseif cmd == "button" and currentTab then
        local id = instr.id
        currentTab:CreateButton({
            Name     = instr.name,
            Callback = function()
                local targetOpt = nil
                -- Jeśli przycisk czyta z dropdownu (np. Kick/Kill)
                if instr.sourceDropdown and dropdowns[instr.sourceDropdown] then
                    targetOpt = dropdowns[instr.sourceDropdown]:GetCurrent()
                end
                AdminAction:FireServer(instr.action or id, { targetName = targetOpt })
            end,
        })

    -- keybind
    -- NAPRAWIONE: Callback(newKey) aktualizuje klucz w runtime
    -- OnPress woła toggleRefs[toggleId]:Toggle() jeśli podano toggleId
    elseif cmd == "keybind" and currentTab then
        local id       = instr.id
        local toggleId = instr.toggleId
        local initKey  = Enum.KeyCode[instr.key] or Enum.KeyCode.Unknown

        currentTab:CreateKeybind({
            Name       = instr.name,
            CurrentKey = initKey,

            -- Wciśnięcie przypisanego klawisza
            OnPress = function()
                if toggleId and toggleRefs[toggleId] then
                    -- Odwróć stan powiązanego toggle'a
                    toggleRefs[toggleId]:Toggle()
                else
                    AdminAction:FireServer(instr.action or id, {})
                end
            end,

            -- Callback po zmianie klawisza przez gracza
            -- Jeśli id == "PanelToggle" — zmień hotkey panelu
            Callback = function(newKey)
                if id == "PanelToggle" and Window_ref then
                    Window_ref:SetPanelHotkey(newKey)
                end
                -- Możesz tu dodać wysyłanie do serwera jeśli potrzeba
            end,
        })

    -- done: koniec budowania
    elseif cmd == "done" and Window then
        Window:Notify({
            Title    = "Admin Panel",
            Content  = instr.msg or "Panel załadowany.",
            Duration = 5,
        })
    end
end)

-- ── Odświeżanie dropdownu graczy ─────────────────────
UpdatePlayerList.OnClientEvent:Connect(function(names)
    local filtered = {}
    for _, n in ipairs(names) do
        if n ~= lp.Name then table.insert(filtered, n) end
    end
    local list = #filtered > 0 and filtered or { "Brak graczy" }
    for _, id in ipairs({ "TeleportToPlayer", "TargetPlayer" }) do
        if dropdowns[id] then
            dropdowns[id]:Refresh(list, true)
        end
    end
end)
