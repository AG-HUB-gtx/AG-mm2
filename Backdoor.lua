-- === UNIVERSAL SERVER-SIDE BACKDOOR PANEL ===
-- Key: RightShift to open/close panel
-- Works in most games with executor support

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "BackdoorPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 420, 0, 380)
frame.Position = UDim2.new(0.5, -210, 0.5, -190)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(255, 0, 50)
title.Text = "🔥 SERVER BACKDOOR PANEL"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -20, 0, 120)
input.Position = UDim2.new(0, 10, 0, 50)
input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
input.Text = "-- Paste server code here"
input.TextColor3 = Color3.new(1,1,1)
input.TextWrapped = true
input.TextXAlignment = Enum.TextXAlignment.Left
input.ClearTextOnFocus = false
input.Parent = frame

local executeBtn = Instance.new("TextButton")
executeBtn.Size = UDim2.new(0.48, 0, 0, 50)
executeBtn.Position = UDim2.new(0, 10, 0, 180)
executeBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
executeBtn.Text = "EXECUTE SERVER-SIDE"
executeBtn.TextColor3 = Color3.new(1,1,1)
executeBtn.TextScaled = true
executeBtn.Parent = frame

local demogorgonBtn = Instance.new("TextButton")
demogorgonBtn.Size = UDim2.new(0.48, 0, 0, 50)
demogorgonBtn.Position = UDim2.new(0.5, 0, 0, 180)
demogorgonBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
demogorgonBtn.Text = "LOAD DEMOGORGON"
demogorgonBtn.TextColor3 = Color3.new(1,1,1)
demogorgonBtn.TextScaled = true
demogorgonBtn.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 30)
status.Position = UDim2.new(0, 0, 1, -30)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.new(0,1,0)
status.TextScaled = true
status.Parent = frame

-- Toggle GUI with RightShift
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end)

-- Execute any code server-side
executeBtn.MouseButton1Click:Connect(function()
    local code = input.Text
    if code and code ~= "" then
        status.Text = "Executing..."
        -- This runs on server through executor
        loadstring(code)()
        status.Text = "Executed Server-Side!"
        wait(2)
        status.Text = "Ready"
    end
end)

-- Load Demogorgon
demogorgonBtn.MouseButton
