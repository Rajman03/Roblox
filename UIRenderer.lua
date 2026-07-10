-- UIRenderer.lua
-- Modul renderujący GUI admina. Nie zawiera logiki gry.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local UIS               = game:GetService("UserInputService")
local lp                = Players.LocalPlayer

local UIRenderer = {}

function UIRenderer.init()
    local R = ReplicatedStorage:WaitForChild("AdminRemotes", 15)
    if not R then return end

    local BuildUI          = R:WaitForChild("BuildUI", 15)
    local AdminAction      = R:WaitForChild("AdminAction", 15)
    local UpdatePlayerList = R:WaitForChild("UpdatePlayerList", 15)
    if not (BuildUI and AdminAction and UpdatePlayerList) then
        return
    end

    local Config    = require(ReplicatedStorage:WaitForChild("Config", 10))
    local UILibrary = require(ReplicatedStorage:WaitForChild("UILibrary", 10))

    local Window     = nil
    local currentTab = nil
    local toggleRefs = {}
    local dropdowns  = {}
    local Window_ref = nil

    local flyConn = nil
    local clickActive = false
    local clickConn   = nil

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

    local function setClickTeleport(enabled)
        clickActive = enabled
        if enabled then
            if clickConn then return end
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

    BuildUI.OnClientEvent:Connect(function(instr)
        local cmd = instr.cmd

        if cmd == "init" then
            local oldGui = lp.PlayerGui:FindFirstChild("AdminUI")
            if oldGui then oldGui:Destroy() end
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

        elseif cmd == "tab" and Window then
            currentTab = Window:CreateTab(instr.name)

        elseif cmd == "section" and currentTab then
            currentTab:CreateSection(instr.name)

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
                    if id == "ClickTeleport" then
                        setClickTeleport(on)
                    end
                end,
            })
            if id then toggleRefs[id] = ref end

            if instr.value == true then
                if id == "Fly"           then startFlyLoop()         end
                if id == "ClickTeleport" then setClickTeleport(true)  end
            end

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

        elseif cmd == "dropdown" and currentTab then
            local id  = instr.id
            local ref = currentTab:CreateDropdown({
                Name          = instr.name,
                Options       = instr.options or {},
                CurrentOption = instr.current or (instr.options and instr.options[1]) or "",
                Callback      = function(opt)
                    if instr.action and instr.action ~= "_none" then
                        AdminAction:FireServer(instr.action, { targetName = opt, option = opt })
                    end
                end,
            })
            if id then dropdowns[id] = ref end

        elseif cmd == "button" and currentTab then
            local id = instr.id
            currentTab:CreateButton({
                Name     = instr.name,
                Callback = function()
                    local targetOpt = nil
                    if instr.sourceDropdown and dropdowns[instr.sourceDropdown] then
                        targetOpt = dropdowns[instr.sourceDropdown]:GetCurrent()
                    end
                    AdminAction:FireServer(instr.action or id, { targetName = targetOpt })
                end,
            })

        elseif cmd == "keybind" and currentTab then
            local id       = instr.id
            local toggleId = instr.toggleId
            local initKey  = Enum.KeyCode[instr.key] or Enum.KeyCode.Unknown

            currentTab:CreateKeybind({
                Name       = instr.name,
                CurrentKey = initKey,
                OnPress = function()
                    if toggleId and toggleRefs[toggleId] then
                        toggleRefs[toggleId]:Toggle()
                    else
                        AdminAction:FireServer(instr.action or id, {})
                    end
                end,
                Callback = function(newKey)
                    if id == "PanelToggle" and Window_ref then
                        Window_ref:SetPanelHotkey(newKey)
                    end
                end,
            })

        elseif cmd == "done" and Window then
            Window:Notify({
                Title    = "Admin Panel",
                Content  = instr.msg or "Panel załadowany.",
                Duration = 5,
            })
        end
    end)

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
end

return UIRenderer
