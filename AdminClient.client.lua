-- =====================================================
-- AdminClient.client.lua  (LocalScript → StarterPlayerScripts)
-- Klient tylko ładuje moduły renderujące i efekty.
-- Zero logiki UI w LocalScript.
-- =====================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local lp                = Players.LocalPlayer

local R = ReplicatedStorage:WaitForChild("AdminRemotes", 15)
if not R then script:Destroy(); return end

local CheckAdmin  = R:WaitForChild("CheckAdmin", 15)
if not CheckAdmin then script:Destroy(); return end

if not CheckAdmin:InvokeServer() then
    script:Destroy(); return
end

local UIRenderer = require(ReplicatedStorage:WaitForChild("UIRenderer", 10))
UIRenderer.init()
