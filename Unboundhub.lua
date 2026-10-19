-- =========================================================
--  Unbound Hub (English Edition)
-- =========================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

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
screenGui.Name = "UnboundHubLoader"
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
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    mainFrame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                           startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- Logo
local logo = Instance.new("ImageLabel", mainFrame)
logo.Size = UDim2.new(0, 36, 0, 36)
logo.Position = UDim2.new(0, 18, 0, 10)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://6023426915"

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -65, 0, 55)
title.Position = UDim2.new(0, 60, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Unbound Hub - Steal an Egg"
title.TextColor3 = Color3.fromRGB(240, 240, 240)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local holder = Instance.new("Frame", mainFrame)
holder.Size = UDim2.new(1, -40, 0, 60)
holder.Position = UDim2.new(0, 20, 0, 65)
holder.BackgroundTransparency = 1
local lay = Instance.new("UIListLayout", holder)
lay.FillDirection = Enum.FillDirection.Horizontal
lay.Padding = UDim.new(0, 10)
lay.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function makeBtn(text, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 1, 0)
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(240, 240, 240)
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 15
    b.Parent = holder
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local btnLoad = makeBtn("Load Script", Color3.fromRGB(40, 90, 200))

local status = Instance.new("TextLabel", mainFrame)
status.Size = UDim2.new(1, -40, 0, 26)
status.Position = UDim2.new(0, 20, 1, -40)
status.BackgroundTransparency = 1
status.Text = ""
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.Font = Enum.Font.Gotham
status.TextSize = 12

-- =========================================================
--  EXECUTION HANDLER
-- =========================================================
local isLoading = false

local function runLoader()
    if isLoading then return end
    isLoading = true

    status.Text = "Loading script..."
    btnLoad.Text = "Loading..."

    task.spawn(function()
        local src = fetchCode(TargetUrl)
        if not src then
            status.Text = "❌ Failed to fetch script! Click to retry."
            btnLoad.Text = "Retry"
            isLoading = false
            return
        end

        status.Text = "▶️ Running..."
        task.wait(0.3)
        screenGui:Destroy()

        local safeLoader = loadstring or load
        local fn, err = safeLoader(src)
        if not fn then
            warn("[UnboundHub] loadstring error: " .. tostring(err))
            return
        end

        local ok, err2 = pcall(fn)
        if not ok then
            warn("[UnboundHub] runtime error: " .. tostring(err2))
        end
    end)
end

btnLoad.MouseButton1Click:Connect(runLoader)
