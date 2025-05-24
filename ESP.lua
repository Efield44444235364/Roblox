local Plr = game.Players.LocalPlayer.Name
_G.ESP = true

while _G.ESP do
    wait(0.5)
    pcall(function()
        for i, v in pairs(game.Players:GetPlayers()) do
            if v.Character and v.Name ~= Plr then
                local existingESP = v.Character:FindFirstChild("ESP")
                if _G.ESP and not existingESP then
                    local hl = Instance.new("Highlight")
                    hl.Name = "ESP"
                    hl.Parent = v.Character
                elseif not _G.ESP and existingESP then
                    existingESP:Destroy()
                end
            end
        end
    end)
end

print("Esp active")
