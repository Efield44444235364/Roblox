local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
_G.ESP = true

-- สร้าง ESP ให้ character ถ้าไม่มีอยู่
local function addESP(character)
	if not _G.ESP then return end
	if character and not character:FindFirstChild("ESP") then
		local hl = Instance.new("Highlight")
		hl.Name = "ESP"
		hl.Parent = character
	end
end

-- ลบ ESP ออกจาก character
local function removeESP(character)
	local hl = character and character:FindFirstChild("ESP")
	if hl then hl:Destroy() end
end

-- ฟังเมื่อผู้เล่นใหม่เข้า
local function onPlayerAdded(player)
	if player == LocalPlayer then return end

	player.CharacterAdded:Connect(function(char)
		if _G.ESP then
			addESP(char)
		end
	end)

	-- ถ้าเข้าเกมมาพร้อม character แล้ว
	if player.Character then
		addESP(player.Character)
	end
end

-- เริ่มต้น: ฟังทุกผู้เล่นที่มีอยู่แล้ว
for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		onPlayerAdded(player)
	end
end

-- ฟังผู้เล่นใหม่ในอนาคต
Players.PlayerAdded:Connect(onPlayerAdded)

-- Optional: เรียกฟังก์ชันนี้เมื่อต้องการปิด ESP
function DisableESP()
	_G.ESP = false
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			removeESP(player.Character)
		end
	end
	print("ESP disabled")
end
