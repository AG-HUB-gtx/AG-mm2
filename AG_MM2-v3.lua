-- =============================================
-- AG MM2 Script | Mobile Friendly + Improved ESP + Fixed Dragging
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local AG = {
    Toggles = { 
        ESP = false, 
        ShootMurder = false, 
        TpToGun = false, 
        KillRandom = false,
        InfJump = false,
        Noclip = false
    },
    Connections = {},
    Highlights = {},
    ActionButtons = {}
}

-- ====================== GUI ======================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AG_MM2_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- Main Panel
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 480)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- Top Bar (Independent dragging)
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
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

-- Dragging for Panel (Separate from AG Button)
local panelDragging = false
local panelDragStart, panelStartPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        panelDragging = true
        panelDragStart = input.Position
        panelStartPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if panelDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - panelDragStart
        MainFrame.Position = UDim2.new(panelStartPos.X.Scale, panelStartPos.X.Offset + delta.X, panelStartPos.Y.Scale, panelStartPos.Y.Offset + delta.Y)
    end
end)

TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        panelDragging = false
    end
end)

CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- AG Floating Button (Independent dragging)
local AGButton = Instance.new("TextButton")
AGButton.Size = UDim2.new(0, 70, 0, 70)
AGButton.Position = UDim2.new(0, 20, 0, 20)
AGButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
AGButton.Text = "AG"
AGButton.TextColor3 = Color3.new(1,1,1)
AGButton.TextScaled = true
AGButton.Font = Enum.Font.GothamBold
AGButton.Parent = ScreenGui

Instance.new("UICorner", AGButton).CornerRadius = UDim.new(0, 16)

local buttonDragging = false
local buttonDragStart, buttonStartPos

AGButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        buttonDragging = true
        buttonDragStart = input.Position
        buttonStartPos = AGButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if buttonDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - buttonDragStart
        AGButton.Position = UDim2.new(buttonStartPos.X.Scale, buttonStartPos.X.Offset + delta.X, buttonStartPos.Y.Scale, buttonStartPos.Y.Offset + delta.Y)
    end
end)

AGButton.InputEnded:Connect(function() buttonDragging = false end)

AGButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ====================== TOGGLE CREATOR ======================
local yOffset = 60
local function createToggle(name, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 60)
    ToggleFrame.Position = UDim2.new(0, 10, 0, yOffset)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleFrame.Parent = MainFrame
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel")
    Label.Text = name
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextSize = 18
    Label.Font = Enum.Font.Gotham
    Label.Parent = ToggleFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 100, 0, 40)
    ToggleBtn.Position = UDim2.new(1, -110, 0.5, -20)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Color3.new(1,1,1)
    ToggleBtn.TextSize = 18
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Parent = ToggleFrame
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

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

    yOffset = yOffset + 70
end

-- ====================== IMPROVED ESP (Early Role + GunDrop) ======================
local function updateHighlights()
    for _, hl in pairs(AG.Highlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    AG.Highlights = {}

    if not AG.Toggles.ESP then return end

    -- Player ESP
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            local role = "Innocent"
            local color = Color3.fromRGB(0, 255, 0)

            -- Early role detection (works before timer)
            if char:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife") then
                role = "Murderer"
                color = Color3.fromRGB(255, 0, 0)
            elseif char:FindFirstChild("Gun") or plr.Backpack:FindFirstChild("Gun") then
                role = "Sheriff"
                color = Color3.fromRGB(0, 100, 255)
            elseif char:FindFirstChild("Hero") or plr.Backpack:FindFirstChild("Hero") then
                role = "Hero"
                color = Color3.fromRGB(255, 255, 0)
            end

            local highlight = Instance.new("Highlight")
            highlight.Adornee = char
            highlight.FillColor = color
            highlight.OutlineColor = color
            highlight.FillTransparency = 0.65
            highlight.OutlineTransparency = 0
            highlight.Parent = char
            table.insert(AG.Highlights, highlight)
        end
    end

    -- Dropped Gun Highlight
    local gunDrop = Workspace:FindFirstChild("GunDrop", true) or Workspace:FindFirstChild("Gun", true)
    if gunDrop and gunDrop:IsA("BasePart") then
        local gunHighlight = Instance.new("Highlight")
        gunHighlight.Adornee = gunDrop
        gunHighlight.FillColor = Color3.fromRGB(255, 215, 0)
        gunHighlight.OutlineColor = Color3.fromRGB(255, 255, 0)
        gunHighlight.FillTransparency = 0.4
        gunHighlight.OutlineTransparency = 0
        gunHighlight.Parent = gunDrop
        table.insert(AG.Highlights, gunHighlight)
    end
end

-- ====================== INF JUMP & NOCLIP ======================
local infJumpConn, noclipConn

local function toggleInfJump(state)
    if state then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            local hum = player.Character and player.Character:FindFirstChild("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    elseif infJumpConn then
        infJumpConn:Disconnect()
        infJumpConn = nil
    end
end

local function toggleNoclip(state)
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    elseif noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

-- ====================== ACTION BUTTONS ======================
local function createActionButton(text, yScale, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 220, 0, 65)
    btn.Position = UDim2.new(0.5, -110, yScale, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = playerGui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

    btn.MouseButton1Click:Connect(callback)
    table.insert(AG.ActionButtons, btn)
    return btn
end

local function removeActionButtons()
    for _, btn in ipairs(AG.ActionButtons) do
        if btn and btn.Parent then btn:Destroy() end
    end
    AG.ActionButtons = {}
end

-- Shoot Murder
local function createShootMurderButton()
    createActionButton("🔫 SHOOT MURDER", 0.72, function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                if plr.Character:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife") then
                    local gun = player.Character and (player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun"))
                    if gun and gun:IsA("Tool") then
                        gun:Activate()
                    end
                    break
                end
            end
        end
    end)
end

-- TP to Gun
local function createTpToGunButton()
    createActionButton("🔫 TP TO GUN", 0.58, function()
        local gun = Workspace:FindFirstChild("GunDrop", true) or Workspace:FindFirstChild("Gun", true)
        if gun and gun:IsA("BasePart") then
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = gun.CFrame + Vector3.new(0, 6, 0)
            end
        else
            StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "Error: Gun hasn't been dropped yet!", Duration = 4})
        end
    end)
end

-- Kill Random
local function createKillRandomButton()
    createActionButton("💀 KILL RANDOM", 0.44, function()
        local candidates = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(candidates, plr)
            end
        end
        if #candidates > 0 then
            local target = candidates[math.random(#candidates)]
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 3)
                StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "Teleported to: "..target.Name, Duration = 3})
            end
        end
    end)
end

-- ====================== TOGGLES ======================

createToggle("ESP", function(state)
    AG.Toggles.ESP = state
    if state then
        updateHighlights()
        table.insert(AG.Connections, RunService.RenderStepped:Connect(updateHighlights))
    else
        for _, c in ipairs(AG.Connections) do c:Disconnect() end
        AG.Connections = {}
        for _, hl in pairs(AG.Highlights) do if hl then hl:Destroy() end end
        AG.Highlights = {}
    end
end)

createToggle("Shoot Murder Button", function(state)
    if state then
        createShootMurderButton()
    else
        removeActionButtons() -- simple way: remove all and recreate needed ones if multiple toggled
    end
end)

createToggle("TP to Gun Button", function(state)
    if state then
        createTpToGunButton()
    else
        removeActionButtons()
    end
end)

createToggle("Kill Random Button", function(state)
    if state then
        createKillRandomButton()
    else
        removeActionButtons()
    end
end)

createToggle("Inf Jump", toggleInfJump)
createToggle("Noclip", toggleNoclip)

-- ====================== INIT ======================

print("✅ AG MM2 Script Loaded!")
StarterGui:SetCore("SendNotification", {
    Title = "AG MM2",
    Text = "Improved ESP + Fixed dragging + Gun highlight loaded!",
    Duration = 6
})
