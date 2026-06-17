-- AG MM2 - Minimal Mobile Version for Delta

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.Parent = playerGui

-- AG Button
local ag = Instance.new("TextButton")
ag.Size = UDim2.new(0, 90, 0, 90)
ag.Position = UDim2.new(0, 20, 0, 100)
ag.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
ag.Text = "AG"
ag.TextColor3 = Color3.new(1,1,1)
ag.TextScaled = true
ag.Font = Enum.Font.GothamBold
ag.Parent = sg
Instance.new("UICorner", ag).CornerRadius = UDim.new(0, 20)

-- Main Panel
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 320, 0, 450)
panel.Position = UDim2.new(0.5, -160, 0.2, 0)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
panel.Visible = true
panel.Parent = sg
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 50)
top.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
top.Parent = panel
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Text = "AG MM2"
title.Size = UDim2.new(1, -60, 1, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = top

local close = Instance.new("TextButton")
close.Text = "✕"
close.Size = UDim2.new(0, 50, 1, 0)
close.Position = UDim2.new(1, -50, 0, 0)
close.BackgroundTransparency = 1
close.TextColor3 = Color3.new(1,1,1)
close.TextScaled = true
close.Parent = top

-- Click AG to toggle panel
ag.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

close.MouseButton1Click:Connect(function()
    panel.Visible = false
end)

-- Simple Toggle Example
local y = 70
local function addToggle(text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -20, 0, 65)
    f.Position = UDim2.new(0, 10, 0, y)
    f.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    f.Parent = panel
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)

    local l = Instance.new("TextLabel")
    l.Text = text
    l.Size = UDim2.new(0.65, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.new(1,1,1)
    l.TextSize = 20
    l.Parent = f

    local t = Instance.new("TextButton")
    t.Size = UDim2.new(0, 100, 0, 45)
    t.Position = UDim2.new(1, -115, 0.5, -22.5)
    t.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    t.Text = "OFF"
    t.TextColor3 = Color3.new(1,1,1)
    t.TextSize = 18
    t.Parent = f
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 10)

    y = y + 75
end

addToggle("ESP")
addToggle("Shoot Murder Button")
addToggle("TP to Gun Button")
addToggle("Kill Random Button")
addToggle("Inf Jump")
addToggle("Noclip")

print("AG MM2 Minimal Version Loaded")
game.StarterGui:SetCore("SendNotification", {
    Title = "AG MM2",
    Text = "Panel should be visible now!",
    Duration = 10
})
