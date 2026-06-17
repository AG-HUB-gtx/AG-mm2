-- =============================================
-- AG MM2 - Delta Mobile Fixed Version
-- =============================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- AG Floating Button
local AGButton = Instance.new("TextButton")
AGButton.Name = "AG_MainButton"
AGButton.Size = UDim2.new(0, 85, 0, 85)
AGButton.Position = UDim2.new(0, 25, 0, 80)
AGButton.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
AGButton.Text = "AG"
AGButton.TextColor3 = Color3.new(1,1,1)
AGButton.TextScaled = true
AGButton.Font = Enum.Font.GothamBold
AGButton.Parent = playerGui
Instance.new("UICorner", AGButton).CornerRadius = UDim.new(0, 20)

-- Make AG Button draggable
local dragging = false
AGButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        AGButton.Position = UDim2.new(0, AGButton.Position.X.Offset + input.Position.X - AGButton.Position.X.Offset - 40, 0, AGButton.Position.Y.Offset + input.Position.Y - AGButton.Position.Y.Offset - 40)
    end
end)
AGButton.InputEnded:Connect(function() dragging = false end)

-- ====================== ACTION BUTTONS ======================
local buttons = {}

local function createButton(name, text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.new(0, 280, 0, 90)
    btn.Position = UDim2.new(0.5, -140, yPos, 0)
    btn.BackgroundColor3 = Color3.fromRGB(200, 30, 30)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Visible = false
    btn.Parent = playerGui
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 16)

    btn.MouseButton1Click:Connect(callback)
    btn.TouchTap:Connect(callback)

    buttons[name] = btn
    return btn
end

-- Create Buttons
createButton("ShootMurder", "🔫 SHOOT MURDER", 0.25, function()
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

createButton("TpToGun", "🔫 TP TO GUN", 0.45, function()
    local gun = Workspace:FindFirstChild("GunDrop", true) or Workspace:FindFirstChild("Gun", true)
    if gun and gun:IsA("BasePart") then
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = gun.CFrame + Vector3.new(0, 8, 0)
        end
    else
        StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = "Gun not dropped yet!", Duration = 5})
    end
end)

createButton("KillRandom", "💀 KILL RANDOM", 0.65, function()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, plr)
        end
    end
    if #list > 0 then
        local target = list[math.random(#list)]
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0, 5)
        end
    end
end)

-- ====================== TOGGLE FUNCTION ======================
local function setButtonVisible(name, state)
    if buttons[name] then
        buttons[name].Visible = state
        -- Force update for Delta
        buttons[name].Parent = playerGui
    end
end

-- AG Button Click opens controls via notification for now
AGButton.MouseButton1Click:Connect(function()
    StarterGui:SetCore("SendNotification", {
        Title = "AG MM2 Controls",
        Text = "Type in console:\nAG_Show('ShootMurder')\nAG_Show('TpToGun')\nAG_Show('KillRandom')",
        Duration = 10
    })
end)

-- Easy commands for Delta
_G.AG_Show = function(name)
    setButtonVisible(name, true)
    StarterGui:SetCore("SendNotification", {Title = "AG MM2", Text = name .. " button shown!", Duration = 4})
end

_G.AG_Hide = function(name)
    setButtonVisible(name, false)
end

-- Auto show all buttons for testing
spawn(function()
    wait(1.5)
    setButtonVisible("ShootMurder", true)
    wait(0.5)
    setButtonVisible("TpToGun", true)
    wait(0.5)
    setButtonVisible("KillRandom", true)
    
    StarterGui:SetCore("SendNotification", {
        Title = "AG MM2",
        Text = "All 3 buttons should now be visible!",
        Duration = 8
    })
end)

print("AG MM2 Loaded for Delta")
print("Use _G.AG_Show('ShootMurder') etc in console if needed")
