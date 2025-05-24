local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

-- executor check
local executorName = "Unknown"
if identifyexecutor then
	local name = identifyexecutor()
	if typeof(name) == "string" then
		executorName = name
	end
end

--krnl is kick
if executorName == "Krnl" then
wait(2.5)
StarterGui:SetCore("SendNotification", {
	Title = player.name .. "r u use Krnl???",
	Text = "bitch",
	Duration = 5
})
     wait(2)
	game.Players.LocalPlayer:Kick("r u use Krnl?? go to sleep bitch krnl cant unlock fps i try it \n trust me u idiot clown")
end

-- codex kick
if executorName == "Codex" then
wait(2.5)
StarterGui:SetCore("SendNotification", {
	Title = player.name .. "r u use codex????",
	Text = "fuck u",
	Duration = 5
})
     wait(2)
	game.Players.LocalPlayer:Kick("codex cant unlock fps bitch hahahaha clown")
end

local bindable = Instance.new("BindableFunction")
function bindable.OnInvoke(response)
	if response == "Yes" then
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Efield44444235364/Ff/refs/heads/main/Fpsload1(none).lua"))()
	elseif response == "No" then
		print('อิห่านี่ ' .. player.Name .. ' เสือกกด "No" เฉย')
	end
end

-- notification 
StarterGui:SetCore("SendNotification", {
	Title = "Boost FPS??",
	Text = player.Name .. " | " .. executorName .. " Edition right licence",  -- เพิ่มชื่อผู้เล่นและ executor
	Duration = 200000000,
	Callback = bindable,
	Button1 = "Yes",
	Button2 = "No"
})
