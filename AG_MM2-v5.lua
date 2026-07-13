-- AG MM2 v5 - YARHM ESP + Shoot + TP (Fixed GUI)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.Parent = player.PlayerGui

-- AG Button
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

-- Main Panel
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 340, 0, 550)
MainPanel.Position = UDim2.new(0.5, -170, 0.15, 0)
MainPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainPanel.Visible = false
MainPanel.Parent = sg
Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 12)

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
TopBar.Parent = MainPanel
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Text = "AG MM2 v5"
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

local function makeDraggable(obj)
    local dragging, startDrag
    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startDrag = input.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - startDrag
            obj.Position = UDim2.new(obj.Position.X.Scale, obj.Position.X.Offset + delta.X, obj.Position.Y.Scale, obj.Position.Y.Offset + delta.Y)
            startDrag = input.Position
        end
    end)
    obj.InputEnded:Connect(function() dragging = false end)
end

makeDraggable(AGButton)
makeDraggable(TopBar)

-- ==================== ESP ====================
local highlights = {}
local espConn
local playerData = {}

if ReplicatedStorage:FindFirstChild("Remotes") then
    local dataRemote = ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("PlayerDataChanged")
    if dataRemote then
        dataRemote.OnClientEvent:Connect(function(data)
            playerData = data or {}
        end)
    end
end

local function updateESP()
    for _, hl in pairs(highlights) do if hl and hl.Parent then hl:Destroy() end end
    highlights = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local role = playerData[plr.Name] and playerData[plr.Name].Role or "Innocent"
            local color = Color3.fromRGB(0, 255, 0)

            if role == "Murderer" or plr.Character:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife") then
                color = Color3.fromRGB(255, 0, 0)
            elseif role == "Sheriff" or plr.Character:FindFirstChild("Gun") or plr.Backpack:FindFirstChild("Gun") then
                color = Color3.fromRGB(0, 100, 255)
            end

            local hl = Instance.new("Highlight")
            hl.Adornee = plr.Character
            hl.FillColor = color
            hl.OutlineColor = color
            hl.FillTransparency = 0.6
            hl.OutlineTransparency = 0
            hl.Parent = plr.Character
            table.insert(highlights, hl)
        end
    end

    -- Gun Drop
    local gunDrop = Workspace:FindFirstChild("GunDrop", true)
    if gunDrop then
        local hl = Instance.new("Highlight")
        hl.Adornee = gunDrop
        hl.FillColor = Color3.fromRGB(255, 255, 0)
        hl.OutlineColor = Color3.fromRGB(255, 255, 0)
        hl.FillTransparency = 0.4
        hl.Parent = gunDrop
        table.insert(highlights, hl)
    end

    -- Traps
    for _, trap in ipairs(Workspace:GetDescendants()) do
        if trap.Name == "Trap" and (trap.Parent:IsA("Folder") or trap.Parent:IsA("Model")) then
            trap.Transparency = 0
            local hl = Instance.new("Highlight")
            hl.Adornee = trap
            hl.FillColor = Color3.fromRGB(255, 100, 0)
            hl.OutlineColor = Color3.fromRGB(255, 100, 0)
            hl.FillTransparency = 0.5
            hl.Parent = trap
            table.insert(highlights, hl)
        end
    end
end

-- ==================== SHOOT MURDER ====================
local function shootMurder()
    local murderer = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character and (plr.Character:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife")) then
            murderer = plr
            break
        end
    end

    if murderer then
        local gun = player.Character and (player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun"))
        if gun then
            gun:Activate()
            StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "Shot at "..murderer.Name, Duration = 3})
        else
            StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "Equip gun first!", Duration = 4})
        end
    else
        StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "No Murderer found!", Duration = 4})
    end
end

-- ==================== TP TO GUN ====================
local function tpToGun()
    local gun = Workspace:FindFirstChild("GunDrop", true)
    if gun and gun:IsA("BasePart") then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local originalPos = char.HumanoidRootPart.CFrame
            char.HumanoidRootPart.CFrame = gun.CFrame + Vector3.new(0, 8, 0)
            wait(0.25)
            char.HumanoidRootPart.CFrame = originalPos
            StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "Teleported to gun and back!", Duration = 3})
        end
    else
        StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "Gun not dropped yet!", Duration = 5})
    end
end

-- ==================== NOCLIP & INF JUMP ====================
local noclipConn, infJumpConn

local function toggleNoclip(state)
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end

local function toggleInfJump(state)
    if state then
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            local hum = player.Character and player.Character:FindFirstChild("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    else
        if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
    end
end

-- ==================== TOGGLES ====================
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

createToggle("Role ESP", function(state)
    if state then
        updateESP()
        espConn = RunService.RenderStepped:Connect(updateESP)
    else
        if espConn then espConn:Disconnect() end
        for _, hl in pairs(highlights) do if hl then hl:Destroy() end end
        highlights = {}
    end
end)

createToggle("Shoot Murder", function(state)
    if state then
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 260, 0, 85)
        btn.Position = UDim2.new(0.5, -130, 0.35, 0)
        btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        btn.Text = "🔫 SHOOT MURDER"
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.Parent = sg
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 16)
        makeDraggable(btn)
        btn.MouseButton1Click:Connect(shootMurder)
    end
end)

createToggle("TP to Gun", function(state)
    if state then
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 260, 0, 85)
        btn.Position = UDim2.new(0.5, -130, 0.35, 0)
        btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        btn.Text = "🔫 TP TO GUN"
        btn.TextColor3 = Color3.new(1,1,1)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.Parent = sg
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 16)
        makeDraggable(btn)
        btn.MouseButton1Click:Connect(tpToGun)
    end
end)

createToggle("Inf Jump", toggleInfJump)
createToggle("Noclip", toggleNoclip)

StarterGui:SetCore("SendNotification", {
    Title = "AG MM2 v5",
    Text = "Full features loaded!",
    Duration = 8
})
