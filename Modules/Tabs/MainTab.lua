-- Modules/Tabs/MainTab.lua  (ServerScriptService)
-- extra.state = { SetFly=bool, SetNoclip=bool, ... }
-- Przekazywane przy każdym build() — zachowuje stan po zmianie motywu.

local MainTab = {}
MainTab.Name  = "Main"

function MainTab.build(send, AdminAction, Config, player, extra)
    local st = extra and extra.state or {}

    -- Helper: odczytaj bool ze stanu, domyślnie false
    local function tog(action) return st[action] == true end
    -- Helper: odczytaj liczbę ze stanu, domyślnie defaultVal
    local function sld(action, defaultVal) return st[action] or defaultVal end

    -- ── LATANIE ────────────────────────────────────
    send({ cmd="section", name="Latanie" })

    send({ cmd="toggle", id="Fly",
        name="Fly  [WASD + Spacja/Ctrl]",
        value=tog("SetFly"), action="SetFly",
    })

    -- ── RUCH ───────────────────────────────────────
    send({ cmd="section", name="Ruch" })

    send({ cmd="toggle", id="Noclip",
        name="Noclip",
        value=tog("SetNoclip"), action="SetNoclip",
    })
    send({ cmd="slider", id="SetWalkSpeed",
        name="WalkSpeed",
        min=Config.MinWalkSpeed, max=Config.MaxWalkSpeed,
        inc=1, suffix=" u/s",
        value=sld("SetWalkSpeed", Config.MinWalkSpeed),
        action="SetWalkSpeed",
    })
    send({ cmd="slider", id="SetJumpPower",
        name="JumpPower",
        min=Config.MinJumpPower, max=Config.MaxJumpPower,
        inc=1, suffix="",
        value=sld("SetJumpPower", Config.MinJumpPower),
        action="SetJumpPower",
    })
    send({ cmd="toggle", id="InfiniteJump",
        name="Infinite Jump",
        value=tog("SetInfiniteJump"), action="SetInfiniteJump",
    })

    -- ── COMBAT ─────────────────────────────────────
    send({ cmd="section", name="Combat" })

    send({ cmd="toggle", id="GodMode",
        name="God Mode",
        value=tog("SetGodMode"), action="SetGodMode",
    })

    -- ── NIEWIDZIALNOŚĆ ─────────────────────────────
    send({ cmd="section", name="Niewidzialność" })

    send({ cmd="toggle", id="Vanish",
        name="Vanish  (ty widzisz siebie)",
        value=tog("SetVanish"), action="SetVanish",
    })

    -- ── TELEPORT ───────────────────────────────────
    send({ cmd="section", name="Teleport" })

    send({ cmd="toggle", id="ClickTeleport",
        name="Click to Teleport",
        value=tog("SetClickTeleport"), action="SetClickTeleport",
    })
end

return MainTab
