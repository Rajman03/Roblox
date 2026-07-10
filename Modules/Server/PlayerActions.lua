-- =====================================================
-- Modules/Server/PlayerActions.lua  (ModuleScript)
-- Akcje na innych graczach: Kick, Kill
-- =====================================================

local PlayerActions = {}

function PlayerActions.init(deps)
    local Players = deps.Players

    deps.onAction("KickPlayer", function(player, data)
        local target = Players:FindFirstChild(tostring(data.targetName))
        if not target or target == player then return end
        target:Kick("Zostałeś wyrzucony przez admina: " .. player.Name)
    end)

    deps.onAction("KillPlayer", function(player, data)
        local target = Players:FindFirstChild(tostring(data.targetName))
        if not target or target == player then return end
        local char = target.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end)
end

return PlayerActions
