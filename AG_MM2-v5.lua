-- AG MM2 v5 - Updated from your v4

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- ==================== GUI (from your v4 style) ====================
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.Parent = player.PlayerGui

local AGButton = Instance.new("TextButton")
AGButton.Size = UDim2.new(0, 80, 0, 80)
AGButton.Position = UDim2.new(0, 20, 0, 100)
AGButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
AGButton.Text = "AG"
AGButton.TextColor3 = Color3.new(1,1,1)
AGButton.TextScaled = true
AGButton.Font = Enum.Font.GothamBold
AGButton.Parent = sg
Instance.new("UICorner", AGButton).CornerRadius = UDim.new(0, 16)

local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 320, 0, 480)
MainPanel.Position = UDim2.new(0.5, -160, 0.2, 0)
MainPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainPanel.Visible = false
MainPanel.Parent = sg
Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Text = "AG MM2 v5"
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
Title.TextColor3 = Color3.new(1,1,1)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainPanel
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.TextScaled = true
CloseBtn.Parent = MainPanel

AGButton.MouseButton1Click:Connect(function() MainPanel.Visible = not MainPanel.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainPanel.Visible = false end)

-- Draggable
local function makeDraggable(gui)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            update(dragInput)
        end
    end)
end

makeDraggable(MainPanel)
makeDraggable(AGButton)

-- ==================== IMPROVED ESP (from YARHM style) ====================
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
    for _, v in pairs(highlights) do v:Destroy() end
    highlights = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local color = Color3.fromRGB(0, 255, 0)
            local label = "Innocent"

            if playerData[plr.Name] and playerData[plr.Name].Role == "Murderer" or plr.Character:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife") then
                color = Color3.fromRGB(255, 0, 0)
                label = "Murderer"
            elseif playerData[plr.Name] and playerData[plr.Name].Role == "Sheriff" or plr.Character:FindFirstChild("Gun") or plr.Backpack:FindFirstChild("Gun") then
                color = Color3.fromRGB(0, 100, 255)
                label = "Sheriff"
            end

            local hl = Instance.new("Highlight")
            hl.Adornee = plr.Character
            hl.FillColor = color
            hl.OutlineColor = color
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0
            hl.Parent = plr.Character
            table.insert(highlights, hl)
        end
    end
end

-- ==================== SHOOT MURDER ====================
local function shootMurder()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and (plr.Character:FindFirstChild("Knife") or plr.Backpack:FindFirstChild("Knife")) then
            local gun = player.Character:FindFirstChild("Gun") or player.Backpack:FindFirstChild("Gun")
            if gun then
                if player.Character:FindFirstChild("Gun") == nil then
                    gun.Parent = player.Character
                end
                gun:Activate()
                StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "Shooting "..plr.Name, Duration = 2})
                return
            end
        end
    end
    StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "No murderer found or no gun!", Duration = 4})
end

-- ==================== TP TO GUN ====================
local function tpToGun()
    local gunDrop = Workspace:FindFirstChild("GunDrop", true)
    if gunDrop then
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local oldCFrame = root.CFrame
            root.CFrame = gunDrop.CFrame + Vector3.new(0, 5, 0)
            wait(0.3)
            root.CFrame = oldCFrame
            StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "Got gun & returned", Duration = 3})
        end
    else
        StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "No gun dropped", Duration = 4})
    end
end

-- ==================== KILL RANDOM ====================
local function killRandom()
    local target = nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            target = plr
            break
        end
    end
    if target and player.Character and player.Character:FindFirstChild("Knife") then
        local root = player.Character.HumanoidRootPart
        root.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
        wait(0.2)
        player.Character.Knife.Stab:FireServer("Slash")
        StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "Killed "..target.Name, Duration = 3})
    else
        StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "Need knife or no players", Duration = 4})
    end
end

-- ==================== TOGGLES ====================
local y = 60
local function addButton(text, func)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 50)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = MainPanel
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(func)
    y = y + 60
end

addButton("Toggle ESP", function()
    if espConn then
        espConn:Disconnect()
        espConn = nil
        for _, hl in pairs(highlights) do hl:Destroy() end
        StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "ESP OFF", Duration = 2})
    else
        updateESP()
        espConn = RunService.RenderStepped:Connect(updateESP)
        StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "ESP ON", Duration = 2})
    end
end)

addButton("Shoot Murder", shootMurder)
addButton("TP to Gun", tpToGun)
addButton("Kill Random", killRandom)

StarterGui:SetCore("SendNotification", {
    Title = "AG MM2 v5",
    Text = "Updated from v4 - Panel ready!",
    Duration = 8
})
