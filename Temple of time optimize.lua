local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local NotificationHandler = require(ReplicatedStorage:WaitForChild("NotificationSystem"):WaitForChild("NotificationHandler"))

-- รอจนกว่า Temple of Time จะมาอยู่ใน Workspace
local function waitForTemple()
    while not Workspace:FindFirstChild("Temple of Time") do
        task.wait()
    end
end

-- รอจนภายใน Temple โหลดครบ (อย่างน้อย 25 ชิ้น)
local function waitForTempleLoad()
    local temple = Workspace:WaitForChild("Temple of Time")
    repeat task.wait() until #temple:GetChildren() >= 110
end

-- ลบ Object แบบปลอดภัย
local function safeRemove(instance)
    if instance and instance:IsA("Instance") and instance.Parent then
        instance:Destroy()
    end
end

-- ลบ PerformanceBarrel และ PerformanceCrate ใน SpawnRoom
local function purgePerformanceStuff()
    local spawnRoom = Workspace["Temple of Time"]:FindFirstChild("SpawnRoom")
    if not spawnRoom then return end
    for _, child in ipairs(spawnRoom:GetChildren()) do
        if child:FindFirstChild("PerformanceBarrel") then
            safeRemove(child.PerformanceBarrel)
        end
        if child:FindFirstChild("PerformanceCrate") then
            safeRemove(child.PerformanceCrate)
        end
    end
end

-- ลบจุดเฉพาะ + Orbs + CyborgCorridor + GiantRoom
local function removeSpecificParts()
    local temple = Workspace["Temple of Time"]
    local function try(pathFunc)
        local success, result = pcall(pathFunc)
        if success and result then
            safeRemove(result)
        end
    end

    -- จุดเก่า
    try(function() return temple:GetChildren()[7]:GetChildren()[5] end)
    try(function() return temple:GetChildren()[25]:GetChildren()[6] end)
    try(function() return temple.GiantRoom:FindFirstChild("FallingLeaves") end)
    try(function() return temple.GiantRoom:GetChildren()[193] end)
    try(function() return temple.SpawnRoom:GetChildren()[13]:FindFirstChild("PerformanceBarrel") and temple.SpawnRoom:GetChildren()[13].PerformanceBarrel:FindFirstChild("Barrel") end)
    try(function() return temple.SpawnRoom:GetChildren()[13]:GetChildren()[4] end)
    try(function() return temple.SpawnRoom:GetChildren()[13]:FindFirstChild("PerformanceBarrel") end)
    try(function() return temple.SpawnRoom:GetChildren()[13]:FindFirstChild("PerformanceCrate") end)
    try(function() return temple.SpawnRoom:GetChildren()[13]:GetChildren()[2] end)

    -- Orbs
    local orbsFolder = temple:FindFirstChild("Orbs")
    if orbsFolder then
        for _, orb in ipairs(orbsFolder:GetChildren()) do
            safeRemove(orb)
        end
    end

    -- CyborgCorridor
    try(function() return temple.CyborgCorridor:GetChildren()[13] end)
    try(function() return temple.CyborgCorridor:GetChildren()[47] end)
    try(function() return temple.CyborgCorridor:GetChildren()[30]:GetChildren()[2] end)

    -- GiantRoom เพิ่มเติม
    try(function() return temple.GiantRoom:GetChildren()[52] end)
end

-- Main
task.spawn(function()
    waitForTemple()
    waitForTempleLoad()
    purgePerformanceStuff()
    removeSpecificParts()
    NotificationHandler:Notify("✅ Temple of Time optimized.")
end)
