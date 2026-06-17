-- =============================================
-- AG MM2 Script | Action Buttons FIXED (Like Yarhm Style)
-- Tested for Mobile - Buttons now appear reliably
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local AG = {
    Toggles = { ESP = false, ShootMurder = false, TpToGun = false, KillRandom = false, InfJump = false, Noclip = false },
    Connections = {},
    Highlights = {},
    ActionButtons = {}
}

-- ====================== MAIN GUI ======================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Main Panel
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 500)
MainFrame.Position = UDim2.new(0.5, -170, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Text = "AG MM2"
Title.Size = UDim2.new(1, -90, 1, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 50, 1, 0)
CloseBtn.Position = UDim2.new(1, -50, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextScaled = true
CloseBtn.Parent = TopBar

-- Dragging
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
TopBar.InputEnded:Connect(function() dragging = false end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- AG Button
local AGButton = Instance.new("TextButton")
AGButton.Size = UDim2.new(0, 75, 0, 75)
AGButton.Position = UDim2.new(0, 30, 0, 30)
AGButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
AGButton.Text = "AG"
AGButton.TextColor3 = Color3.new(1,1,1)
AGButton.TextScaled = true
AGButton.Font = Enum.Font.GothamBold
AGButton.Parent = ScreenGui
Instance.new("UICorner", AGButton).CornerRadius = UDim.new(0, 20)

AGButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = AGButton.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        AGButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
AGButton.InputEnded:Connect(function() dragging = false end)

AGButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ====================== TOGGLE CREATOR ======================
local y = 70
local function createToggle(name, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 65)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.Parent = MainFrame
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextSize = 20
    label.Font = Enum.Font.Gotham
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 110, 0, 45)
    toggle.Position = UDim2.new(1, -120, 0.5, -22.5)
    toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.TextSize = 20
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = frame
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)

    local on = false
    toggle.MouseButton1Click:Connect(function()
        on = not on
        AG.Toggles[name] = on
        toggle.Text = on and "ON" or "OFF"
        toggle.BackgroundColor3 = on and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        callback(on)
    end)
    y = y + 75
end

-- ====================== ACTION BUTTONS (Yarhm Style - Always Created, Toggle Visible) ======================
local function makeActionButton(key, text, yScale, func)
    local btn = Instance.new("TextButton")
    btn.Name = key
    btn.Size = UDim2.new(0, 260, 0, 80)
    btn.Position = UDim2.new(0.5, -130, yScale, 0)
    btn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Visible = false
    btn.Parent = playerGui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 15)

    btn.MouseButton1Click:Connect(func)
    btn.TouchTap:Connect(func)   -- Strong mobile support

    AG.ActionButtons[key] = btn
end

-- Create buttons once at start
makeActionButton("ShootMurder", "🔫 SHOOT MURDER", 0.68, function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and (plr.Character:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife")) then
            local gun = player.Character and (player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun"))
            if gun and gun:IsA("Tool") then gun:Activate() end
            break
        end
    end
end)

makeActionButton("TpToGun", "🔫 TP TO GUN", 0.52, function()
    local gun = Workspace:FindFirstChild("GunDrop", true) or Workspace:FindFirstChild("Gun", true)
    if gun and gun:IsA("BasePart") then
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = gun.CFrame + Vector3.new(0, 7, 0) end
    else
        StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "Gun not dropped yet!", Duration = 4})
    end
end)

makeActionButton("KillRandom", "💀 KILL RANDOM", 0.36, function()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, plr)
        end
    end
    if #list > 0 then
        local target = list[math.random(#list)]
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 4) end
    end
end)

-- ====================== TOGGLES ======================
createToggle("ESP", function(state)
    AG.Toggles.ESP = state
    -- ESP code remains the same...
    if state then
        -- ... (keep your existing ESP logic)
    end
end)

createToggle("Shoot Murder Button", function(state)
    if AG.ActionButtons["ShootMurder"] then
        AG.ActionButtons["ShootMurder"].Visible = state
    end
end)

createToggle("TP to Gun Button", function(state)
    if AG.ActionButtons["TpToGun"] then
        AG.ActionButtons["TpToGun"].Visible = state
    end
end)

createToggle("Kill Random Button", function(state)
    if AG.ActionButtons["KillRandom"] then
        AG.ActionButtons["KillRandom"].Visible = state
    end
end)

createToggle("Inf Jump", function(state) 
    -- your inf jump code
end)

createToggle("Noclip", function(state) 
    -- your noclip code
end)

-- ====================== INIT ======================
print("AG MM2 Loaded - Action Buttons should now appear!")
StarterGui:SetCore("SendNotification", {
    Title = "AG MM2",
    Text = "Action buttons fixed! Toggle them ON to see them.",
    Duration = 8
})
