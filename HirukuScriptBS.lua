-- Hiruku · Blox Strike · Mobile Fixed
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Theme = {
    bg = Color3.fromRGB(15,15,19),
    panel = Color3.fromRGB(24,24,30),
    panel2 = Color3.fromRGB(30,30,38),
    stroke = Color3.fromRGB(50,50,62),
    text = Color3.fromRGB(232,232,240),
    textDim = Color3.fromRGB(148,148,162),
    textMute = Color3.fromRGB(96,96,110),
    accent = Color3.fromRGB(138,92,246),
    accent2 = Color3.fromRGB(168,132,255),
    off = Color3.fromRGB(46,46,56),
    bgTransp = 0.15,
}

local IconIds = {
    logo="6031075931", combat="6031094303", aim="6031266840",
    visuals="6031237641", player="6031267778", misc="6031099225",
    settings="6031239822", close="6031251557", toggle="6031285016",
    search="6031277085", dropdown="6031095057",
}

local function new(class, props)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k]=v end
    return o
end
local function corner(p,r) return new("UICorner",{CornerRadius=UDim.new(0,r or 6),Parent=p}) end
local function stroke(p,c,t,tr) return new("UIStroke",{Color=c or Theme.stroke,Thickness=t or 1,Transparency=tr or 0.2,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=p}) end
local function pad(p,a,b,c,d) return new("UIPadding",{PaddingTop=UDim.new(0,a),PaddingBottom=UDim.new(0,b or a),PaddingLeft=UDim.new(0,c or a),PaddingRight=UDim.new(0,d or a),Parent=p}) end
local function icon(parent,id,size,pos,color)
    return new("ImageLabel",{BackgroundTransparency=1,Image="rbxassetid://"..id,ImageColor3=color or Theme.text,Size=size,Position=pos,Parent=parent})
end

local gui = new("ScreenGui",{Name="Hiruku",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true})
pcall(function() gui.Parent=game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent=LP:WaitForChild("PlayerGui") end

-- blur
local blur = new("BlurEffect",{Name="HirukuBlur",Size=0,Parent=Lighting})
local function setBlur(on) TweenService:Create(blur,TweenInfo.new(0.25),{Size=on and 24 or 0}):Play() end

-- watermark
local wm = new("Frame",{Parent=gui,BackgroundColor3=Theme.bg,BackgroundTransparency=Theme.bgTransp,Size=UDim2.new(0,230,0,32),Position=UDim2.new(0,12,0,12),BorderSizePixel=0})
corner(wm,6); stroke(wm,Theme.accent,1,0.55)
icon(wm,IconIds.logo,UDim2.new(0,14,0,14),UDim2.new(0,10,0.5,-7),Theme.accent)
new("TextLabel",{Parent=wm,BackgroundTransparency=1,Position=UDim2.new(0,30,0,0),Size=UDim2.new(1,-38,1,0),Font=Enum.Font.Code,TextSize=13,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text="Hiruku  ·  Blox Strike"})
local wmStats = new("TextLabel",{Parent=wm,BackgroundTransparency=1,Size=UDim2.new(1,-8,1,0),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.textDim,TextXAlignment=Enum.TextXAlignment.Right,Text=""})

-- toggle button
local btn = new("TextButton",{Parent=gui,BackgroundColor3=Theme.bg,BackgroundTransparency=Theme.bgTransp,Size=UDim2.new(0,44,0,44),Position=UDim2.new(0,12,0,52),BorderSizePixel=0,Text="",AutoButtonColor=false})
corner(btn,10); stroke(btn,Theme.accent,1.3,0.35)
icon(btn,IconIds.toggle,UDim2.new(0,20,0,20),UDim2.new(0.5,-10,0.5,-10),Theme.accent)

local function makeDraggable(frame,handle)
    handle=handle or frame
    local dragging,dragStart,startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=i.Position; startPos=frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dragStart
            frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end
makeDraggable(wm); makeDraggable(btn)

-- main window
local win = new("Frame",{Parent=gui,BackgroundColor3=Theme.bg,BackgroundTransparency=Theme.bgTransp,Size=UDim2.new(0,720,0,460),Position=UDim2.new(0.5,-360,0.5,-230),BorderSizePixel=0,Visible=false})
corner(win,6); stroke(win,Theme.stroke,1,0.3)
makeDraggable(win)

-- title bar
local titleBar = new("Frame",{Parent=win,BackgroundTransparency=1,Size=UDim2.new(1,0,0,42)})
icon(titleBar,IconIds.logo,UDim2.new(0,16,0,16),UDim2.new(0,14,0.5,-8),Theme.accent)
new("TextLabel",{Parent=titleBar,BackgroundTransparency=1,Position=UDim2.new(0,36,0,0),Size=UDim2.new(1,-120,1,0),Font=Enum.Font.Code,TextSize=14,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text="Hiruku  ·  Combat"})

local searchBox = new("TextBox",{Parent=titleBar,BackgroundColor3=Theme.panel,Position=UDim2.new(1,-300,0.5,-12),Size=UDim2.new(0,200,0,24),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.text,PlaceholderText="search...",Text="",ClearTextOnFocus=false,BorderSizePixel=0})
corner(searchBox,4); stroke(searchBox,Theme.stroke,1,0.6); pad(searchBox,0,0,6,6)

local closeBtn = new("TextButton",{Parent=titleBar,BackgroundTransparency=1,Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-38,0.5,-15),Text=""})
icon(closeBtn,IconIds.close,UDim2.new(0,14,0,14),UDim2.new(0.5,-7,0.5,-7),Theme.textDim)
closeBtn.MouseButton1Click:Connect(function() win.Visible=false; setBlur(false) end)

-- sidebar (NO profileBox inside!)
local sidebar = new("Frame",{Parent=win,BackgroundColor3=Theme.panel,BackgroundTransparency=0.1,Position=UDim2.new(0,0,0,42),Size=UDim2.new(0,180,1,-42),BorderSizePixel=0})
corner(sidebar,6)
new("UIListLayout",{Parent=sidebar,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center})
pad(sidebar,10)

-- content
local content = new("Frame",{Parent=win,BackgroundTransparency=1,Position=UDim2.new(0,180,0,42),Size=UDim2.new(1,-180,1,-42)})

local scroll = new("ScrollingFrame",{Parent=content,BackgroundTransparency=1,Size=UDim2.new(1,-12,1,-12),Position=UDim2.new(0,6,0,6),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=6,ScrollBarImageColor3=Theme.accent,ScrollBarImageTransparency=0.4,BorderSizePixel=0,ClipsDescendants=true})
new("UIListLayout",{Parent=scroll,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder})
pad(scroll,0,10,0,4)

local sections = {
    {id="combat",icon=IconIds.combat,name="Combat"},
    {id="aim",icon=IconIds.aim,name="Aim"},
    {id="visuals",icon=IconIds.visuals,name="Visuals"},
    {id="player",icon=IconIds.player,name="Player"},
    {id="misc",icon=IconIds.misc,name="Misc"},
    {id="settings",icon=IconIds.settings,name="Settings"},
}

local currentSection = "combat"

local function clearContent()
    for _,c in ipairs(scroll:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
end

-- UI component builders
local function addHeader(text)
    local h = new("TextLabel",{Parent=scroll,BackgroundTransparency=1,Size=UDim2.new(1,0,0,24),Font=Enum.Font.Code,TextSize=12,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text=text})
    h.LayoutOrder=#scroll:GetChildren()
end

local function addToggle(label,desc,default,cb)
    local row = new("Frame",{Parent=scroll,BackgroundColor3=Theme.panel,BackgroundTransparency=0.5,Size=UDim2.new(1,0,0,desc and 40 or 32),BorderSizePixel=0})
    row.LayoutOrder=#scroll:GetChildren()
    corner(row,5); stroke(row,Theme.stroke,1,0.7)
    new("TextLabel",{Parent=row,BackgroundTransparency=1,Position=UDim2.new(0,10,0,desc and 5 or 0),Size=UDim2.new(1,-60,0,15),Font=Enum.Font.Code,TextSize=12,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text=label})
    if desc then
        new("TextLabel",{Parent=row,BackgroundTransparency=1,Position=UDim2.new(0,10,0,20),Size=UDim2.new(1,-60,0,13),Font=Enum.Font.Code,TextSize=9,TextColor3=Theme.textMute,TextXAlignment=Enum.TextXAlignment.Left,Text=desc})
    end
    local sw = new("TextButton",{Parent=row,BackgroundColor3=default and Theme.accent or Theme.off,Size=UDim2.new(0,38,0,18),Position=UDim2.new(1,-48,0.5,-9),BorderSizePixel=0,Text=""})
    corner(sw,99)
    local knob = new("Frame",{Parent=sw,BackgroundColor3=Color3.fromRGB(240,240,245),Size=UDim2.new(0,14,0,14),Position=default and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),BorderSizePixel=0})
    corner(knob,99)
    local state = default
    sw.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(sw,TweenInfo.new(0.15),{BackgroundColor3=state and Theme.accent or Theme.off}):Play()
        TweenService:Create(knob,TweenInfo.new(0.15),{Position=state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
        if cb then cb(state) end
    end)
end

local function addSlider(label,min,max,default,step,cb)
    local row = new("Frame",{Parent=scroll,BackgroundColor3=Theme.panel,BackgroundTransparency=0.5,Size=UDim2.new(1,0,0,42),BorderSizePixel=0})
    row.LayoutOrder=#scroll:GetChildren()
    corner(row,5); stroke(row,Theme.stroke,1,0.7)
    local lbl = new("TextLabel",{Parent=row,BackgroundTransparency=1,Position=UDim2.new(0,10,0,3),Size=UDim2.new(1,-60,0,14),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text=label})
    local valLbl = new("TextLabel",{Parent=row,BackgroundTransparency=1,Position=UDim2.new(1,-50,0,3),Size=UDim2.new(0,40,0,14),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.accent2,TextXAlignment=Enum.TextXAlignment.Right,Text=tostring(default)})
    local track = new("Frame",{Parent=row,BackgroundColor3=Theme.off,Position=UDim2.new(0,10,0,24),Size=UDim2.new(1,-20,0,6),BorderSizePixel=0})
    corner(track,99)
    local fill = new("Frame",{Parent=track,BackgroundColor3=Theme.accent,Size=UDim2.new((default-min)/(max-min),0,1,0),BorderSizePixel=0})
    corner(fill,99)
    local val=default; local dragging=false
    local function apply(input)
        local rel=math.clamp((input.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local raw=min+(max-min)*rel
        val=math.floor(raw/step+0.5)*step; val=math.clamp(val,min,max)
        fill.Size=UDim2.new((val-min)/(max-min),0,1,0); valLbl.Text=tostring(val)
        if cb then cb(val) end
    end
    track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; apply(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then apply(i) end end)
end

local function addTextbox(label,default,cb)
    local row = new("Frame",{Parent=scroll,BackgroundColor3=Theme.panel,BackgroundTransparency=0.5,Size=UDim2.new(1,0,0,38),BorderSizePixel=0})
    row.LayoutOrder=#scroll:GetChildren()
    corner(row,5); stroke(row,Theme.stroke,1,0.7)
    new("TextLabel",{Parent=row,BackgroundTransparency=1,Position=UDim2.new(0,10,0,0),Size=UDim2.new(0,100,1,0),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text=label})
    local tb = new("TextBox",{Parent=row,BackgroundColor3=Theme.panel2,Position=UDim2.new(1,-230,0.5,-11),Size=UDim2.new(0,220,0,22),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.text,PlaceholderText="...",Text=default or "",ClearTextOnFocus=false,BorderSizePixel=0})
    corner(tb,4); stroke(tb,Theme.stroke,1,0.6); pad(tb,0,0,6,6)
    tb.FocusLost:Connect(function() if cb then cb(tb.Text) end end)
end

local function addButton(label,cb,col)
    local b = new("TextButton",{Parent=scroll,BackgroundColor3=col or Theme.panel,BackgroundTransparency=0.4,Size=UDim2.new(1,0,0,32),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.text,Text=label,BorderSizePixel=0,AutoButtonColor=false})
    b.LayoutOrder=#scroll:GetChildren()
    corner(b,5); stroke(b,Theme.stroke,1,0.7)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
end

local function addDropdown(label,options,default,cb)
    local row = new("Frame",{Parent=scroll,BackgroundColor3=Theme.panel,BackgroundTransparency=0.5,Size=UDim2.new(1,0,0,38),BorderSizePixel=0})
    row.LayoutOrder=#scroll:GetChildren()
    corner(row,5); stroke(row,Theme.stroke,1,0.7)
    new("TextLabel",{Parent=row,BackgroundTransparency=1,Position=UDim2.new(0,10,0,0),Size=UDim2.new(0,100,1,0),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text=label})
    local sel = new("TextButton",{Parent=row,BackgroundColor3=Theme.panel2,Position=UDim2.new(1,-230,0.5,-11),Size=UDim2.new(0,220,0,22),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.text,Text=default or options[1],BorderSizePixel=0,AutoButtonColor=false})
    corner(sel,4); stroke(sel,Theme.stroke,1,0.6)
    icon(sel,IconIds.dropdown,UDim2.new(0,10,0,10),UDim2.new(1,-16,0.5,-5),Theme.textDim)
    local open=false
    local list = new("Frame",{Parent=sel,BackgroundColor3=Theme.panel2,Position=UDim2.new(0,0,1,2),Size=UDim2.new(1,0,0,#options*24),Visible=false,BorderSizePixel=0,ZIndex=5})
    corner(list,4); stroke(list,Theme.stroke,1,0.5)
    new("UIListLayout",{Parent=list,Padding=UDim.new(0,0),SortOrder=Enum.SortOrder.LayoutOrder})
    for i,o in ipairs(options) do
        local ob = new("TextButton",{Parent=list,BackgroundColor3=Theme.panel2,BackgroundTransparency=1,Size=UDim2.new(1,0,0,24),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.text,Text=o,AutoButtonColor=false,LayoutOrder=i,ZIndex=6})
        ob.MouseButton1Click:Connect(function()
            sel.Text=o; list.Visible=false; open=false
            if cb then cb(o) end
        end)
    end
    sel.MouseButton1Click:Connect(function() open=not open; list.Visible=open end)
end

-- core functions
local function getChar(plr) return plr and plr.Character end
local function isAlive(plr)
    local c=getChar(plr); local h=c and c:FindFirstChildOfClass("Humanoid")
    return h and h.Health>0
end
local function isEnemy(plr)
    if not LP.Team or not plr.Team then return true end
    return plr.Team~=LP.Team
end
local function getTarget()
    local best,bestDist=nil,math.huge
    local center = Camera.ViewportSize/2
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and isAlive(plr) and isEnemy(plr) then
            local char=getChar(plr)
            local part=char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            if part then
                local sp,onScreen=Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist=(Vector2.new(sp.X,sp.Y)-center).Magnitude
                    if dist<=120 and dist<bestDist then
                        best,bestDist=part,dist
                    end
                end
            end
        end
    end
    return best
end

local chamsFolder = new("Folder",{Name="HirukuChams",Parent=workspace})

local function applyChams(char,on)
    local old=chamsFolder:FindFirstChild(char.Name)
    if old then old:Destroy() end
    if not on then return end
    local h=new("Highlight",{Name=char.Name,Adornee=char,FillColor=Theme.accent,OutlineColor=Theme.accent2,FillTransparency=0.5,OutlineTransparency=0.15,Parent=chamsFolder})
end

-- state
local State = {
    aimbot=false, aimSmooth=15, aimFov=120, silent=false, wallshot=false,
    chams=false, espBox=false, espName=false, espHealth=false, espDist=false,
    watermark=true, fps=true, ping=false, coords=false,
    fovCircle=false, crosshair=false,
    walkSpeed=16, walkSpeedOn=false, jumpPower=50, jumpPowerOn=false,
    fly=false, noclip=false, infiniteJump=false,
}

-- fov circle
local fovCircle = new("Frame",{Parent=gui,BackgroundTransparency=1,Size=UDim2.new(0,240,0,240),Position=UDim2.new(0.5,-120,0.5,-120),Visible=false,ZIndex=0})
new("UICorner",{CornerRadius=UDim.new(1,0),Parent=fovCircle})
new("UIStroke",{Color=Theme.accent,Thickness=1,Transparency=0.3,Parent=fovCircle})

-- render
RunService.RenderStepped:Connect(function(dt)
    if State.chams then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP and isAlive(plr) and isEnemy(plr) then applyChams(plr.Character,true) end
        end
    end

    fovCircle.Visible = State.fovCircle and State.aimbot
    if State.fovCircle then
        local r=State.aimFov
        fovCircle.Size=UDim2.new(0,r*2,0,r*2)
        fovCircle.Position=UDim2.new(0.5,-r,0.5,-r)
    end

    if State.aimbot then
        local target=getTarget()
        if target then
            local aimCF=CFrame.new(Camera.CFrame.Position,target.Position)
            Camera.CFrame=Camera.CFrame:Lerp(aimCF,math.clamp(State.aimSmooth/100,0.01,1))
        end
    end

    if State.walkSpeedOn then
        local h=getChar(LP) and getChar(LP):FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed=State.walkSpeed end
    end
    if State.jumpPowerOn then
        local h=getChar(LP) and getChar(LP):FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower=State.jumpPower; h.UseJumpPower=true end
    end

    wm.Visible = State.watermark
    wmStats.Text=""
    if State.fps then wmStats.Text=wmStats.Text..math.floor(1/math.max(dt,1e-6)).."fps " end
    if State.ping then wmStats.Text=wmStats.Text..math.floor(Players:GetNetworkPing()*1000).."ms " end
    if State.coords then
        local hrp=getChar(LP) and getChar(LP):FindFirstChild("HumanoidRootPart")
        if hrp then wmStats.Text=wmStats.Text..string.format("%.0f,%.0f,%.0f",hrp.Position.X,hrp.Position.Y,hrp.Position.Z) end
    end
end)

-- section builders
local function buildCombat()
    addHeader("CHAMS")
    addToggle("Chams","highlight enemies",State.chams,function(v) State.chams=v end)
    addHeader("ESP")
    addToggle("Box","",State.espBox,function(v) State.espBox=v end)
    addToggle("Name","",State.espName,function(v) State.espName=v end)
    addToggle("Health","",State.espHealth,function(v) State.espHealth=v end)
    addToggle("Distance","",State.espDist,function(v) State.espDist=v end)
end

local function buildAim()
    addHeader("AIMBOT")
    addToggle("Aimbot","main toggle",State.aimbot,function(v) State.aimbot=v end)
    addSlider("Smooth",1,100,State.aimSmooth,1,function(v) State.aimSmooth=v end)
    addSlider("FOV",20,400,State.aimFov,5,function(v) State.aimFov=v end)
    addToggle("Silent Aim","",State.silent,function(v) State.silent=v end)
    addToggle("Wallshot","",State.wallshot,function(v) State.wallshot=v end)
    addDropdown("Aim Part",{"Head","HumanoidRootPart","UpperTorso","LowerTorso"},"Head",function(v) end)
end

local function buildVisuals()
    addHeader("HUD")
    addToggle("Watermark","top-left badge",State.watermark,function(v) State.watermark=v end)
    addToggle("FPS","",State.fps,function(v) State.fps=v end)
    addToggle("Ping","",State.ping,function(v) State.ping=v end)
    addToggle("Coords","",State.coords,function(v) State.coords=v end)
    addHeader("WORLD")
    addToggle("FOV Circle","",State.fovCircle,function(v) State.fovCircle=v end)
    addToggle("Crosshair","",State.crosshair,function(v) State.crosshair=v end)
end

local function buildPlayer()
    addHeader("MOVEMENT")
    addToggle("WalkSpeed","",State.walkSpeedOn,function(v) State.walkSpeedOn=v end)
    addSlider("Speed",16,200,State.walkSpeed,1,function(v) State.walkSpeed=v end)
    addToggle("JumpPower","",State.jumpPowerOn,function(v) State.jumpPowerOn=v end)
    addSlider("Jump",50,300,State.jumpPower,5,function(v) State.jumpPower=v end)
    addToggle("Infinite Jump","",State.infiniteJump,function(v) State.infiniteJump=v end)
    addToggle("Fly","",State.fly,function(v) State.fly=v end)
    addToggle("Noclip","",State.noclip,function(v) State.noclip=v end)
    addHeader("ACTIONS")
    addButton("Reset Character",function()
        local c=getChar(LP)
        if c then local h=c:FindFirstChildOfClass("Humanoid"); if h then h.Health=0 end end
    end)
end

local function buildMisc()
    addHeader("SERVER")
    addButton("Rejoin",function() game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end)
    addButton("Server Hop",function()
        local ts=game:GetService("TeleportService")
        local ok,res=pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")) end)
        if ok and res and res.data then
            for _,s in ipairs(res.data) do
                if s.playing<s.maxPlayers and s.id~=game.JobId then
                    pcall(function() ts:TeleportToPlaceInstance(game.PlaceId,s.id,LP) end)
                    break
                end
            end
        end
    end)
    addHeader("UTILITY")
    addButton("Unload",function() gui:Destroy(); blur:Destroy(); chamsFolder:Destroy() end, Color3.fromRGB(180,60,60))
end

local function buildSettings()
    addHeader("MENU")
    addSlider("Transparency",0,90,15,1,function(v) win.BackgroundTransparency=v/100 end)
    addSlider("Blur Size",0,50,24,1,function(v) blur.Size=v end)
    addButton("Save Config",function()
        local data=HttpService:JSONEncode(State)
        if writefile then writefile("hiruku.json",data) end
    end)
    addButton("Load Config",function()
        if readfile and isfile and isfile("hiruku.json") then
            local ok,d=pcall(function() return HttpService:JSONDecode(readfile("hiruku.json")) end)
            if ok and d then for k,v in pairs(d) do State[k]=v end end
        end
    end)
end

local builders = {combat=buildCombat,aim=buildAim,visuals=buildVisuals,player=buildPlayer,misc=buildMisc,settings=buildSettings}

local function selectSection(s)
    currentSection=s.id
    clearContent()
    if builders[s.id] then builders[s.id]() end
end

-- sidebar buttons (correct layout now)
for i,s in ipairs(sections) do
    local b = new("TextButton",{Parent=sidebar,BackgroundColor3=Theme.panel2,BackgroundTransparency=1,Size=UDim2.new(1,0,0,34),Text="",AutoButtonColor=false,LayoutOrder=i})
    corner(b,5)
    icon(b,s.icon,UDim2.new(0,16,0,16),UDim2.new(0,10,0.5,-8),Theme.textDim)
    new("TextLabel",{Parent=b,BackgroundTransparency=1,Position=UDim2.new(0,34,0,0),Size=UDim2.new(1,-42,1,0),Font=Enum.Font.Code,TextSize=12,TextColor3=Theme.textDim,TextXAlignment=Enum.TextXAlignment.Left,Text=s.name})
    b.MouseButton1Click:Connect(function()
        for _,other in ipairs(sidebar:GetChildren()) do
            if other:IsA("TextButton") then
                TweenService:Create(other,TweenInfo.new(0.12),{BackgroundTransparency=1,BackgroundColor3=Theme.panel2}):Play()
                local lbl=other:FindFirstChildOfClass("TextLabel"); if lbl then lbl.TextColor3=Theme.textDim end
                local ic=other:FindFirstChildOfClass("ImageLabel"); if ic then ic.ImageColor3=Theme.textDim end
            end
        end
        TweenService:Create(b,TweenInfo.new(0.12),{BackgroundTransparency=0.5,BackgroundColor3=Theme.accent}):Play()
        b:FindFirstChildOfClass("TextLabel").TextColor3=Theme.text
        b:FindFirstChildOfClass("ImageLabel").ImageColor3=Theme.text
        selectSection(s)
    end)
    if i==1 then
        task.defer(function()
            b.BackgroundTransparency=0.5; b.BackgroundColor3=Theme.accent
            b:FindFirstChildOfClass("TextLabel").TextColor3=Theme.text
            b:FindFirstChildOfClass("ImageLabel").ImageColor3=Theme.text
            selectSection(s)
        end)
    end
end

-- open/close
local open=false
local function toggleMenu() open=not open; win.Visible=open; setBlur(open) end
btn.MouseButton1Click:Connect(toggleMenu)
UserInputService.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.RightShift then toggleMenu() end end)