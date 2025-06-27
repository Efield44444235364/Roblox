

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local executor = identifyexecutor and identifyexecutor() or "UnknownExecutor"
local placeId = game.PlaceId

local folderName = "Optimization"
local placeFolder = folderName.."/"..tostring(placeId)
if not isfolder(folderName) then makefolder(folderName) end
if not isfolder(placeFolder) then makefolder(placeFolder) end

local optimizeFile = string.format("%s/optimize_%s_%s.json", placeFolder, executor, placeId)
local errorFile = string.format("%s/err_%s.json", placeFolder, executor)

local optimizedCache = {}
local optimizeQueue = {}
local LOD_DistanceFar = 400
local LOD_DistanceNear = 150
local SkillOptimizeDistance = 300
local VegetationLODDistance = 40
local GrassFreezeDistance = 50
local OptimizeInterval = 1

-- 🌑 Disable Shadows and Light Reflection
local function DisableShadows()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10
    Lighting.ShadowSoftness = 0
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    if sethiddenproperty then
        pcall(function()
            sethiddenproperty(Lighting, "Technology", 2)
        end)
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Optimize",
            Text = "Executor does not support sethiddenproperty.",
            Duration = 6
        })
    end
end

if _G.Settings and (_G.Settings["No Shadows"] or (_G.Settings.Other and _G.Settings.Other["No Shadows"])) then
    DisableShadows()
end

-- 🌠 Reduce Lighting Effects Slightly
local function SoftenLighting()
    Lighting.Brightness = math.clamp(Lighting.Brightness * 0.8, 1, 2)
    Lighting.ExposureCompensation = Lighting.ExposureCompensation - 0.2
    Lighting.Ambient = Color3.new(0.4, 0.4, 0.4)
    Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
end
pcall(SoftenLighting)

-- 🌊 Water Optimization
if _G.Settings and (_G.Settings["Low Water Graphics"] or (_G.Settings.Other and _G.Settings.Other["Low Water Graphics"])) then
    task.spawn(function()
        while not workspace:FindFirstChildOfClass("Terrain") do task.wait() end
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0.1
        terrain.WaterTransparency = 0.2
        if sethiddenproperty then
            sethiddenproperty(terrain, "Decoration", false)
        end
    end)
end

-- 🧠 Load Cache
local function loadCache()
    if isfile(optimizeFile) then
        local ok, content = pcall(function()
            return HttpService:JSONDecode(readfile(optimizeFile))
        end)
        if ok and typeof(content) == "table" then
            optimizedCache = content
        end
    end
end

-- 💾 Save Cache
local function saveCache()
    local head = string.format("--[[\n  %s :\nMAP ID : %s\nExecute when : %s : %s\n(This is a debug log file pls do not change anything in file ok???)\n]]--\n\n\n",
        player.Name, placeId, os.date("%d/%m/%Y"), os.date("%H:%M:%S"))
    writefile(optimizeFile, head .. HttpService:JSONEncode(optimizedCache, true))
end

-- 🛡️ Safe Call
local function safeCall(fn, context)
    local success, result = pcall(fn)
    if not success then
        local err = {
            mapid = placeId,
            player = player.Name,
            executor = executor,
            message = tostring(result),
            context = context or "Unknown",
            timestamp = os.date("%c")
        }
        local head = string.format("--[[\n  Error MAP ID : %s\nPlayer Name : %s\nExecuter : %s\n\nNote : Error Log Pls Report to dev when you got some issues bug (anyybug u can report rnn)\n]]--\n\n\n",
            placeId, player.Name, executor)
        writefile(errorFile, head .. HttpService:JSONEncode(err, true))
    end
end

-- 🧱 Optimize Part
local function optimizePart(part)
    if not part:IsA("BasePart") then return end
    local id = part:GetFullName()
    if optimizedCache[id] then return end
    optimizedCache[id] = {
        Transparency = part.Transparency,
        Material = tostring(part.Material),
        Reflectance = part.Reflectance,
        Size = {part.Size.X, part.Size.Y, part.Size.Z}
    }
    part.Transparency = 0.7
    part.Material = Enum.Material.SmoothPlastic
    part.Reflectance = 0
end

-- ♻️ Restore Part
local function restorePart(part)
    if not part:IsA("BasePart") then return end
    local id = part:GetFullName()
    local data = optimizedCache[id]
    if not data then return end
    part.Transparency = data.Transparency or part.Transparency
    part.Material = Enum.Material[data.Material] or part.Material
    part.Reflectance = data.Reflectance or part.Reflectance
    if data.Size then
        part.Size = Vector3.new(unpack(data.Size))
    end
    optimizedCache[id] = nil
end

-- 🌿 Vegetation LOD
local function optimizeVegetation(part, distance)
    local name = string.lower(part.Name)
    if name:find("leaf") or name:find("grass") or name:find("bush") then
        if distance > VegetationLODDistance and not part:GetAttribute("__LowDetail") then
            part.Material = Enum.Material.SmoothPlastic
            part.Transparency = 0.6
            part:SetAttribute("__LowDetail", true)
        elseif distance <= VegetationLODDistance and part:GetAttribute("__LowDetail") then
            part.Material = Enum.Material.Grass
            part.Transparency = 0
            part:SetAttribute("__LowDetail", nil)
        end
    end
    if name:find("grass") or name:find("bush") then
        if distance > GrassFreezeDistance then
            part.Anchored = true
        else
            part.Anchored = false
        end
    end
end

-- 🌩️ Optimize Skill Effects
local function optimizeSkill(model, playerPos)
    if not model or not model:GetAttribute("__IsSkill") then return end
    local dist = (model:GetBoundingBox().Position - playerPos).Magnitude
    if dist > SkillOptimizeDistance then
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("ParticleEmitter") then
                d.Rate = math.max(1, d.Rate * 0.1)
                d.Size = NumberSequence.new(0.1)
                d.Transparency = NumberSequence.new(0.8)
                d.LightEmission = 0
                d.LightInfluence = 0
                d.ZOffset = -1
                d.VelocitySpread = 0
            elseif d:IsA("Trail") then
                d.Lifetime = NumberRange.new(0.05)
                d.Transparency = NumberSequence.new(1)
            elseif d:IsA("Beam") then
                d.Enabled = false
            elseif d:IsA("Decal") then
                d.Transparency = 1
            end
        end
    end
end

-- 🖋️ Optimize UI Text
local function optimizeUIText(ui)
    safeCall(function()
        if ui:IsA("TextLabel") or ui:IsA("TextButton") or ui:IsA("TextBox") then
            ui.Font = Enum.Font.SourceSans
            ui.TextScaled = false
            ui.RichText = false
            ui.TextSize = 14
        end
    end, "UI Optimize")
end

-- 📥 Queue Part
local function queuePart(part)
    if not part:IsA("BasePart") then return end
    table.insert(optimizeQueue, part)
end

-- 🔄 Process Queue
local function processQueue(playerPos)
    if #optimizeQueue == 0 then return end
    local part = table.remove(optimizeQueue, 1)
    local dist = (part.Position - playerPos).Magnitude
    optimizeVegetation(part, dist)
    if dist > LOD_DistanceFar then
        optimizePart(part)
    elseif dist < LOD_DistanceNear then
        restorePart(part)
    end
end

-- 🔁 Scan
local function scanParts()
    local playerPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not playerPos then return end
    playerPos = playerPos.Position

    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            queuePart(v)
        elseif v:IsA("Model") and v:GetAttribute("__IsSkill") then
            safeCall(function() optimizeSkill(v, playerPos) end, "SkillEffect")
        elseif v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
            optimizeUIText(v)
        end
    end
end

-- 🚀 Run
local lastUpdate = 0
RunService.Heartbeat:Connect(function(dt)
    lastUpdate += dt
    if lastUpdate >= OptimizeInterval then
        lastUpdate = 0
        local playerPos = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if playerPos then
            processQueue(playerPos.Position)
            scanParts()
            saveCache()
        end
    end
end)

loadCache()
print("✅ Full Optimize system loaded!")
