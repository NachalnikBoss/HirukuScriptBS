-- Hiruku · Blox Strike · Fixed
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Theme = {
    bg=Color3.fromRGB(15,15,19), panel=Color3.fromRGB(24,24,30),
    panel2=Color3.fromRGB(30,30,38), stroke=Color3.fromRGB(50,50,62),
    text=Color3.fromRGB(232,232,240), textDim=Color3.fromRGB(148,148,162),
    textMute=Color3.fromRGB(96,96,110), accent=Color3.fromRGB(138,92,246),
    accent2=Color3.fromRGB(168,132,255), off=Color3.fromRGB(46,46,56),
    bgTransp=0.15,
}

local Icons = {
    logo="rbxassetid://7847285702",
    combat="rbxassetid://7847265842",
    aim="rbxassetid://7847266255",
    visuals="rbxassetid://7847266534",
    player="rbxassetid://7847266891",
    misc="rbxassetid://7847267216",
    settings="rbxassetid://7847267518",
    close="rbxassetid://7847267829",
    toggle="rbxassetid://7847268190",
    search="rbxassetid://7847268495",
}

local function new(c,p) local o=Instance.new(c); for k,v in pairs(p or {}) do o[k]=v end; return o end
local function corner(p,r) return new("UICorner",{CornerRadius=UDim.new(0,r or 5),Parent=p}) end
local function stroke(p,c,t,tr) return new("UIStroke",{Color=c or Theme.stroke,Thickness=t or 1,Transparency=tr or 0.2,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=p}) end
local function pad(p,a,b,c,d) return new("UIPadding",{PaddingTop=UDim.new(0,a),PaddingBottom=UDim.new(0,b or a),PaddingLeft=UDim.new(0,c or a),PaddingRight=UDim.new(0,d or a),Parent=p}) end
local function ico(parent,id,size,pos,col)
    return new("ImageLabel",{BackgroundTransparency=1,Image=id,ImageColor3=col or Theme.text,Size=size,Position=pos,Parent=parent})
end

local gui = new("ScreenGui",{Name="Hiruku",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true})
pcall(function() gui.Parent=game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent=LP:WaitForChild("PlayerGui") end

local blur = new("BlurEffect",{Name="HirukuBlur",Size=0,Parent=Lighting})
local function setBlur(on) TweenService:Create(blur,TweenInfo.new(0.25),{Size=on and 24 or 0}):Play() end

-- watermark
local wm = new("Frame",{Parent=gui,BackgroundColor3=Theme.bg,BackgroundTransparency=Theme.bgTransp,Size=UDim2.new(0,230,0,32),Position=UDim2.new(0,12,0,12),BorderSizePixel=0})
corner(wm,6); stroke(wm,Theme.accent,1,0.55)
ico(wm,Icons.logo,UDim2.new(0,14,0,14),UDim2.new(0,10,0.5,-7),Theme.accent)
new("TextLabel",{Parent=wm,BackgroundTransparency=1,Position=UDim2.new(0,30,0,0),Size=UDim2.new(1,-38,1,0),Font=Enum.Font.Code,TextSize=13,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text="Hiruku  ·  Blox Strike"})
local wmStats = new("TextLabel",{Parent=wm,BackgroundTransparency=1,Size=UDim2.new(1,-8,1,0),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.textDim,TextXAlignment=Enum.TextXAlignment.Right,Text=""})

-- toggle button
local btn = new("TextButton",{Parent=gui,BackgroundColor3=Theme.bg,BackgroundTransparency=Theme.bgTransp,Size=UDim2.new(0,44,0,44),Position=UDim2.new(0,12,0,52),BorderSizePixel=0,Text="",AutoButtonColor=false})
corner(btn,10); stroke(btn,Theme.accent,1.3,0.35)
ico(btn,Icons.toggle,UDim2.new(0,20,0,20),UDim2.new(0.5,-10,0.5,-10),Theme.accent)

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

-- window
local win = new("Frame",{Parent=gui,BackgroundColor3=Theme.bg,BackgroundTransparency=Theme.bgTransp,Size=UDim2.new(0,720,0,460),Position=UDim2.new(0.5,-360,0.5,-230),BorderSizePixel=0,Visible=false})
corner(win,6); stroke(win,Theme.stroke,1,0.3)
draggable(win)

-- title
local title = new("Frame",{Parent=win,BackgroundTransparency=1,Size=UDim2.new(1,0,0,42)})
ico(title,Icons.logo,UDim2.new(0,16,0,16),UDim2.new(0,14,0.5,-8),Theme.accent)
new("TextLabel",{Parent=title,BackgroundTransparency=1,Position=UDim2.new(0,36,0,0),Size=UDim2.new(1,-120,1,0),Font=Enum.Font.Code,TextSize=14,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text="Hiruku  ·  Combat"})

local closeB = new("TextButton",{Parent=title,BackgroundTransparency=1,Size=UDim2.new(0,30,0,30),Position=UDim2.new(1,-38,0.5,-15),Text=""})
ico(closeB,Icons.close,UDim2.new(0,14,0,14),UDim2.new(0.5,-7,0.5,-7),Theme.textDim)
closeB.MouseButton1Click:Connect(function() win.Visible=false; setBlur(false) end)

-- sidebar
local side = new("Frame",{Parent=win,BackgroundColor3=Theme.panel,BackgroundTransparency=0.1,Position=UDim2.new(0,0,0,42),Size=UDim2.new(0,180,1,-42),BorderSizePixel=0})
corner(side,6)
new("UIListLayout",{Parent=side,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center})
pad(side,10)

-- content
local cont = new("Frame",{Parent=win,BackgroundTransparency=1,Position=UDim2.new(0,180,0,42),Size=UDim2.new(1,-180,1,-42)})
local scroll = new("ScrollingFrame",{Parent=cont,BackgroundTransparency=1,Size=UDim2.new(1,-12,1,-12),Position=UDim2.new(0,6,0,6),CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=6,ScrollBarImageColor3=Theme.accent,ScrollBarImageTransparency=0.4,BorderSizePixel=0,ClipsDescendants=true})
new("UIListLayout",{Parent=scroll,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder})
pad(scroll,0,10,0,4)

local sections = {
    {id="combat",icon=Icons.combat,name="Combat"},
    {id="aim",icon=Icons.aim,name="Aim"},
    {id="visuals",icon=Icons.visuals,name="Visuals"},
    {id="player",icon=Icons.player,name="Player"},
    {id="misc",icon=Icons.misc,name="Misc"},
    {id="settings",icon=Icons.settings,name="Settings"},
}

local currentSec = "combat"

local function clear() for _,c in ipairs(scroll:GetChildren()) do if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end end end

local function hdr(t)
    local h=new("TextLabel",{Parent=scroll,BackgroundTransparency=1,Size=UDim2.new(1,0,0,24),Font=Enum.Font.Code,TextSize=12,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text=t})
    h.LayoutOrder=#scroll:GetChildren()
end

local function tgl(label,desc,def,cb)
    local row=new("Frame",{Parent=scroll,BackgroundColor3=Theme.panel,BackgroundTransparency=0.5,Size=UDim2.new(1,0,0,desc and 40 or 32),BorderSizePixel=0})
    row.LayoutOrder=#scroll:GetChildren()
    corner(row,5); stroke(row,Theme.stroke,1,0.7)
    new("TextLabel",{Parent=row,BackgroundTransparency=1,Position=UDim2.new(0,10,0,desc and 5 or 0),Size=UDim2.new(1,-60,0,15),Font=Enum.Font.Code,TextSize=12,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text=label})
    if desc then new("TextLabel",{Parent=row,BackgroundTransparency=1,Position=UDim2.new(0,10,0,20),Size=UDim2.new(1,-60,0,13),Font=Enum.Font.Code,TextSize=9,TextColor3=Theme.textMute,TextXAlignment=Enum.TextXAlignment.Left,Text=desc}) end
    local sw=new("TextButton",{Parent=row,BackgroundColor3=def and Theme.accent or Theme.off,Size=UDim2.new(0,38,0,18),Position=UDim2.new(1,-48,0.5,-9),BorderSizePixel=0,Text=""})
    corner(sw,99)
    local knob=new("Frame",{Parent=sw,BackgroundColor3=Color3.fromRGB(240,240,245),Size=UDim2.new(0,14,0,14),Position=def and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),BorderSizePixel=0})
    corner(knob,99)
    local st=def
    sw.MouseButton1Click:Connect(function()
        st=not st
        TweenService:Create(sw,TweenInfo.new(0.15),{BackgroundColor3=st and Theme.accent or Theme.off}):Play()
        TweenService:Create(knob,TweenInfo.new(0.15),{Position=st and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
        if cb then cb(st) end
    end)
end

local function sld(label,min,max,def,step,cb)
    local row=new("Frame",{Parent=scroll,BackgroundColor3=Theme.panel,BackgroundTransparency=0.5,Size=UDim2.new(1,0,0,42),BorderSizePixel=0})
    row.LayoutOrder=#scroll:GetChildren()
    corner(row,5); stroke(row,Theme.stroke,1,0.7)
    new("TextLabel",{Parent=row,BackgroundTransparency=1,Position=UDim2.new(0,10,0,3),Size=UDim2.new(1,-60,0,14),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.text,TextXAlignment=Enum.TextXAlignment.Left,Text=label})
    local vl=new("TextLabel",{Parent=row,BackgroundTransparency=1,Position=UDim2.new(1,-50,0,3),Size=UDim2.new(0,40,0,14),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.accent2,TextXAlignment=Enum.TextXAlignment.Right,Text=tostring(def)})
    local tr=new("Frame",{Parent=row,BackgroundColor3=Theme.off,Position=UDim2.new(0,10,0,24),Size=UDim2.new(1,-20,0,6),BorderSizePixel=0})
    corner(tr,99)
    local fl=new("Frame",{Parent=tr,BackgroundColor3=Theme.accent,Size=UDim2.new((def-min)/(max-min),0,1,0),BorderSizePixel=0})
    corner(fl,99)
    local v=def; local dg=false
    local function ap(i)
        local r=math.clamp((i.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
        v=math.floor((min+(max-min)*r)/step+0.5)*step; v=math.clamp(v,min,max)
        fl.Size=UDim2.new((v-min)/(max-min),0,1,0); vl.Text=tostring(v)
        if cb then cb(v) end
    end
    tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=true; ap(i) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false end end)
    UserInputService.InputChanged:Connect(function(i) if dg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then ap(i) end end)
end

local function btn_(label,cb,col)
    local b=new("TextButton",{Parent=scroll,BackgroundColor3=col or Theme.panel,BackgroundTransparency=0.4,Size=UDim2.new(1,0,0,32),Font=Enum.Font.Code,TextSize=11,TextColor3=Theme.text,Text=label,BorderSizePixel=0,AutoButtonColor=false})
    b.LayoutOrder=#scroll:GetChildren()
    corner(b,5); stroke(b,Theme.stroke,1,0.7)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
end

-- CORE: team detection for Blox Strike
local function getTeamColor(plr)
    local char = plr.Character
    if char and char.Parent then
        local pn = char.Parent.Name:lower()
        if pn:find("counter") or pn:find("police") or pn:find("blue") or pn=="ct" then
            return Color3.fromRGB(0,160,255)
        elseif pn:find("terror") or pn:find("attack") or pn=="t" then
            return Color3.fromRGB(255,140,0)
        end
    end
    if plr.Team then
        if plr.Team.TeamColor==BrickColor.new("Deep blue") or plr.Team.TeamColor==BrickColor.new("Bright blue") then
            return Color3.fromRGB(0,160,255)
        elseif plr.Team.TeamColor==BrickColor.new("Bright orange") or plr.Team.TeamColor==BrickColor.new("Neon orange") then
            return Color3.fromRGB(255,140,0)
        end
    end
    if LP.Team and plr.Team==LP.Team then return Color3.fromRGB(0,160,255) end
    return Color3.fromRGB(255,140,0)
end

local function isEnemy(plr)
    if not LP.Team or not plr.Team then return true end
    return plr.Team~=LP.Team
end

local function alive(plr)
    local c=plr.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
    return h and h.Health>0
end

-- CHAMS with AlwaysOnTop (critical for Blox Strike)
local chamsF = new("Folder",{Name="HirukuChams",Parent=workspace})
local chams = {}

local function applyChams(plr,on)
    local old=chams[plr]
    if old then old:Destroy(); chams[plr]=nil end
    if not on or not alive(plr) or not isEnemy(plr) then return end
    local h=new("Highlight",{Name=plr.Name,Adornee=plr.Character,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,FillColor=getTeamColor(plr),OutlineColor=getTeamColor(plr),FillTransparency=0.5,OutlineTransparency=0.15,Parent=chamsF})
    chams[plr]=h
end

-- AIMBOT with prediction + hold key (like real Blox Strike scripts)
local aimState = {enabled=false, key=Enum.UserInputType.MouseButton2, smooth=0.15, fov=120, part="Head", teamCheck=true, prediction=0.05}
local holding = false

local function getTarget()
    local best,bd=nil,math.huge
    local center=Camera.ViewportSize/2
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and alive(plr) and (not aimState.teamCheck or isEnemy(plr)) then
            local c=plr.Character
            local p=c:FindFirstChild(aimState.part) or c:FindFirstChild("HumanoidRootPart")
            if p then
                local pos,on=Camera:WorldToViewportPoint(p.Position)
                if on then
                    local d=(Vector2.new(pos.X,pos.Y)-center).Magnitude
                    if d<=aimState.fov and d<bd then best,bd=p,d end
                end
            end
        end
    end
    return best
end

-- render loop
RunService.RenderStepped:Connect(function(dt)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP then applyChams(plr, aimState.enabled and true or false) end
    end
    -- chams toggle controlled by separate state
end)

-- separate chams state
local chamsOn = false
local aimOn = false

RunService.RenderStepped:Connect(function(dt)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP then applyChams(plr, chamsOn) end
    end

    if aimOn and holding then
        local t=getTarget()
        if t then
            local pred = t.Position + (t.Velocity * aimState.prediction)
            local cf=CFrame.lookAt(Camera.CFrame.Position,pred)
            Camera.CFrame=Camera.CFrame:Lerp(cf,aimState.smooth)
        end
    end

    wmStats.Text=""
    if aimOn then wmStats.Text=wmStats.Text.."AIM " end
    if chamsOn then wmStats.Text=wmStats.Text.."CHM " end
end)

UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.UserInputType==aimState.key then holding=true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==aimState.key then holding=false end
end)

-- sections
local function buildCombat()
    hdr("CHAMS")
    tgl("Chams","highlight enemies through walls",chamsOn,function(v) chamsOn=v end)
    hdr("ESP")
    tgl("Box","",false,function() end)
    tgl("Name","",false,function() end)
    tgl("Health","",false,function() end)
    tgl("Distance","",false,function() end)
end

local function buildAim()
    hdr("AIMBOT")
    tgl("Aimbot","hold Right Mouse Button",aimOn,function(v) aimOn=v end)
    sld("Smooth",1,100,15,1,function(v) aimState.smooth=v/100 end)
    sld("FOV",20,400,120,5,function(v) aimState.fov=v end)
    sld("Prediction",0,50,5,1,function(v) aimState.prediction=v/1000 end)
    tgl("Team Check","ignore teammates",true,function(v) aimState.teamCheck=v end)
    hdr("SILENT AIM")
    tgl("Silent Aim","",false,function() end)
    tgl("Wallshot","",false,function() end)
end

local function buildVisuals()
    hdr("HUD")
    tgl("Watermark","",true,function(v) wm.Visible=v end)
    tgl("Stats","fps/aim status",true,function() end)
    hdr("WORLD")
    tgl("FOV Circle","",false,function() end)
    tgl("Crosshair","",false,function() end)
end

local function buildPlayer()
    hdr("MOVEMENT")
    tgl("WalkSpeed","",false,function(v)
        local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed=v and 100 or 16 end
    end)
    tgl("JumpPower","",false,function(v)
        local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if h then h.JumpPower=v and 200 or 50; h.UseJumpPower=true end
    end)
    tgl("Infinite Jump","",false,function() end)
    tgl("Fly","",false,function() end)
    tgl("Noclip","",false,function() end)
    hdr("ACTIONS")
    btn_("Reset Character",function()
        local c=LP.Character
        if c then local h=c:FindFirstChildOfClass("Humanoid"); if h then h.Health=0 end end
    end)
end

local function buildMisc()
    hdr("SERVER")
    btn_("Rejoin",function() game:GetService("TeleportService"):Teleport(game.PlaceId,LP) end)
    btn_("Server Hop",function()
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
    hdr("UTILITY")
    btn_("Unload",function() gui:Destroy(); blur:Destroy(); chamsF:Destroy() end,Color3.fromRGB(180,60,60))
end

local function buildSettings()
    hdr("MENU")
    sld("Transparency",0,90,15,1,function(v) win.BackgroundTransparency=v/100 end)
    sld("Blur Size",0,50,24,1,function(v) blur.Size=v end)
    hdr("CONFIG")
    btn_("Save Config",function()
        local data=HttpService:JSONEncode({chams=chamsOn,aim=aimOn,smooth=aimState.smooth,fov=aimState.fov})
        if writefile then writefile("hiruku.json",data) end
    end)
    btn_("Load Config",function()
        if readfile and isfile and isfile("hiruku.json") then
            local ok,d=pcall(function() return HttpService:JSONDecode(readfile("hiruku.json")) end)
            if ok and d then chamsOn=d.chams or false; aimOn=d.aim or false end
        end
    end)
end

local builders={combat=buildCombat,aim=buildAim,visuals=buildVisuals,player=buildPlayer,misc=buildMisc,settings=buildSettings}

local function select(s)
    currentSec=s.id; clear()
    if builders[s.id] then builders[s.id]() end
end

-- sidebar buttons
for i,s in ipairs(sections) do
    local b=new("TextButton",{Parent=side,BackgroundColor3=Theme.panel2,BackgroundTransparency=1,Size=UDim2.new(1,0,0,34),Text="",AutoButtonColor=false,LayoutOrder=i})
    corner(b,5)
    ico(b,s.icon,UDim2.new(0,16,0,16),UDim2.new(0,10,0.5,-8),Theme.textDim)
    new("TextLabel",{Parent=b,BackgroundTransparency=1,Position=UDim2.new(0,34,0,0),Size=UDim2.new(1,-42,1,0),Font=Enum.Font.Code,TextSize=12,TextColor3=Theme.textDim,TextXAlignment=Enum.TextXAlignment.Left,Text=s.name})
    b.MouseButton1Click:Connect(function()
        for _,o in ipairs(side:GetChildren()) do
            if o:IsA("TextButton") then
                TweenService:Create(o,TweenInfo.new(0.12),{BackgroundTransparency=1,BackgroundColor3=Theme.panel2}):Play()
                local l=o:FindFirstChildOfClass("TextLabel"); if l then l.TextColor3=Theme.textDim end
                local ic=o:FindFirstChildOfClass("ImageLabel"); if ic then ic.ImageColor3=Theme.textDim end
            end
        end
        TweenService:Create(b,TweenInfo.new(0.12),{BackgroundTransparency=0.5,BackgroundColor3=Theme.accent}):Play()
        b:FindFirstChildOfClass("TextLabel").TextColor3=Theme.text
        b:FindFirstChildOfClass("ImageLabel").ImageColor3=Theme.text
        select(s)
    end)
    if i==1 then
        task.defer(function()
            b.BackgroundTransparency=0.5; b.BackgroundColor3=Theme.accent
            b:FindFirstChildOfClass("TextLabel").TextColor3=Theme.text
            b:FindFirstChildOfClass("ImageLabel").ImageColor3=Theme.text
            select(s)
        end)
    end
end

-- open/close
local open=false
local function toggle() open=not open; win.Visible=open; setBlur(open) end
btn.MouseButton1Click:Connect(toggle)
UserInputService.InputBegan:Connect(function(i,gp) if not gp and i.KeyCode==Enum.KeyCode.RightShift then toggle() end end)