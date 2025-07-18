local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

pcall(function()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
end)

pcall(function()
    StarterGui:SetCore("EmotesMenuOpen", true)
end)
