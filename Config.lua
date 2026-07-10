-- =====================================================
-- Config.lua  (ModuleScript → ReplicatedStorage)
-- =====================================================

local Config = {}

-- WHITELIST
Config.Whitelist = {
    "Rajman39",         -- Creator
    -- "NazwaGracza2",
}

-- WALKSPEED
Config.MinWalkSpeed = 16
Config.MaxWalkSpeed = 100

-- JUMPPOWER
Config.MinJumpPower = 50
Config.MaxJumpPower = 300

-- FLY
Config.FlySpeed = 50

-- ─────────────────────────────────────────────────────
-- MOTYW – "Default" (ciemny + niebieski) lub "Purple" (fioletowy)
-- ─────────────────────────────────────────────────────
Config.Theme = "Default"

-- ─────────────────────────────────────────────────────-- TAGI ADMINA / OWNERA
-- Zmień nazwę właściciela lub dodaj dodatkowych adminów.
-- Tagi pojawiają się nad głowami oraz w czacie.
-- Admin/Owner są traktowani jako użytkownicy z uprawnieniami admina.
-- ─────────────────────────────────────────────────────
Config.Owner = "Rajman39"
Config.AdminTag = "ADMIN"
Config.OwnerTag = "OWNER"

-- ─────────────────────────────────────────────────────-- HOTKEY – klawisz pokazujący/ukrywający panel
-- Obsługiwany przez UILibrary, nie przez LocalScript.
-- Zmień np. na: Enum.KeyCode.F9 / Insert / F4
-- ─────────────────────────────────────────────────────
Config.HotkeyToggle = Enum.KeyCode.RightShift

return Config
