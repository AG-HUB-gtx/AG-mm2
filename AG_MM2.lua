-- =============================================
-- MM2 AG Script | Advanced GUI + Features
-- Author: AG
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local AG = {}
AG.Connections = {}
AG.Toggles = {
    ESP = false,
    ShootMurder = false,
    TpToGun = false,
    KillRandom = false,
}

-- ====================== GUI CREATION ======================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AG_MM2_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Main Panel
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainPanel"
MainFrame.Size = UDim2.new(0, 280, 0, 320)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 8)
TopCorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Text = "AG MM2"
Title.Size = UDim2.new(1, -80, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

-- Draggable TopBar
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- AG Button (Small floating button)
local AGButton = Instance.new("TextButton")
AGButton.Name = "AGButton"
AGButton.Size = UDim2.new(0, 60, 0, 60)
AGButton.Position = UDim2.new(0, 20, 0, 20)
AGButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
AGButton.Text = "AG"
AGButton.TextColor3 = Color3.new(1,1,1)
AGButton.TextScaled = true
AGButton.Font = Enum.Font.GothamBold
AGButton.Parent = ScreenGui

local AGCorner = Instance.new("UICorner")
AGCorner.CornerRadius = UDim.new(0, 12)
AGCorner.Parent = AGButton

-- Make AG Button Draggable
AGButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = AGButton.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        AGButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

AGButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

AGButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ====================== TOGGLE BUTTONS ======================

local function createToggle(name, yOffset, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 50)
    ToggleFrame.Position = UDim2.new(0, 10, 0, yOffset)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleFrame.Parent = MainFrame

    local UIC = Instance.new("UICorner")
    UIC.CornerRadius = UDim.new(0, 6)
    UIC.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Text = name
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 16
    Label.Parent = ToggleFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 80, 0, 30)
    ToggleBtn.Position = UDim2.new(1, -90, 0.5, -15)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.new(1,1,1)
    ToggleBtn.Parent = ToggleFrame

    local TC = Instance.new("UICorner")
    TC.CornerRadius = UDim.new(0, 6)
    TC.Parent = ToggleBtn

    local enabled = false
    ToggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        AG.Toggles[name] = enabled
        if enabled then
            ToggleBtn.Text = "ON"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        else
            ToggleBtn.Text = "OFF"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        end
        callback(enabled)
    end)

    return ToggleBtn
end

-- ====================== FEATURES ======================

-- ESP (Role + Gun)
local espFolder = Instance.new("Folder")
espFolder.Name = "AG_ESP"
espFolder.Parent = Workspace

local function updateESP()
    for _, v in pairs(espFolder:GetChildren()) do v:Destroy() end
    
    if not AG.Toggles.ESP then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local role = "Innocent"
            
            -- Simple role detection (MM2 common method)
            if plr.Character:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife") then
                role = "Murderer"
            elseif plr.Character:FindFirstChild("Gun") or plr.Backpack:FindFirstChild("Gun") then
                role = "Sheriff"
            end

            local color = role == "Murderer" and Color3.new(1,0,0) or 
                         (role == "Sheriff" and Color3.new(0,0,1) or Color3.new(1,1,0))

            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0, 200, 0, 50)
            bill.Adornee = root
            bill.AlwaysOnTop = true
            bill.Parent = espFolder

            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1,0,1,0)
            text.BackgroundTransparency = 1
            text.Text = plr.Name .. " [" .. role .. "]"
            text.TextColor3 = color
            text.TextScaled = true
            text.Font = Enum.Font.GothamBold
            text.Parent = bill
        end
    end
end

-- Shoot Murder Button
local shootBtn = nil
local function createShootMurderButton()
    if shootBtn then return end
    
    shootBtn = Instance.new("TextButton")
    shootBtn.Size = UDim2.new(0, 180, 0, 50)
    shootBtn.Position = UDim2.new(0.5, -90, 0.8, 0)
    shootBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    shootBtn.Text = "SHOOT MURDER"
    shootBtn.TextColor3 = Color3.new(1,1,1)
    shootBtn.TextScaled = true
    shootBtn.Font = Enum.Font.GothamBold
    shootBtn.Parent = playerGui

    local c = Instance.new("UICorner", shootBtn)

    shootBtn.MouseButton1Click:Connect(function()
        -- Basic shoot murder logic (you can improve)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local knife = plr.Character:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife")
                if knife then
                    -- Fire remote or simulate shot (common MM2 method)
                    local gun = player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
                    if gun then
                        gun:Activate()
                        wait(0.1)
                    end
                    break
                end
            end
        end
    end)
end

-- TP to Gun
local function tpToGun()
    local gun = Workspace:FindFirstChild("Gun", true) or Workspace:FindFirstChild("GunDrop")
    if gun and gun:IsA("BasePart") then
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = gun.CFrame + Vector3.new(0, 5, 0)
        end
    else
        StarterGui:SetCore("SendNotification", {
            Title = "AG MM2",
            Text = "Error: Gun hasn't been dropped yet!",
            Duration = 4
        })
    end
end

-- Kill Random (outside lobby)
local function killRandom()
    local candidates = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(candidates, plr)
        end
    end
    
    if #candidates > 0 then
        local target = candidates[math.random(1, #candidates)]
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 3)
            wait(0.3)
            -- Simulate kill (you can expand with remotes)
            StarterGui:SetCore("SendNotification", {Title = "AG", Text = "Teleported to: " .. target.Name})
        end
    end
end

-- ====================== TOGGLE CALLBACKS ======================

createToggle("ESP", 50, function(state)
    AG.Toggles.ESP = state
    if state then
        updateESP()
        table.insert(AG.Connections, RunService.RenderStepped:Connect(updateESP))
    else
        for _, c in ipairs(AG.Connections) do c:Disconnect() end
        AG.Connections = {}
        for _, v in pairs(espFolder:GetChildren()) do v:Destroy() end
    end
end)

createToggle("Shoot Murder Button", 110, function(state)
    AG.Toggles.ShootMurder = state
    if state then
        createShootMurderButton()
    elseif shootBtn then
        shootBtn:Destroy()
        shootBtn = nil
    end
end)

createToggle("TP to Gun Button", 170, function(state)
    AG.Toggles.TpToGun = state
    if state then
        -- Create TP Button
        local tpBtn = Instance.new("TextButton")
        tpBtn.Name = "TpGunBtn"
        tpBtn.Size = UDim2.new(0, 180, 0, 50)
        tpBtn.Position = UDim2.new(0.5, -90, 0.65, 0)
        tpBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        tpBtn.Text = "TP TO GUN"
        tpBtn.TextColor3 = Color3.new(1,1,1)
        tpBtn.TextScaled = true
        tpBtn.Font = Enum.Font.GothamBold
        tpBtn.Parent = playerGui
        Instance.new("UICorner", tpBtn)

        tpBtn.MouseButton1Click:Connect(tpToGun)
    end
end)

createToggle("Kill Random Button", 230, function(state)
    AG.Toggles.KillRandom = state
    if state then
        local killBtn = Instance.new("TextButton")
        killBtn.Name = "KillRandomBtn"
        killBtn.Size = UDim2.new(0, 180, 0, 50)
        killBtn.Position = UDim2.new(0.5, -90, 0.5, 0)
        killBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
        killBtn.Text = "KILL RANDOM"
        killBtn.TextColor3 = Color3.new(1,1,1)
        killBtn.TextScaled = true
        killBtn.Font = Enum.Font.GothamBold
        killBtn.Parent = playerGui
        Instance.new("UICorner", killBtn)

        killBtn.MouseButton1Click:Connect(killRandom)
    end
end)

-- ====================== INIT ======================

print("AG MM2 Script Loaded! Click the blue 'AG' button.")
StarterGui:SetCore("SendNotification", {
    Title = "AG MM2",
    Text = "Script loaded successfully! Click the AG button.",
    Duration = 6
})
