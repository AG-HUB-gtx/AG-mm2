-- =============================================
-- AG MM2 - Draggable Panel Version (Delta Mobile)
-- All buttons are now INSIDE the panel
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- ==================== MAIN DRAGGABLE PANEL ====================
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 340, 0, 520)
MainPanel.Position = UDim2.new(0.5, -170, 0.3, 0)
MainPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainPanel.Visible = true
MainPanel.Parent = ScreenGui
Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 12)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 55)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
TopBar.Parent = MainPanel
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

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
CloseBtn.Size = UDim2.new(0, 50, 1, 0)
CloseBtn.Position = UDim2.new(1, -50, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

-- Dragging
local dragging = false
local dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainPanel.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        MainPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

TopBar.InputEnded:Connect(function() dragging = false end)
CloseBtn.MouseButton1Click:Connect(function() MainPanel.Visible = false end)

-- ==================== TOGGLES + ACTION BUTTONS INSIDE PANEL ====================
local yOffset = 70

local function createToggle(name, onToggle)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 70)
    frame.Position = UDim2.new(0, 10, 0, yOffset)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Parent = MainPanel
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

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 110, 0, 50)
    toggleBtn.Position = UDim2.new(1, -125, 0.5, -25)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    toggleBtn.Text = "OFF"
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.TextSize = 20
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = frame
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)

    local enabled = false
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggleBtn.Text = enabled and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        onToggle(enabled)
    end)

    yOffset = yOffset + 80
end

-- Action Buttons (Placed inside panel when toggled)
local function createActionButtonInside(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 75)
    btn.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainPanel
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    btn.MouseButton1Click:Connect(callback)
    btn.TouchTap:Connect(callback)

    yOffset = yOffset + 85
    return btn
end

-- Button Functions
local shootBtn, tpBtn, killBtn

createToggle("ESP", function(state) 
    -- ESP code here later
    print("ESP toggled:", state)
end)

createToggle("Shoot Murder Button", function(state)
    if state then
        shootBtn = createActionButtonInside("🔫 SHOOT MURDER", function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    if plr.Character:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife") then
                        local gun = player.Character and (player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun"))
                        if gun and gun:IsA("Tool") then gun:Activate() end
                        break
                    end
                end
            end
        end)
    elseif shootBtn then
        shootBtn:Destroy()
    end
end)

createToggle("TP to Gun Button", function(state)
    if state then
        tpBtn = createActionButtonInside("🔫 TP TO GUN", function()
            local gun = Workspace:FindFirstChild("GunDrop", true) or Workspace:FindFirstChild("Gun", true)
            if gun and gun:IsA("BasePart") then
                local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if root then root.CFrame = gun.CFrame + Vector3.new(0, 8, 0) end
            else
                StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "Gun not dropped yet!", Duration = 5})
            end
        end)
    elseif tpBtn then
        tpBtn:Destroy()
    end
end)

createToggle("Kill Random Button", function(state)
    if state then
        killBtn = createActionButtonInside("💀 KILL RANDOM", function()
            local list = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(list, plr)
                end
            end
            if #list > 0 then
                local target = list[math.random(#list)]
                local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if root then root.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 5) end
            end
        end)
    elseif killBtn then
        killBtn:Destroy()
    end
end)

createToggle("Inf Jump", function(state)
    print("Inf Jump:", state)
end)

createToggle("Noclip", function(state)
    print("Noclip:", state)
end)

-- Init
StarterGui:SetCore("SendNotification", {
    Title = "AG MM2",
    Text = "Draggable Panel Loaded! Toggle buttons to see them inside.",
    Duration = 10
})

print("AG MM2 Panel Version Loaded")
