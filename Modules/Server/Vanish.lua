-- Modules/Server/Vanish.lua
-- =====================================================
-- VANISH — admin niewidoczny dla innych, widoczny dla siebie.
--
-- ARCHITEKTURA (jedyna niezawodna metoda w Roblox):
--
--   Serwer NIE dotyka Transparency (zbyt wiele efektów ubocznych).
--
--   Zamiast tego:
--   1. Serwer wysyła "VanishShow" do admina
--      → klient admina: LTM = 0 (domyślne, widzi siebie normalnie)
--
--   2. Serwer wysyła "VanishHide" do WSZYSTKICH POZOSTAŁYCH graczy
--      → każdy inny klient: LTM = 1 na częściach admina
--        (LTM=1 przy Transparency=0 → finalAlpha=1 = niewidoczny)
--
--   3. Przy wyłączeniu: serwer wysyła "VanishRestore" do pozostałych
--      → każdy inny klient: LTM = 0 (przywrócona widoczność)
--
--   4. Przy dołączeniu nowego gracza gdy vanish aktywny:
--      → dostaje "VanishHide" dla każdego aktywnego vanish admina
--
-- Dlaczego nie Transparency?
--   - Transparency=1 na BasePart jest widoczne przez SERWER
--     ale Decal/Shirt/Pants nie skalują się z nim tak samo na kliencie
--   - LTM działa tylko kliencko → bezpieczne, brak artefaktów
--   - Przywrócenie jest dokładne (nie tracimy oryginalnych wartości)
-- =====================================================

local Vanish = {}

function Vanish.init(deps)
    local Players     = deps.Players
    local ClientEffect = deps.ClientEffect

    -- [UserId] = bool — czy vanish aktywny
    local vanishActive = {}

    -- Wyślij LTM do wszystkich graczy POZA adminem
    local function fireOthers(admin, action, data)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= admin and not deps.isAdmin(p) then
                ClientEffect:FireClient(p, action, data)
            end
        end
    end

    deps.onAction("SetVanish", function(player, data)
        vanishActive[player.UserId] = data.enabled

        local charName = player.Character and player.Character.Name or player.Name

        if data.enabled then
            -- Admin widzi siebie: LTM=0
            ClientEffect:FireClient(player, "VanishSelf", { enabled = true })

            -- Wszyscy inni bez uprawnień admina: LTM=1 na tej postaci
            fireOthers(player, "VanishHide", { charName = charName })
        else
            -- Admin: przywróć
            ClientEffect:FireClient(player, "VanishSelf", { enabled = false })

            -- Wszyscy inni bez uprawnień admina: LTM=0
            fireOthers(player, "VanishRestore", { charName = charName })
        end
    end)

    -- Nowy gracz dołącza — wyślij mu aktywne vanishe
    Players.PlayerAdded:Connect(function(newPlayer)
        task.wait(1)  -- poczekaj aż klient się załaduje
        if deps.isAdmin(newPlayer) then
            return
        end
        for userId, active in pairs(vanishActive) do
            if active then
                local admin = Players:GetPlayerByUserId(userId)
                if admin and admin ~= newPlayer then
                    local charName = admin.Character and admin.Character.Name or admin.Name
                    ClientEffect:FireClient(newPlayer, "VanishHide", { charName = charName })
                end
            end
        end
    end)

    -- Admin respawnuje — ponownie wyślij VanishHide do innych
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if vanishActive[player.UserId] then
                local charName = char.Name
                -- Przywróć ukrycie nametaga po respawnie
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                    hum.HealthDisplayType   = Enum.HumanoidHealthDisplayType.AlwaysOff
                end
                fireOthers(player, "VanishHide", { charName = charName })
                ClientEffect:FireClient(player, "VanishSelf", { enabled = true })
            end
        end)
    end)

    -- Gracz wychodzi — usuń stan
    Players.PlayerRemoving:Connect(function(player)
        if vanishActive[player.UserId] then
            -- Przywróć widoczność dla innych
            local charName = player.Character and player.Character.Name or player.Name
            fireOthers(player, "VanishRestore", { charName = charName })
        end
        vanishActive[player.UserId] = nil
    end)

    -- Binduj CharacterAdded dla już istniejących graczy
    for _, player in ipairs(Players:GetPlayers()) do
        player.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            if vanishActive[player.UserId] then
                fireOthers(player, "VanishHide", { charName = char.Name })
                ClientEffect:FireClient(player, "VanishSelf", { enabled = true })
            end
        end)
    end
end

return Vanish
