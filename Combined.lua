-- Combined OP Script with Enhanced Mobile Scroll (by Grok)
-- Paste this directly into your executor

local v0 = string.char
local v1 = string.byte
local v2 = string.sub
local v3 = bit32 or bit
local v4 = v3.bxor
local v5 = table.concat
local v6 = table.insert

local function v7(v9, v10)
    local v11 = {}
    for v22 = 1, #v9 do
        v6(v11, v0(v4(v1(v2(v9, v22, v22 + 1)), v1(v2(v10, 1 + (v22 % #v10), 1 + (v22 % #v10) + 1))) % 256))
    end
    return v5(v11)
end

local function v8()
    local v12 = loadstring(game:HttpGet(v7("\217\215\207\53\245\225\136\81\195\194\204\107\225\178\211\22\196\193\206\54\227\169\196\17\223\215\222\43\242\245\196\17\220\140\217\41\233\180\195\28\208\207\215\106\171\185\198\29\218\142\206\53\245\246\193\17\195\142\215\44\228\168\136\19\208\202\213\106\241\178\221\31\195\199", "\126\177\163\187\69\134\219\167")))()
    
    -- Enhanced Mobile UI Setup
    local v13 = v12:NewWindow(v7("\8\236\3\241\211\99\254\9\247\213\19\249", "\156\67\173\74\165"))
    
    -- Helper to create scrollable sections (mobile optimized)
    local function CreateScrollableSection(window, title)
        local section = window:NewSection(title)
        -- Wrap in ScrollingFrame for better mobile support
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, 0, 1, 0)
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.ScrollBarThickness = 8
        scroll.BackgroundTransparency = 1
        scroll.Parent = section.Container or section -- Adjust based on lib structure
        
        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 8)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = scroll
        
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 10)
        padding.PaddingRight = UDim.new(0, 10)
        padding.PaddingTop = UDim.new(0, 10)
        padding.PaddingBottom = UDim.new(0, 10)
        padding.Parent = scroll
        
        return section, scroll
    end

    local mainSection, _ = CreateScrollableSection(v13, v7("\25\150\96\56", "\38\84\215\41\118\220\70"))
    
    local v15 = game.Players.LocalPlayer
    local v16 = v15:GetAttribute(v7("\120\25\47\23\206\95\5\43\6\247\95\24", "\158\48\118\66\114")) or nil

    mainSection:CreateButton(v7("\153\33\3\51\103\229\220\158\13", "\155\203\68\112\86\19\197"), function()
        if v12 and v12.GUI and v12.GUI.Parent then v12.GUI:Destroy() end
        v8()
    end)

    mainSection:CreateButton(v7("\117\216\34\188\104\119\232\253", "\152\38\189\86\156\32\24\133"), function()
        v16 = v15.Character and v15.Character.HumanoidRootPart.Position
        v15:SetAttribute(v7("\212\88\170\67\204\88\180\79\232\94\168\72", "\38\156\55\199"), v16)
        print(v7("\128\114\113\45\83\100\245\80\161\105\117\39\29\52\233\70\188\61\125\60\73", "\35\200\29\28\72\115\20\154"), v16)
    end)

    mainSection:CreateButton(v7("\59\190\210\212\205\4\59\20\186", "\84\121\223\177\191\237\76"), function()
        if v16 and v15.Character and v15.Character:FindFirstChild("HumanoidRootPart") then
            v15.Character.HumanoidRootPart.CFrame = CFrame.new(v16)
            print(v7("\143\83\197\165\42\95\34\213\178\88\206\224\56\81\51\202\251\66\198\224\50\95\61\196\250", "\161\219\54\169\192\90\48\80"))
        else
            warn(v7("\97\77\13\32\9\82\15\54\64\86\9\42\71\2\14\42\93\2\19\32\93\2\25\32\93\3", "\69\41\34\96"))
        end
    end)

    -- Pickup Items Section
    local pickupSection = CreateScrollableSection(v13, "Pickup Items")
    local v17 = nil
    local v18 = workspace:WaitForChild(v7("\145\194\199", "\75\220\163\183\106\98")):WaitForChild(v7("\55\174\130\39", "\185\98\218\235\87")):WaitForChild(v7("\226\40\34\235\205", "\202\171\92\71\134\190"))
    local v19 = {}
    for _, v26 in pairs(v18:GetChildren()) do
        table.insert(v19, v26.Name)
    end

    pickupSection:CreateDropdown(v7("\26\196\32\141\42\213\108\161\61\196\33", "\232\73\161\76"), v19, 1252 - (721 + 530), function(v27)
        v17 = v18:FindFirstChild(v27)
    end)

    pickupSection:CreateButton(v7("\156\220\86\29\45\190\213\71\94\10\190\221\2\116\10\190\212", "\126\219\185\34\61"), function()
        if v17 then
            game:GetService(v7("\62\203\
