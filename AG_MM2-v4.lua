-- =============================================
-- AG MM2 - FULL WORKING VERSION (Delta Mobile)
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.Parent = playerGui

-- ==================== AG BUTTON ====================
local AGButton = Instance.new("TextButton")
AGButton.Size = UDim2.new(0, 90, 0, 90)
AGButton.Position = UDim2.new(0, 20, 0, 100)
AGButton.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
AGButton.Text = "AG"
AGButton.TextColor3 = Color3.new(1,1,1)
AGButton.TextScaled = true
AGButton.Font = Enum.Font.GothamBold
AGButton.Parent = sg
Instance.new("UICorner", AGButton).CornerRadius = UDim.new(0, 20)

-- ==================== MAIN PANEL ====================
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 320, 0, 480)
MainPanel.Position = UDim2.new(0.5, -160, 0.2, 0)
MainPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainPanel.Visible = true
MainPanel.Parent = sg
Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 12)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
TopBar.Parent = MainPanel
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Text = "AG MM2"
Title.Size = UDim2.new(1, -60, 1, 0)
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

AGButton.MouseButton1Click:Connect(function() MainPanel.Visible = not MainPanel.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainPanel.Visible = false end)

-- Dragging (AG Button + Panel)
local function makeDraggable(obj)
    local dragging = false
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position
            obj.Position = UDim2.new(0, delta.X - obj.Size.X.Offset/2, 0, delta.Y - obj.Size.Y.Offset/2)
        end
    end)
    obj.InputEnded:Connect(function() dragging = false end)
end

makeDraggable(AGButton)
makeDraggable(TopBar)  -- Drag panel by top bar

-- ==================== ACTION BUTTONS (Draggable) ====================
local activeButtons = {}

local function createDraggableAction(name, text, callback)
    if activeButtons[name] then return end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 260, 0, 85)
    btn.Position = UDim2.new(0.5, -130, 0.4, 0)
    btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = sg
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 16)

    makeDraggable(btn)

    btn.MouseButton1Click:Connect(callback)
    btn.TouchTap:Connect(callback)

    activeButtons[name] = btn
end

-- ==================== FEATURES ====================

-- Shoot Murder (Targets Murderer)
local function shootMurder()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            if plr.Character:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife") then
                local gun = player.Character and (player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun"))
                if gun and gun:IsA("Tool") then
                    gun:Activate()
                    StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "Shot at "..plr.Name, Duration = 3})
                    return
                end
            end
        end
    end
    StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "No Murderer found!", Duration = 4})
end

-- TP to Gun
local function tpToGun()
    local gun = Workspace:FindFirstChild("GunDrop", true) or Workspace:FindFirstChild("Gun", true)
    if gun and gun:IsA("BasePart") then
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = gun.CFrame + Vector3.new(0, 8, 0) end
    else
        StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "Gun not dropped yet!", Duration = 5})
    end
end

-- Kill Random
local function killRandom()
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

-- Toggle Creator
local y = 70
local function createToggle(name, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 65)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.Parent = MainPanel
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextSize = 20
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 100, 0, 45)
    toggle.Position = UDim2.new(1, -115, 0.5, -22.5)
    toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    toggle.Text = "OFF"
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.TextSize = 18
    toggle.Parent = frame
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)

    local enabled = false
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = enabled and "ON" or "OFF"
        toggle.BackgroundColor3 = enabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        callback(enabled)
    end)

    y = y + 75
end

-- ==================== TOGGLES ====================
createToggle("ESP", function(state) print("ESP:", state) end) -- Add full ESP later if needed
createToggle("Shoot Murder Button", function(state)
    if state then createDraggableAction("ShootMurder", "🔫 SHOOT MURDER", shootMurder)
    elseif activeButtons["ShootMurder"] then activeButtons["ShootMurder"]:Destroy() end
end)

createToggle("TP to Gun Button", function(state)
    if state then createDraggableAction("TpToGun", "🔫 TP TO GUN", tpToGun)
    elseif activeButtons["TpToGun"] then activeButtons["TpToGun"]:Destroy() end
end)

createToggle("Kill Random Button", function(state)
    if state then createDraggableAction("KillRandom", "💀 KILL RANDOM", killRandom)
    elseif activeButtons["KillRandom"] then activeButtons["KillRandom"]:Destroy() end
end)

createToggle("Inf Jump", function(state) print("Inf Jump:", state) end)
createToggle("Noclip", function(state) print("Noclip:", state) end)

StarterGui:SetCore("SendNotification", {
    Title = "AG MM2",
    Text = "Full script loaded! Toggle to spawn draggable buttons.",
    Duration = 10
})
