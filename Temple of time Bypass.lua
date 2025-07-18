local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Step 1: เช็ค RaceV4Progress
local success, result = pcall(function()
    return Remote:InvokeServer("RaceV4Progress", "Check")
end)
if not success then
    return
end

-- Step 2: Teleport ด้วย RaceV4Progress
pcall(function()
    Remote:InvokeServer("RaceV4Progress", "Teleport")
end)

-- รอให้ Server โหลด Temple
task.wait(0.1)

-- Step 3: เรียก Activate เพื่อโหลด Temple จริง (ปลดล็อกการใช้งานคันโยก)
pcall(function()
    Remote:InvokeServer("RaceV4Progress", "Activate")
end)

-- Step 4: ย้าย Temple จาก MapStash มา Workspace
local MapStash = ReplicatedStorage:FindFirstChild("MapStash")
if MapStash then
    local temple = MapStash:FindFirstChild("Temple of Time")
    if temple then
        temple.Parent = Workspace
    end
end

-- Step 5: ขอเข้า Temple
local templePos = Vector3.new(28286.35546875, 14895.3017578125, 102.62469482421875)
pcall(function()
    Remote:InvokeServer("requestEntrance", templePos)
end)

print(" [ ✅ ] Temple of time bypass sussed")
task.wait(2)
