-- =====================================================
-- Modules/Server/InfiniteJump.lua  (ModuleScript)
-- HumanoidStateType jest client-authoritative w Roblox —
-- serwer nie może wymusić skoku. Stan jest tylko zapisywany
-- tutaj; rzeczywisty efekt działa w ClientEffects.lua.
-- =====================================================

local InfiniteJump = {}

function InfiniteJump.init(deps)
    -- Serwer tylko loguje stan (może być użyty do logowania/antycheat)
    local jumpStates = {}

    deps.onAction("SetInfiniteJump", function(player, data)
        jumpStates[player.UserId] = data.enabled
    end)

    deps.Players.PlayerRemoving:Connect(function(player)
        jumpStates[player.UserId] = nil
    end)
end

return InfiniteJump
