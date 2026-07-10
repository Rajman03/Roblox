-- =====================================================
-- Modules/Server/Fly.lua  (ModuleScript)
-- Obsługa lotu po stronie serwera.
-- Rejestruje akcje: SetFly, UpdateFlyVelocity
-- =====================================================

local RunService = game:GetService("RunService")

local Fly = {}

function Fly.init(deps)
    local Config = deps.Config

    -- Stan per gracz: czy leci
    local flyStates = {}  -- [UserId] = bool

    -- Pomocnik: tworzy lub usuwa BodyMovery w HRP
    local function startFly(player)
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        -- Usuń stare instancje
        local old1 = hrp:FindFirstChild("AdminFlyVelocity")
        local old2 = hrp:FindFirstChild("AdminFlyGyro")
        if old1 then old1:Destroy() end
        if old2 then old2:Destroy() end

        local bv = Instance.new("BodyVelocity")
        bv.Name     = "AdminFlyVelocity"
        bv.Velocity  = Vector3.zero
        bv.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
        bv.Parent    = hrp

        local bg = Instance.new("BodyGyro")
        bg.Name      = "AdminFlyGyro"
        bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bg.CFrame    = hrp.CFrame
        bg.Parent    = hrp
    end

    local function stopFly(player)
        flyStates[player.UserId] = false
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bv = hrp:FindFirstChild("AdminFlyVelocity")
        local bg = hrp:FindFirstChild("AdminFlyGyro")
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end

    -- Akcja: włącz/wyłącz lot
    deps.onAction("SetFly", function(player, data)
        flyStates[player.UserId] = data.enabled
        if data.enabled then
            startFly(player)
        else
            stopFly(player)
        end
    end)

    -- Akcja: aktualizuj prędkość/kierunek lotu (każda klatka z klienta)
    deps.onAction("UpdateFlyVelocity", function(player, data)
        if not flyStates[player.UserId] then return end
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bv = hrp:FindFirstChild("AdminFlyVelocity")
        local bg = hrp:FindFirstChild("AdminFlyGyro")
        if bv and typeof(data.velocity) == "Vector3" then
            bv.Velocity = data.velocity
        end
        if bg and typeof(data.cframe) == "CFrame" then
            bg.CFrame = data.cframe
        end
    end)

    -- Sprzątanie przy odejściu gracza
    deps.Players.PlayerRemoving:Connect(function(player)
        flyStates[player.UserId] = nil
    end)
end

return Fly
