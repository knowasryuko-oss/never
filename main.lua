repeat task.wait() until game:IsLoaded()

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- Net remotes (tanpa chaining panjang)
local Packages = ReplicatedStorage:WaitForChild("Packages")
local _Index = Packages:WaitForChild("_Index")
local NetPkg = _Index:WaitForChild("sleitnick_net@0.2.0")
local net = NetPkg:WaitForChild("net")

local Remotes = {
equip = net:WaitForChild("RE/EquipToolFromHotbar"),
unequip = net:FindFirstChild("RE/UnequipToolFromHotbar"),
charge = net:WaitForChild("RF/ChargeFishingRod"),
minigame = net:WaitForChild("RF/RequestFishingMinigameStarted"),
finish = net:WaitForChild("RE/FishingCompleted"),
cancel = net:WaitForChild("RF/CancelFishingInputs"),
}

-- Config (strict)
local cfg = {
hotbarSlot = 1, -- fixed
chargeWait = 0.05, -- fixed
recastDelay = 0.18, -- fixed
completeDelay = 0.00, -- UI
cancelDelay = 0.00, -- UI
}

-- Helpers
local function notify(txt, dur)
pcall(function()
StarterGui:SetCore("SendNotification", { Title = "Blatant Tester", Text = txt, Duration = dur or 3 })
end)
print("[BlatantTester] " .. tostring(txt))
end

local function invokeCharge(ts)
local ok = pcall(function() Remotes.charge:InvokeServer(ts) end)
if ok then return true end
local okTbl = pcall(function() Remotes.charge:InvokeServer({ ts }) end)
return okTbl
end

local function invokeMinigame(x, y, ts)
local ok3 = pcall(function() Remotes.minigame:InvokeServer(x, y, ts) end)
if ok3 then return true end
local ok2 = pcall(function() Remotes.minigame:InvokeServer(x, y) end)
return ok2
end

-- Core loop (Pure Lynxx; vector 1,0)
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
if onNotify then onNotify("Started (pure Lynxx flow)") else notify("Started (pure Lynxx flow)", 3) end
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
if onNotify then onNotify("Stopped") else notify("Stopped", 2) end
end

-- Rayfield loader (robust). Jika gagal, fallback UI sederhana dipakai.
local function tryLoadRayfield()
if type(loadstring) ~= "function" then return nil end
local okHttp, src = pcall(function() return game:HttpGet("https://sirius.menu/rayfield") end)
if not okHttp or type(src) ~= "string" or #src == 0 then return nil end
local okCompile, chunk = pcall(loadstring, src)
if not okCompile or type(chunk) ~= "function" then return nil end
local okRun, lib = pcall(chunk)
if not okRun or not lib then return nil end
return lib
end

-- Build Rayfield UI (strict 1:1)
local function buildRayfieldUI(Rayfield)
local Window = Rayfield:CreateWindow({
Name = "🎣 Blatant Tester (Lynxx) • Strict",
LoadingTitle = "Lynxx Flow",
LoadingSubtitle = "Charge → Minigame → Complete → Cancel",
ConfigurationSaving = { Enabled = false }
})

text

local Tab = Window:CreateTab("⚡ Blatant Tester", 4483362458)
Tab:CreateSection("Core")

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
end

-- Fallback UI (tanpa loadstring/http; 100% lokal)
local function buildFallbackUI()
local CoreGui = game:GetService("CoreGui")
local sg = Instance.new("ScreenGui")
sg.Name = "BlatantTester_Fallback"
sg.IgnoreGuiInset = true
sg.ResetOnSpawn = false
sg.Parent = CoreGui

text

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(320, 160)
frame.Position = UDim2.fromOffset(50, 220)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
frame.Parent = sg
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 22)
title.Position = UDim2.fromOffset(10, 8)
title.BackgroundTransparency = 1
title.Text = "Blatant Tester (Fallback)"
title.TextColor3 = Color3.new(1,1,1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local function makeInput(lbl, y, default, setter)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.fromOffset(150, 22)
    l.Position = UDim2.fromOffset(10, y)
    l.BackgroundTransparency = 1
    l.Text = lbl
    l.TextColor3 = Color3.new(1,1,1)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.fromOffset(130, 22)
    box.Position = UDim2.fromOffset(180, y)
    box.BackgroundColor3 = Color3.fromRGB(55,55,65)
    box.TextColor3 = Color3.new(1,1,1)
    box.Text = default
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n and n >= 0 then setter(n) else box.Text = default end
    end)
end

makeInput("Complete Delay (s)", 40, "0.00", function(n) cfg.completeDelay = n; notify(("Complete=%.3f"):format(n),2) end)
makeInput("Cancel Delay (s)",   70, "0.00", function(n) cfg.cancelDelay = n; notify(("Cancel=%.3f"):format(n),2) end)

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.fromOffset(140, 26)
startBtn.Position = UDim2.fromOffset(10, 120)
startBtn.BackgroundColor3 = Color3.fromRGB(90,160,90)
startBtn.Text = "Start"
startBtn.TextColor3 = Color3.new(1,1,1)
startBtn.Parent = frame
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,6)

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.fromOffset(140, 26)
stopBtn.Position = UDim2.fromOffset(170, 120)
stopBtn.BackgroundColor3 = Color3.fromRGB(160,90,90)
stopBtn.Text = "Stop"
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.Parent = frame
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0,6)

startBtn.MouseButton1Click:Connect(function() startLoop() end)
stopBtn.MouseButton1Click:Connect(function() stopLoop() end)
end

-- Try Rayfield; if fail, fallback
local Rayfield = tryLoadRayfield()
if Rayfield then
buildRayfieldUI(Rayfield)
else
notify("Rayfield gagal dimuat (loadstring/HttpGet?). Pakai UI fallback.", 5)
buildFallbackUI()
end
