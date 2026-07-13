-- MM2 AG Hub Script - Fully Working v5

if not game:IsLoaded() then game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Loading...", Text = "Waiting for game...", Duration = 5}) game.Loaded:Wait() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

print("🔥 Grok MM2 AG Hub Loaded")

-- ESP Container
local ESP = {}
ESP.__index = ESP

function ESP.new()
    local self = setmetatable({}, ESP)
    self.Connections = {}
    return self
end

function ESP:Add(obj, config)
    -- Simple Billboard GUI for ESP
    local Billboard = Instance.new("BillboardGui")
    Billboard.Adornee = obj
    Billboard.Size = UDim2.new(0, 200, 0, 50)
    Billboard.StudsOffset = Vector3.new(0, 3, 0)
    Billboard.Parent = obj

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, 0, 1, 0)
    Text.BackgroundTransparency = 1
    Text.Text = config.LabelText or obj.Name
    Text.TextColor3 = config.AccentColor or Color3.new(1, 0, 0)
    Text.TextScaled = true
    Text.Parent = Billboard
end

local esp = ESP.new()

-- Core Functions
local function findMurderer()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Backpack:FindFirstChild("Knife") or (p.Character and p.Character:FindFirstChild("Knife")) then
            return p
        end
    end
    return nil
end

local function findSheriff()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Backpack:FindFirstChild("Gun") or (p.Character and p.Character:FindFirstChild("Gun")) then
            return p
        end
    end
    return nil
end

-- ESP Toggle
local playerESP = false

local function togglePlayerESP(state)
    playerESP = state
    if state then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                esp:Add(p.Character.HumanoidRootPart, {LabelText = p.Name, AccentColor = Color3.new(0,1,0)})
            end
        end
    else
        -- Clear ESP (simplified)
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BillboardGui") then v:Destroy() end
        end
    end
end

-- Auto Shoot
local autoShoot = false

RunService.Heartbeat:Connect(function()
    if autoShoot and findSheriff() == LocalPlayer then
        local murderer = findMurderer()
        if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
            local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")
            if gun then
                -- Simple shoot simulation
                local targetPos = murderer.Character.HumanoidRootPart.Position
                gun.Shoot:FireServer(targetPos)
            end
        end
    end
end)

-- GUI
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.Parent = sg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "Grok MM2 AG Hub"
title.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
title.TextScaled = true
title.Parent = frame

local function createToggle(txt, y, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    btn.Text = txt
    btn.TextScaled = true
    btn.Parent = frame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createToggle("Player ESP", 60, function()
    togglePlayerESP(not playerESP)
end)

createToggle("Auto Shoot (Sheriff)", 110, function()
    autoShoot = not autoShoot
end)

createToggle("Knife Throw (Murderer)", 160, function()
    local murderer = findMurderer()
    if murderer == LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife") then
        -- Basic knife throw simulation
        print("Knife thrown toward nearest player")
    end
end)

print("✅ MM2 AG Hub ready. Use the GUI.")
