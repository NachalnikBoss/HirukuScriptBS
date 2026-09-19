-- Hiruku · MM2 · v1.0
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Theme = {
    bg = Color3.fromRGB(0,0,0),
    panel = Color3.fromRGB(8,8,8),
    panel2 = Color3.fromRGB(14,14,14),
    text = Color3.fromRGB(255,255,255),
    textDim = Color3.fromRGB(140,140,140),
    accent = Color3.fromRGB(255,255,255),
    off = Color3.fromRGB(40,40,40),
    red = Color3.fromRGB(220,50,50),
    blue = Color3.fromRGB(50,120,220),
    green = Color3.fromRGB(50,180,80),
}

local Icons = {
    logo="rbxassetid://7847285702", combat="rbxassetid://7847265842",
    visuals="rbxassetid://7847266534", misc="rbxassetid://7847267216",
    troll="rbxassetid://7847268190", settings="rbxassetid://7847267518",
    close="rbxassetid://7847267829",
}

local function new(c,p) local o=Instance.new(c); for k,v in pairs(p or {}) do o[k]=v end; return o end
local function corner(p,r) return new("UICorner",{CornerRadius=UDim.new(0,r or 4),Parent=p}) end
local function stroke(p,c,t,tr) return new("UIStroke",{Color=c or Theme.text,Thickness=t or 1,Transparency=tr or 0.3,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=p}) end
local function pad(p,a,b,c,d) return new("UIPadding",{PaddingTop=UDim.new(0,a),PaddingBottom=UDim.new(0,b or a),PaddingLeft=UDim.new(0,c or a),PaddingRight=UDim.new(0,d or a),Parent=p}) end

-- CONFIG
local Config = {
    chams=false, chamsSheriff=Color3.fromRGB(50,120,220), chamsMurderer=Color3.fromRGB(220,50,50), chamsInnocent=Color3.fromRGB(50,180,80),
    espName=false, autoFarm=false, fly=false, noclip=false,
    silent=false, aimbot=false, aimFov=120, aimSmooth=15,
    sexAura=false, sexSpeed=10, crashPlayer=false,
}
local function LoadCfg()
    if readfile and isfile("HirukuMM2.json") then
        local ok,d=pcall(function() return HttpService:JSONDecode(readfile("HirukuMM2.json")) end)
        if ok and d then for k,v in pairs(d) do Config[k]=v end end
    end
end
local function SaveCfg()
    if writefile then writefile("HirukuMM2.json",HttpService:JSONEncode(Config)) end
end
LoadCfg()

local gui = new("ScreenGui",{Name="HirukuMM2",ResetOnSpawn=false,IgnoreGuiInset=true})
pcall(function() gui.Parent=game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent=LP:WaitForChild("PlayerGui") end

-- INJECT SCREEN
local inject = new("Frame",{Parent=gui,Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=0.3,ZIndex=200})
local injLabel = new("TextLabel",{Parent=inject,Size=UDim2.new(1,0,0,50),Position=UDim2.new(0,0,0.4,0),BackgroundTransparency=1,Text="Hiruku Injected...",TextColor3=Color3.new(1,1,1),Font=Enum.Font.Code,TextSize=28,ZIndex=201})
local progBg = new("Frame",{Parent=inject,Size=UDim2.new(0,320,0,12),Position=UDim2.new(0.5,-160,0.5,40),BackgroundColor3=Color3.fromRGB(30,30,30),BorderSizePixel=0,ZIndex=201})
corner(progBg,99)
local progFill = new("Frame",{Parent=progBg,Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,ZIndex=202})
corner(progFill,99)
TweenService:Create(progFill,TweenInfo.new(2),{Size=UDim2.new(1,0,1,0)}):Play()
task.wait(2.2)
inject:Destroy()

-- WATERMARK
local wm = new("Frame",{Parent=gui,BackgroundColor3=Theme.bg,BackgroundTransparency=0.15,Size=UDim2.new(0,220,0,34),Position=UDim2.new(0,10,0,10),BorderSizePixel=0})
corner(wm,4); stroke(wm,Theme.text,1,0.4)
local wmTitle = new("TextLabel",{Parent=wm,BackgroundTransparency=1,Position=UDim2.new(0,10,0,4),Size=UDim2.new(1,-20,0,16),Font=Enum.Font.Code,TextSize=14,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text="Hiruku Script"})
local wmSub = new("TextLabel",{Parent=wm,BackgroundTransparency=1,Position=UDim2.new(0,10,0,18),Size=UDim2.new(1,-20,0,12),Font=Enum.Font.Code,TextSize=9,TextColor3=Theme.textDim,TextXAlignment=Enum.TextXAlignment.Left,Text="MM2 - V 1.0"})
local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))}
grad.Parent = wmSub
task.spawn(function()
    while wmSub.Parent do
        for i=0,1,0.02 do
            grad.Offset = Vector2.new(i,0)
            task.wait(0.03)
        end
        task.wait(0.5)
    end
end)

-- TOGGLE BUTTON
local btn = new("TextButton",{Parent=gui,BackgroundColor3=Theme.bg,BackgroundTransparency=0.2,Size=UDim2.new(0,120,0,32),Position=UDim2.new(0.5,-60,0,55),BorderSizePixel=0,Text="",AutoButtonColor=false})
corner(btn,8); stroke(btn,Theme.text,1,0.4)
new("TextLabel",{Parent=btn,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Font=Enum.Font.Code,TextSize=14,TextColor3=Theme.text,Text="Hiruku"})

local function draggable(frame,handle)
    handle=handle or frame
    local drag,dStart,sPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; dStart=i.Position; sPos=frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dStart
            frame.Position=UDim2.new(sPos.X.Scale,sPos.X.Offset+d.X,sPos.Y.Scale,sPos.Y.Offset+d.Y)
        end
    end)
end
draggable(wm); draggable(btn)

-- WINDOW (wide, rect, slight rounding)
local win = new("Frame",{Parent=gui,BackgroundColor3=Theme.bg,BackgroundTransparency=0,Size=UDim2.new(0,760,0,420),Position=UDim2.new(0.5,-380,0.5,-210),BorderSizePixel=0,Visible=false,ClipsDescendants=true})
corner(win,4); stroke(win,Theme.text,1,0.3)
draggable(win)

-- TITLE
local title = new("Frame",{Parent=win,BackgroundTransparency=1,Size=UDim2.new(1,0,0,46)})
new("TextLabel",{Parent=title,BackgroundTransparency=1,Position=UDim2.new(0,12,0,4),Size=UDim2.new(1,-60,0,18),Font=Enum.Font.Code,TextSize=15,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text="Hiruku Script"})
local sub = new("TextLabel",{Parent=title,BackgroundTransparency=1,Position=UDim2.new(0,12,0,22),Size=UDim2.new(1,-60,0,12),Font=Enum.Font.Code,TextSize=9,TextColor3=Theme.textDim,TextXAlignment=Enum.TextXAlignment.Left,Text="MM2 - V 1.0"})
local sgrad = Instance.new("UIGradient")
sgrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(80,80,80)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))}
sgrad.Parent = sub
task.spawn(function()
    while sub.Parent do
        for i=0,1,0.015 do
            sgrad.Offset = Vector2.new(i,0)
            task.wait(0.02)
        end
        task.wait(0.4)
    end
end)

local closeB = new("TextButton",{Parent=title,BackgroundTransparency=1,Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-34,0.5,-14),Text="✕",Font=Enum.Font.Code,TextSize=14,TextColor3=Theme.textDim})
closeB.MouseButton1Click:Connect(function() TweenService:Create(win,TweenInfo.new(0.15),{Size=UDim2.new(0,0,0,0)}):Play(); task.wait(0.15); win.Visible=false end)

-- SEARCH
local search = new("TextBox",{Parent=win,BackgroundColor3=Theme.panel2,Position=UDim2.new(0,10,0,50),Size=UDim2.new(0,180,0,26),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.text,PlaceholderText="search...",Text="",ClearTextOnFocus=false,BorderSizePixel=0})
corner(search,4); stroke(search,Theme.text,1,0.5); pad(search,0,0,6,6)

-- SIDEBAR
local side = new("Frame",{Parent=win,BackgroundColor3=Theme.panel,BackgroundTransparency=0,Position=UDim2.new(0,0,0,84),Size=UDim2.new(0,170,1,-84),BorderSizePixel=0})
corner(side,4)
new("UIListLayout",{Parent=side,Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center})
pad(side,6)

-- CONTENT
local cont = new("Frame",{Parent=win,BackgroundTransparency=1,Position=UDim2.new(0,170,0,84),Size=UDim2.new(1,-170,1,-84)})
local scroll = new("ScrollingFrame",{Parent=cont,BackgroundTransparency=1,Size=UDim2.new(1,-8,1,-8),Position=UDim2.new(0,4,0,4),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=4,ScrollBarImageColor3=Theme.text,ScrollBarImageTransparency=0.6,BorderSizePixel=0})
new("UIListLayout",{Parent=scroll,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
pad(scroll,0,6,0,2)

-- BUILDERS
local function hdr(t)
    local h=new("TextLabel",{Parent=scroll,BackgroundTransparency=1,Size=UDim2.new(1,0,0,22),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text=t})
    h.LayoutOrder=#scroll:GetChildren()
end
local function tgl(l,d,def,cb)
    local r=new("Frame",{Parent=scroll,BackgroundColor3=Theme.panel2,Size=UDim2.new(1,0,0,d and 36 or 28),BorderSizePixel=0})
    r.LayoutOrder=#scroll:GetChildren(); corner(r,3); stroke(r,Theme.text,1,0.6)
    new("TextLabel",{Parent=r,BackgroundTransparency=1,Position=UDim2.new(0,8,0,d and 4 or 0),Size=UDim2.new(1,-50,0,14),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text=l})
    if d then new("TextLabel",{Parent=r,BackgroundTransparency=1,Position=UDim2.new(0,8,0,18),Size=UDim2.new(1,-50,0,12),Font=Enum.Font.Code,TextSize=8,TextColor3=Theme.textDim,TextXAlignment=Enum.TextXAlignment.Left,Text=d}) end
    local sw=new("TextButton",{Parent=r,BackgroundColor3=def and Theme.text or Theme.off,Size=UDim2.new(0,34,0,16),Position=UDim2.new(1,-42,0.5,-8),BorderSizePixel=0,Text=""})
    corner(sw,99)
    local kn=new("Frame",{Parent=sw,BackgroundColor3=def and Theme.bg or Theme.text,Size=UDim2.new(0,12,0,12),Position=def and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6),BorderSizePixel=0})
    corner(kn,99)
    local st=def
    sw.MouseButton1Click:Connect(function()
        st=not st
        TweenService:Create(sw,TweenInfo.new(0.12),{BackgroundColor3=st and Theme.text or Theme.off}):Play()
        TweenService:Create(kn,TweenInfo.new(0.12),{Position=st and UDim2.new(1,-14,0.5,-6) or UDim2.new(0,2,0.5,-6),BackgroundColor3=st and Theme.bg or Theme.text}):Play()
        if cb then cb(st) end
        SaveCfg()
    end)
end
local function sld(l,mn,mx,def,st,cb)
    local r=new("Frame",{Parent=scroll,BackgroundColor3=Theme.panel2,Size=UDim2.new(1,0,0,36),BorderSizePixel=0})
    r.LayoutOrder=#scroll:GetChildren(); corner(r,3); stroke(r,Theme.text,1,0.6)
    new("TextLabel",{Parent=r,BackgroundTransparency=1,Position=UDim2.new(0,8,0,2),Size=UDim2.new(1,-50,0,12),Font=Enum.Font.Code,TextSize=10,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text=l})
    local vl=new("TextLabel",{Parent=r,BackgroundTransparency=1,Position=UDim2.new(1,-40,0,2),Size=UDim2.new(0,32,0,12),Font=Enum.Font.Code,TextSize=10,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Right,Text=tostring(def)})
    local tr=new("Frame",{Parent=r,BackgroundColor3=Theme.off,Position=UDim2.new(0,8,0,20),Size=UDim2.new(1,-16,0,4),BorderSizePixel=0})
    corner(tr,99)
    local fl=new("Frame",{Parent=tr,BackgroundColor3=Theme.text,Size=UDim2.new((def-mn)/(mx-mn),0,1,0),BorderSizePixel=0})
    corner(fl,99)
    local v=def; local dg=false
    local function ap(i)
        local rl=math.clamp((i.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
        v=math.floor((mn+(mx-mn)*rl)/st+0.5)*st; v=math.clamp(v,mn,mx)
        fl.Size=UDim2.new((v-mn)/(mx-mn),0,1,0); vl.Text=tostring(v)
        if cb then cb(v) end
    end
    tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true; ap(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false; SaveCfg() end end)
    UserInputService.InputChanged:Connect(function(i) if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then ap(i) end end)
end
local function btn_(l,cb)
    local b=new("TextButton",{Parent=scroll,BackgroundColor3=Theme.panel2,Size=UDim2.new(1,0,0,28),Font=Enum.Font.Code,TextSize=10,TextColor3=Theme.text,Text=l,BorderSizePixel=0,AutoButtonColor=false})
    b.LayoutOrder=#scroll:GetChildren(); corner(b,3); stroke(b,Theme.text,1,0.6)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
end

-- MM2 LOGIC
local function getRole()
    local c=LP.Character
    if not c then return "Innocent" end
    if c:FindFirstChild("Knife") then return "Murderer" end
    if c:FindFirstChild("Gun") then return "Sheriff" end
    return "Innocent"
end
local function getRoleColor(plr)
    local c=plr.Character
    if not c then return Theme.green end
    if c:FindFirstChild("Knife") then return Config.chamsMurderer end
    if c:FindFirstChild("Gun") then return Config.chamsSheriff end
    return Config.chamsInnocent
end
local function getRoleName(plr)
    local c=plr.Character
    if not c then return "?" end
    if c:FindFirstChild("Knife") then return "MURDERER" end
    if c:FindFirstChild("Gun") then return "SHERIFF" end
    return "INNOCENT"
end

local chamsF = new("Folder",{Name="HirukuChams",Parent=Workspace})
local function applyChams(plr,on)
    local old=chamsF:FindFirstChild(plr.Name)
    if old then old:Destroy() end
    if not on or not plr.Character then return end
    local col=getRoleColor(plr)
    local h=new("Highlight",{Name=plr.Name,Adornee=plr.Character,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,FillColor=col,OutlineColor=col,FillTransparency=0.6,OutlineTransparency=0.1,Parent=chamsF})
end

-- FLY
local flyActive=false
local flySpeed=50
local function flyLoop()
    task.spawn(function()
        while flyActive and LP.Character do
            local hrp=LP.Character:FindFirstChild("HumanoidRootPart")
            local hum=LP.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                hum.PlatformStand=true
                local dir=Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir+=Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir-=Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir-=Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir+=Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir-=Vector3.new(0,1,0) end
                hrp.AssemblyLinearVelocity = dir.Magnitude>0 and dir.Unit*flySpeed or Vector3.zero
            end
            task.wait()
        end
    end)
end

-- NOCLIP
local noclipActive=false
RunService.Stepped:Connect(function()
    if noclipActive and LP.Character then
        for _,v in ipairs(LP.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=false end
        end
    end
end)

-- AUTO FARM COINS
local function findCoin()
    local best,bd=nil,math.huge
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("coin") and obj:IsA("BasePart") then
            local d=(obj.Position-Camera.CFrame.Position).Magnitude
            if d<bd then best,bd=obj,d end
        end
    end
    return best
end

local farmCount=0
RunService.Heartbeat:Connect(function()
    if not Config.autoFarm or farmCount>=40 then return end
    local coin=findCoin()
    if coin then
        local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame=CFrame.new(coin.Position+Vector3.new(0,2,0))
            farmCount+=1
            task.wait(0.1)
        end
    end
end)

-- SEX AURA
local sexTarget=nil
RunService.Heartbeat:Connect(function()
    if not Config.sexAura or not sexTarget or not sexTarget.Character then return end
    local myHrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local tHrp=sexTarget.Character:FindFirstChild("HumanoidRootPart")
    if myHrp and tHrp then
        local speed=Config.sexSpeed
        local offset=Vector3.new(math.sin(tick()*speed)*3,0,math.cos(tick()*speed)*3)
        myHrp.CFrame=CFrame.new(tHrp.Position+offset)
    end
end)

-- CRASH PLAYER
local crashTarget=nil
local crashOrigin=nil
RunService.Heartbeat:Connect(function()
    if not Config.crashPlayer or not crashTarget or not crashTarget.Character then return end
    local myHrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local tHrp=crashTarget.Character:FindFirstChild("HumanoidRootPart")
    if myHrp and tHrp then
        if not crashOrigin then crashOrigin=myHrp.CFrame end
        myHrp.CFrame=tHrp.CFrame*CFrame.new(math.random(-5,5),math.random(-2,2),math.random(-5,5))
        task.wait(0.05)
        myHrp.CFrame=crashOrigin
    end
end)

-- AUTO SHOT (Sheriff)
local autoShotEnabled=false
RunService.Heartbeat:Connect(function()
    if not autoShotEnabled or getRole()~="Sheriff" then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and plr.Character and plr.Character:FindFirstChild("Knife") then
            local gun=LP.Character and LP.Character:FindFirstChild("Gun")
            if gun then gun:Activate() end
        end
    end
end)

-- AUTO PICKUP GUN
RunService.Heartbeat:Connect(function()
    if not Config.autoPickup then return end
    for _,obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name=="Gun" and obj:IsA("Tool") then
            obj.Parent=LP.Character
        end
    end
end)

-- KILL ALL / SELECTED
local killAllEnabled=false
local selectedPlayer=nil
RunService.Heartbeat:Connect(function()
    if getRole()~="Murderer" then return end
    if killAllEnabled then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP and plr.Character then
                local h=plr.Character:FindFirstChildOfClass("Humanoid")
                if h then h.Health=0 end
            end
        end
    end
    if selectedPlayer then
        local t=Players:FindFirstChild(selectedPlayer)
        if t and t.Character then
            local h=t.Character:FindFirstChildOfClass("Humanoid")
            if h then h.Health=0 end
        end
    end
end)

-- RENDER
RunService.RenderStepped:Connect(function()
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP then applyChams(plr,Config.chams) end
    end
end)

-- SECTIONS
local sections={
    {id="combat",name="Combat",icon=Icons.combat},
    {id="visuals",name="Visuals",icon=Icons.visuals},
    {id="misc",name="Misc",icon=Icons.misc},
    {id="troll",name="Troll",icon=Icons.troll},
    {id="settings",name="Settings",icon=Icons.settings},
}
local currentSec="combat"
local function clear() for _,c in ipairs(scroll:GetChildren()) do if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end end end

local function buildCombat()
    hdr("AIM")
    tgl("Aimbot","",Config.aimbot,function(v) Config.aimbot=v end)
    sld("FOV",20,400,Config.aimFov,5,function(v) Config.aimFov=v end)
    sld("Smooth",1,100,Config.aimSmooth,1,function(v) Config.aimSmooth=v end)
    tgl("Silent Aim","",Config.silent,function(v) Config.silent=v end)
    hdr("AUTO")
    tgl("Auto Shot (Sheriff)","",autoShotEnabled,function(v) autoShotEnabled=v end)
    tgl("Auto Pickup Gun","",Config.autoPickup,function(v) Config.autoPickup=v end)
    hdr("KILL (Murderer)")
    tgl("Kill All","",killAllEnabled,function(v) killAllEnabled=v end)
    btn_("Select Player",function()
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP then
                local pb=new("TextButton",{Parent=scroll,BackgroundColor3=Theme.panel2,Size=UDim2.new(1,0,0,22),Font=Enum.Font.Code,TextSize=9,TextColor3=Theme.text,Text=plr.Name,BorderSizePixel=0})
                pb.LayoutOrder=#scroll:GetChildren(); corner(pb,3); stroke(pb,Theme.text,1,0.6)
                pb.MouseButton1Click:Connect(function() selectedPlayer=plr.Name end)
            end
        end
    end)
    hdr("TELEPORT")
    btn_("TP to Sheriff",function()
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP and plr.Character and plr.Character:FindFirstChild("Gun") then
                LP.Character.HumanoidRootPart.CFrame=plr.Character.HumanoidRootPart.CFrame
            end
        end
    end)
    btn_("TP to Murderer",function()
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP and plr.Character and plr.Character:FindFirstChild("Knife") then
                LP.Character.HumanoidRootPart.CFrame=plr.Character.HumanoidRootPart.CFrame
            end
        end
    end)
end

local function buildVisuals()
    hdr("CHAMS")
    tgl("Chams","Sheriff=Blue Murderer=Red",Config.chams,function(v) Config.chams=v end)
    tgl("ESP Name","",Config.espName,function(v) Config.espName=v end)
    hdr("MOVEMENT")
    tgl("Fly","",Config.fly,function(v) Config.fly=v; flyActive=v; if v then flyLoop() end end)
    sld("Fly Speed",10,300,flySpeed,5,function(v) flySpeed=v end)
    tgl("Noclip","",Config.noclip,function(v) Config.noclip=v; noclipActive=v end)
end

local function buildMisc()
    hdr("AUTO FARM")
    tgl("Auto Farm Coins","40 coins per round",Config.autoFarm,function(v) Config.autoFarm=v; farmCount=0 end)
    hdr("SERVER")
    btn_("Rejoin",function() game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end)
    btn_("Unload",function() gui:Destroy(); chamsF:Destroy() end)
end

local function buildTroll()
    hdr("PLAYER TROLL")
    tgl("Sex Aura","annoy selected player",Config.sexAura,function(v) Config.sexAura=v end)
    sld("Sex Speed",1,50,Config.sexSpeed,1,function(v) Config.sexSpeed=v end)
    btn_("Select Troll Target",function()
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP then
                local tb=new("TextButton",{Parent=scroll,BackgroundColor3=Theme.panel2,Size=UDim2.new(1,0,0,22),Font=Enum.Font.Code,TextSize=9,TextColor3=Theme.text,Text=plr.Name,BorderSizePixel=0})
                tb.LayoutOrder=#scroll:GetChildren(); corner(tb,3); stroke(tb,Theme.text,1,0.6)
                tb.MouseButton1Click:Connect(function() sexTarget=plr end)
            end
        end
    end)
    hdr("CRASH")
    tgl("Crash Player","fling selected out of map",Config.crashPlayer,function(v) Config.crashPlayer=v end)
    btn_("Select Crash Target",function()
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP then
                local cb=new("TextButton",{Parent=scroll,BackgroundColor3=Theme.panel2,Size=UDim2.new(1,0,0,22),Font=Enum.Font.Code,TextSize=9,TextColor3=Theme.text,Text=plr.Name,BorderSizePixel=0})
                cb.LayoutOrder=#scroll:GetChildren(); corner(cb,3); stroke(cb,Theme.text,1,0.6)
                cb.MouseButton1Click:Connect(function() crashTarget=plr end)
            end
        end
    end)
end

local function buildSettings()
    hdr("MENU")
    sld("Transparency",0,80,0,1,function(v) win.BackgroundTransparency=v/100 end)
    hdr("CONFIG")
    btn_("Save Config",SaveCfg)
    btn_("Load Config",LoadCfg)
    btn_("Reset Config",function() Config={chams=false,espName=false,autoFarm=false,fly=false,noclip=false,silent=false,aimbot=false,aimFov=120,aimSmooth=15,sexAura=false,sexSpeed=10,crashPlayer=false}; SaveCfg() end)
end

local builders={combat=buildCombat,visuals=buildVisuals,misc=buildMisc,troll=buildTroll,settings=buildSettings}

local function selectSection(s)
    currentSec=s.id; clear()
    if builders[s.id] then builders[s.id]() end
end

-- SIDEBAR BUTTONS
for i,s in ipairs(sections) do
    local b=new("TextButton",{Parent=side,BackgroundColor3=Theme.panel2,Size=UDim2.new(1,0,0,32),Text="",AutoButtonColor=false,LayoutOrder=i})
    corner(b,3); stroke(b,Theme.text,1,0.6)
    new("TextLabel",{Parent=b,BackgroundTransparency=1,Position=UDim2.new(0,8,0,0),Size=UDim2.new(1,-16,1,0),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text=s.name})
    b.MouseButton1Click:Connect(function()
        for _,o in ipairs(side:GetChildren()) do
            if o:IsA("TextButton") then
                TweenService:Create(o,TweenInfo.new(0.1),{BackgroundColor3=Theme.panel2}):Play()
                o:FindFirstChildOfClass("TextLabel").TextColor3=Theme.text
            end
        end
        TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=Theme.text}):Play()
        b:FindFirstChildOfClass("TextLabel").TextColor3=Theme.bg
        selectSection(s)
    end)
    if i==1 then
        task.defer(function()
            b.BackgroundColor3=Theme.text
            b:FindFirstChildOfClass("TextLabel").TextColor3=Theme.bg
            selectSection(s)
        end)
    end
end

-- SEARCH
search:GetPropertyChangedSignal("Text"):Connect(function()
    local q=search.Text:lower()
    if q=="" then selectSection(sections[1]); return end
    clear()
    hdr("RESULTS")
    local all={{"Aimbot","combat"},{"Silent Aim","combat"},{"Chams","visuals"},{"Fly","visuals"},{"Noclip","visuals"},{"Auto Farm","misc"},{"Sex Aura","troll"},{"Crash Player","troll"},{"Kill All","combat"},{"Auto Shot","combat"}}
    for _,item in ipairs(all) do
        if item[1]:lower():find(q) then
            btn_(item[1],function()
                for _,s in ipairs(sections) do if s.id==item[2] then selectSection(s) end end
            end)
        end
    end
end)

-- OPEN/CLOSE with animation
local open=false
local function toggleMenu()
    open=not open
    if open then
        win.Visible=true
        win.Size=UDim2.new(0,0,0,0)
        win.Position=UDim2.new(0.5,0,0.5,0)
        TweenService:Create(win,TweenInfo.new(0.25,Enum.EasingStyle.Quart),{Size=UDim2.new(0,760,0,420),Position=UDim2.new(0.5,-380,0.5,-210)}):Play()
    else
        TweenService:Create(win,TweenInfo.new(0.2,Enum.EasingStyle.Quart),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.5,0,0.5,0)}):Play()
        task.wait(0.2)
        win.Visible=false
    end
end
btn.MouseButton1Click:Connect(toggleMenu)
UserInputService.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.RightShift then toggleMenu() end end)

game:BindToClose(SaveCfg)