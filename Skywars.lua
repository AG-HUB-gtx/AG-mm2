-- SkyWars GUI (Main, Blacksmith, Merchant, Perm Buffs)
-- Error‑proof remotes, full features, no All tab, no Wall Walk

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then player = Players:WaitForChild("LocalPlayer") end
local playerGui = player:WaitForChild("PlayerGui")

-- ---- Remote IDs ----
local REMOTE_IDS = {
    PLAYER = "93b2718b-2b2a-4859-b36e-fd4614c7f0c9",
    BLACKSMITH_BUY = "11788c3d-970c-4db8-a442-8a6f6e823b72",
    BLACKSMITH_UPGRADE = "97c8fa11-dd8b-479e-ac76-ee2d8b654971",
    MERCHANT = "2fc3b306-ea1f-4b39-95ce-a7b0298a2d7f",
}

-- ---- Safely get remotes ----
local function getRemote(remoteId)
    local success, result = pcall(function()
        return ReplicatedStorage:WaitForChild("Kw8"):WaitForChild(remoteId)
    end)
    if not success then
        warn("Remote not found: Kw8." .. remoteId)
        return nil
    end
    return result
end

local playerRemote = getRemote(REMOTE_IDS.PLAYER)
local blacksmithBuyRemote = getRemote(REMOTE_IDS.BLACKSMITH_BUY)
local blacksmithUpgradeRemote = getRemote(REMOTE_IDS.BLACKSMITH_UPGRADE)
local merchantRemote = getRemote(REMOTE_IDS.MERCHANT)

-- ---- Utility functions ----
local function getRootPart()
    local char = player.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function teleportTo(position)
    local root = getRootPart()
    if root and root:IsA("BasePart") then
        root.CFrame = CFrame.new(position)
    end
end

local function getHitboxes(typeName)
    local hitboxes = {}
    for _, child in ipairs(Workspace:GetChildren()) do
        if child.Name == typeName then
            local hitbox = child:FindFirstChild("Hitbox")
            if hitbox and hitbox:IsA("BasePart") then
                table.insert(hitboxes, hitbox)
            end
        end
    end
    return hitboxes
end

local function getShardHitboxes()
    local shard = Workspace:FindFirstChild("Shard")
    if shard then
        local hitbox = shard:FindFirstChild("Hitbox")
        if hitbox and hitbox:IsA("BasePart") then
            return {hitbox}
        end
    end
    return {}
end

local function getAllHitboxes()
    local all = {}
    for _, t in ipairs({"BronzeCoin", "IronCoin", "GoldCoin"}) do
        for _, h in ipairs(getHitboxes(t)) do
            table.insert(all, h)
        end
    end
    for _, h in ipairs(getShardHitboxes()) do
        table.insert(all, h)
    end
    return all
end

-- ----- Kill Aura loop -----
local killAuraThread = nil
local function startKillAura(runningRef)
    if killAuraThread then return end
    if not playerRemote then
        warn("Kill Aura remote missing")
        return
    end
    killAuraThread = spawn(function()
        while runningRef.KillAura do
            for _, plr in ipairs(Players:GetPlayers()) do
                playerRemote:FireServer(plr)
            end
            task.wait(0.1)
        end
        killAuraThread = nil
    end)
end

-- ----- Farm loops -----
local farmThreads = {}
local function startFarmLoop(getHitboxesFunc, runningRef, key)
    if farmThreads[key] then return end
    farmThreads[key] = spawn(function()
        local index = 1
        while runningRef[key] do
            local hitboxes = getHitboxesFunc()
            if #hitboxes > 0 then
                local part = hitboxes[index]
                if part and part:IsA("BasePart") and part.Parent then
                    teleportTo(part.Position + Vector3.new(0, 2, 0))
                end
                index = index % #hitboxes + 1
            end
            task.wait(0.2)
        end
        farmThreads[key] = nil
    end)
end

-- ----- Toggle states -----
local running = {
    KillAura = false,
    FarmBronze = false,
    FarmIron = false,
    FarmGold = false,
    FarmShards = false,
    FarmAllCoins = false,
}

-- ----- Helper: rounded corners ----
local function addRoundedCorners(obj, radius)
    radius = radius or 8
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
end

-- ----- Store previous position for Return button ----
local previousPosition = nil

-- ----- Create hollow cube at AFK coordinates ----
local function createHollowBox(position, size, color)
    size = size or 32
    local half = size/2
    local folder = Instance.new("Folder")
    folder.Name = "AFKHollowCube"
    folder.Parent = Workspace

    local floor = Instance.new("Part")
    floor.Size = Vector3.new(size, 1, size)
    floor.Position = position + Vector3.new(0, -half, 0)
    floor.Anchored = true
    floor.CanCollide = true
    floor.BrickColor = BrickColor.new(color or "Bright blue")
    floor.Material = Enum.Material.SmoothPlastic
    floor.Transparency = 0.4
    floor.Parent = folder

    local roof = floor:Clone()
    roof.Position = position + Vector3.new(0, half, 0)
    roof.Parent = folder

    for _, zOffset in ipairs({-half, half}) do
        local wall = Instance.new("Part")
        wall.Size = Vector3.new(size, size, 1)
        wall.Position = position + Vector3.new(0, 0, zOffset)
        wall.Anchored = true
        wall.CanCollide = true
        wall.BrickColor = BrickColor.new(color or "Bright blue")
        wall.Material = Enum.Material.SmoothPlastic
        wall.Transparency = 0.4
        wall.Parent = folder
    end

    for _, xOffset in ipairs({-half, half}) do
        local wall = Instance.new("Part")
        wall.Size = Vector3.new(1, size, size)
        wall.Position = position + Vector3.new(xOffset, 0, 0)
        wall.Anchored = true
        wall.CanCollide = true
        wall.BrickColor = BrickColor.new(color or "Bright blue")
        wall.Material = Enum.Material.SmoothPlastic
        wall.Transparency = 0.4
        wall.Parent = folder
    end
end

local afkCoord = Vector3.new(-650, 87854, -3715)
createHollowBox(afkCoord, 32, "Bright blue")

-- ============ BUILD GUI ============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SkyWarsGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 493)
mainFrame.Position = UDim2.new(1, -360, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
addRoundedCorners(mainFrame, 10)

-- ---- Title ----
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "SkyWars"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextSize = 24
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- ---- Close button ----
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.AutoButtonColor = true
closeBtn.Parent = mainFrame
addRoundedCorners(closeBtn, 6)

-- ---- Show/Hide ----
local showButton = nil
closeBtn.Activated:Connect(function()
    mainFrame.Visible = false
    if not showButton then
        showButton = Instance.new("TextButton")
        showButton.Size = UDim2.new(0, 150, 0, 30)
        showButton.Position = UDim2.new(0.5, -75, 0, 5)
        showButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        showButton.BorderSizePixel = 0
        showButton.Text = "Show SkyWars"
        showButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        showButton.TextSize = 16
        showButton.Font = Enum.Font.SourceSansBold
        showButton.AutoButtonColor = true
        showButton.Parent = screenGui
        addRoundedCorners(showButton, 8)
        showButton.Activated:Connect(function()
            mainFrame.Visible = true
            showButton:Destroy()
            showButton = nil
        end)
    end
end)

-- ---- Tab bar (static, no All) ----
local TAB_WIDTH = 85
local TAB_HEIGHT = 25
local TAB_SPACING = 10

local tabOrder = {"Main", "Blacksmith", "Merchant", "Perm Buffs"}
local tabButtons = {}

local tabBar = Instance.new("ScrollingFrame")
tabBar.Size = UDim2.new(1, 0, 0, 30)
tabBar.Position = UDim2.new(0, 0, 0, 35)
tabBar.BackgroundTransparency = 1
tabBar.BorderSizePixel = 0

-- ✨ EXACT canvas width – no trailing empty space
local firstTabX = 5
local lastTabX = firstTabX + (#tabOrder - 1) * (TAB_WIDTH + TAB_SPACING) + TAB_WIDTH
tabBar.CanvasSize = UDim2.new(lastTabX, 0, 0, 0)

tabBar.ScrollBarThickness = 4
tabBar.HorizontalScrollBarInset = Enum.ScrollBarInset.None
tabBar.VerticalScrollBarInset = Enum.ScrollBarInset.None
tabBar.Parent = mainFrame

-- ---- Content container ----
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, 0, 1, -65)
contentContainer.Position = UDim2.new(0, 0, 0, 65)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = mainFrame

-- ---- Content frames ----
local function createContentFrame()
    local f = Instance.new("ScrollingFrame")
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.CanvasSize = UDim2.new(0, 0, 0, 0)
    f.ScrollBarThickness = 6
    f.Parent = contentContainer
    f.Visible = false
    return f
end

local mainScroll = createContentFrame()
local blacksmithScroll = createContentFrame()
local merchantScroll = createContentFrame()
local permBuffsScroll = createContentFrame()

-- ---- Button templates ----
local buttonTemplate = Instance.new("TextButton")
buttonTemplate.Size = UDim2.new(0, 300, 0, 40)
buttonTemplate.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
buttonTemplate.BorderSizePixel = 0
buttonTemplate.Text = ""
buttonTemplate.Font = Enum.Font.SourceSans
buttonTemplate.TextSize = 14
buttonTemplate.AutoButtonColor = false

local subTextTemplate = Instance.new("TextLabel")
subTextTemplate.Size = UDim2.new(1, 0, 0, 16)
subTextTemplate.Position = UDim2.new(0, 0, 0, 24)
subTextTemplate.BackgroundTransparency = 1
subTextTemplate.TextColor3 = Color3.fromRGB(200, 200, 200)
subTextTemplate.TextSize = 12
subTextTemplate.Font = Enum.Font.SourceSans
subTextTemplate.Text = ""
subTextTemplate.TextXAlignment = Enum.TextXAlignment.Center
subTextTemplate.TextYAlignment = Enum.TextYAlignment.Top

-- ---- Helper: add buttons to scroll (used for Main, Merchant) ----
local function addButtonsToScroll(scroll, buttonData, yOffset, subtextHeight)
    subtextHeight = subtextHeight or 16
    local hasSubtext = false
    for _, data in ipairs(buttonData) do
        if data.subtext and data.subtext ~= "" then
            hasSubtext = true
            break
        end
    end
    local baseHeight = 40
    local uniformHeight = hasSubtext and (baseHeight + subtextHeight + 4) or baseHeight

    local refs = {}
    local y = yOffset or 5
    local spacing = 5
    for _, data in ipairs(buttonData) do
        local button = buttonTemplate:Clone()
        button.Size = UDim2.new(0, 300, 0, uniformHeight)
        button.Parent = scroll
        button.Position = UDim2.new(0.5, -150, 0, y)
        addRoundedCorners(button, 6)
        refs[data.label] = button

        local mainLabelHeight = hasSubtext and (uniformHeight - subtextHeight - 4) or uniformHeight
        if mainLabelHeight < 20 then mainLabelHeight = 20 end
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, mainLabelHeight)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = data.label
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 16
        label.Font = Enum.Font.SourceSansBold
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.Parent = button

        if hasSubtext then
            local sub = subTextTemplate:Clone()
            sub.Size = UDim2.new(1, 0, 0, subtextHeight)
            sub.Position = UDim2.new(0, 0, 0, mainLabelHeight + 2)
            sub.Text = data.subtext or ""
            sub.Parent = button
        end

        y = y + uniformHeight + spacing
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)
    return refs
end

-- ---- Helper: build a "set row" (label, textbox, set button) ----
local function buildSetRow(parent, labelText, placeholderText, setCallback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(0, 300, 0, 40)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local label = Instance.new("TextButton")
    label.Size = UDim2.new(0, 80, 0, 40)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    label.BorderSizePixel = 0
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.SourceSansBold
    label.AutoButtonColor = false
    label.Parent = row
    addRoundedCorners(label, 4)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 130, 0, 40)
    box.Position = UDim2.new(0, 85, 0, 0)
    box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    box.BorderSizePixel = 0
    box.Text = ""
    box.PlaceholderText = placeholderText
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextSize = 14
    box.Font = Enum.Font.SourceSans
    box.Parent = row
    addRoundedCorners(box, 4)

    local setBtn = Instance.new("TextButton")
    setBtn.Size = UDim2.new(0, 75, 0, 40)
    setBtn.Position = UDim2.new(0, 225, 0, 0)
    setBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    setBtn.BorderSizePixel = 0
    setBtn.Text = "Set"
    setBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setBtn.TextSize = 14
    setBtn.Font = Enum.Font.SourceSansBold
    setBtn.AutoButtonColor = true
    setBtn.Parent = row
    addRoundedCorners(setBtn, 4)

    setBtn.Activated:Connect(function()
        local val = tonumber(box.Text)
        if val then
            setCallback(val)
        end
    end)

    return row
end

-- ---- Main tab ----
local function buildMainTab()
    local refs = {}
    local y = 5
    local spacing = 5

    -- Kill Aura
    local kaBtn = buttonTemplate:Clone()
    kaBtn.Size = UDim2.new(0, 300, 0, 40 + 16 + 4)
    kaBtn.Parent = mainScroll
    kaBtn.Position = UDim2.new(0.5, -150, 0, y)
    addRoundedCorners(kaBtn, 6)
    refs["Kill Aura"] = kaBtn

    local kaLabel = Instance.new("TextLabel")
    kaLabel.Size = UDim2.new(1, 0, 0, 40)
    kaLabel.Position = UDim2.new(0, 0, 0, 0)
    kaLabel.BackgroundTransparency = 1
    kaLabel.Text = "Kill Aura"
    kaLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    kaLabel.TextSize = 16
    kaLabel.Font = Enum.Font.SourceSansBold
    kaLabel.TextXAlignment = Enum.TextXAlignment.Center
    kaLabel.TextYAlignment = Enum.TextYAlignment.Center
    kaLabel.Parent = kaBtn

    local kaSub = subTextTemplate:Clone()
    kaSub.Size = UDim2.new(1, 0, 0, 16)
    kaSub.Position = UDim2.new(0, 0, 0, 40 + 2)
    kaSub.Text = "Hold Weapon"
    kaSub.Parent = kaBtn

    y = y + (40 + 16 + 4) + spacing

    local farmLabels = {"Farm Bronze Coins", "Farm Iron Coins", "Farm Gold Coins", "Farm Shards", "Farm All", "AFKBox", "Return"}
    for _, label in ipairs(farmLabels) do
        local btn = buttonTemplate:Clone()
        btn.Size = UDim2.new(0, 300, 0, 40)
        btn.Parent = mainScroll
        btn.Position = UDim2.new(0.5, -150, 0, y)
        addRoundedCorners(btn, 6)
        refs[label] = btn

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 40)
        lbl.Position = UDim2.new(0, 0, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.TextSize = 16
        lbl.Font = Enum.Font.SourceSansBold
        lbl.TextXAlignment = Enum.TextXAlignment.Center
        lbl.TextYAlignment = Enum.TextYAlignment.Center
        lbl.Parent = btn

        y = y + 40 + spacing
    end

    mainScroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)
    return refs
end

local mainRefs = buildMainTab()
mainScroll.Visible = false

-- ---- Blacksmith tab ----
local upgradeData = {
    {label = "Upgrade Armor", subtext = "1st Upgrade Costs 25 Bronze\n2nd Upgrade Costs 25 Iron\n3rd Upgrade Costs 35 Iron\n4th Upgrade Costs 30 Gold", index = 0},
    {label = "Upgrade Weapon", subtext = "1st Upgrade Costs 15 Bronze\n2nd Upgrade Costs 15 Iron\n3rd Upgrade Costs 24 Iron\n4th Upgrade Costs 36 Iron", index = 1},
    {label = "Upgrade Pickaxe", subtext = "1st Upgrade Costs 12 Bronze\n2nd Upgrade Costs 16 Bronze\n3rd Upgrade Costs 24 Iron\n4th Upgrade Costs 32 Iron", index = 2},
}

local rowContainer = Instance.new("Frame")
rowContainer.Size = UDim2.new(0, 300, 0, 120)
rowContainer.Position = UDim2.new(0.5, -150, 0, 5)
rowContainer.BackgroundTransparency = 1
rowContainer.Parent = blacksmithScroll

local upgradeButtons = {}
local buttonWidth = 90
local spacing = 10
local totalWidth = buttonWidth * 3 + spacing * 2
local startX = (300 - totalWidth) / 2

for i, data in ipairs(upgradeData) do
    local group = Instance.new("Frame")
    group.Size = UDim2.new(0, buttonWidth, 0, 120)
    group.Position = UDim2.new(0, startX + (i-1) * (buttonWidth + spacing), 0, 0)
    group.BackgroundTransparency = 1
    group.Parent = rowContainer

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = data.label
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.SourceSansBold
    btn.AutoButtonColor = false
    btn.Parent = group
    addRoundedCorners(btn, 4)
    upgradeButtons[data.label] = btn

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 90)
    sub.Position = UDim2.new(0, 0, 0, 32)
    sub.BackgroundTransparency = 1
    sub.Text = data.subtext
    sub.TextColor3 = Color3.fromRGB(200, 200, 200)
    sub.TextSize = 11
    sub.Font = Enum.Font.SourceSans
    sub.TextXAlignment = Enum.TextXAlignment.Center
    sub.TextYAlignment = Enum.TextYAlignment.Top
    sub.TextWrapped = true
    sub.Parent = group
end

local buyButtonData = {
    {label = "Buy Team Blocks (6 Bronze)", subtext = ""},
    {label = "Buy Wooden Planks (16 Bronze)", subtext = ""},
    {label = "Buy Stone Bricks (24 Bronze)", subtext = ""},
    {label = "Buy Aqua Blocks (8 Iron)", subtext = ""},
    {label = "Buy Iron Blocks (16 Iron)", subtext = ""},
    {label = "Buy Snowballs (12 Bronze)", subtext = ""},
    {label = "Buy Bow (20 Bronze)", subtext = ""},
    {label = "Buy Arrows (9 Bronze)", subtext = ""},
    {label = "Buy Ender Pearl (5 Gold)", subtext = ""},
    {label = "Buy Dynamite (6 Gold)", subtext = ""},
    {label = "Buy Boost Syringe (8 Gold)", subtext = ""},
    {label = "Buy Explosive Trap (5 Gold)", subtext = ""},
    {label = "Buy Fling Trap (5 Gold)", subtext = ""},
    {label = "Buy Fishing Rod (8 Gold)", subtext = ""},
}
local buyRefs = {}
local y = 125
for _, data in ipairs(buyButtonData) do
    local btn = buttonTemplate:Clone()
    btn.Size = UDim2.new(0, 300, 0, 40)
    btn.Parent = blacksmithScroll
    btn.Position = UDim2.new(0.5, -150, 0, y)
    addRoundedCorners(btn, 6)
    buyRefs[data.label] = btn
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 40)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = data.label
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.SourceSansBold
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = btn
    y = y + 45
end
blacksmithScroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)
blacksmithScroll.Visible = false

-- ---- Merchant tab ----
local merchantSubtext = "Tier I Costs 5 Shards\nTier II Costs 10 Shards\nTier III Costs 15 Shards"
local merchantButtonData = {
    {label = "Tier Up Triump", subtext = merchantSubtext},
    {label = "Tier Up Vampyrism", subtext = merchantSubtext},
    {label = "Tier Up Healing Wizard", subtext = merchantSubtext},
    {label = "Tier Up Last Stand", subtext = merchantSubtext},
    {label = "Tier Up Looting Luck", subtext = merchantSubtext},
    {label = "Tier Up Generator", subtext = merchantSubtext},
}
local merchantRefs = addButtonsToScroll(merchantScroll, merchantButtonData, 5, 40)
merchantScroll.Visible = false

-- ---- Perm Buffs tab ----
local permBuffs = {
    voidFloat = false,
    walkSpeed = nil,
    jumpPower = nil,
    hipHeight = nil,
    gravity = nil,
    clickTeleport = false,
}

-- ---- Void Float ----
local voidFloatPart = nil
local voidFloatThread = nil
local voidFloatInitialY = nil

local function startVoidFloat()
    if voidFloatThread then return end
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local rigType = hum and hum.RigType or Enum.HumanoidRigType.R15

    local leftFoot, rightFoot
    if rigType == Enum.HumanoidRigType.R15 then
        leftFoot = char:FindFirstChild("LeftFoot")
        rightFoot = char:FindFirstChild("RightFoot")
    end
    if not leftFoot or not rightFoot then
        leftFoot = char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
        rightFoot = leftFoot
    end
    if not leftFoot then return end

    local leftPos = leftFoot.Position
    local rightPos = rightFoot.Position
    local midPos = (leftPos + rightPos) / 2
    voidFloatInitialY = math.min(leftPos.Y, rightPos.Y) - 0.5

    local part = Instance.new("Part")
    part.Size = Vector3.new(10, 1, 10)
    part.Anchored = true
    part.CanCollide = true
    part.Transparency = 0.3
    part.BrickColor = BrickColor.new("White")
    part.Material = Enum.Material.SmoothPlastic
    part.Parent = Workspace
    voidFloatPart = part
    part.Position = Vector3.new(midPos.X, voidFloatInitialY, midPos.Z)

    voidFloatThread = spawn(function()
        while permBuffs.voidFloat and char and char.Parent and leftFoot and leftFoot.Parent and rightFoot and rightFoot.Parent do
            local leftPos = leftFoot.Position
            local rightPos = rightFoot.Position
            local midPos = (leftPos + rightPos) / 2
            part.Position = Vector3.new(midPos.X, voidFloatInitialY, midPos.Z)
            task.wait(0.0001)
        end
        if part then part:Destroy() end
        voidFloatPart = nil
        voidFloatThread = nil
    end)
end

local function stopVoidFloat()
    permBuffs.voidFloat = false
    if voidFloatThread then
        task.cancel(voidFloatThread)
        voidFloatThread = nil
    end
    if voidFloatPart then
        voidFloatPart:Destroy()
        voidFloatPart = nil
    end
    voidFloatInitialY = nil
end

-- ---- Apply stats ----
local function applyWalkSpeed()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and permBuffs.walkSpeed then
        hum.WalkSpeed = permBuffs.walkSpeed
    end
end

local function applyJumpPower()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and permBuffs.jumpPower then
        hum.JumpPower = permBuffs.jumpPower
    end
end

local function applyHipHeight()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and permBuffs.hipHeight then
        hum.HipHeight = permBuffs.hipHeight
    end
end

local function applyGravity()
    if permBuffs.gravity then
        Workspace.Gravity = permBuffs.gravity
    else
        Workspace.Gravity = 196.2
    end
end

-- ---- Click Teleport ----
local clickTeleportConnection = nil
local function toggleClickTeleport(state)
    if state then
        if clickTeleportConnection then clickTeleportConnection:Disconnect() end
        clickTeleportConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local mouse = player:GetMouse()
                if mouse and mouse.Hit then
                    local pos = mouse.Hit.Position
                    local char = player.Character
                    if char then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            root.CFrame = CFrame.new(pos)
                        end
                    end
                end
            end
        end)
    else
        if clickTeleportConnection then
            clickTeleportConnection:Disconnect()
            clickTeleportConnection = nil
        end
    end
end

-- ---- Build Perm Buffs tab ----
local function buildPermBuffsTab()
    local y = 5
    local spacing = 8

    -- WalkSpeed row
    buildSetRow(permBuffsScroll, "WalkSpeed", "Enter Speed, Eg 60", function(val) permBuffs.walkSpeed = val; applyWalkSpeed() end).Position = UDim2.new(0.5, -150, 0, y)
    y = y + 40 + spacing

    -- JumpPower row
    buildSetRow(permBuffsScroll, "JumpPower", "Enter JumpPower, Eg 60", function(val) permBuffs.jumpPower = val; applyJumpPower() end).Position = UDim2.new(0.5, -150, 0, y)
    y = y + 40 + spacing

    -- HipHeight row
    buildSetRow(permBuffsScroll, "HipHeight", "Enter HipHeight, Eg 2", function(val) permBuffs.hipHeight = val; applyHipHeight() end).Position = UDim2.new(0.5, -150, 0, y)
    y = y + 40 + spacing

    -- Gravity row
    buildSetRow(permBuffsScroll, "Gravity", "Enter Gravity, Eg 196.2", function(val) permBuffs.gravity = val; applyGravity() end).Position = UDim2.new(0.5, -150, 0, y)
    y = y + 40 + spacing

    -- Click Teleport toggle
    local ctBtn = Instance.new("TextButton")
    ctBtn.Size = UDim2.new(0, 300, 0, 40)
    ctBtn.Position = UDim2.new(0.5, -150, 0, y)
    ctBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ctBtn.BorderSizePixel = 0
    ctBtn.Text = "Click Teleport"
    ctBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ctBtn.TextSize = 16
    ctBtn.Font = Enum.Font.SourceSansBold
    ctBtn.AutoButtonColor = false
    ctBtn.Parent = permBuffsScroll
    addRoundedCorners(ctBtn, 6)
    ctBtn.Activated:Connect(function()
        permBuffs.clickTeleport = not permBuffs.clickTeleport
        ctBtn.BackgroundColor3 = permBuffs.clickTeleport and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        toggleClickTeleport(permBuffs.clickTeleport)
    end)
    y = y + 40 + spacing

    -- Void Float toggle
    local vfBtn = Instance.new("TextButton")
    vfBtn.Size = UDim2.new(0, 300, 0, 40)
    vfBtn.Position = UDim2.new(0.5, -150, 0, y)
    vfBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    vfBtn.BorderSizePixel = 0
    vfBtn.Text = "Void Float"
    vfBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    vfBtn.TextSize = 16
    vfBtn.Font = Enum.Font.SourceSansBold
    vfBtn.AutoButtonColor = false
    vfBtn.Parent = permBuffsScroll
    addRoundedCorners(vfBtn, 6)
    vfBtn.Activated:Connect(function()
        permBuffs.voidFloat = not permBuffs.voidFloat
        vfBtn.BackgroundColor3 = permBuffs.voidFloat and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        if permBuffs.voidFloat then startVoidFloat() else stopVoidFloat() end
    end)
    y = y + 40 + spacing

    permBuffsScroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

buildPermBuffsTab()
permBuffsScroll.Visible = false

-- ---- Tab switching function ----
local function switchTab(tabName)
    -- Highlight the active tab
    for _, data in ipairs(tabButtons) do
        data.button.BackgroundColor3 = (data.name == tabName) and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
    end

    -- Hide all content frames
    for _, frame in ipairs({mainScroll, blacksmithScroll, merchantScroll, permBuffsScroll}) do
        if frame then frame.Visible = false end
    end

    -- Show the chosen tab
    if tabName == "Main" and mainScroll then mainScroll.Visible = true
    elseif tabName == "Blacksmith" and blacksmithScroll then blacksmithScroll.Visible = true
    elseif tabName == "Merchant" and merchantScroll then merchantScroll.Visible = true
    elseif tabName == "Perm Buffs" and permBuffsScroll then permBuffsScroll.Visible = true
    end
end

-- ---- Create tab buttons and connect ----
for i, name in ipairs(tabOrder) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, TAB_WIDTH, 0, TAB_HEIGHT)
    btn.Position = UDim2.new(0, (i-1) * (TAB_WIDTH + TAB_SPACING) + 5, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansBold
    btn.AutoButtonColor = true
    btn.Parent = tabBar
    addRoundedCorners(btn, 5)
    btn.Name = "TabButton"

    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
    btn.TouchTap:Connect(function()
        switchTab(name)
    end)

    tabButtons[i] = {button = btn, name = name}
end

-- ---- Default tab ----
switchTab("Main")

-- ---- Flash effect ----
local buttonTweens = {}
local function flashButton(button)
    spawn(function()
        if buttonTweens[button] then
            buttonTweens[button]:Cancel()
            buttonTweens[button] = nil
        end
        local originalColor = button.BackgroundColor3
        local flashColor = Color3.fromRGB(200, 200, 200)
        button.BackgroundColor3 = flashColor
        task.wait(0.01)
        local tweenBack = TweenService:Create(button, TweenInfo.new(0.003, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundColor3 = originalColor})
        buttonTweens[button] = tweenBack
        tweenBack:Play()
        tweenBack.Completed:Wait()
        buttonTweens[button] = nil
    end)
end

-- ---- Apply persistent buffs on character spawn ----
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if permBuffs.walkSpeed then applyWalkSpeed() end
    if permBuffs.jumpPower then applyJumpPower() end
    if permBuffs.hipHeight then applyHipHeight() end
    if permBuffs.gravity then applyGravity() end
    if permBuffs.voidFloat then startVoidFloat() end
    if permBuffs.clickTeleport then toggleClickTeleport(true) end
end)

-- ---- Connect all buttons ----
local function setButtonState(button, isOn)
    button.BackgroundColor3 = isOn and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
end

-- Main
mainRefs["Kill Aura"].Activated:Connect(function()
    local key = "KillAura"
    running[key] = not running[key]
    setButtonState(mainRefs["Kill Aura"], running[key])
    if running[key] then
        startKillAura(running)
    end
end)

local farmMap = {
    ["Farm Bronze Coins"] = {key = "FarmBronze", getter = function() return getHitboxes("BronzeCoin") end},
    ["Farm Iron Coins"]   = {key = "FarmIron",   getter = function() return getHitboxes("IronCoin") end},
    ["Farm Gold Coins"]   = {key = "FarmGold",   getter = function() return getHitboxes("GoldCoin") end},
    ["Farm Shards"]       = {key = "FarmShards", getter = getShardHitboxes},
    ["Farm All"]          = {key = "FarmAllCoins", getter = getAllHitboxes},
}
for label, info in pairs(farmMap) do
    local btn = mainRefs[label]
    btn.Activated:Connect(function()
        running[info.key] = not running[info.key]
        setButtonState(btn, running[info.key])
        if running[info.key] then
            startFarmLoop(info.getter, running, info.key)
        end
    end)
end

mainRefs["AFKBox"].Activated:Connect(function()
    flashButton(mainRefs["AFKBox"])
    local root = getRootPart()
    if root then
        local distance = (root.Position - afkCoord).Magnitude
        if distance > 40000 then
            previousPosition = root.CFrame
        end
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        rootPart.CFrame = CFrame.new(afkCoord)
    end
end)

mainRefs["Return"].Activated:Connect(function()
    flashButton(mainRefs["Return"])
    if previousPosition then
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart")
        rootPart.CFrame = previousPosition
    else
        print("No previous position stored.")
    end
end)

-- ---- Blacksmith upgrade ----
for label, btn in pairs(upgradeButtons) do
    local index = nil
    for _, data in ipairs(upgradeData) do
        if data.label == label then
            index = data.index
            break
        end
    end
    btn.Activated:Connect(function()
        flashButton(btn)
        if blacksmithUpgradeRemote then
            blacksmithUpgradeRemote:FireServer("Blacksmith", index)
        end
    end)
end

-- ---- Blacksmith buy ----
local blacksmithBuyIndices = {
    ["Buy Team Blocks (6 Bronze)"] = 0,
    ["Buy Wooden Planks (16 Bronze)"] = 1,
    ["Buy Stone Bricks (24 Bronze)"] = 2,
    ["Buy Aqua Blocks (8 Iron)"] = 3,
    ["Buy Iron Blocks (16 Iron)"] = 4,
    ["Buy Snowballs (12 Bronze)"] = 5,
    ["Buy Bow (20 Bronze)"] = 6,
    ["Buy Arrows (9 Bronze)"] = 7,
    ["Buy Ender Pearl (5 Gold)"] = 8,
    ["Buy Dynamite (6 Gold)"] = 9,
    ["Buy Boost Syringe (8 Gold)"] = 10,
    ["Buy Explosive Trap (5 Gold)"] = 11,
    ["Buy Fling Trap (5 Gold)"] = 12,
    ["Buy Fishing Rod (8 Gold)"] = 13,
}
for label, index in pairs(blacksmithBuyIndices) do
    local btn = buyRefs[label]
    if btn then
        btn.Activated:Connect(function()
            flashButton(btn)
            if blacksmithBuyRemote then
                blacksmithBuyRemote:FireServer("Blacksmith", index)
            else
                warn("Blacksmith buy remote missing")
            end
        end)
    end
end

-- ---- Merchant ----
local merchantIndices = {
    ["Tier Up Triump"] = 0,
    ["Tier Up Vampyrism"] = 1,
    ["Tier Up Healing Wizard"] = 2,
    ["Tier Up Last Stand"] = 3,
    ["Tier Up Looting Luck"] = 4,
    ["Tier Up Generator"] = 5,
}
for label, index in pairs(merchantIndices) do
    local btn = merchantRefs[label]
    if btn then
        btn.Activated:Connect(function()
            flashButton(btn)
            if merchantRemote then
                merchantRemote:FireServer("Merchant", index)
            else
                warn("Merchant remote missing")
            end
        end)
    end
end

print("SkyWars GUI fully loaded – Main, Blacksmith, Merchant, Perm Buffs (no All, no Wall Walk).")
