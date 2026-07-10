-- =====================================================
-- Modules/Server/Movement.lua  (ModuleScript)
-- POPRAWKA: UseJumpPower=true przed ustawieniem JumpPower
-- =====================================================

local Movement = {}

function Movement.init(deps)
    local Config = deps.Config

    local function getHumanoid(player)
        local char = player.Character
        return char and char:FindFirstChildOfClass("Humanoid")
    end

    -- Włącz UseJumpPower dla każdego gracza (nowe gry mają go wyłączone)
    local function ensureJumpPowerMode(player)
        local function apply(char)
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.UseJumpPower = true end
        end
        apply(player.Character)
        player.CharacterAdded:Connect(apply)
    end

    for _, p in ipairs(deps.Players:GetPlayers()) do ensureJumpPowerMode(p) end
    deps.Players.PlayerAdded:Connect(ensureJumpPowerMode)

    deps.onAction("SetWalkSpeed", function(player, data)
        local speed = math.clamp(
            tonumber(data.value) or Config.MinWalkSpeed,
            Config.MinWalkSpeed, Config.MaxWalkSpeed
        )
        local hum = getHumanoid(player)
        if hum then hum.WalkSpeed = speed end
    end)

    deps.onAction("SetJumpPower", function(player, data)
        local power = math.clamp(
            tonumber(data.value) or Config.MinJumpPower,
            Config.MinJumpPower, Config.MaxJumpPower
        )
        local hum = getHumanoid(player)
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = power
        end
    end)
end

return Movement
