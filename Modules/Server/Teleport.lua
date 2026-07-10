-- =====================================================
-- Modules/Server/Teleport.lua  (ModuleScript)
-- Obsługa teleportacji po stronie serwera.
-- Rejestruje akcje: TeleportToPlayer, TeleportToPosition
-- =====================================================

local Teleport = {}

function Teleport.init(deps)
    local Players = deps.Players

    -- Teleport do innego gracza
    deps.onAction("TeleportToPlayer", function(player, data)
        local targetName = tostring(data.targetName)
        local target = Players:FindFirstChild(targetName)
        if not target or target == player then return end

        local targetChar = target.Character
        local myChar     = player.Character
        if not targetChar or not myChar then return end

        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
        local myHRP     = myChar:FindFirstChild("HumanoidRootPart")
        if targetHRP and myHRP then
            -- Teleportuj lekko za cel
            myHRP.CFrame = targetHRP.CFrame + targetHRP.CFrame.LookVector * 3
        end
    end)

    -- Teleport w kliknięte miejsce (raycast po stronie klienta → Vector3 tu)
    deps.onAction("TeleportToPosition", function(player, data)
        if typeof(data.position) ~= "Vector3" then return end
        local myChar = player.Character
        local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHRP then
            myHRP.CFrame = CFrame.new(data.position + Vector3.new(0, 3, 0))
        end
    end)
end

return Teleport
