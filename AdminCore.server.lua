-- =====================================================
-- AdminCore.server.lua  (Script → ServerScriptService/AdminSystem)
--
-- ARCHITEKTURA:
--   • Taby (Modules/Tabs/) są w ServerScriptService — gracz
--     bez uprawnień nigdy ich nie pobiera i nie widzi ich kodu.
--   • Serwer wysyła do klienta gotowe "instrukcje UI" przez
--     RemoteEvent BuildUI — protokół cmd/params.
--   • AdminClient (LocalScript) to czysty renderer:
--     odbiera BuildUI i rysuje GUI, NIE zawiera żadnej logiki.
--   • Gracz bez uprawnień: CheckAdmin zwraca false →
--     AdminClient niszczy siebie → nic nie ładuje.
-- =====================================================

local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

-- ─────────────────────────────────────────────────────
-- REMOTY
-- ─────────────────────────────────────────────────────
local R = ReplicatedStorage:FindFirstChild("AdminRemotes")
if not R then
    R = Instance.new("Folder")
    R.Name   = "AdminRemotes"
    R.Parent = ReplicatedStorage
end

local function createRemote(name, className)
    local obj = R:FindFirstChild(name)
    if obj then return obj end
    obj = Instance.new(className)
    obj.Name = name
    obj.Parent = R
    return obj
end

-- Klient pyta serwer: czy jestem adminem?
local CheckAdmin = createRemote("CheckAdmin", "RemoteFunction")

-- Serwer → klient: instrukcje budowania UI
-- Protokół: { cmd="tab"|"section"|"toggle"|"slider"|
--             "dropdown"|"button"|"keybind"|"done", ...params }
local BuildUI = createRemote("BuildUI", "RemoteEvent")

-- Klient → serwer: akcja użytkownika (toggle, slider, klik)
local AdminAction = createRemote("AdminAction", "RemoteEvent")

-- Serwer → klient: odśwież dropdown graczy
local UpdatePlayerList = createRemote("UpdatePlayerList", "RemoteEvent")

-- Serwer → klient: efekty client-side (noclip, infJump itp.)
local ClientEffect = createRemote("ClientEffect", "RemoteEvent")

-- ─────────────────────────────────────────────────────
-- WHITELIST
-- ─────────────────────────────────────────────────────
local function isAdmin(player)
    for _, n in ipairs(Config.Whitelist) do
        if n == player.Name then return true end
    end
    return false
end

CheckAdmin.OnServerInvoke = function(player)
    return isAdmin(player)
end

-- ─────────────────────────────────────────────────────
-- ŁADOWANIE MODUŁÓW SERWEROWYCH (logika gry)
-- ─────────────────────────────────────────────────────
local ServerMods = ServerScriptService
    :WaitForChild("AdminSystem")
    :WaitForChild("Modules")
    :WaitForChild("Server")

local ActionHandlers = {}

local deps = {
    Config       = Config,
    Players      = Players,
    isAdmin      = isAdmin,
    ClientEffect = ClientEffect,
    fireClient   = function(player, effect, data)
        ClientEffect:FireClient(player, effect, data)
    end,
    onAction     = function(name, fn)
        ActionHandlers[name] = fn
    end,
}

for _, m in ipairs(ServerMods:GetChildren()) do
    if m:IsA("ModuleScript") then
        local ok, err = pcall(function()
            local mod = require(m)
            if type(mod.init) == "function" then mod.init(deps) end
        end)
        if not ok then
            warn("[AdminCore] Server mod " .. m.Name .. ": " .. err)
        else
        end
    end
end

-- ─────────────────────────────────────────────────────
-- ŁADOWANIE TABÓW — tylko ServerScriptService
-- Gracz NIE ma dostępu do tych ModuleScriptów.
--
-- Każdy Tab ModuleScript musi zwracać:
--   { Name = "Nazwa",  build = function(send, AdminAction, Config, player) }
--
-- 'send(instruction)' wysyła jeden wpis BuildUI do klienta.
-- Przykład:
--   send({ cmd="toggle", id="Fly", name="Fly", value=false })
--
-- Dostępne cmdy (klient obsługuje w AdminClient):
--   section  { name }
--   toggle   { id, name, value }
--   slider   { id, name, min, max, inc, suffix, value }
--   dropdown { id, name, options, current }
--   button   { id, name }
--   keybind  { id, name, key }
-- ─────────────────────────────────────────────────────
local TabMods = ServerScriptService
    :WaitForChild("AdminSystem")
    :WaitForChild("Modules")
    :WaitForChild("Tabs")

-- Kolejność zakładek
local TAB_ORDER = { MainTab = 1, PlayerTab = 2, SettingsTab = 3 }

-- ─────────────────────────────────────────────────────
-- HANDLER AKCJI od klienta
-- ─────────────────────────────────────────────────────
-- Te akcje są client-side i muszą być przekazywane przez ClientEffect.
local CLIENT_EFFECTS_BOOL = {
    SetNoclip      = true,
    SetInfiniteJump = true,
}
local CLIENT_EFFECTS_NUM = {
    SetWalkSpeed = true,
    SetJumpPower = true,
}

-- Per-player theme (domyślnie z Configa)
local playerTheme = {}   -- [UserId] = "Default" | "Purple"
local buildUIForPlayer   -- forward declaration (definicja poniżej)

-- Stan toggle/slider per gracz — zachowany przy zmianie motywu.
-- Klucz = action string (np. "SetFly"), wartość = bool lub number.
local playerState = {}   -- [UserId] = { SetFly=bool, SetWalkSpeed=number, ... }

local function getState(player)
    if not playerState[player.UserId] then
        playerState[player.UserId] = {}
    end
    return playerState[player.UserId]
end

-- Automatycznie zapisuj stan przy każdej akcji toggle/slider
local function trackState(player, action, data)
    local st = getState(player)
    -- toggle: enabled = bool
    if data.enabled ~= nil then
        st[action] = data.enabled
    -- slider: value = number
    elseif data.value ~= nil then
        st[action] = data.value
    end
end

AdminAction.OnServerEvent:Connect(function(player, action, data)
    if not isAdmin(player) then
        warn("[AdminCore] Brak dostępu: " .. player.Name)
        return
    end

    -- SetTheme: przebuduj UI z nowym motywem
    -- Stany togglei są zachowane po stronie serwera w modułach
    if action == "SetTheme" then
        local themeName = data and data.option or "Default"
        playerTheme[player.UserId] = themeName
        -- Przebuduj całe UI z nowym motywem
        buildUIForPlayer(player, themeName)
        return
    end

    -- Zapisz stan (toggle/slider) przed wywołaniem modułu
    trackState(player, action, data or {})

    local h = ActionHandlers[action]
    if h then h(player, data or {}) end

    -- Przekaż efekty do klienta tylko dla akcji, które tego wymagają.
    if CLIENT_EFFECTS_BOOL[action] then
        ClientEffect:FireClient(player, action, data)
    elseif CLIENT_EFFECTS_NUM[action] then
        ClientEffect:FireClient(player, action, { enabled = true, value = data and data.value })
    end
end)

-- ─────────────────────────────────────────────────────
-- BUDOWANIE UI DLA KONKRETNEGO GRACZA
-- Iteruje taby i wysyła serię BuildUI do klienta.
-- ─────────────────────────────────────────────────────
buildUIForPlayer = function(player, themeOverride)
    -- Inicjalizacja okna
    local themeName = themeOverride or playerTheme[player.UserId] or Config.Theme or "Default"
    BuildUI:FireClient(player, {
        cmd    = "init",
        name   = "Admin Panel",
        theme  = themeName,
        hotkey = (Config.HotkeyToggle or Enum.KeyCode.RightShift).Name,
    })

    -- Posortuj taby
    local tabs = {}
    for _, m in ipairs(TabMods:GetChildren()) do
        if m:IsA("ModuleScript") then table.insert(tabs, m) end
    end
    table.sort(tabs, function(a, b)
        return (TAB_ORDER[a.Name] or 99) < (TAB_ORDER[b.Name] or 99)
    end)

    for _, m in ipairs(tabs) do
        local ok, err = pcall(function()
            local tabDef = require(m)

            -- Otwórz nową zakładkę po stronie klienta
            BuildUI:FireClient(player, { cmd = "tab", name = tabDef.Name })

            -- Helper send() dla definicji taba
            -- Każde wywołanie = jeden element UI wysłany do klienta
            local function send(instr)
                instr.tab = tabDef.Name
                BuildUI:FireClient(player, instr)
            end

            -- Zbuduj zakładkę — przekaż aktualny stan gracza
            -- żeby toggle/slidery pokazywały właściwe wartości po przebudowaniu UI
            tabDef.build(send, AdminAction, Config, player, {
                UpdatePlayerList = UpdatePlayerList,
                state            = getState(player),
                currentTheme     = playerTheme[player.UserId] or Config.Theme or "Default",
            })
        end)
        if not ok then
            warn("[AdminCore] Tab " .. m.Name .. ": " .. tostring(err))
        end
    end

    -- Koniec budowania — klient pokazuje okno
    BuildUI:FireClient(player, {
        cmd  = "done",
        msg  = "Witaj, " .. player.Name .. "!  [" ..
               (Config.HotkeyToggle or Enum.KeyCode.RightShift).Name ..
               " = pokaż/ukryj]",
    })
end

-- ─────────────────────────────────────────────────────
-- LISTA GRACZY
-- ─────────────────────────────────────────────────────
local function broadcastPlayerList()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(names, p.Name)
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if isAdmin(p) then
            UpdatePlayerList:FireClient(p, names)
        end
    end
end

-- ─────────────────────────────────────────────────────
-- DOŁĄCZANIE GRACZA
-- ─────────────────────────────────────────────────────
Players.PlayerAdded:Connect(function(player)
    task.wait(2)  -- poczekaj aż LocalScript klienta się załaduje
    if isAdmin(player) then
        buildUIForPlayer(player)
    end
    broadcastPlayerList()
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    broadcastPlayerList()
end)

-- Gracze już w grze (Studio play solo)
for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(function()
        task.wait(2)
        if isAdmin(player) then
            buildUIForPlayer(player)
        end
    end)
end

broadcastPlayerList()
