local fps = "120"
local SetFps = loadstring(game:HttpGet("https://raw.githubusercontent.com/Efield44444235364/Ff/refs/heads/main/Fpaload2(none).lua"))()

local executor = identifyexecutor and identifyexecutor() or "Unknown Executor"

pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title = executor .. " Executer Script Licence",
        Text = "FPS Unlock",
        Duration = 5
    })
end)

spawn(function()
    while true do
        pcall(function()
            SetFps(fps)  
        end)
        wait(0.0000001)
    end
end)
