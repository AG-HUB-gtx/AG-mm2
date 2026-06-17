-- =============================================
-- AG MM2 - FINAL COMPLETE VERSION (Panel Pops Up)
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==================== FLOATING AG BUTTON ====================
local AGButton = Instance.new("TextButton")
AGButton.Size = UDim2.new(0, 80, 0, 80)
AGButton.Position = UDim2.new(0, 20, 0, 80)
AGButton.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
AGButton.Text = "AG"
AGButton.TextColor3 = Color3.new(1,1,1)
AGButton.TextScaled = true
AGButton.Font = Enum.Font.GothamBold
AGButton.Parent = playerGui
Instance.new("UICorner", AGButton).CornerRadius = UDim.new(0, 20)

-- Draggable AG Button
local agDrag = false
AGButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        agDrag = true
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if agDrag and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        AGButton.Position = UDim2.new(0, input.Position.X - 40, 0, input.Position.Y - 40)
    end
end)
AGButton.InputEnded:Connect(function() agDrag = false end)

AGButton.MouseButton1Click:Connect(function()
    MainPanel.Visible = not MainPanel.Visible
end)

-- ==================== MAIN PANEL (Starts Visible) ====================
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 340, 0, 520)
MainPanel.Position = UDim2.new(0.5, -170, 0.2, 0)
MainPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainPanel.Visible = true
MainPanel.Parent = playerGui
Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 12)

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

CloseBtn.MouseButton1Click:Connect(function()
    MainPanel.Visible = false
end)

-- ==================== ACTION BUTTONS (Separate Draggable) ====================
local activeButtons = {}

local function createDraggableButton(name, text, defaultPos, callback)
    if activeButtons[name] then return end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 90)
    frame.Position = defaultPos
    frame.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
    frame.Parent = playerGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame

    -- Dragging
    local bdrag = false
    local bstart, bpos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            bdrag = true
            bstart = input.Position
            bpos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if bdrag and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - bstart
            frame.Position = UDim2.new(bpos.X.Scale, bpos.X.Offset + delta.X, bpos.Y.Scale, bpos.Y.Offset + delta.Y)
        end
    end)
    frame.InputEnded:Connect(function() bdrag = false end)

    btn.MouseButton1Click:Connect(callback)
    btn.TouchTap:Connect(callback)

    activeButtons[name] = frame
end

-- Functions
local function shootMurderFunc()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            if plr.Character:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife") then
                local gun = player.Character and (player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun"))
                if gun and gun:IsA("Tool") then
                    gun:Activate()
                    StarterGui:SetCore("SendNotification", {Title = "AG", Text = "Shot at "..plr.Name, Duration = 3})
                    return
                end
            end
        end
    end
    StarterGui:SetCore("SendNotification", {Title = "AG", Text = "No Murderer found", Duration = 4})
end

local function tpToGunFunc()
    local gun = Workspace:FindFirstChild("GunDrop", true) or Workspace:FindFirstChild("Gun", true)
    if gun and gun:IsA("BasePart") then
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = gun.CFrame + Vector3.new(0, 8, 0) end
    else
        StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "Gun not dropped yet!", Duration = 5})
    end
end

local function killRandomFunc()
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
end

-- Toggles
local yOffset = 70
local function createToggle(name, callback)
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

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 110, 0, 50)
    toggle.Position = UDim2.new(1, -125, 0.5, -25)
    toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.TextSize = 20
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = frame
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)

    local enabled = false
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = enabled and "ON" or "OFF"
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        callback(enabled)
    end)

    yOffset = yOffset + 80
end

createToggle("ESP", function(s) print("ESP", s) end) -- Add full ESP if you want
createToggle("Shoot Murder Button", function(s) if s then createDraggableButton("Shoot", "🔫 SHOOT MURDER", UDim2.new(0.6,-140,0.3,0), shootMurderFunc) end end)
createToggle("TP to Gun Button", function(s) if s then createDraggableButton("TP", "🔫 TP TO GUN", UDim2.new(0.6,-140,0.45,0), tpToGunFunc) end end)
createToggle("Kill Random Button", function(s) if s then createDraggableButton("Kill", "💀 KILL RANDOM", UDim2.new(0.6,-140,0.6,0), killRandomFunc) end end)
createToggle("Inf Jump", function(s) print("Inf Jump", s) end)
createToggle("Noclip", function(s) print("Noclip", s) end)

StarterGui:SetCore("SendNotification", {
    Title = "AG MM2",
    Text = "Panel should now appear! Tap AG button to hide/show.",
    Duration = 10
})
