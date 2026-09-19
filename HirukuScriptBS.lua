-- Hiruku · MM2 Script
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

-- КОНФИГ
local Config = {
    AutoPickupGun = false,
    KillAll = false,
    SelectedPlayer = nil,
    AutoShot = false,
    FOVCircle = false,
    AimFOV = 120,
    WalkSpeed = 16,
}

-- ЗАГРУЗКА КОНФИГА
local function LoadConfig()
    if readfile and isfile("HirukuMM2.json") then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile("HirukuMM2.json")) end)
        if success and data then
            for k, v in pairs(data) do Config[k] = v end
        end
    end
end

local function SaveConfig()
    if writefile then
        writefile("HirukuMM2.json", HttpService:JSONEncode(Config))
    end
end

LoadConfig()

-- UI CORE
local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
gui.Name = "HirukuMM2"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- INJECTION SCREEN
local injectFrame = Instance.new("Frame", gui)
injectFrame.Size = UDim2.new(1, 0, 1, 0)
injectFrame.BackgroundColor3 = Color3.new(0, 0, 0)
injectFrame.BackgroundTransparency = 0.3
injectFrame.ZIndex = 100

local injectLabel = Instance.new("TextLabel", injectFrame)
injectLabel.Size = UDim2.new(1, 0, 0, 40)
injectLabel.Position = UDim2.new(0, 0, 0.4, 0)
injectLabel.BackgroundTransparency = 1
injectLabel.Text = "Hiruku Injected..."
injectLabel.TextColor3 = Color3.new(1, 1, 1)
injectLabel.Font = Enum.Font.Code
injectLabel.TextSize = 24

local progressBar = Instance.new("Frame", injectFrame)
progressBar.Size = UDim2.new(0, 300, 0, 10)
progressBar.Position = UDim2.new(0.5, -150, 0.5, 20)
progressBar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
progressBar.BorderSizePixel = 0
local pCorner = Instance.new("UICorner", progressBar)
pCorner.CornerRadius = UDim.new(1, 0)

local progressFill = Instance.new("Frame", progressBar)
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.new(1, 1, 1)
progressFill.BorderSizePixel = 0
local fCorner = Instance.new("UICorner", progressFill)
fCorner.CornerRadius = UDim.new(1, 0)

-- АНИМАЦИЯ ЗАГРУЗКИ
TweenService:Create(progressFill, TweenInfo.new(2, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)}):Play()
task.wait(2.2)
injectFrame:Destroy()

-- WATERMARK + TOGGLE BUTTON
local wm = Instance.new("Frame", gui)
wm.Size = UDim2.new(0, 200, 0, 30)
wm.Position = UDim2.new(0, 10, 0, 10)
wm.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
wm.BackgroundTransparency = 0.2
wm.BorderSizePixel = 0
local wmCorner = Instance.new("UICorner", wm); wmCorner.CornerRadius = UDim.new(0, 6)
local wmStroke = Instance.new("UIStroke", wm); wmStroke.Color = Color3.fromRGB(138, 92, 246); wmStroke.Transparency = 0.5

local wmLabel = Instance.new("TextLabel", wm)
wmLabel.Size = UDim2.new(1, 0, 1, 0)
wmLabel.BackgroundTransparency = 1
wmLabel.Text = "Hiruku · MM2"
wmLabel.TextColor3 = Color3.fromRGB(232, 232, 240)
wmLabel.Font = Enum.Font.Code
wmLabel.TextSize = 14

-- TOGGLE BUTTON (по центру, под watermark)
local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 100, 0, 30)
toggleBtn.Position = UDim2.new(0.5, -50, 0, 55)
toggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
toggleBtn.BackgroundTransparency = 0.3
toggleBtn.Text = "Hiruku"
toggleBtn.TextColor3 = Color3.fromRGB(232, 232, 240)
toggleBtn.Font = Enum.Font.Code
toggleBtn.TextSize = 14
toggleBtn.BorderSizePixel = 0
local tCorner = Instance.new("UICorner", toggleBtn); tCorner.CornerRadius = UDim.new(1, 0)
local tStroke = Instance.new("UIStroke", toggleBtn); tStroke.Color = Color3.fromRGB(138, 92, 246); tStroke.Transparency = 0.4

-- MAIN WINDOW
local win = Instance.new("Frame", gui)
win.Size = UDim2.new(0, 700, 0, 400)
win.Position = UDim2.new(0.5, -350, 0.5, -200)
win.BackgroundColor3 = Color3.fromRGB(15, 15, 19)
win.BackgroundTransparency = 0.15
win.BorderSizePixel = 0
win.Visible = false
local winCorner = Instance.new("UICorner", win); winCorner.CornerRadius = UDim.new(0, 6)
local winStroke = Instance.new("UIStroke", win); winStroke.Color = Color3.fromRGB(138, 92, 246); winStroke.Transparency = 0.6

-- DRAG FUNCTION (MOBILE FIX)
local function MakeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end

MakeDraggable(win)
MakeDraggable(toggleBtn)
MakeDraggable(wm)

-- SIDEBAR
local sidebar = Instance.new("Frame", win)
sidebar.Size = UDim2.new(0, 160, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
sidebar.BackgroundTransparency = 0.1
sidebar.BorderSizePixel = 0
local sCorner = Instance.new("UICorner", sidebar); sCorner.CornerRadius = UDim.new(0, 6)

-- CONTENT AREA
local content = Instance.new("Frame", win)
content.Size = UDim2.new(1, -160, 1, 0)
content.Position = UDim2.new(0, 160, 0, 0)
content.BackgroundTransparency = 1

-- SEARCH
local searchBox = Instance.new("TextBox", content)
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 10)
searchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
searchBox.PlaceholderText = "Search functions..."
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.Font = Enum.Font.Code
searchBox.TextSize = 14
searchBox.BorderSizePixel = 0
local searchCorner = Instance.new("UICorner", searchBox); searchCorner.CornerRadius = UDim.new(0, 4)

-- SCROLLING FRAME
local scroll = Instance.new("ScrollingFrame", content)
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = Color3.fromRGB(138, 92, 246)

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ROLE DETECTION
local function GetRole()
    local char = LP.Character
    if not char then return "Innocent" end
    if char:FindFirstChild("Knife") then return "Murderer" end
    if char:FindFirstChild("Gun") then return "Sheriff" end
    return "Innocent"
end

-- FUNCTION: AUTO PICKUP GUN
local function AutoPickupGun()
    if not Config.AutoPickupGun then return end
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name == "Gun" and obj:IsA("Tool") then
            local char = LP.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                obj.Parent = char
            end
        end
    end
end

-- FUNCTION: KILL ALL
local function KillAll()
    if GetRole() ~= "Murderer" then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            plr.Character.Humanoid.Health = 0
        end
    end
end

-- FUNCTION: KILL SELECTED
local function KillSelected()
    if GetRole() ~= "Murderer" or not Config.SelectedPlayer then return end
    local target = Players:FindFirstChild(Config.SelectedPlayer)
    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
        target.Character.Humanoid.Health = 0
    end
end

-- FUNCTION: TP TO ROLE
local function TPToRole(roleName)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local char = plr.Character
            local isTarget = false
            if roleName == "Murderer" and char:FindFirstChild("Knife") then isTarget = true end
            if roleName == "Sheriff" and char:FindFirstChild("Gun") then isTarget = true end
            if isTarget then
                local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
                local targetHrp = char:FindFirstChild("HumanoidRootPart")
                if hrp and targetHrp then
                    hrp.CFrame = targetHrp.CFrame
                end
            end
        end
    end
end

-- FUNCTION: AUTO SHOT
local function AutoShot()
    if not Config.AutoShot or GetRole() ~= "Sheriff" then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local char = plr.Character
            if char:FindFirstChild("Knife") then
                local targetHrp = char:FindFirstChild("HumanoidRootPart")
                local myChar = LP.Character
                local myTool = myChar and myChar:FindFirstChild("Gun")
                if myTool and targetHrp then
                    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
                    if myHrp then
                        myHrp.CFrame = CFrame.new(myHrp.Position, targetHrp.Position)
                        myTool:Activate()
                    end
                end
            end
        end
    end
end

-- FUNCTION: FOV CIRCLE
local fovCircle = Instance.new("Frame", gui)
fovCircle.Size = UDim2.new(0, 240, 0, 240)
fovCircle.Position = UDim2.new(0.5, -120, 0.5, -120)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
local fovCorner = Instance.new("UICorner", fovCircle); fovCorner.CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", fovCircle); fovStroke.Color = Color3.fromRGB(138, 92, 246); fovStroke.Transparency = 0.5

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    AutoPickupGun()
    if Config.KillAll then KillAll() end
    if Config.SelectedPlayer then KillSelected() end
    if Config.AutoShot then AutoShot() end
    if Config.FOVCircle then
        fovCircle.Visible = true
        fovCircle.Size = UDim2.new(0, Config.AimFOV * 2, 0, Config.AimFOV * 2)
        fovCircle.Position = UDim2.new(0.5, -Config.AimFOV, 0.5, -Config.AimFOV)
    else
        fovCircle.Visible = false
    end
end)

-- UI BUILDERS
local function AddToggle(text, default, callback)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
    btn.Text = text .. (default and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.fromRGB(232, 232, 240)
    btn.Font = Enum.Font.Code
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0, 4)
    
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. (state and " [ON]" or " [OFF]")
        callback(state)
        SaveConfig()
    end)
end

local function AddButton(text, callback)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(232, 232, 240)
    btn.Font = Enum.Font.Code
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(callback)
end

local function AddHeader(text)
    local lbl = Instance.new("TextLabel", scroll)
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(138, 92, 246)
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

-- BUILD SECTIONS
local function BuildCombat()
    AddHeader("COMBAT")
    AddToggle("Auto Pickup Gun", Config.AutoPickupGun, function(v) Config.AutoPickupGun = v end)
    AddToggle("Kill All (Murderer)", Config.KillAll, function(v) Config.KillAll = v end)
    AddButton("Kill Selected", function() KillSelected() end)
    AddButton("Select Player", function()
        -- Простой список игроков
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LP then
                local btn = Instance.new("TextButton", scroll)
                btn.Size = UDim2.new(1, 0, 0, 24)
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                btn.Text = plr.Name
                btn.TextColor3 = Color3.new(1, 1, 1)
                btn.Font = Enum.Font.Code
                btn.TextSize = 10
                btn.BorderSizePixel = 0
                local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0, 3)
                btn.MouseButton1Click:Connect(function()
                    Config.SelectedPlayer = plr.Name
                    btn.BackgroundColor3 = Color3.fromRGB(138, 92, 246)
                end)
            end
        end
    end)
end

local function BuildAim()
    AddHeader("AIM")
    AddToggle("Auto Shot (Sheriff)", Config.AutoShot, function(v) Config.AutoShot = v end)
    AddToggle("FOV Circle", Config.FOVCircle, function(v) Config.FOVCircle = v end)
    AddButton("TP to Murderer", function() TPToRole("Murderer") end)
    AddButton("TP to Sheriff", function() TPToRole("Sheriff") end)
end

-- SIDEBAR NAV
local sections = {
    {name = "Combat", builder = BuildCombat},
    {name = "Aim", builder = BuildAim},
}

for _, s in ipairs(sections) do
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, -20, 0, 36)
    btn.Position = UDim2.new(0, 10, 0, 10 + (#sidebar:GetChildren() - 1) * 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    btn.Text = s.name
    btn.TextColor3 = Color3.fromRGB(232, 232, 240)
    btn.Font = Enum.Font.Code
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0, 4)
    
    btn.MouseButton1Click:Connect(function()
        for _, child in pairs(scroll:GetChildren()) do
            if not child:IsA("UIListLayout") then child:Destroy() end
        end
        s.builder()
    end)
end

-- TOGGLE MENU
local menuOpen = false
toggleBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    win.Visible = menuOpen
end)

-- AUTO SAVE ON LEAVE
game:BindToClose(SaveConfig)