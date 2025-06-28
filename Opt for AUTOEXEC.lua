

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

pcall(function()
    if LowRendering then
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
    end
end)

local player = Players.LocalPlayer
local executor = identifyexecutor and identifyexecutor() or "UnknownExecutor"
local placeId = game.PlaceId

local folderName = "Optimization"
local placeFolder = folderName.."/"..tostring(placeId)
if not isfolder(folderName) then makefolder(folderName) end
if not isfolder(placeFolder) then makefolder(placeFolder) end

local optimizeFile = string.format("%s/optimize_%s_%s.json", placeFolder, executor, placeId)
local optimizedCache = {}
local optimizeQueue = {}
local LOD_DistanceFar = 400
local LOD_DistanceNear = 150
local SkillOptimizeDistance = 300
local VegetationLODDistance = 40
local GrassFreezeDistance = 50
local OptimizeInterval = 1

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

local function saveCache()
    writefile(optimizeFile, HttpService:JSONEncode(optimizedCache, true))
end

local function isAnimatedGrass(part)
    return part:FindFirstChildWhichIsA("TweenBase", true) or part:FindFirstChildWhichIsA("Motor", true)
end

local function shouldCullGrass()
    return math.random() < 0.3
end

local function optimizeVegetation(part, distance)
    if not LowRendering then return end

    local name = string.lower(part.Name)

    if name:find("leaf") or name:find("bush") or name:find("grass") then
        if distance > 400 then
            if part:IsDescendantOf(Workspace) and not part:GetAttribute("__WasRemoved") then
                optimizedCache[part:GetFullName()] = {
                    Parent = part.Parent,
                    CFrame = part.CFrame,
                    Size = part.Size,
                    Material = part.Material,
                    Transparency = part.Transparency
                }
                part:SetAttribute("__WasRemoved", true)
                part.Parent = nil
            end
            return
        elseif distance <= 400 and part:GetAttribute("__WasRemoved") and optimizedCache[part:GetFullName()] then
            local data = optimizedCache[part:GetFullName()]
            part.Parent = data.Parent
            part.CFrame = data.CFrame
            part.Size = data.Size
            part.Material = data.Material
            part.Transparency = data.Transparency
            part:SetAttribute("__WasRemoved", nil)
        end
    end

    if name:find("leaf") or name:find("bush") then
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

    if name:find("grass") then
        if isAnimatedGrass(part) then
            part:Destroy()
        elseif distance > GrassFreezeDistance then
            part.Anchored = true
            if shouldCullGrass() then part:Destroy() end
        else
            part.Anchored = false
        end
    end
end

local function queuePart(part)
    if not part:IsA("BasePart") then return end
    table.insert(optimizeQueue, part)
end

local function processQueue(playerPos)
    if #optimizeQueue == 0 then return end
    local part = table.remove(optimizeQueue, 1)
    local dist = (part.Position - playerPos).Magnitude
    optimizeVegetation(part, dist)
end

local function scanParts()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local pos = hrp.Position

    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            queuePart(v)
        end
    end
end

RunService.Heartbeat:Connect(function(dt)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    processQueue(hrp.Position)
end)

task.spawn(function()
    while task.wait(OptimizeInterval) do
        scanParts()
        saveCache()
    end
end)

loadCache()
print("✅ Auto Optimize Loaded with LowRendering =", LowRendering)
