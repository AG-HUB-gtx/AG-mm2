-- AG MM2 v5 - YARHM Enhanced ESP + Gun TP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

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

-- Draggable
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
