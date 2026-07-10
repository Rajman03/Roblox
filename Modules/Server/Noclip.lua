-- =====================================================
-- Modules/Server/Noclip.lua  (ModuleScript)
-- Serwer tylko zapisuje stan i wysyła ClientEffect.
-- Rzeczywisty efekt CanCollide=false działa w ClientEffects.lua
-- =====================================================

local Noclip = {}

function Noclip.init(deps)
    local noclipStates = {}

    deps.onAction("SetNoclip", function(player, data)
        noclipStates[player.UserId] = data.enabled
        -- Przywróć kolizje po stronie serwera gdy wyłączone
        if not data.enabled then
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end)

    deps.Players.PlayerRemoving:Connect(function(player)
        noclipStates[player.UserId] = nil
    end)
end

return Noclip
