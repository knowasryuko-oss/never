-- ====================================================================
-- BLATANT TESTER (LYNXX) - RAYFIELD UI (STRICT 1:1)
-- Only: Start toggle + Complete/Cancel delay inputs
-- ====================================================================

repeat task.wait() until game:IsLoaded()

-- Basic service check
local ok, err = pcall(function()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
assert(Players.LocalPlayer, "LocalPlayer not available")
assert(ReplicatedStorage:FindFirstChild("Packages"), "Packages missing")
end)
if not ok then
error("❌ [Blatant Tester] Dependency check failed: " .. tostring(err))
return
end

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Net remotes
local net = ReplicatedStorage:WaitForChild("Packages")
:WaitForChild("_Index")
:WaitForChild("sleitnick_net@0.2.0")
:WaitForChild("net")

local Remotes = {
equip = net:WaitForChild("RE/EquipToolFromHotbar"),
unequip = net:FindFirstChild("RE/UnequipToolFromHotbar"),
charge = net:WaitForChild("RF/ChargeFishingRod"),
minigame = net:WaitForChild("RF/RequestFishingMinigameStarted"),
finish = net:WaitForChild("RE/FishingCompleted"),
cancel = net:WaitForChild("RF/CancelFishingInputs"),
}

-- Core config (strict: hanya 2 parameter via UI, yang lain fixed)
local cfg = {
hotbarSlot = 1, -- tetap 1 (tidak di-UI)
chargeWait = 0.05, -- tetap 0.05 (tidak di-UI)
recastDelay = 0.18, -- tetap 0.18 (tidak di-UI)
completeDelay = 0.00, -- diatur via UI
cancelDelay = 0.00, -- diatur via UI
}

-- Helpers (compat signature)
local function invokeCharge(ts)
local ok1 = pcall(function() Remotes.charge:InvokeServer(ts) end)
if ok1 then return true end
return pcall(function() Remotes.charge:InvokeServer({ ts }) end)
end

local function invokeMinigame(x, y, ts)
local ok3 = pcall(function() Remotes.minigame:InvokeServer(x, y, ts) end)
if ok3 then return true end
return pcall(function() Remotes.minigame:InvokeServer(x, y) end)
end

-- Pure Lynxx loop (timer-only, vektor cobalt: 1,0)
local running = false
local function oneCycle()
pcall(function() Remotes.equip:FireServer(cfg.hotbarSlot) end)
task.wait(0.08)

text

local tCharge = workspace:GetServerTimeNow()
invokeCharge(tCharge)
if cfg.chargeWait > 0 then task.wait(cfg.chargeWait) end

local tMini = workspace:GetServerTimeNow()
invokeMinigame(1, 0, tMini)

if cfg.completeDelay > 0 then task.wait(cfg.completeDelay) end
pcall(function() Remotes.finish:FireServer() end)

if cfg.cancelDelay > 0 then task.wait(cfg.cancelDelay) end
pcall(function() Remotes.cancel:InvokeServer() end)
end

local function startLoop(onNotify)
if running then return end
running = true
if onNotify then onNotify("Started (pure Lynxx flow)") end
task.spawn(function()
while running do
oneCycle()
task.wait(cfg.recastDelay)
end
end)
end

local function stopLoop(onNotify)
if not running then return end
running = false
pcall(function() if Remotes.unequip then Remotes.unequip:FireServer() end end)
if onNotify then onNotify("Stopped") end
end

-- Rayfield UI minimal
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
Name = "🎣 Blatant Tester (Lynxx) • Strict",
LoadingTitle = "Lynxx Outgoing Flow",
LoadingSubtitle = "Charge → Minigame → Complete → Cancel",
ConfigurationSaving = { Enabled = false }
})

local Tab = Window:CreateTab("⚡ Blatant Tester", 4483362458)
Tab:CreateSection("Core")

-- Start/Stop toggle
Tab:CreateToggle({
Name = "Start Blatant Tester",
CurrentValue = false,
Callback = function(v)
if v then
startLoop(function(msg)
Rayfield:Notify({ Title = "Blatant Tester", Content = msg, Duration = 3, Image = 4483362458 })
end)
else
stopLoop(function(msg)
Rayfield:Notify({ Title = "Blatant Tester", Content = msg, Duration = 2, Image = 4483362458 })
end)
end
end
})

-- Complete Delay input
Tab:CreateInput({
Name = "Complete Delay (s)",
PlaceholderText = "0.00",
RemoveTextAfterFocusLost = false,
Callback = function(text)
local n = tonumber(text)
if n and n >= 0 then
cfg.completeDelay = n
Rayfield:Notify({ Title = "Set", Content = ("Complete Delay = %.3f"):format(cfg.completeDelay), Duration = 2 })
else
Rayfield:Notify({ Title = "Invalid", Content = "Masukkan angka ≥ 0", Duration = 2 })
end
end
})

-- Cancel Delay input
Tab:CreateInput({
Name = "Cancel Delay (s)",
PlaceholderText = "0.00",
RemoveTextAfterFocusLost = false,
Callback = function(text)
local n = tonumber(text)
if n and n >= 0 then
cfg.cancelDelay = n
Rayfield:Notify({ Title = "Set", Content = ("Cancel Delay = %.3f"):format(cfg.cancelDelay), Duration = 2 })
else
Rayfield:Notify({ Title = "Invalid", Content = "Masukkan angka ≥ 0", Duration = 2 })
end
end
})

Rayfield:Notify({
Title = "Blatant Tester Ready",
Content = "Isi Complete/Cancel Delay seperti UI Lynxx, lalu toggle Start.",
Duration = 5,
Image = 4483362458
})
