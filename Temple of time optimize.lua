local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local TotalRemoved = 0
local function safeRemove(instance)
    if instance and instance:IsA("Instance") and instance.Parent then
        instance:Destroy()
        TotalRemoved += 1
    end
end

local function waitForTempleLoad()
    local notified = false
    repeat
        task.wait(1)
        local temple = Workspace:FindFirstChild("Temple of Time")
        local count = temple and #temple:GetDescendants() or 0

        if count < 110 and not notified then
            notified = true
            pcall(function()
                game.StarterGui:SetCore("SendNotification", {
                    Title = "Temple Optimizer",
                    Text = "⏳ รอ Temple of Time โหลด... (" .. count .. "/110)",
                    Duration = 5
                })
            end)
        end
    until Workspace:FindFirstChild("Temple of Time") and #Workspace["Temple of Time"]:GetDescendants() >= 110
end

local function purgePerformanceStuff()
    local temple = Workspace:FindFirstChild("Temple of Time")
    if not temple then return end
    for _, descendant in ipairs(temple:GetDescendants()) do
        if descendant.Name == "PerformanceBarrel" or descendant.Name == "PerformanceCrate" then
            safeRemove(descendant)
        end
    end
end

local function removeSpecificParts()
    local temple = Workspace["Temple of Time"]
    local function try(pathFunc)
        local success, result = pcall(pathFunc)
        if success and result then safeRemove(result) end
    end

    try(function() return temple["GiantRoom"]:GetChildren()[18]:FindFirstChild("FHead") end)
    try(function() return temple:FindFirstChild("Orbs") end)
    try(function() return temple:GetChildren()[78] end)
    try(function() return temple["GiantRoom"]:GetChildren()[43] end)
    try(function() return temple["GiantRoom"]:GetChildren()[57] end)
    try(function() return temple["GiantRoom"]:GetChildren()[58] end)
    try(function() return temple["GiantRoom"]:GetChildren()[52]:GetChildren()[6] end)
    try(function() return temple["GiantRoom"]:GetChildren()[52]:GetChildren()[5] end)
    try(function() return temple["GiantRoom"]:GetChildren()[186] end)
    try(function() return temple["GiantRoom"]:GetChildren()[42] end)

    -- เดิม
    try(function() return temple:GetChildren()[7]:GetChildren()[5] end)
    try(function() return temple:GetChildren()[25]:GetChildren()[6] end)
    try(function() return temple.GiantRoom:FindFirstChild("FallingLeaves") end)
    try(function() return temple.GiantRoom:GetChildren()[193] end)
    try(function() return temple.SpawnRoom:GetChildren()[13]:FindFirstChild("PerformanceBarrel") and temple.SpawnRoom:GetChildren()[13].PerformanceBarrel:FindFirstChild("Barrel") end)
    try(function() return temple.SpawnRoom:GetChildren()[13]:GetChildren()[4] end)
    try(function() return temple.SpawnRoom:GetChildren()[13]:FindFirstChild("PerformanceBarrel") end)
    try(function() return temple.SpawnRoom:GetChildren()[13]:FindFirstChild("PerformanceCrate") end)
    try(function() return temple.SpawnRoom:GetChildren()[13]:GetChildren()[2] end)
end

local function purgeExactOrb()
    local temple = Workspace:FindFirstChild("Temple of Time")
    if not temple then return end
    for _, descendant in ipairs(temple:GetDescendants()) do
        if descendant.Name == "Orb" then
            safeRemove(descendant)
        end
    end
end

local function optimizeLightingInTemple()
    local temple = Workspace:FindFirstChild("Temple of Time")
    if not temple then return end

    for _, obj in ipairs(temple:GetDescendants()) do
        if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            safeRemove(obj)
        end
        if obj:IsA("BasePart") and obj.Material == Enum.Material.Neon then
            obj.Material = Enum.Material.SmoothPlastic
        end
    end
end

local function showNotification(text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "Temple Optimizer",
            Text = text,
            Duration = 5
        })
    end)
end

task.spawn(function()
    waitForTempleLoad()
    purgePerformanceStuff()
    purgeExactOrb()
    removeSpecificParts()
    optimizeLightingInTemple()
    showNotification("ลบของตกแต่งสำเร็จทั้งหมด: " .. TotalRemoved .. " ชิ้น ✅")
end)
