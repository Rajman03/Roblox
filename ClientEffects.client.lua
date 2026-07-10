-- ClientEffects.client.lua  (LocalScript → StarterPlayerScripts)
-- Efekty wymagające LocalScript: Noclip, InfiniteJump, WalkSpeed, JumpPower, Vanish.
--
-- VANISH — nowy mechanizm:
--   VanishSelf   → admin: nic (widzi siebie normalnie, LTM domyślnie 0)
--   VanishHide   → inni: ustaw LTM=1 na częściach postaci admina
--   VanishRestore→ inni: przywróć LTM=0 na częściach postaci admina

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UIS               = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp                = Players.LocalPlayer

local R = ReplicatedStorage:WaitForChild("AdminRemotes", 15)
if not R then return end

local CheckAdmin   = R:WaitForChild("CheckAdmin",   15)
local ClientEffect = R:WaitForChild("ClientEffect", 15)
if not CheckAdmin or not ClientEffect then return end

-- ClientEffects ładuje się dla WSZYSTKICH graczy (nie tylko adminów)
-- bo musi obsługiwać VanishHide/VanishRestore wysyłane przez serwer.
local isAdmin = CheckAdmin:InvokeServer()

local State = {
    noclip       = false,
    infiniteJump = false,
    walkSpeed    = nil,
    jumpPower    = nil,
}

-- [charName] = { [BasePart] = true } — części ukryte przez VanishHide
local hiddenChars = {}

local function getChar() return lp.Character end
local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function reapplyPlayerState(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if State.walkSpeed ~= nil then
            hum.WalkSpeed = State.walkSpeed
        end
        if State.jumpPower ~= nil then
            hum.UseJumpPower = true
            hum.JumpPower = State.jumpPower
        end
    end
    if State.noclip then
        for _, part in ipairs(collectParts(char)) do
            part.CanCollide = false
        end
    end
end

-- Zbiera wszystkie BasePart postaci (bez HumanoidRootPart który nie ma siatki)
local function collectParts(char)
    local parts = {}
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
            table.insert(parts, d)
        end
    end
    return parts
end

-- ── ODBIERANIE ZDARZEŃ ────────────────────────────────
ClientEffect.OnClientEvent:Connect(function(action, data)
    data = data or {}

    -- ── Efekty tylko dla adminów ──────────────────
    if action == "SetNoclip" then
        if not isAdmin then return end
        State.noclip = data.enabled
        if not data.enabled then
            local c = getChar()
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = true end
                end
            end
        end

    elseif action == "SetInfiniteJump" then
        if not isAdmin then return end
        State.infiniteJump = data.enabled

    elseif action == "SetWalkSpeed" then
        if not isAdmin then return end
        State.walkSpeed = data.value

    elseif action == "SetJumpPower" then
        if not isAdmin then return end
        State.jumpPower = data.value

    -- ── VANISH: admin widzi siebie, ale jego nametag jest ukryty ───
    -- VanishSelf wysyłany tylko do admina.
    elseif action == "VanishSelf" then
        if not isAdmin then return end
        -- Ukryj/przywróć własny PlayerName tag (widoczny dla innych przez CoreGui)
        local StarterGui = game:GetService("StarterGui")
        local ok, _ = pcall(function()
            -- Keeping PlayerList visibility unchanged.
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
        end)
        local c = getChar()
        if not c then return end
        -- LTM=0: admin widzi siebie normalnie
        for _, p in ipairs(collectParts(c)) do
            p.LocalTransparencyModifier = 0
        end
        -- Ukryj/pokaż nametag nad własną głową
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.DisplayDistanceType = data.enabled
                and Enum.HumanoidDisplayDistanceType.None
                or  Enum.HumanoidDisplayDistanceType.Subject
        end

    -- ── VANISH: ukryj admina dla innych graczy ────
    -- Serwer wysyła VanishHide do wszystkich pozostałych graczy.
    -- LTM=1 przy Transparency=0 → finalAlpha = clamp(0+1,0,1) = 1 = niewidoczny.
    elseif action == "VanishHide" then
        local charName = data.charName
        if not charName then return end

        -- Znajdź postać admina w Workspace
        local adminChar = workspace:FindFirstChild(charName)
        if not adminChar then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character.Name == charName then
                    adminChar = p.Character; break
                end
            end
        end
        if not adminChar then return end

        hiddenChars[charName] = {}
        for _, part in ipairs(collectParts(adminChar)) do
            hiddenChars[charName][part] = true
            part.LocalTransparencyModifier = 1
        end

        -- Ukryj billboardy nad głową admina
        for _, obj in ipairs(adminChar:GetDescendants()) do
            if obj:IsA("BillboardGui") then
                obj.Enabled = false
            end
        end

    -- ── VANISH: przywróć widoczność admina ────────
    elseif action == "VanishRestore" then
        local charName = data.charName
        if not charName then return end

        local tracked = hiddenChars[charName]
        if tracked then
            for part, _ in pairs(tracked) do
                if part and part.Parent then
                    part.LocalTransparencyModifier = 0
                end
            end
            hiddenChars[charName] = nil
        end

        -- Przywróć BillboardGui
        local adminChar = workspace:FindFirstChild(charName)
        if adminChar then
            for _, obj in ipairs(adminChar:GetDescendants()) do
                if obj:IsA("BillboardGui") then
                    obj.Enabled = true
                end
            end
        end
    end
end)

-- ── NOCLIP ────────────────────────────────────────────
RunService.Heartbeat:Connect(function()
    if not State.noclip then return end
    local c = getChar(); if not c then return end
    for _, p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- ── INFINITE JUMP ─────────────────────────────────────
UIS.JumpRequest:Connect(function()
    if not State.infiniteJump then return end
    local h = getHum(); if not h then return end
    local s = h:GetState()
    if s == Enum.HumanoidStateType.Freefall or s == Enum.HumanoidStateType.Jumping then
        h:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ── WALKSPEED / JUMPPOWER ─────────────────────────────
RunService.Heartbeat:Connect(function()
    if not isAdmin then return end
    local h = getHum(); if not h then return end
    if State.walkSpeed ~= nil and h.WalkSpeed ~= State.walkSpeed then
        h.WalkSpeed = State.walkSpeed
    end
    if State.jumpPower ~= nil and h.JumpPower ~= State.jumpPower then
        h.UseJumpPower = true
        h.JumpPower    = State.jumpPower
    end
end)

-- ── VANISH: wymuszaj LTM=1 co klatkę dla ukrytych postaci ──
-- Roblox może resetować LTM przy animacjach/zmianie stanu.
RunService.Heartbeat:Connect(function()
    for charName, parts in pairs(hiddenChars) do
        for part, _ in pairs(parts) do
            if part and part.Parent then
                if part.LocalTransparencyModifier ~= 1 then
                    part.LocalTransparencyModifier = 1
                end
            else
                parts[part] = nil
            end
        end
    end
end)

lp.CharacterAdded:Connect(function(char)
    reapplyPlayerState(char)
end)

if lp.Character then
    reapplyPlayerState(lp.Character)
end
