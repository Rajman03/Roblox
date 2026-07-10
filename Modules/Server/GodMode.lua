-- =====================================================
-- Modules/Server/GodMode.lua  (ModuleScript)
-- Obsługa nieśmiertelności po stronie serwera.
-- Rejestruje akcję: SetGodMode
-- =====================================================

local GodMode = {}

function GodMode.init(deps)
    local godStates   = {}  -- [UserId] = bool
    local godConns    = {}  -- [UserId] = RBXScriptConnection

    local function getHumanoid(player)
        local char = player.Character
        return char and char:FindFirstChildOfClass("Humanoid")
    end

    local function startGod(player)
        if godConns[player.UserId] then return end
        local hum = getHumanoid(player)
        if not hum then return end
        hum.MaxHealth = math.huge
        hum.Health    = math.huge
        -- Przywracaj HP przy każdym uszkodzeniu
        godConns[player.UserId] = hum.HealthChanged:Connect(function()
            if godStates[player.UserId] then
                hum.Health = math.huge
            end
        end)
    end

    local function stopGod(player)
        godStates[player.UserId] = false
        if godConns[player.UserId] then
            godConns[player.UserId]:Disconnect()
            godConns[player.UserId] = nil
        end
        local hum = getHumanoid(player)
        if hum then
            hum.MaxHealth = 100
            hum.Health    = 100
        end
    end

    deps.onAction("SetGodMode", function(player, data)
        godStates[player.UserId] = data.enabled
        if data.enabled then
            startGod(player)
        else
            stopGod(player)
        end
    end)

    deps.Players.PlayerRemoving:Connect(function(player)
        stopGod(player)
        godStates[player.UserId] = nil
    end)
end

return GodMode
