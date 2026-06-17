-- AG MM2 - Ultra Simple for Delta Mobile

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Force new ScreenGui
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.Parent = playerGui

-- AG Main Button
local ag = Instance.new("TextButton")
ag.Size = UDim2.new(0, 90, 0, 90)
ag.Position = UDim2.new(0, 30, 0, 100)
ag.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
ag.Text = "AG"
ag.TextColor3 = Color3.new(1,1,1)
ag.TextScaled = true
ag.Font = Enum.Font.GothamBold
ag.Parent = sg
Instance.new("UICorner", ag).CornerRadius = UDim.new(0, 25)

-- ACTION BUTTONS
local function makeBtn(name, text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 300, 0, 95)
    b.Position = UDim2.new(0.5, -150, y, 0)
    b.BackgroundColor3 = Color3.fromRGB(200, 20, 20)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Parent = sg
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 18)

    b.MouseButton1Click:Connect(function()
        game.StarterGui:SetCore("SendNotification", {Title = "Clicked", Text = text, Duration = 3})
    end)
    b.TouchTap:Connect(function()
        game.StarterGui:SetCore("SendNotification", {Title = "Clicked", Text = text, Duration = 3})
    end)

    return b
end

-- Create buttons
local shoot = makeBtn("shoot", "🔫 SHOOT MURDER", 0.25)
local tp = makeBtn("tp", "🔫 TP TO GUN", 0.48)
local kill = makeBtn("kill", "💀 KILL RANDOM", 0.71)

print("AG MM2 Simple Buttons Created")
game.StarterGui:SetCore("SendNotification", {
    Title = "AG MM2",
    Text = "Buttons should appear now! Tap them.",
    Duration = 10
})
