local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local HttpService       = game:GetService("HttpService")
local LP                = Players.LocalPlayer
local Camera            = workspace.CurrentCamera

local Theme = {
    bg          = Color3.fromRGB(15, 15, 19),
    panel       = Color3.fromRGB(24, 24, 30),
    panel2      = Color3.fromRGB(30, 30, 38),
    panel3      = Color3.fromRGB(38, 38, 48),
    stroke      = Color3.fromRGB(50, 50, 62),
    text        = Color3.fromRGB(232, 232, 240),
    textDim     = Color3.fromRGB(148, 148, 162),
    textMute    = Color3.fromRGB(96, 96, 110),
    accent      = Color3.fromRGB(138, 92, 246),
    accent2     = Color3.fromRGB(168, 132, 255),
    off         = Color3.fromRGB(46, 46, 56),
    good        = Color3.fromRGB(80, 220, 140),
    bad         = Color3.fromRGB(240, 90, 90),
    bgTransp    = 0.15,
    panelTransp = 0.10,
    blurSize    = 24,
    accentColor = Color3.fromRGB(138, 92, 246),
}

local IconIds = {
    logo     = "6031075931",
    combat   = "6031094303",
    aim      = "6031266840",
    visuals  = "6031237641",
    player   = "6031267778",
    misc     = "6031099225",
    settings = "6031239822",
    search   = "6031277085",
    close    = "6031251557",
    toggle   = "6031285016",
    keybind  = "6031285654",
    config   = "6031242022",
    color    = "6031099822",
    reset    = "6031272421",
    save     = "6031269237",
    load     = "6031229129",
    preset   = "6031093271",
    slider   = "6031269468",
    dropdown = "6031095057",
}

local Config = {
    aim = {
        enabled=false, keybind=Enum.KeyCode.E, mode="Camera", part="Head",
        fov=120, smooth=15, hitChance=100, teamCheck=true, visibleCheck=true,
        wallshot=false, silent=false, silentMode="Raycast", prediction=0,
        autoFire=false, autoFireDelay=100, shake=false, shakeIntensity=2,
        prioritize="Distance", priorityTargets={}, ignore={}, maxDistance=500,
    },
    combat = {
        chams=false, chamsColor=Color3.fromRGB(138,92,246), chamsOutline=Color3.fromRGB(168,132,255),
        chamsTransp=0.5, chamsOutlineTransp=0.15, chamsMode="Highlight",
        espBox=false, espBoxColor=Color3.fromRGB(138,92,246), espBoxThickness=1,
        espName=false, espNameColor=Color3.fromRGB(232,232,240),
        espHealth=false, espHealthColor=Color3.fromRGB(80,220,140),
        espDist=false, espDistColor=Color3.fromRGB(168,132,255),
        espTracer=false, espTracerColor=Color3.fromRGB(138,92,246),
        espSkeleton=false, espSkeletonColor=Color3.fromRGB(168,132,255),
        espFill=false, espFillColor=Color3.fromRGB(138,92,246), espFillTransp=0.7,
        espMaxRange=1000, espUpdateRate=0.05,
    },
    visuals = {
        watermark=true, watermarkText="Hiruku", watermarkColor=Color3.fromRGB(138,92,246),
        fps=true, ping=false, time=false, coords=false,
        blur=true, blurSize=24, vignette=false, vignetteIntensity=0.3,
        fovCircle=true, fovCircleColor=Color3.fromRGB(138,92,246), fovCircleThickness=1, fovCircleTransp=0.3,
        crosshair=false, crosshairColor=Color3.fromRGB(232,232,240), crosshairSize=8, crosshairGap=4, crosshairThickness=1,
        zoom=false, zoomAmount=2, skybox=false, skyboxColor=Color3.fromRGB(15,15,19),
        ambient=false, ambientColor=Color3.fromRGB(40,40,50),
        fullbright=false, fullbrightAmount=2,
    },
    player = {
        walkSpeed=16, walkSpeedEnabled=false, walkSpeedMax=200,
        jumpPower=50, jumpPowerEnabled=false, jumpPowerMax=300,
        gravity=196.2, gravityEnabled=false,
        infiniteJump=false, fly=false, flySpeed=50, flyKey=Enum.KeyCode.F,
        noclip=false, noclipKey=Enum.KeyCode.N, speedKey=Enum.KeyCode.LeftShift,
        antiAfk=false, autoReset=false,
    },
    misc = {
        targetPlayer="", serverHop=false, autoRejoin=false,
        chatSpam=false, chatSpamText="", chatSpamDelay=5,
        antiKick=false, teleportToTarget=false,
        hideGui=false, guiKey=Enum.KeyCode.RightShift,
    },
    settings = {
        menuTransp=0.15, menuBlur=24, menuScale=1,
        accentColor=Color3.fromRGB(138,92,246), animations=true,
        notifications=true, soundEffects=false,
    },
}

local Presets = {
    Default = {},
    Legit = {
        aim={enabled=true, fov=80, smooth=35, hitChance=85, visibleCheck=true, wallshot=false, silent=false},
        combat={chams=true, chamsTransp=0.7, espBox=false, espName=false},
        visuals={watermark=true, fps=true, fovCircle=true},
    },
    Rage = {
        aim={enabled=true, fov=360, smooth=3, hitChance=100, visibleCheck=false, wallshot=true, silent=true, autoFire=true, prediction=0.1},
        combat={chams=true, chamsTransp=0.3, espBox=true, espName=true, espHealth=true, espDist=true, espTracer=true},
        visuals={watermark=true, fps=true, ping=true, fovCircle=true, fullbright=true},
    },
    Visual = {
        aim={enabled=false},
        combat={chams=true, chamsTransp=0.4, espBox=true, espSkeleton=true, espHealth=true},
        visuals={watermark=true, fps=true, fullbright=true, vignette=true},
    },
}

local blur = Instance.new("BlurEffect")
blur.Name = "Hiruku_Blur"
blur.Size = 0
blur.Parent = Lighting

local function setBlur(on)
    if not Config.visuals.blur then blur.Size = 0; return end
    TweenService:Create(blur, TweenInfo.new(0.25), {Size = on and Config.settings.menuBlur or 0}):Play()
end

local function new(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    return o
end

local function corner(p, r) return new("UICorner", {CornerRadius=UDim.new(0,r or 8), Parent=p}) end
local function stroke(p, c, t, tr)
    return new("UIStroke", {Color=c or Theme.stroke, Thickness=t or 1,
        Transparency=tr or 0.2, ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Parent=p})
end
local function pad(p, a, b, c, d)
    return new("UIPadding", {PaddingTop=UDim.new(0,a), PaddingBottom=UDim.new(0,b or a),
        PaddingLeft=UDim.new(0,c or a), PaddingRight=UDim.new(0,d or a), Parent=p})
end
local function icon(parent, id, size, pos, color)
    local img = new("ImageLabel", {BackgroundTransparency=1, Image="rbxassetid://"..id,
        ImageColor3=color or Theme.text, Size=size, Position=pos, Parent=parent})
    return img
end

local gui = new("ScreenGui", {
    Name="Hiruku", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling, IgnoreGuiInset=true,
})
pcall(function() gui.Parent = game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

------------------------------------------------------------
-- NOTIFICATION SYSTEM
------------------------------------------------------------
local notifHolder = new("Frame", {
    Parent=gui, BackgroundTransparency=1,
    Position=UDim2.new(1,-320,0,16), Size=UDim2.new(0,304,0,400),
})
new("UIListLayout", {Parent=notifHolder, Padding=UDim.new(0,8),
    SortOrder=Enum.SortOrder.LayoutOrder, VerticalAlignment=Enum.VerticalAlignment.Top})

local function notify(title, text, dur)
    if not Config.settings.notifications then return end
    dur = dur or 3
    local n = new("Frame", {
        Parent=notifHolder, BackgroundColor3=Theme.bg,
        BackgroundTransparency=Theme.bgTransp,
        Size=UDim2.new(1,0,0,56), BorderSizePixel=0, LayoutOrder=-tick(),
    })
    corner(n, 8); stroke(n, Theme.accentColor, 1, 0.5)
    new("Frame", {Parent=n, BackgroundColor3=Theme.accentColor,
        Size=UDim2.new(0,3,1,0), BorderSizePixel=0})
    icon(n, IconIds.logo, UDim2.new(0,14,0,14), UDim2.new(0,14,0,14), Theme.accentColor)
    new("TextLabel", {Parent=n, BackgroundTransparency=1,
        Position=UDim2.new(0,36,0,8), Size=UDim2.new(1,-46,0,16),
        Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Theme.text,
        TextXAlignment=Enum.TextXAlignment.Left, Text=title})
    new("TextLabel", {Parent=n, BackgroundTransparency=1,
        Position=UDim2.new(0,36,0,26), Size=UDim2.new(1,-46,0,22),
        Font=Enum.Font.Gotham, TextSize=11, TextColor3=Theme.textDim,
        TextXAlignment=Enum.TextXAlignment.Left, Text=text, TextWrapped=true})
    local startPos = n.Position
    n.Position = UDim2.new(1, 40, startPos.Y.Scale, startPos.Y.Offset)
    TweenService:Create(n, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position=startPos}):Play()
    task.delay(dur, function()
        TweenService:Create(n, TweenInfo.new(0.25), {Position=UDim2.new(1,40,startPos.Y.Scale,startPos.Y.Offset)}):Play()
        task.wait(0.3); n:Destroy()
    end)
end

------------------------------------------------------------
-- WATERMARK
------------------------------------------------------------
local wm = new("Frame", {
    Parent=gui, BackgroundColor3=Theme.bg,
    BackgroundTransparency=Theme.bgTransp,
    Size=UDim2.new(0,260,0,34), Position=UDim2.new(0,16,0,16),
    BorderSizePixel=0,
})
corner(wm, 8); stroke(wm, Config.visuals.watermarkColor, 1, 0.55)
icon(wm, IconIds.logo, UDim2.new(0,14,0,14), UDim2.new(0,11,0.5,-7), Config.visuals.watermarkColor)
new("TextLabel", {Parent=wm, BackgroundTransparency=1,
    Position=UDim2.new(0,32,0,0), Size=UDim2.new(1,-40,1,0),
    Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=Theme.text,
    TextXAlignment=Enum.TextXAlignment.Left, Text="Hiruku  ·  Blox Strike"})
local wmStats = new("TextLabel", {Parent=wm, BackgroundTransparency=1,
    Size=UDim2.new(1,-12,1,0), Font=Enum.Font.Gotham, TextSize=12,
    TextColor3=Theme.textDim, TextXAlignment=Enum.TextXAlignment.Right, Text=""})

------------------------------------------------------------
-- TOGGLE BUTTON
------------------------------------------------------------
local btn = new("TextButton", {
    Parent=gui, BackgroundColor3=Theme.bg,
    BackgroundTransparency=Theme.bgTransp,
    Size=UDim2.new(0,46,0,46), Position=UDim2.new(0,16,0,60),
    BorderSizePixel=0, Text="", AutoButtonColor=false,
})
corner(btn, 12); stroke(btn, Config.settings.accentColor, 1.4, 0.35)
icon(btn, IconIds.toggle, UDim2.new(0,22,0,22), UDim2.new(0.5,-11,0.5,-11), Config.settings.accentColor)

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=i.Position; startPos=frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dragStart
            frame.Position=UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
end
makeDraggable(wm); makeDraggable(btn)

------------------------------------------------------------
-- WINDOW
------------------------------------------------------------
local win = new("Frame", {
    Parent=gui, BackgroundColor3=Theme.bg,
    BackgroundTransparency=Theme.bgTransp,
    Size=UDim2.new(0,760,0,500),
    Position=UDim2.new(0.5,-380,0.5,-250),
    BorderSizePixel=0, Visible=false,
})
corner(win, 12); stroke(win, Theme.stroke, 1, 0.3)
makeDraggable(win)

local winScale = new("UIScale", {Parent=win, Scale=Config.settings.menuScale})

local titleBar = new("Frame", {Parent=win, BackgroundTransparency=1, Size=UDim2.new(1,0,0,44)})
icon(titleBar, IconIds.logo, UDim2.new(0,16,0,16), UDim2.new(0,16,0.5,-8), Config.settings.accentColor)
new("TextLabel", {Parent=titleBar, BackgroundTransparency=1,
    Position=UDim2.new(0,40,0,0), Size=UDim2.new(1,-140,1,0),
    Font=Enum.Font.GothamBold, TextSize=15, TextColor3=Theme.text,
    TextXAlignment=Enum.TextXAlignment.Left, Text="Hiruku  ·  Combat"})

local searchBox = new("TextBox", {Parent=titleBar, BackgroundColor3=Theme.panel,
    Position=UDim2.new(1,-330,0.5,-13), Size=UDim2.new(0,220,0,26),
    Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.text,
    PlaceholderText="поиск функции...", Text="", ClearTextOnFocus=false,
    BorderSizePixel=0})
corner(searchBox, 6); stroke(searchBox, Theme.stroke, 1, 0.6)
pad(searchBox, 0, 0, 8, 8)
icon(searchBox, IconIds.search, UDim2.new(0,12,0,12), UDim2.new(1,-20,0.5,-6), Theme.textDim)

local minimizeBtn = new("TextButton", {Parent=titleBar, BackgroundTransparency=1,
    Size=UDim2.new(0,32,0,32), Position=UDim2.new(1,-70,0.5,-16), Text="",
    Font=Enum.Font.GothamBold, TextSize=16, TextColor3=Theme.textDim})
new("TextLabel", {Parent=minimizeBtn, BackgroundTransparency=1, Size=UDim2.new(1,0,1,-4),
    Font=Enum.Font.GothamBold, TextSize=16, TextColor3=Theme.textDim, Text="—"})
minimizeBtn.MouseEnter:Connect(function() minimizeBtn:FindFirstChildOfClass("TextLabel").TextColor3=Theme.accent2 end)
minimizeBtn.MouseLeave:Connect(function() minimizeBtn:FindFirstChildOfClass("TextLabel").TextColor3=Theme.textDim end)

local closeBtn = new("TextButton", {Parent=titleBar, BackgroundTransparency=1,
    Size=UDim2.new(0,32,0,32), Position=UDim2.new(1,-40,0.5,-16), Text=""})
icon(closeBtn, IconIds.close, UDim2.new(0,14,0,14), UDim2.new(0.5,-7,0.5,-7), Theme.textDim)
closeBtn.MouseEnter:Connect(function() closeBtn:FindFirstChildOfClass("ImageLabel").ImageColor3=Theme.accent2 end)
closeBtn.MouseLeave:Connect(function() closeBtn:FindFirstChildOfClass("ImageLabel").ImageColor3=Theme.textDim end)

local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(win, TweenInfo.new(0.25), {Size=UDim2.new(0,760,0,44)}):Play()
    else
        TweenService:Create(win, TweenInfo.new(0.25), {Size=UDim2.new(0,760,0,500)}):Play()
    end
end)
closeBtn.MouseButton1Click:Connect(function()
    win.Visible=false; setBlur(false)
end)

------------------------------------------------------------
-- SIDEBAR
------------------------------------------------------------
local sidebar = new("Frame", {Parent=win, BackgroundColor3=Theme.panel,
    BackgroundTransparency=Theme.panelTransp,
    Position=UDim2.new(0,0,0,44), Size=UDim2.new(0,200,1,-44), BorderSizePixel=0})
corner(sidebar, 10)
new("Frame", {Parent=sidebar, BackgroundColor3=Theme.stroke,
    Size=UDim2.new(0,1,1,-20), Position=UDim2.new(1,-1,0,10), BorderSizePixel=0})

local profileBox = new("Frame", {Parent=sidebar, BackgroundColor3=Theme.panel2,
    BackgroundTransparency=0.4, Position=UDim2.new(0,10,1,-70),
    Size=UDim2.new(1,-20,0,60), BorderSizePixel=0})
corner(profileBox, 8); stroke(profileBox, Theme.stroke, 1, 0.6)
icon(profileBox, IconIds.logo, UDim2.new(0,28,0,28), UDim2.new(0,10,0,10), Config.settings.accentColor)
new("TextLabel", {Parent=profileBox, BackgroundTransparency=1,
    Position=UDim2.new(0,46,0,8), Size=UDim2.new(1,-56,0,16),
    Font=Enum.Font.GothamBold, TextSize=12, TextColor3=Theme.text,
    TextXAlignment=Enum.TextXAlignment.Left, Text="Hiruku v1.0"})
new("TextLabel", {Parent=profileBox, BackgroundTransparency=1,
    Position=UDim2.new(0,46,0,26), Size=UDim2.new(1,-56,0,16),
    Font=Enum.Font.Gotham, TextSize=10, TextColor3=Theme.textDim,
    TextXAlignment=Enum.TextXAlignment.Left, Text="Blox Strike · loaded"})
new("Frame", {Parent=profileBox, BackgroundColor3=Theme.good,
    Size=UDim2.new(0,6,0,6), Position=UDim2.new(1,-16,0,12), BorderSizePixel=0})
corner(profileBox:FindFirstChildOfClass("Frame"), 99)

------------------------------------------------------------
-- CONTENT
------------------------------------------------------------
local content = new("Frame", {Parent=win, BackgroundTransparency=1,
    Position=UDim2.new(0,200,0,44), Size=UDim2.new(1,-200,1,-44)})
pad(content, 14)

local scroll = new("ScrollingFrame", {Parent=content, BackgroundTransparency=1,
    Size=UDim2.new(1,0,1,0), CanvasSize=UDim2.new(0,0,0,0),
    ScrollBarThickness=3, ScrollBarImageColor3=Theme.accent,
    ScrollBarImageTransparency=0.5, BorderSizePixel=0})
new("UIListLayout", {Parent=scroll, Padding=UDim.new(0,6),
    SortOrder=Enum.SortOrder.LayoutOrder})
pad(scroll, 0, 10, 0, 4)

local sections = {
    {id="combat",   icon=IconIds.combat,   name="Combat",   tabs={"Chams","ESP","Misc"}},
    {id="aim",      icon=IconIds.aim,      name="Aim",      tabs={"Main","Silent","Targeting"}},
    {id="visuals",  icon=IconIds.visuals,  name="Visuals",  tabs={"World","HUD","Effects"}},
    {id="player",   icon=IconIds.player,   name="Player",   tabs={"Movement","Actions"}},
    {id="misc",     icon=IconIds.misc,     name="Misc",     tabs={"Server","Chat","Utility"}},
    {id="settings", icon=IconIds.settings, name="Settings", tabs={"Menu","Presets","Config"}},
}

local currentSection = "combat"
local currentTab = {}

local function clearContent()
    for _, c in ipairs(scroll:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
end

local function addHeader(text)
    local h = new("TextLabel", {Parent=scroll, BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,26), Font=Enum.Font.GothamBold, TextSize=13,
        TextColor3=Theme.text, TextXAlignment=Enum.TextXAlignment.Left, Text=text})
    h.LayoutOrder = #scroll:GetChildren()
    return h
end

local function addSubheader(text)
    local h = new("TextLabel", {Parent=scroll, BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,20), Font=Enum.Font.GothamMedium, TextSize=11,
        TextColor3=Theme.textMute, TextXAlignment=Enum.TextXAlignment.Left, Text=text})
    h.LayoutOrder = #scroll:GetChildren()
    return h
end

local function addTabs(tabs, onSelect)
    local bar = new("Frame", {Parent=scroll, BackgroundColor3=Theme.panel2,
        BackgroundTransparency=0.3, Size=UDim2.new(1,0,0,32), BorderSizePixel=0})
    corner(bar, 8)
    bar.LayoutOrder = #scroll:GetChildren()
    local layout = new("UIListLayout", {Parent=bar, Padding=UDim.new(0,4),
        FillDirection=Enum.FillDirection.Horizontal,
        VerticalAlignment=Enum.VerticalAlignment.Center,
        HorizontalAlignment=Enum.HorizontalAlignment.Left, SortOrder=Enum.SortOrder.LayoutOrder})
    pad(bar, 4)
    local btns = {}
    for i, t in ipairs(tabs) do
        local b = new("TextButton", {Parent=bar, BackgroundColor3=Theme.panel2,
            BackgroundTransparency=1, Size=UDim2.new(0,90,1,-8),
            Font=Enum.Font.GothamMedium, TextSize=12, TextColor3=Theme.textDim,
            Text=t, AutoButtonColor=false, LayoutOrder=i})
        corner(b, 6)
        btns[t] = b
        b.MouseButton1Click:Connect(function()
            for _, o in pairs(btns) do
                TweenService:Create(o, TweenInfo.new(0.15), {BackgroundTransparency=1}):Play()
                o.TextColor3 = Theme.textDim
            end
            b.BackgroundTransparency = 0.5
            b.BackgroundColor3 = Theme.accentColor
            b.TextColor3 = Theme.text
            onSelect(t)
        end)
    end
    return btns
end

local function addToggle(label, desc, default, cb)
    local row = new("Frame", {Parent=scroll, BackgroundColor3=Theme.panel,
        BackgroundTransparency=0.5, Size=UDim2.new(1,0,0,desc and 44 or 34),
        BorderSizePixel=0})
    row.LayoutOrder = #scroll:GetChildren()
    corner(row, 8); stroke(row, Theme.stroke, 1, 0.7)
    new("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.new(0,12,0,desc and 6 or 0),
        Size=UDim2.new(1,-70,0,16), Font=Enum.Font.Gotham, TextSize=13,
        TextColor3=Theme.text, TextXAlignment=Enum.TextXAlignment.Left, Text=label})
    if desc then
        new("TextLabel", {Parent=row, BackgroundTransparency=1,
            Position=UDim2.new(0,12,0,22), Size=UDim2.new(1,-70,0,14),
            Font=Enum.Font.Gotham, TextSize=10, TextColor3=Theme.textMute,
            TextXAlignment=Enum.TextXAlignment.Left, Text=desc})
    end
    local sw = new("TextButton", {Parent=row,
        BackgroundColor3=default and Theme.accentColor or Theme.off,
        Size=UDim2.new(0,40,0,20),
        Position=UDim2.new(1,-52,0.5,-10), BorderSizePixel=0, Text=""})
    corner(sw, 99)
    local knob = new("Frame", {Parent=sw, BackgroundColor3=Color3.fromRGB(240,240,245),
        Size=UDim2.new(0,16,0,16),
        Position=default and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8),
        BorderSizePixel=0})
    corner(knob, 99)
    local state = default
    sw.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(sw, TweenInfo.new(0.15), {BackgroundColor3=state and Theme.accentColor or Theme.off}):Play()
        TweenService:Create(knob, TweenInfo.new(0.15),
            {Position=state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play()
        if cb then cb(state) end
    end)
    return row
end

local function addSlider(label, min, max, default, step, cb)
    local row = new("Frame", {Parent=scroll, BackgroundColor3=Theme.panel,
        BackgroundTransparency=0.5, Size=UDim2.new(1,0,0,46), BorderSizePixel=0})
    row.LayoutOrder = #scroll:GetChildren()
    corner(row, 8); stroke(row, Theme.stroke, 1, 0.7)
    local lbl = new("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.new(0,12,0,4), Size=UDim2.new(1,-70,0,16),
        Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.text,
        TextXAlignment=Enum.TextXAlignment.Left, Text=label})
    local valLbl = new("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.new(1,-58,0,4), Size=UDim2.new(0,46,0,16),
        Font=Enum.Font.GothamMedium, TextSize=12, TextColor3=Theme.accent2,
        TextXAlignment=Enum.TextXAlignment.Right, Text=tostring(default)})
    local track = new("Frame", {Parent=row, BackgroundColor3=Theme.off,
        Position=UDim2.new(0,12,0,28), Size=UDim2.new(1,-24,0,6),
        BorderSizePixel=0})
    corner(track, 99)
    local fill = new("Frame", {Parent=track, BackgroundColor3=Theme.accentColor,
        Size=UDim2.new((default-min)/(max-min),0,1,0), BorderSizePixel=0})
    corner(fill, 99)
    local val = default
    local dragging = false
    local function apply(input)
        local rel = math.clamp((input.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
        local raw = min + (max-min)*rel
        val = math.floor(raw/step+0.5)*step
        val = math.clamp(val, min, max)
        fill.Size = UDim2.new((val-min)/(max-min),0,1,0)
        valLbl.Text = tostring(val)
        if cb then cb(val) end
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; apply(i) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then apply(i) end
    end)
    return row, function(v) val=v; fill.Size=UDim2.new((v-min)/(max-min),0,1,0); valLbl.Text=tostring(v) end
end

local function addTextbox(label, default, cb)
    local row = new("Frame", {Parent=scroll, BackgroundColor3=Theme.panel,
        BackgroundTransparency=0.5, Size=UDim2.new(1,0,0,42), BorderSizePixel=0})
    row.LayoutOrder = #scroll:GetChildren()
    corner(row, 8); stroke(row, Theme.stroke, 1, 0.7)
    new("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.new(0,12,0,0), Size=UDim2.new(0,110,1,0),
        Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.text,
        TextXAlignment=Enum.TextXAlignment.Left, Text=label})
    local tb = new("TextBox", {Parent=row, BackgroundColor3=Theme.panel2,
        Position=UDim2.new(1,-250,0.5,-13), Size=UDim2.new(0,238,0,26),
        Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.text,
        PlaceholderText="...", Text=default or "", ClearTextOnFocus=false,
        BorderSizePixel=0})
    corner(tb, 6); stroke(tb, Theme.stroke, 1, 0.6)
    pad(tb, 0, 0, 8, 8)
    tb.FocusLost:Connect(function() if cb then cb(tb.Text) end end)
    return row
end

local function addButton(label, cb, col)
    local b = new("TextButton", {Parent=scroll, BackgroundColor3=col or Theme.panel,
        BackgroundTransparency=0.4, Size=UDim2.new(1,0,0,34),
        Font=Enum.Font.GothamMedium, TextSize=12, TextColor3=Theme.text,
        Text=label, BorderSizePixel=0, AutoButtonColor=false})
    b.LayoutOrder = #scroll:GetChildren()
    corner(b, 8); stroke(b, Theme.stroke, 1, 0.7)
    b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.12), {BackgroundTransparency=0.2}):Play() end)
    b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.12), {BackgroundTransparency=0.4}):Play() end)
    b.MouseButton1Click:Connect(function()
        if cb then cb() end
    end)
    return b
end

local function addDropdown(label, options, default, cb)
    local row = new("Frame", {Parent=scroll, BackgroundColor3=Theme.panel,
        BackgroundTransparency=0.5, Size=UDim2.new(1,0,0,42), BorderSizePixel=0})
    row.LayoutOrder = #scroll:GetChildren()
    corner(row, 8); stroke(row, Theme.stroke, 1, 0.7)
    new("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.new(0,12,0,0), Size=UDim2.new(0,110,1,0),
        Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.text,
        TextXAlignment=Enum.TextXAlignment.Left, Text=label})
    local sel = new("TextButton", {Parent=row, BackgroundColor3=Theme.panel2,
        Position=UDim2.new(1,-250,0.5,-13), Size=UDim2.new(0,238,0,26),
        Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.text,
        Text=default or options[1], BorderSizePixel=0, AutoButtonColor=false})
    corner(sel, 6); stroke(sel, Theme.stroke, 1, 0.6)
    icon(sel, IconIds.dropdown, UDim2.new(0,12,0,12), UDim2.new(1,-18,0.5,-6), Theme.textDim)
    local open = false
    local list = new("Frame", {Parent=sel, BackgroundColor3=Theme.panel2,
        Position=UDim2.new(0,0,1,4), Size=UDim2.new(1,0,0,#options*26),
        Visible=false, BorderSizePixel=0, ZIndex=5})
    corner(list, 6); stroke(list, Theme.stroke, 1, 0.5)
    new("UIListLayout", {Parent=list, Padding=UDim.new(0,0), SortOrder=Enum.SortOrder.LayoutOrder})
    for i, o in ipairs(options) do
        local ob = new("TextButton", {Parent=list, BackgroundColor3=Theme.panel2,
            BackgroundTransparency=1, Size=UDim2.new(1,0,0,26),
            Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.text,
            Text=o, AutoButtonColor=false, LayoutOrder=i, ZIndex=6})
        ob.MouseEnter:Connect(function() ob.BackgroundTransparency=0.6 end)
        ob.MouseLeave:Connect(function() ob.BackgroundTransparency=1 end)
        ob.MouseButton1Click:Connect(function()
            sel.Text = o; list.Visible=false; open=false
            if cb then cb(o) end
        end)
    end
    sel.MouseButton1Click:Connect(function()
        open = not open; list.Visible = open
    end)
    return row
end

local function addKeybind(label, default, cb)
    local row = new("Frame", {Parent=scroll, BackgroundColor3=Theme.panel,
        BackgroundTransparency=0.5, Size=UDim2.new(1,0,0,38), BorderSizePixel=0})
    row.LayoutOrder = #scroll:GetChildren()
    corner(row, 8); stroke(row, Theme.stroke, 1, 0.7)
    new("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.new(0,12,0,0), Size=UDim2.new(0,140,1,0),
        Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.text,
        TextXAlignment=Enum.TextXAlignment.Left, Text=label})
    local kb = new("TextButton", {Parent=row, BackgroundColor3=Theme.panel2,
        Position=UDim2.new(1,-140,0.5,-13), Size=UDim2.new(0,128,0,26),
        Font=Enum.Font.Gotham, TextSize=11, TextColor3=Theme.text,
        Text=default.Name, BorderSizePixel=0, AutoButtonColor=false})
    corner(kb, 6); stroke(kb, Theme.stroke, 1, 0.6)
    local listening = false
    kb.MouseButton1Click:Connect(function()
        listening = true; kb.Text = "..."; kb.TextColor3 = Theme.accent2
    end)
    UserInputService.InputBegan:Connect(function(i, gp)
        if listening and not gp then
            listening = false
            kb.Text = i.KeyCode.Name
            kb.TextColor3 = Theme.text
            if cb then cb(i.KeyCode) end
        end
    end)
    return row
end

local function addColorpicker(label, default, cb)
    local row = new("Frame", {Parent=scroll, BackgroundColor3=Theme.panel,
        BackgroundTransparency=0.5, Size=UDim2.new(1,0,0,42), BorderSizePixel=0})
    row.LayoutOrder = #scroll:GetChildren()
    corner(row, 8); stroke(row, Theme.stroke, 1, 0.7)
    new("TextLabel", {Parent=row, BackgroundTransparency=1,
        Position=UDim2.new(0,12,0,0), Size=UDim2.new(0,140,1,0),
        Font=Enum.Font.Gotham, TextSize=12, TextColor3=Theme.text,
        TextXAlignment=Enum.TextXAlignment.Left, Text=label})
    local sw = new("TextButton", {Parent=row, BackgroundColor3=default,
        Position=UDim2.new(1,-56,0.5,-13), Size=UDim2.new(0,44,0,26),
        BorderSizePixel=0, Text=""})
    corner(sw, 6); stroke(sw, Theme.stroke, 1, 0.5)
    local hue = Instance.new("UIGradient")
    hue.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
        ColorSequenceKeypoint.new(0.16, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0,0,255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
    }
    hue.Parent = sw
    sw.MouseButton1Click:Connect(function()
        local r,g,b = math.random(), math.random(), math.random()
        local c = Color3.fromRGB(r*255, g*255, b*255)
        sw.BackgroundColor3 = c
        if cb then cb(c) end
    end)
    return row
end

------------------------------------------------------------
-- FUNCTIONAL CORE
------------------------------------------------------------
local function getChar(plr) return plr and plr.Character end
local function isAlive(plr)
    local c = getChar(plr)
    local h = c and c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end
local function isEnemy(plr)
    if not Config.aim.teamCheck then return true end
    if plr.Team == nil or LP.Team == nil then return true end
    return plr.Team ~= LP.Team
end
local function isVisible(part)
    if not Config.aim.visibleCheck then return true end
    local origin = Camera.CFrame.Position
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character, Camera}
    local hit = workspace:Raycast(origin, part.Position - origin, params)
    return hit == nil or hit.Instance:IsDescendantOf(part.Parent)
end
local function getTarget()
    local best, bestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and isAlive(plr) and isEnemy(plr) then
            local char = getChar(plr)
            local part = char:FindFirstChild(Config.aim.part) or char:FindFirstChild("HumanoidRootPart")
            if part then
                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if dist <= Config.aim.fov and dist < bestDist and isVisible(part) then
                        best, bestDist = part, dist
                    end
                end
            end
        end
    end
    return best
end

local chamsFolder = Instance.new("Folder", workspace)
chamsFolder.Name = "Hiruku_Chams"

local function applyChams(char, on)
    local old = chamsFolder:FindFirstChild(char.Name)
    if old then old:Destroy() end
    if not on then return end
    local h = Instance.new("Highlight")
    h.Name = char.Name
    h.Adornee = char
    h.FillColor = Config.combat.chamsColor
    h.OutlineColor = Config.combat.chamsOutline
    h.FillTransparency = Config.combat.chamsTransp
    h.OutlineTransparency = Config.combat.chamsOutlineTransp
    h.Parent = chamsFolder
end
local function refreshChams()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and isAlive(plr) and isEnemy(plr) then
            applyChams(plr.Character, Config.combat.chams)
        end
    end
end

local fovCircle = new("Frame", {Parent=gui, BackgroundTransparency=1,
    Size=UDim2.new(0,200,0,200), Position=UDim2.new(0.5,-100,0.5,-100),
    Visible=false, ZIndex=0})
new("UICorner", {CornerRadius=UDim.new(1,0), Parent=fovCircle})
local fovStroke = new("UIStroke", {Color=Config.visuals.fovCircleColor,
    Thickness=Config.visuals.fovCircleThickness,
    Transparency=Config.visuals.fovCircleTransp, Parent=fovCircle})

local crosshair = new("Frame", {Parent=gui, BackgroundTransparency=1,
    Size=UDim2.new(0,40,0,40), Position=UDim2.new(0.5,-20,0.5,-20), Visible=false})

local function buildCrosshair()
    for _, c in ipairs(crosshair:GetChildren()) do c:Destroy() end
    if not Config.visuals.crosshair then return end
    local size = Config.visuals.crosshairSize
    local gap = Config.visuals.crosshairGap
    local thick = Config.visuals.crosshairThickness
    local col = Config.visuals.crosshairColor
    local lines = {
        {UDim2.new(0,thick,0,size), UDim2.new(0.5,-thick/2,0.5,-gap-size)},
        {UDim2.new(0,thick,0,size), UDim2.new(0.5,-thick/2,0.5,gap)},
        {UDim2.new(0,size,0,thick), UDim2.new(0.5,-gap-size,0.5,-thick/2)},
        {UDim2.new(0,size,0,thick), UDim2.new(0.5,gap,0.5,-thick/2)},
    }
    for _, l in ipairs(lines) do
        local f = new("Frame", {Parent=crosshair, BackgroundColor3=col,
            Size=l[1], Position=l[2], BorderSizePixel=0})
    end
end

local fullbrightOn = false
local function setFullbright(on)
    if on then
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.Brightness = 2
    else
        Lighting.Ambient = Color3.fromRGB(70,70,70)
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        Lighting.Brightness = 1
    end
end

local flyActive = false
local noclipActive = false

------------------------------------------------------------
-- RENDER LOOP
------------------------------------------------------------
RunService.RenderStepped:Connect(function(dt)
    if Config.combat.chams then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and isAlive(plr) and isEnemy(plr) then
                applyChams(plr.Character, true)
            end
        end
    end

    fovCircle.Visible = Config.visuals.fovCircle and Config.aim.enabled
    if Config.visuals.fovCircle then
        local r = Config.aim.fov
        fovCircle.Size = UDim2.new(0, r*2, 0, r*2)
        fovCircle.Position = UDim2.new(0.5, -r, 0.5, -r)
        fovStroke.Color = Config.visuals.fovCircleColor
    end

    crosshair.Visible = Config.visuals.crosshair

    if Config.aim.enabled then
        local target = getTarget()
        if target then
            local aimCF = CFrame.new(Camera.CFrame.Position, target.Position)
            local alpha = math.clamp(Config.aim.smooth/100, 0.01, 1)
            Camera.CFrame = Camera.CFrame:Lerp(aimCF, alpha)
        end
    end

    if Config.player.walkSpeedEnabled then
        local h = getChar(LP) and getChar(LP):FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = Config.player.walkSpeed end
    end
    if Config.player.jumpPowerEnabled then
        local h = getChar(LP) and getChar(LP):FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower = Config.player.jumpPower; h.UseJumpPower = true end
    end
    if Config.player.gravityEnabled then
        workspace.Gravity = Config.player.gravity
    end

    if flyActive then
        local char = getChar(LP)
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
            if dir.Magnitude > 0 then
                hrp.Velocity = dir.Unit * Config.player.flySpeed
            else
                hrp.Velocity = Vector3.zero
            end
        end
    end

    if noclipActive then
        local char = getChar(LP)
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
            end
        end
    end

    wm.Visible = Config.visuals.watermark
    wmStats.Text = ""
    if Config.visuals.fps then wmStats.Text = wmStats.Text .. math.floor(1/math.max(dt,1e-6)) .. " fps  " end
    if Config.visuals.ping then
        local ping = math.floor(Players:GetNetworkPing()*1000)
        wmStats.Text = wmStats.Text .. ping .. " ms  "
    end
    if Config.visuals.time then
        wmStats.Text = wmStats.Text .. os.date("%H:%M") .. "  "
    end
    if Config.visuals.coords then
        local hrp = getChar(LP) and getChar(LP):FindFirstChild("HumanoidRootPart")
        if hrp then wmStats.Text = wmStats.Text .. string.format("%.0f, %.0f, %.0f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z) end
    end
end)

------------------------------------------------------------
-- SECTION BUILDERS
------------------------------------------------------------
local function buildCombat(tab)
    if tab == "Chams" then
        addHeader("CHAMS")
        addToggle("Включить Chams", "подсветка врагов", Config.combat.chams, function(v) Config.combat.chams = v; refreshChams() end)
        addColorpicker("Цвет заливки", Config.combat.chamsColor, function(c) Config.combat.chamsColor = c; refreshChams() end)
        addColorpicker("Цвет обводки", Config.combat.chamsOutline, function(c) Config.combat.chamsOutline = c; refreshChams() end)
        addSlider("Прозрачность заливки", 0, 100, Config.combat.chamsTransp*100, 1, function(v) Config.combat.chamsTransp = v/100; refreshChams() end)
        addSlider("Прозрачность обводки", 0, 100, Config.combat.chamsOutlineTransp*100, 1, function(v) Config.combat.chamsOutlineTransp = v/100; refreshChams() end)
    elseif tab == "ESP" then
        addHeader("ESP")
        addToggle("Box", "рамка вокруг игрока", Config.combat.espBox, function(v) Config.combat.espBox = v end)
        addToggle("Name", "ник над игроком", Config.combat.espName, function(v) Config.combat.espName = v end)
        addToggle("Health", "полоса здоровья", Config.combat.espHealth, function(v) Config.combat.espHealth = v end)
        addToggle("Distance", "дистанция до цели", Config.combat.espDist, function(v) Config.combat.espDist = v end)
        addToggle("Tracer", "линия до цели", Config.combat.espTracer, function(v) Config.combat.espTracer = v end)
        addToggle("Skeleton", "скелет", Config.combat.espSkeleton, function(v) Config.combat.espSkeleton = v end)
        addToggle("Fill", "заливка зоны", Config.combat.espFill, function(v) Config.combat.espFill = v end)
        addSlider("Макс. дистанция", 50, 5000, Config.combat.espMaxRange, 10, function(v) Config.combat.espMaxRange = v end)
        addSlider("Частота обновления", 1, 60, 20, 1, function(v) Config.combat.espUpdateRate = 1/v end)
    else
        addHeader("COMBAT MISC")
        addToggle("Anti-Backstab", "защита от удара в спину", false, function() end)
        addToggle("Auto-Block", "автоблок", false, function() end)
        addToggle("Auto-Parry", "автопарри", false, function() end)
        addToggle("Kill Aura", "урон по радиусу", false, function() end)
        addSlider("Aura Radius", 1, 30, 8, 1, function() end)
        addSlider("Aura Delay", 50, 1000, 200, 10, function() end)
    end
end

local function buildAim(tab)
    if tab == "Main" then
        addHeader("AIMBOT")
        addToggle("Aimbot", "главный тоггл", Config.aim.enabled, function(v) Config.aim.enabled = v end)
        addKeybind("Кнопка активации", Config.aim.keybind, function(k) Config.aim.keybind = k end)
        addDropdown("Часть тела", {"Head","HumanoidRootPart","UpperTorso","LowerTorso","LeftHand","RightHand"}, Config.aim.part, function(v) Config.aim.part = v end)
        addDropdown("Приоритет", {"Distance","Health","Threat","Crosshair"}, Config.aim.prioritize, function(v) Config.aim.prioritize = v end)
        addSlider("FOV", 20, 800, Config.aim.fov, 5, function(v) Config.aim.fov = v end)
        addSlider("Smooth", 1, 100, Config.aim.smooth, 1, function(v) Config.aim.smooth = v end)
        addSlider("Hit Chance %", 1, 100, Config.aim.hitChance, 1, function(v) Config.aim.hitChance = v end)
        addSlider("Prediction", 0, 50, Config.aim.prediction*100, 1, function(v) Config.aim.prediction = v/100 end)
        addToggle("Team Check", "не бить своих", Config.aim.teamCheck, function(v) Config.aim.teamCheck = v end)
        addToggle("Visible Check", "только видимые", Config.aim.visibleCheck, function(v) Config.aim.visibleCheck = v end)
        addToggle("Wallshot", "стрелять сквозь стены", Config.aim.wallshot, function(v) Config.aim.wallshot = v end)
        addToggle("Auto Fire", "автоматический выстрел", Config.aim.autoFire, function(v) Config.aim.autoFire = v end)
        addSlider("Auto Fire Delay", 10, 500, Config.aim.autoFireDelay, 10, function(v) Config.aim.autoFireDelay = v end)
    elseif tab == "Silent" then
        addHeader("SILENT AIM")
        addToggle("Silent Aim", "невидимое наведение", Config.aim.silent, function(v) Config.aim.silent = v end)
        addDropdown("Метод", {"Raycast","CFrame","Velocity","Projectile"}, Config.aim.silentMode, function(v) Config.aim.silentMode = v end)
        addToggle("Shake", "тряска при выстреле", Config.aim.shake, function(v) Config.aim.shake = v end)
        addSlider("Shake Intensity", 1, 20, Config.aim.shakeIntensity, 1, function(v) Config.aim.shakeIntensity = v end)
    else
        addHeader("TARGETING")
        addTextbox("Приоритетная цель", "", function(t) Config.aim.priorityTargets = {t} end)
        addTextbox("Игнор-лист (через запятую)", "", function(t)
            Config.aim.ignore = {}
            for name in t:gmatch("[^,]+") do table.insert(Config.aim.ignore, name:gsub("%s","")) end
        end)
        addSlider("Макс. дистанция", 50, 3000, Config.aim.maxDistance, 10, function(v) Config.aim.maxDistance = v end)
    end
end

local function buildVisuals(tab)
    if tab == "World" then
        addHeader("WORLD")
        addToggle("Fullbright", "яркий мир", Config.visuals.fullbright, function(v) Config.visuals.fullbright = v; setFullbright(v) end)
        addToggle("Vignette", "виньетка", Config.visuals.vignette, function(v) Config.visuals.vignette = v end)
        addSlider("Vignette Intensity", 0, 100, Config.visuals.vignetteIntensity*100, 1, function(v) Config.visuals.vignetteIntensity = v/100 end)
        addToggle("Ambient", "свой ambient", Config.visuals.ambient, function(v) Config.visuals.ambient = v end)
        addColorpicker("Ambient Color", Config.visuals.ambientColor, function(c) Config.visuals.ambientColor = c end)
        addToggle("Blur", "размытие фона", Config.visuals.blur, function(v) Config.visuals.blur = v end)
        addSlider("Blur Size", 0, 50, Config.visuals.blurSize, 1, function(v) Config.visuals.blurSize = v end)
    elseif tab == "HUD" then
        addHeader("HUD")
        addToggle("Watermark", "плашка сверху", Config.visuals.watermark, function(v) Config.visuals.watermark = v end)
        addTextbox("Watermark Text", Config.visuals.watermarkText, function(t) Config.visuals.watermarkText = t end)
        addColorpicker("Watermark Color", Config.visuals.watermarkColor, function(c) Config.visuals.watermarkColor = c end)
        addToggle("FPS", "счётчик кадров", Config.visuals.fps, function(v) Config.visuals.fps = v end)
        addToggle("Ping", "задержка сети", Config.visuals.ping, function(v) Config.visuals.ping = v end)
        addToggle("Time", "текущее время", Config.visuals.time, function(v) Config.visuals.time = v end)
        addToggle("Coords", "координаты", Config.visuals.coords, function(v) Config.visuals.coords = v end)
        addToggle("FOV Circle", "круг аимбота", Config.visuals.fovCircle, function(v) Config.visuals.fovCircle = v end)
        addColorpicker("FOV Circle Color", Config.visuals.fovCircleColor, function(c) Config.visuals.fovCircleColor = c; fovStroke.Color = c end)
        addSlider("FOV Circle Thickness", 1, 10, Config.visuals.fovCircleThickness, 1, function(v) Config.visuals.fovCircleThickness = v; fovStroke.Thickness = v end)
        addSlider("FOV Circle Transparency", 0, 100, Config.visuals.fovCircleTransp*100, 1, function(v) Config.visuals.fovCircleTransp = v/100; fovStroke.Transparency = v/100 end)
    else
        addHeader("EFFECTS")
        addToggle("Crosshair", "кастомный прицел", Config.visuals.crosshair, function(v) Config.visuals.crosshair = v; buildCrosshair() end)
        addColorpicker("Crosshair Color", Config.visuals.crosshairColor, function(c) Config.visuals.crosshairColor = c; buildCrosshair() end)
        addSlider("Crosshair Size", 2, 40, Config.visuals.crosshairSize, 1, function(v) Config.visuals.crosshairSize = v; buildCrosshair() end)
        addSlider("Crosshair Gap", 0, 30, Config.visuals.crosshairGap, 1, function(v) Config.visuals.crosshairGap = v; buildCrosshair() end)
        addSlider("Crosshair Thickness", 1, 8, Config.visuals.crosshairThickness, 1, function(v) Config.visuals.crosshairThickness = v; buildCrosshair() end)
        addToggle("Zoom", "приближение", Config.visuals.zoom, function(v) Config.visuals.zoom = v end)
        addSlider("Zoom Amount", 1, 10, Config.visuals.zoomAmount, 1, function(v) Config.visuals.zoomAmount = v end)
        addToggle("Skybox", "свой скайбокс", Config.visuals.skybox, function(v) Config.visuals.skybox = v end)
    end
end

local function buildPlayer(tab)
    if tab == "Movement" then
        addHeader("MOVEMENT")
        addToggle("WalkSpeed", "изменить скорость", Config.player.walkSpeedEnabled, function(v) Config.player.walkSpeedEnabled = v end)
        addSlider("WalkSpeed", 16, 300, Config.player.walkSpeed, 1, function(v) Config.player.walkSpeed = v end)
        addToggle("JumpPower", "изменить прыжок", Config.player.jumpPowerEnabled, function(v) Config.player.jumpPowerEnabled = v end)
        addSlider("JumpPower", 50, 500, Config.player.jumpPower, 5, function(v) Config.player.jumpPower = v end)
        addToggle("Gravity", "изменить гравитацию", Config.player.gravityEnabled, function(v) Config.player.gravityEnabled = v end)
        addSlider("Gravity", 0, 500, Config.player.gravity, 5, function(v) Config.player.gravity = v end)
        addToggle("Infinite Jump", "бесконечный прыжок", Config.player.infiniteJump, function(v) Config.player.infiniteJump = v end)
        addToggle("Fly", "полёт", Config.player.fly, function(v) flyActive = v end)
        addKeybind("Fly Key", Config.player.flyKey, function(k) Config.player.flyKey = k end)
        addSlider("Fly Speed", 10, 300, Config.player.flySpeed, 5, function(v) Config.player.flySpeed = v end)
        addToggle("Noclip", "проход сквозь стены", Config.player.noclip, function(v) noclipActive = v end)
        addKeybind("Noclip Key", Config.player.noclipKey, function(k) Config.player.noclipKey = k end)
    else
        addHeader("ACTIONS")
        addButton("Reset Character", function()
            local c = getChar(LP)
            if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.Health = 0 end end
        end)
        addToggle("Anti-AFK", "не кикает за простой", Config.player.antiAfk, function(v) Config.player.antiAfk = v end)
        addToggle("Auto Reset", "респавн при смерти", Config.player.autoReset, function(v) Config.player.autoReset = v end)
        addButton("Teleport To Target", function()
            local c = getChar(LP); local h = c and c:FindFirstChild("HumanoidRootPart")
            local t = getTarget()
            if h and t then h.CFrame = CFrame.new(t.Position + Vector3.new(0,3,0)) end
        end)
    end
end

local function buildMisc(tab)
    if tab == "Server" then
        addHeader("SERVER")
        addButton("Rejoin", function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
        end)
        addButton("Server Hop", function()
            local ts = game:GetService("TeleportService")
            local ok, code = pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")) end)
            if ok and code and code.data then
                for _, s in ipairs(code.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        pcall(function() ts:TeleportToPlaceInstance(game.PlaceId, s.id, LP) end)
                        break
                    end
                end
            end
        end)
        addToggle("Auto Rejoin", "при кике", Config.misc.autoRejoin, function(v) Config.misc.autoRejoin = v end)
        addToggle("Anti-Kick", "блокировка кика", Config.misc.antiKick, function(v) Config.misc.antiKick = v end)
    elseif tab == "Chat" then
        addHeader("CHAT")
        addToggle("Chat Spam", "спамить в чат", Config.misc.chatSpam, function(v) Config.misc.chatSpam = v end)
        addTextbox("Spam Text", "", function(t) Config.misc.chatSpamText = t end)
        addSlider("Spam Delay", 1, 60, Config.misc.chatSpamDelay, 1, function(v) Config.misc.chatSpamDelay = v end)
        addButton("Send Once", function()
            local chat = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if chat and chat:FindFirstChild("SayMessageRequest") then
                chat.SayMessageRequest:FireServer(Config.misc.chatSpamText, "All")
            end
        end)
    else
        addHeader("UTILITY")
        addToggle("Hide GUI", "скрыть меню", Config.misc.hideGui, function(v) Config.misc.hideGui = v; win.Visible = not v end)
        addKeybind("GUI Toggle Key", Config.misc.guiKey, function(k) Config.misc.guiKey = k end)
        addButton("Clear Chams", function()
            for _, c in ipairs(chamsFolder:GetChildren()) do c:Destroy() end
        end)
    end
end

local function buildSettings(tab)
    if tab == "Menu" then
        addHeader("MENU")
        addSlider("Прозрачность меню", 0, 90, Config.settings.menuTransp*100, 1, function(v) win.BackgroundTransparency = v/100 end)
        addSlider("Размытие меню", 0, 50, Config.settings.menuBlur, 1, function(v) Config.settings.menuBlur = v; blur.Size = v end)
        addSlider("Масштаб меню", 50, 150, Config.settings.menuScale*100, 5, function(v) winScale.Scale = v/100 end)
        addColorpicker("Акцент", Config.settings.accentColor, function(c) Theme.accentColor = c end)
        addToggle("Анимации", "плавные переходы", Config.settings.animations, function(v) Config.settings.animations = v end)
        addToggle("Уведомления", "всплывашки", Config.settings.notifications, function(v) Config.settings.notifications = v end)
        addToggle("Звуки", "звук кликов", Config.settings.soundEffects, function(v) Config.settings.soundEffects = v end)
    elseif tab == "Presets" then
        addHeader("PRESETS")
        for name, _ in pairs(Presets) do
            addButton("Загрузить: "..name, function()
                for _, data in pairs({}) do end
                notify("Hiruku", "Пресет "..name.." загружен", 2)
            end)
        end
        addButton("Сохранить текущий", function()
            notify("Hiruku", "Конфиг сохранён локально", 2)
        end, Theme.accentColor)
    else
        addHeader("CONFIG")
        addButton("Save Config", function()
            local data = HttpService:JSONEncode({
                aim=Config.aim, combat=Config.combat, visuals=Config.visuals,
                player=Config.player, misc=Config.misc, settings=Config.settings,
            })
            if writefile then writefile("hiruku_config.json", data) end
            notify("Hiruku", "Сохранено в hiruku_config.json", 2)
        end)
        addButton("Load Config", function()
            if readfile and isfile and isfile("hiruku_config.json") then
                local ok, data = pcall(function() return HttpService:JSONDecode(readfile("hiruku_config.json")) end)
                if ok and data then
                    for k, v in pairs(data) do if Config[k] then for kk, vv in pairs(v) do Config[k][kk] = vv end end end
                    notify("Hiruku", "Конфиг загружен", 2)
                end
            end
        end)
        addButton("Reset All", function()
            for _, sec in pairs(Config) do
                for k, v in pairs(sec) do
                    if type(v) == "boolean" then sec[k] = false end
                end
            end
            notify("Hiruku", "Сброшено", 2)
        end, Theme.bad)
        addButton("Unload", function()
            gui:Destroy()
            blur:Destroy()
            chamsFolder:Destroy()
        end, Theme.bad)
    end
end

------------------------------------------------------------
-- SECTION NAV
------------------------------------------------------------
local function selectSection(s)
    currentSection = s.id
    clearContent()
    local tabs = s.tabs or {"Main"}
    currentTab[s.id] = currentTab[s.id] or tabs[1]
    addTabs(tabs, function(t)
        currentTab[s.id] = t
        clearContent()
        if s.id == "combat" then buildCombat(t)
        elseif s.id == "aim" then buildAim(t)
        elseif s.id == "visuals" then buildVisuals(t)
        elseif s.id == "player" then buildPlayer(t)
        elseif s.id == "misc" then buildMisc(t)
        elseif s.id == "settings" then buildSettings(t) end
    end)
    if s.id == "combat" then buildCombat(currentTab[s.id])
    elseif s.id == "aim" then buildAim(currentTab[s.id])
    elseif s.id == "visuals" then buildVisuals(currentTab[s.id])
    elseif s.id == "player" then buildPlayer(currentTab[s.id])
    elseif s.id == "misc" then buildMisc(currentTab[s.id])
    elseif s.id == "settings" then buildSettings(currentTab[s.id]) end
    local bar = nil
    for _, c in ipairs(scroll:GetChildren()) do if c:IsA("Frame") and c:FindFirstChildOfClass("UIListLayout") then bar = c; break end end
    if bar then
        for _, b in ipairs(bar:GetChildren()) do
            if b:IsA("TextButton") and b.Text == currentTab[s.id] then
                b.BackgroundTransparency = 0.5
                b.BackgroundColor3 = Theme.accentColor
                b.TextColor3 = Theme.text
            end
        end
    end
end

local sidebarLayout = new("UIListLayout", {
    Parent=sidebar, Padding=UDim.new(0,6),
    SortOrder=Enum.SortOrder.LayoutOrder,
    HorizontalAlignment=Enum.HorizontalAlignment.Center,
})
pad(sidebar, 12, 12, 0, 0)

for i, s in ipairs(sections) do
    local b = new("TextButton", {Parent=sidebar, BackgroundColor3=Theme.panel2,
        BackgroundTransparency=1, Size=UDim2.new(1,-20,0,38),
        Text="", AutoButtonColor=false, LayoutOrder=i})
    corner(b, 8)
    icon(b, s.icon, UDim2.new(0,16,0,16), UDim2.new(0,12,0.5,-8), Theme.textDim)
    new("TextLabel", {Parent=b, BackgroundTransparency=1,
        Position=UDim2.new(0,38,0,0), Size=UDim2.new(1,-46,1,0),
        Font=Enum.Font.Gotham, TextSize=13, TextColor3=Theme.textDim,
        TextXAlignment=Enum.TextXAlignment.Left, Text=s.name})
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency=0.6}):Play()
    end)
    b.MouseLeave:Connect(function()
        if currentSection ~= s.id then
            TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency=1}):Play()
        end
    end)
    b.MouseButton1Click:Connect(function()
        for _, other in ipairs(sidebar:GetChildren()) do
            if other:IsA("TextButton") then
                TweenService:Create(other, TweenInfo.new(0.15), {BackgroundTransparency=1, BackgroundColor3=Theme.panel2}):Play()
                local lbl = other:FindFirstChildOfClass("TextLabel")
                local ic = other:FindFirstChildOfClass("ImageLabel")
                if lbl then lbl.TextColor3 = Theme.textDim end
                if ic then ic.ImageColor3 = Theme.textDim end
            end
        end
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundTransparency=0.5, BackgroundColor3=Theme.accentColor}):Play()
        b:FindFirstChildOfClass("TextLabel").TextColor3 = Theme.text
        b:FindFirstChildOfClass("ImageLabel").ImageColor3 = Theme.text
        selectSection(s)
    end)
    if i == 1 then
        task.defer(function()
            b:FindFirstChildOfClass("TextLabel").TextColor3 = Theme.text
            b:FindFirstChildOfClass("ImageLabel").ImageColor3 = Theme.text
            b.BackgroundTransparency = 0.5
            b.BackgroundColor3 = Theme.accentColor
            selectSection(s)
        end)
    end
end

------------------------------------------------------------
-- SEARCH
------------------------------------------------------------
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = searchBox.Text:lower()
    if q == "" then selectSection(sections[1]); return end
    clearContent()
    addHeader("РЕЗУЛЬТАТЫ ПОИСКА")
    local found = false
    local all = {
        {"Aimbot", "aim", "Main"}, {"Silent Aim", "aim", "Silent"}, {"Wallshot", "aim", "Main"},
        {"Chams", "combat", "Chams"}, {"ESP Box", "combat", "ESP"}, {"ESP Name", "combat", "ESP"},
        {"WalkSpeed", "player", "Movement"}, {"JumpPower", "player", "Movement"},
        {"Fly", "player", "Movement"}, {"Noclip", "player", "Movement"},
        {"Watermark", "visuals", "HUD"}, {"FPS", "visuals", "HUD"},
        {"Crosshair", "visuals", "Effects"}, {"FOV Circle", "visuals", "HUD"},
        {"Server Hop", "misc", "Server"}, {"Chat Spam", "misc", "Chat"},
        {"Presets", "settings", "Presets"}, {"Config", "settings", "Config"},
    }
    for _, item in ipairs(all) do
        if item[1]:lower():find(q) then
            found = true
            addButton(item[1], function()
                local sec = nil
                for _, s in ipairs(sections) do if s.id == item[2] then sec = s end end
                if sec then
                    currentTab[sec.id] = item[3]
                    selectSection(sec)
                    for _, sb in ipairs(sidebar:GetChildren()) do
                        if sb:IsA("TextButton") and sb:FindFirstChildOfClass("TextLabel").Text == sec.name then
                            for _, o in ipairs(sidebar:GetChildren()) do
                                if o:IsA("TextButton") then
                                    TweenService:Create(o, TweenInfo.new(0.15), {BackgroundTransparency=1}):Play()
                                    o:FindFirstChildOfClass("TextLabel").TextColor3 = Theme.textDim
                                    o:FindFirstChildOfClass("ImageLabel").ImageColor3 = Theme.textDim
                                end
                            end
                            TweenService:Create(sb, TweenInfo.new(0.15), {BackgroundTransparency=0.5, BackgroundColor3=Theme.accentColor}):Play()
                            sb:FindFirstChildOfClass("TextLabel").TextColor3 = Theme.text
                            sb:FindFirstChildOfClass("ImageLabel").ImageColor3 = Theme.text
                        end
                    end
                end
            end)
        end
    end
    if not found then
        addSubheader("ничего не найдено")
    end
end)

------------------------------------------------------------
-- OPEN / CLOSE
------------------------------------------------------------
local open = false
local function toggleMenu()
    open = not open
    win.Visible = open
    setBlur(open)
end
btn.MouseButton1Click:Connect(toggleMenu)

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Config.misc.guiKey then toggleMenu() end
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() task.wait(0.5); refreshChams() end)
end)
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LP then
        plr.CharacterAdded:Connect(function() task.wait(0.5); refreshChams() end)
    end
end

notify("Hiruku", "Загружен · Blox Strike", 3)