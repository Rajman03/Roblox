-- =====================================================
-- Modules/Tabs/PlayerTab.lua  (ModuleScript → ServerScriptService)
-- Funkcje na innych graczach: teleport, kick, kill.
-- =====================================================

local PlayerTab = {}
PlayerTab.Name  = "Player"

function PlayerTab.build(send, AdminAction, Config, player, extra)
    local Players = game:GetService("Players")

    local function getOthers()
        local t = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then table.insert(t, p.Name) end
        end
        return #t > 0 and t or { "Brak graczy" }
    end

    local others = getOthers()

    -- ── TELEPORT DO GRACZA ─────────────────────────

    -- Dropdown gracza + przycisk w jednym rzędzie
    -- Klient po kliknięciu dropdown od razu teleportuje
    send({ cmd="dropdown", id="TeleportToPlayer",
        name    = "Teleport do gracza",
        options = others,
        current = others[1],
        action  = "TeleportToPlayer",
    })

    -- ── AKCJE NA GRACZU ────────────────────────────

    -- Dropdown wyboru celu — używany przez Kick i Kill
    send({ cmd="dropdown", id="TargetPlayer",
        name    = "Wybierz cel",
        options = others,
        current = others[1],
        action  = "_none",
    })

    send({ cmd="button", id="KickPlayer",
        name           = "Kick gracza",
        action         = "KickPlayer",
        sourceDropdown = "TargetPlayer",
    })

    send({ cmd="button", id="KillPlayer",
        name           = "Kill gracza",
        action         = "KillPlayer",
        sourceDropdown = "TargetPlayer",
    })
end

return PlayerTab
