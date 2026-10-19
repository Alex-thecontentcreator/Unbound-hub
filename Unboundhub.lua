-- =========================================================
--  Unbound Hub Loader (English Edition)
-- =========================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Prevent opening two loaders at once
local GUI_NAME = "UnboundHubLoader"
do
    local old = CoreGui:FindFirstChild(GUI_NAME)
    if old then old:Destroy() end
    local pg = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
    if pg and pg:FindFirstChild(GUI_NAME) then pg[GUI_NAME]:Destroy() end
end

-- TARGET SCRIPT (Luarmor loader)
local TargetUrl = "https://api.luarmor.net/files/v4/loaders/271f96ca25f29ae395be1c0f9e6f4ead.lua"

-- =========================================================
--  FETCH EXTERNAL CODE
-- =========================================================
local function fetchCode(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and type(res) == "string" and #res > 0 then return res end

    local env = (getgenv and getgenv()) or _G
    for _, name in ipairs({"request", "http_request", "syn_request"}) do
        local fn = env[name]
        if type(fn) == "function" then
            local ok2, r = pcall(fn, {Url = url, Method = "GET"})
            if ok2 and r and r.Body and #r.Body > 0 then return r.Body end
        end
    end

    if syn and syn.request then
        local ok3, r = pcall(syn.request, {Url = url, Method = "GET"})
        if ok3 and r and r.Body and #r.Body > 0 then return r.Body end
    end

    return nil
end

-- =========================================================
--  UI
-- =========================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = GUI_NAME
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
do
    local ok = pcall(function() screenGui.Parent = CoreGui end)
    if not ok or not screenGui.Parent then
        screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 220)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(75, 75, 100)

-- Drag support
do
    local dragging, dragStart, startPos
    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = mainFrame.Position
