local InputService = game:GetService("UserInputService")
local HttpService  = game:GetService("HttpService")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local Workspace    = game:GetService("Workspace")
local Players      = game:GetService("Players")
local Lighting     = game:GetService("Lighting")
local Stats        = game:GetService("Stats")

local Camera      = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

local vec2, vec3, dim2, dim = Vector2.new, Vector3.new, UDim2.new, UDim.new
local rect, dim_offset      = Rect.new, UDim2.fromOffset
local rgb, rgbseq, rgbkey   = Color3.fromRGB, ColorSequence.new, ColorSequenceKeypoint.new
local hsv, numseq, numkey   = Color3.fromHSV, NumberSequence.new, NumberSequenceKeypoint.new

local newVector2, newDrawing = Vector2.new, Drawing.new
local clamp, floor, abs = math.clamp, math.floor, math.abs
local round = function(...)
    local a = {}
    for i, v in next, table.pack(...) do a[i] = math.round(v) end
    return unpack(a)
end

local TextFont = Enum.Font.GothamBold
do
    local hasFileAPI = (writefile and isfile and getcustomasset and HttpService)
    if hasFileAPI then
        pcall(function()
            local fileName = "Minecraftia-Regular.ttf"
            local fontJson = "Minecraftia.font"
            if not isfile(fileName) then
                writefile(fileName, game:HttpGet(
                    "https://github.com/i77lhm/storage/raw/refs/heads/main/fonts/Minecraftia-Regular.ttf"
                ))
            end
            if isfile(fontJson) then delfile(fontJson) end
            local data = {
                name = "Minecraftia",
                faces = {{
                    name = "Regular", weight = 400, style = "Normal",
                    assetId = getcustomasset(fileName),
                }},
            }
            writefile(fontJson, HttpService:JSONEncode(data))
            TextFont = Font.new(getcustomasset(fontJson), Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        end)
    end
end

local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"
local Library      = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

local Settings = {
    Enabled         = true,
    RenderDistance  = 1000,

    Boxes           = true,
    BoxColor1       = rgb(255, 255, 255),
    BoxColor2       = rgb(255, 255, 255),

    BoxFill         = true,
    BoxFillColor1   = rgb(255, 255, 255),
    BoxFillColor2   = rgb(255, 255, 255),
    BoxFillTransp   = 0.45,
    BoxFillImage    = "rbxassetid://9812088890",

    Healthbar       = true,
    Healthbar_Pos   = "Left",
    Healthbar_Width = 3,
    Healthbar_Offset= 5,
    Healthbar_Outline = true,

    TextSize        = 11,

    Name_Text       = true,
    Name_Color      = rgb(255, 255, 255),
    Distance_Text   = true,
    Distance_Color  = rgb(255, 255, 255),
    Weapon_Text     = true,
    Weapon_Color    = rgb(255, 255, 255),

    Skeleton        = false,
    SkeletonColor   = rgb(255, 255, 255),
    Tracer          = false,
    TracerColor     = rgb(255, 255, 255),
    TracerOrigin    = "Bottom",

    TeamCheck       = false,
    TeamColor       = false,
    VisibleCheck    = false,

    Chams           = false,
    ChamsFill       = rgb(255, 255, 255),
    ChamsFillTransp = 0.5,
    ChamsOutline    = rgb(255, 255, 255),
    ChamsOutlineTransp = 0.5,
    ChamsTeamCheck  = true,

    SelfChams       = false,
    SelfChamsColor  = rgb(0, 255, 255),
    SelfChamsTransp = 0,

    JumpCircles     = false,
    JumpCircleColor = rgb(255, 255, 255),
    JumpCircleSize  = 3,
    JumpCircleSides = 30,
    JumpCircleTransp= 0.3,
    JumpCircleLifetime = 1,

    Cross2D         = false,
    Cross2DStyle    = "Cross",
    Cross2DSize     = 10,
    Cross2DThickness= 2,
    Cross2DColor    = rgb(255, 255, 255),
    Cross2DOutline  = true,
    Cross2DOutlineColor = rgb(0, 0, 0),
    Cross2DSpin     = false,
    Cross2DSpinSpeed= 90,
    Cross2DRotation = 0,
    Cross2DShowName = true,
    Cross2DName     = "Floppa Hub",

    Hitbox          = false,
    HitboxX         = 5,
    HitboxY         = 5,
    HitboxZ         = 5,
    HitboxTransp    = 0.7,
    HitboxTeamCheck = true,

    SpeedEnabled    = false,
    SpeedMethod     = "WalkSpeed",
    SpeedValue      = 32,

    FlyEnabled      = false,
    FlySpeed        = 60,

    NoclipEnabled   = false,

    Freecam         = false,
    FreecamSpeed    = 50,
    FreecamSmooth   = 0.2,

    ZoomEnabled     = false,
    ZoomValue       = 30,
    ZoomKey         = Enum.KeyCode.Z,

    FOVEnabled      = false,
    FOVValue        = 90,

    CtrlClickTP     = false,
    TPTool          = false,
    TPToolKey       = Enum.KeyCode.T,

    Desync          = false,
    DesyncCube      = false,

    FullBright      = false,
    NoFog           = false,
    RemoveShadows   = false,
    ShadowColorEnabled = false,
    ShadowColor     = rgb(0, 0, 0),
    RemoveGrass     = false,

    AmbientEnabled  = false,
    AmbientColor    = rgb(255, 255, 255),

    SkyboxEnabled   = false,
    SkyboxId        = "16573649975",

    Watermark       = false,
}

local parentGui
if gethui then parentGui = gethui()
elseif syn and syn.protect_gui then
    local g = Instance.new("ScreenGui"); syn.protect_gui(g)
    parentGui = game:GetService("CoreGui")
else parentGui = game:GetService("CoreGui") end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FloppaHub_" .. tostring(math.random(10000, 99999))
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentGui

local OrigLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Ambient = Lighting.Ambient,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    FogColor = Lighting.FogColor,
}
local OrigSky = Lighting:FindFirstChildOfClass("Sky")
local OrigSkyData = OrigSky and {
    Bk = OrigSky.SkyboxBk, Dn = OrigSky.SkyboxDn, Ft = OrigSky.SkyboxFt,
    Lf = OrigSky.SkyboxLf, Rt = OrigSky.SkyboxRt, Up = OrigSky.SkyboxUp,
} or nil
local OrigFOV = Camera.FieldOfView

local Esp = { Players = {}, Connections = {} }

function Esp:Create(instance, props)
    local ins = Instance.new(instance)
    for k, v in next, props do ins[k] = v end
    return ins
end

function Esp:Connection(signal, callback)
    local c = signal:Connect(callback)
    Esp.Connections[#Esp.Connections + 1] = c
    return c
end

function Esp:BoxSolve(torso)
    if not torso then return nil, nil, false, nil end
    local size = torso.Size
    local top    = torso.Position + Vector3.new(0, size.Y / 2 + 0.6, 0)
    local bottom = torso.Position - Vector3.new(0, size.Y / 2 + 2.0, 0)
    local dist = (torso.Position - Camera.CFrame.Position).Magnitude

    local topSP, topOn = Camera:WorldToViewportPoint(top)
    local botSP, botOn = Camera:WorldToViewportPoint(bottom)
    local onScreen = topOn and botOn

    local h = math.max(math.abs(botSP.Y - topSP.Y), 8)
    local w = h / 1.8
    local x = topSP.X - w / 2
    local y = math.min(topSP.Y, botSP.Y)

    return Vector2.new(math.floor(w), math.floor(h)),
           Vector2.new(math.floor(x), math.floor(y)),
           onScreen, math.floor(dist)
end

function Esp.CreateObject(player)
    local Data = {
        Items = {}, Info = {},
        Drawings = { SkeletonBones = {}, Tracer = {} },
    }
    local Items = Data.Items

    Items.Root = Esp:Create("Frame", {
        Parent = ScreenGui, Name = "esp_" .. player.Name,
        BackgroundTransparency = 1, Visible = false,
        Size = dim2(0, 0, 0, 0), Position = dim2(0, 0, 0, 0),
        BorderSizePixel = 0,
    })

    Items.BoxFill = Esp:Create("ImageLabel", {
        Parent = Items.Root, Name = "BoxFill",
        BackgroundTransparency = 1,
        Image = Settings.BoxFillImage,
        ImageColor3 = Settings.BoxFillColor1,
        ImageTransparency = Settings.BoxFillTransp,
        ScaleType = Enum.ScaleType.Stretch,
        Size = dim2(1, 0, 1, 0),
        Position = dim2(0, 0, 0, 0),
        BorderSizePixel = 0, ZIndex = 1,
    })

    Items.Corners = Esp:Create("Frame", {
        Parent = Items.Root, Name = "Corners",
        BackgroundTransparency = 1,
        Size = dim2(1, 0, 1, 0),
        BorderSizePixel = 0, ZIndex = 2,
    })

    local function mkCorner(imgId, size, anchor, pos, rot, sliceCenter)
        local c = Esp:Create("ImageLabel", {
            Parent = Items.Corners, ScaleType = Enum.ScaleType.Slice, Name = "\0",
            BackgroundColor3 = rgb(255, 255, 255), Size = size, AnchorPoint = anchor,
            Image = imgId, BackgroundTransparency = 1, Position = pos,
            ZIndex = 5, BorderSizePixel = 0, SliceCenter = sliceCenter,
        })
        Esp:Create("UIGradient", { Parent = c, Rotation = rot or 0 })
        return c
    end
    mkCorner("rbxassetid://83548615999411",  dim2(0.4,0,0,3),  vec2(0,1), dim2(0,0,1,0),    0, rect(vec2(1,1), vec2(99,2)))
    mkCorner("rbxassetid://83548615999411",  dim2(0.4,0,0,3),  vec2(1,1), dim2(1,0,1,0),    0, rect(vec2(1,1), vec2(99,2)))
    mkCorner("rbxassetid://83548615999411",  dim2(0.4,0,0,3),  vec2(0,0), dim2(0,0,0,0),    0, rect(vec2(1,1), vec2(99,2)))
    mkCorner("rbxassetid://83548615999411",  dim2(0.4,0,0,3),  vec2(1,0), dim2(1,0,0,0),    0, rect(vec2(1,1), vec2(99,2)))
    mkCorner("rbxassetid://101715268403902", dim2(0,3,0.25,0), vec2(0,1), dim2(0,0,1,-2), -90, rect(vec2(1,0), vec2(2,96)))
    mkCorner("rbxassetid://101715268403902", dim2(0,3,0.25,0), vec2(1,1), dim2(1,0,1,-2),  90, rect(vec2(1,0), vec2(2,96)))
    mkCorner("rbxassetid://102467475629368", dim2(0,3,0.25,0), vec2(0,0), dim2(0,0,0,2),   90, rect(vec2(1,0), vec2(2,98)))
    mkCorner("rbxassetid://102467475629368", dim2(0,3,0.25,0), vec2(1,0), dim2(1,0,0,2),  -90, rect(vec2(1,0), vec2(2,98)))

    local function mkText(name, defaultText)
        return Esp:Create("TextLabel", {
            Parent = Items.Root, Name = name, Text = defaultText or "",
            BackgroundTransparency = 1, BorderSizePixel = 0,
            FontFace = TextFont,
            TextColor3 = rgb(255, 255, 255),
            TextStrokeTransparency = 0, TextStrokeColor3 = rgb(0, 0, 0),
            Size = dim2(0, 200, 0, 14), TextSize = Settings.TextSize,
            ZIndex = 6,
        })
    end
    Items.Name     = mkText("Name", player.Name)
    Items.Distance = mkText("Distance", "")
    Items.Weapon   = mkText("Weapon", "[NONE]")

    Items.HPOutline = Esp:Create("Frame", {
        Parent = Items.Root, Name = "HPOutline",
        BackgroundColor3 = rgb(0, 0, 0), BorderSizePixel = 0, ZIndex = 3,
    })
    Items.HPBar = Esp:Create("Frame", {
        Parent = Items.HPOutline, Name = "HPBar",
        BackgroundColor3 = rgb(20, 20, 20), BackgroundTransparency = 0.3,
        BorderSizePixel = 0, Position = dim2(0, 1, 0, 1),
        Size = dim2(1, -2, 1, -2), ZIndex = 4,
    })
    Items.HPClip = Esp:Create("Frame", {
        Parent = Items.HPBar, Name = "HPClip",
        BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 5,
        Size = dim2(1, 0, 1, 0),
    })
    Items.HPFill = Esp:Create("Frame", {
        Parent = Items.HPClip, Name = "HPFill",
        BackgroundColor3 = rgb(255, 255, 255),
        Size = dim2(1, 0, 1, 0), BorderSizePixel = 0, ZIndex = 5,
    })
    Esp:Create("UIGradient", {
        Parent = Items.HPFill, Rotation = 90,
        Color = rgbseq{
            rgbkey(0.0, rgb(0, 255, 0)),
            rgbkey(0.5, rgb(255, 255, 0)),
            rgbkey(1.0, rgb(255, 0, 0)),
        },
    })

    for i = 1, 19 do
        local ol = newDrawing("Line"); ol.Thickness = 3; ol.Color = rgb(0,0,0)
        ol.Transparency = 1; ol.Visible = false; ol.ZIndex = 1
        local ln = newDrawing("Line"); ln.Thickness = 1; ln.Color = Settings.SkeletonColor
        ln.Transparency = 1; ln.Visible = false; ln.ZIndex = 2
        Data.Drawings.SkeletonBones[i] = { outline = ol, line = ln }
    end

    Data.Drawings.Tracer.outline = newDrawing("Line")
    Data.Drawings.Tracer.outline.Thickness = 3
    Data.Drawings.Tracer.outline.Color = rgb(0,0,0)
    Data.Drawings.Tracer.outline.Transparency = 1
    Data.Drawings.Tracer.outline.Visible = false
    Data.Drawings.Tracer.outline.ZIndex = 1

    Data.Drawings.Tracer.line = newDrawing("Line")
    Data.Drawings.Tracer.line.Thickness = 1
    Data.Drawings.Tracer.line.Color = Settings.TracerColor
    Data.Drawings.Tracer.line.Transparency = 1
    Data.Drawings.Tracer.line.Visible = false
    Data.Drawings.Tracer.line.ZIndex = 2

    Data.RefreshChams = function()
        local char = Data.Info.Character
        if not char then return end
        if not Data.Highlight then
            Data.Highlight = Esp:Create("Highlight", {
                Name = "FloppaHub_Chams",
                DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
                Adornee = char, Parent = char,
            })
        end
        Data.Highlight.Adornee = char
        Data.Highlight.FillColor = Settings.ChamsFill
        Data.Highlight.FillTransparency = Settings.ChamsFillTransp
        Data.Highlight.OutlineColor = Settings.ChamsOutline
        Data.Highlight.OutlineTransparency = Settings.ChamsOutlineTransp
        Data.Highlight.Enabled = Settings.Chams
    end

    Data.UpdateWeapon = function()
        local char = Data.Info.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        Items.Weapon.Text = tool and ("[" .. tool.Name .. "]") or "[NONE]"
    end

    Data.RefreshDescendants = function()
        local char = player.Character or player.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
        Data.Info.Character = char
        Data.Info.Humanoid = humanoid
        Data.Info.RootPart = humanoid.RootPart

        Esp:Connection(char.ChildAdded, Data.UpdateWeapon)
        Esp:Connection(char.ChildRemoved, Data.UpdateWeapon)
        Data.UpdateWeapon()
        Data.RefreshChams()
    end

    Data.Destroy = function()
        if Items.Root then Items.Root:Destroy() end
        if Data.Highlight then Data.Highlight:Destroy() end
        for _, b in pairs(Data.Drawings.SkeletonBones) do
            pcall(function() b.outline:Remove() end)
            pcall(function() b.line:Remove() end)
        end
        if Data.Drawings.Tracer.line then
            pcall(function() Data.Drawings.Tracer.outline:Remove() end)
            pcall(function() Data.Drawings.Tracer.line:Remove() end)
        end
        Esp.Players[player.Name] = nil
    end

    Data.RefreshDescendants()
    Esp:Connection(player.CharacterAdded, Data.RefreshDescendants)
    Esp.Players[player.Name] = Data
    return Data
end

local selfChamsOriginals = {}

local function selfChamsApply()
    local char = LocalPlayer.Character
    if not char then return end
    if not selfChamsOriginals[char] then selfChamsOriginals[char] = {} end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if not selfChamsOriginals[char][part] then
                selfChamsOriginals[char][part] = {
                    Material = part.Material,
                    Color = part.Color,
                    Transparency = part.Transparency,
                }
            end
            part.Material = Enum.Material.ForceField
            part.Color = Settings.SelfChamsColor
            part.Transparency = Settings.SelfChamsTransp
        end
    end
end

local function selfChamsRevert()
    for char, parts in pairs(selfChamsOriginals) do
        for part, orig in pairs(parts) do
            if part and part.Parent then
                pcall(function()
                    part.Material = orig.Material
                    part.Color = orig.Color
                    part.Transparency = orig.Transparency
                end)
            end
        end
    end
    selfChamsOriginals = {}
end

local function updateSelfChams()
    if Settings.SelfChams then selfChamsApply() else selfChamsRevert() end
end

local SKELETON_CONNECTIONS = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"UpperTorso","RightUpperArm"},
    {"LeftUpperArm","LeftLowerArm"},{"RightUpperArm","RightLowerArm"},
    {"LeftLowerArm","LeftHand"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LowerTorso","RightUpperLeg"},
    {"LeftUpperLeg","LeftLowerLeg"},{"RightUpperLeg","RightLowerLeg"},
    {"LeftLowerLeg","LeftFoot"},{"RightLowerLeg","RightFoot"},
    {"Torso","Head"},{"Torso","Left Arm"},{"Torso","Right Arm"},
    {"Torso","Left Leg"},{"Torso","Right Leg"},
}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

local function isVisible(part)
    if not part then return false end
    rayParams.FilterDescendantsInstances = { LocalPlayer.Character, part.Parent }
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    local result = Workspace:Raycast(origin, dir, rayParams)
    return result == nil
end

local visibleCache = {}
local lastVisCheck = 0

function Esp.Update()
    for name, Data in pairs(Esp.Players) do
        local Items = Data.Items
        local player = Players:FindFirstChild(name)
        if not player then continue end

        local char = Data.Info.Character
        local humanoid = Data.Info.Humanoid

        local hideAll = function()
            if Items.Root then Items.Root.Visible = false end
            if Items.HPOutline then Items.HPOutline.Visible = false end
            if Items.BoxFill then Items.BoxFill.Visible = false end
            if Items.Corners then Items.Corners.Visible = false end
            if Items.Name then Items.Name.Visible = false end
            if Items.Distance then Items.Distance.Visible = false end
            if Items.Weapon then Items.Weapon.Visible = false end
            for _, b in pairs(Data.Drawings.SkeletonBones) do
                b.outline.Visible = false; b.line.Visible = false
            end
            Data.Drawings.Tracer.outline.Visible = false
            Data.Drawings.Tracer.line.Visible = false
            if Data.Highlight then Data.Highlight.Enabled = false end
        end

        if not Settings.Enabled then hideAll(); continue end
        if not char or not humanoid or humanoid.Health <= 0 then hideAll(); continue end

        if Data.Highlight then
            local teamBlockC = Settings.ChamsTeamCheck and player.Team
                and LocalPlayer.Team and player.Team == LocalPlayer.Team
            if teamBlockC then
                Data.Highlight.Enabled = false
            else
                Data.Highlight.Enabled = Settings.Chams
                Data.Highlight.FillColor = Settings.ChamsFill
                Data.Highlight.FillTransparency = Settings.ChamsFillTransp
                Data.Highlight.OutlineColor = Settings.ChamsOutline
                Data.Highlight.OutlineTransparency = Settings.ChamsOutlineTransp
            end
        end

        local teamBlock = Settings.TeamCheck and player.Team
            and LocalPlayer.Team and player.Team == LocalPlayer.Team
        if teamBlock then hideAll(); continue end

        local now = tick()
        if Settings.VisibleCheck and (now - lastVisCheck) > 0.1 then
            lastVisCheck = now
            local root = Data.Info.RootPart
            visibleCache[name] = root and isVisible(root) or false
        end
        if Settings.VisibleCheck and not visibleCache[name] then hideAll(); continue end

        local BoxSize, BoxPos, OnScreen, Distance = Esp:BoxSolve(humanoid.RootPart)
        if not BoxSize or not BoxPos or Distance > Settings.RenderDistance or not OnScreen then
            hideAll(); continue
        end

        Items.Root.Visible = true
        Items.Root.Position = dim_offset(BoxPos.X, BoxPos.Y)
        Items.Root.Size = dim2(0, BoxSize.X, 0, BoxSize.Y)

        local boxColor = Settings.TeamColor and player.TeamColor.Color or Settings.BoxColor1

        Items.BoxFill.Visible = Settings.Boxes and Settings.BoxFill
        Items.BoxFill.Image = Settings.BoxFillImage
        Items.BoxFill.ImageTransparency = Settings.BoxFillTransp
        if Settings.BoxFillColor1 ~= Settings.BoxFillColor2 then
            Items.BoxFill.ImageColor3 = rgb(255, 255, 255)
            if not Items.BoxFillGrad then
                Items.BoxFillGrad = Esp:Create("UIGradient", { Parent = Items.BoxFill, Rotation = 180 })
            end
            Items.BoxFillGrad.Color = rgbseq{
                rgbkey(0, Settings.BoxFillColor1),
                rgbkey(1, Settings.BoxFillColor2),
            }
        else
            Items.BoxFill.ImageColor3 = Settings.BoxFillColor1
        end

        Items.Corners.Visible = Settings.Boxes
        for _, corner in ipairs(Items.Corners:GetChildren()) do
            local g = corner:FindFirstChildOfClass("UIGradient")
            if g then
                g.Color = rgbseq{
                    rgbkey(0, Settings.BoxColor1),
                    rgbkey(1, Settings.BoxColor2),
                }
            end
        end

        Items.Name.Text = player.Name
        Items.Name.TextColor3 = Settings.Name_Color
        Items.Name.TextSize = Settings.TextSize
        Items.Name.FontFace = TextFont
        Items.Name.Visible = Settings.Name_Text
        Items.Name.AnchorPoint = vec2(0.5, 1)
        Items.Name.Position = dim2(0, BoxSize.X / 2, 0, -2)

        Items.Distance.Text = tostring(Distance) .. " studs"
        Items.Distance.TextColor3 = Settings.Distance_Color
        Items.Distance.TextSize = Settings.TextSize
        Items.Distance.FontFace = TextFont
        Items.Distance.Visible = Settings.Distance_Text
        Items.Distance.AnchorPoint = vec2(0.5, 0)
        Items.Distance.Position = dim2(0, BoxSize.X / 2, 1, 2)

        Items.Weapon.TextColor3 = Settings.Weapon_Color
        Items.Weapon.TextSize = Settings.TextSize
        Items.Weapon.FontFace = TextFont
        Items.Weapon.Visible = Settings.Weapon_Text
        Items.Weapon.AnchorPoint = vec2(0.5, 0)
        Items.Weapon.Position = dim2(0, BoxSize.X / 2, 1, 2 + Settings.TextSize + 2)

        if Settings.Healthbar then
            local maxHp = humanoid.MaxHealth
            local hp = humanoid.Health
            local p = maxHp > 0 and clamp(hp / maxHp, 0, 1) or 0
            local barW = Settings.Healthbar_Width
            local barH = BoxSize.Y

            local isLeft = Settings.Healthbar_Pos == "Left"
            local posX = isLeft and (-barW - Settings.Healthbar_Offset)
                or (BoxSize.X + Settings.Healthbar_Offset)

            Items.HPOutline.Visible = true
            Items.HPBar.Visible = true
            Items.HPClip.Visible = true

            if Settings.Healthbar_Outline then
                Items.HPOutline.BackgroundColor3 = rgb(0, 0, 0)
                Items.HPOutline.BackgroundTransparency = 0
                Items.HPOutline.Size = dim2(0, barW + 2, 0, barH + 2)
                Items.HPOutline.Position = dim2(0, posX - 1, 0, -1)
                Items.HPBar.Position = dim2(0, 1, 0, 1)
                Items.HPBar.Size = dim2(1, -2, 1, -2)
            else
                Items.HPOutline.BackgroundTransparency = 1
                Items.HPOutline.Size = dim2(0, barW, 0, barH)
                Items.HPOutline.Position = dim2(0, posX, 0, 0)
                Items.HPBar.Position = dim2(0, 0, 0, 0)
                Items.HPBar.Size = dim2(1, 0, 1, 0)
            end

            local filledH = round(barH * p)
            Items.HPClip.Size = dim2(0, barW, 0, filledH)
            Items.HPClip.Position = dim2(0, 0, 0, barH - filledH)
            Items.HPFill.Size = dim2(1, 0, 0, barH)
            Items.HPFill.Position = dim2(0, 0, 0, -(barH - filledH))
        else
            Items.HPOutline.Visible = false
        end

        if Settings.Skeleton then
            for i, conn in ipairs(SKELETON_CONNECTIONS) do
                local p1, p2 = char:FindFirstChild(conn[1]), char:FindFirstChild(conn[2])
                local b = Data.Drawings.SkeletonBones[i]
                if p1 and p2 and b then
                    local v1, s1 = Camera:WorldToViewportPoint(p1.Position)
                    local v2, s2 = Camera:WorldToViewportPoint(p2.Position)
                    if s1 and s2 then
                        b.outline.From = newVector2(v1.X, v1.Y); b.outline.To = newVector2(v2.X, v2.Y); b.outline.Visible = true
                        b.line.From = newVector2(v1.X, v1.Y); b.line.To = newVector2(v2.X, v2.Y)
                        b.line.Color = Settings.SkeletonColor; b.line.Visible = true
                    else
                        b.outline.Visible = false; b.line.Visible = false
                    end
                elseif b then
                    b.outline.Visible = false; b.line.Visible = false
                end
            end
        else
            for _, b in pairs(Data.Drawings.SkeletonBones) do b.outline.Visible = false; b.line.Visible = false end
        end

        local tr = Data.Drawings.Tracer
        if Settings.Tracer then
            local sp = Camera:WorldToViewportPoint(char:GetModelCFrame().Position)
            local origin
            if Settings.TracerOrigin == "Bottom" then
                origin = newVector2(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            elseif Settings.TracerOrigin == "Center" then
                origin = newVector2(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            else
                origin = Mouse.Location
            end
            local target = newVector2(sp.X, sp.Y)
            tr.outline.From = origin; tr.outline.To = target; tr.outline.Visible = true
            tr.line.From = origin; tr.line.To = target
            tr.line.Color = Settings.TracerColor; tr.line.Visible = true
        else
            tr.outline.Visible = false; tr.line.Visible = false
        end
    end
end

local originalSizes = {}

local function resetHitbox(player)
    local char = player.Character
    if not char then return end
    local saved = originalSizes[player]
    if not saved then return end
    for partName, size in pairs(saved) do
        local p = char:FindFirstChild(partName)
        if p and p:IsA("BasePart") then
            pcall(function() p.Size = size end)
        end
    end
    originalSizes[player] = nil
end

local function applyHitbox(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local teamBlock = Settings.HitboxTeamCheck and player.Team
        and LocalPlayer.Team and player.Team == LocalPlayer.Team
    if teamBlock or not Settings.Hitbox then resetHitbox(player); return end
    if not originalSizes[player] then originalSizes[player] = {} end
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            if not originalSizes[player][part.Name] then
                originalSizes[player][part.Name] = part.Size
            end
            pcall(function()
                part.Size = vec3(Settings.HitboxX, Settings.HitboxY, Settings.HitboxZ)
                part.Transparency = Settings.HitboxTransp
                part.CanCollide = false
                part.Massless = true
            end)
        end
    end
end

local function updateAllHitboxes()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then applyHitbox(p) end
    end
end

local Aimbot = {
    Enabled     = false,
    Held        = false,
    Key         = Enum.KeyCode.E,
    LockPart    = "Head",
    FOV         = 150,
    FOVColor    = rgb(255, 255, 255),
    FOVColorLocked = rgb(255, 150, 150),
    FOVOutlineColor = rgb(0, 0, 0),
    Sensitivity = 0.25,
    MaxDistance = 1000,
    TeamCheck   = true,
    VisCheck    = false,
    Prediction  = false,
    PredictionAmount = 0.15,
    Locked      = nil,
    Blacklist   = {},
    Tracer      = newDrawing("Line"),
    FOVCircle   = newDrawing("Circle"),
    FOVOutline  = newDrawing("Circle"),
}

Aimbot.Tracer.Thickness = 1
Aimbot.Tracer.Color = rgb(255, 255, 255)
Aimbot.Tracer.Transparency = 1
Aimbot.Tracer.Visible = false
Aimbot.Tracer.ZIndex = 1

Aimbot.FOVCircle.NumSides = 60
Aimbot.FOVCircle.Thickness = 1
Aimbot.FOVCircle.Color = rgb(255, 255, 255)
Aimbot.FOVCircle.Transparency = 1
Aimbot.FOVCircle.Filled = false
Aimbot.FOVCircle.Visible = false
Aimbot.FOVCircle.ZIndex = 2

Aimbot.FOVOutline.NumSides = 60
Aimbot.FOVOutline.Thickness = 2
Aimbot.FOVOutline.Color = rgb(0, 0, 0)
Aimbot.FOVOutline.Transparency = 1
Aimbot.FOVOutline.Filled = false
Aimbot.FOVOutline.Visible = false
Aimbot.FOVOutline.ZIndex = 1

local function getMousePos() return InputService:GetMouseLocation() end

InputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Aimbot.Key or input.UserInputType == Aimbot.Key then
        Aimbot.Held = true
    end
end)

InputService.InputEnded:Connect(function(input)
    if input.KeyCode == Aimbot.Key or input.UserInputType == Aimbot.Key then
        Aimbot.Held = false
        Aimbot.Locked = nil
        Aimbot.Tracer.Visible = false
    end
end)

local function getClosestAimbotTarget()
    local requiredDistance = Aimbot.FOV
    local closest, closestDist = nil, math.huge
    local mousePos = getMousePos()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if table.find(Aimbot.Blacklist, plr.Name) then continue end
        if Aimbot.TeamCheck and plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then continue end

        local char = plr.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = char:FindFirstChild(Aimbot.LockPart)
        if not part then continue end

        local dist3D = (Camera.CFrame.Position - part.Position).Magnitude
        if dist3D > Aimbot.MaxDistance then continue end
        if Aimbot.VisCheck and not isVisible(part) then continue end

        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then continue end

        local vec = newVector2(sp.X, sp.Y)
        local dist = (mousePos - vec).Magnitude
        if dist < requiredDistance and dist < closestDist then
            closestDist = dist
            closest = { player = plr, part = part, worldPos = part.Position, velocity = part.AssemblyLinearVelocity }
        end
    end
    return closest
end

local function updateAimbot()
    local mousePos = getMousePos()
    Aimbot.FOVCircle.Position = mousePos
    Aimbot.FOVOutline.Position = mousePos
    Aimbot.FOVCircle.Radius = Aimbot.FOV
    Aimbot.FOVOutline.Radius = Aimbot.FOV
    Aimbot.FOVCircle.Color = Aimbot.FOVColor
    Aimbot.FOVOutline.Color = Aimbot.FOVOutlineColor
    Aimbot.FOVCircle.Visible = Aimbot.Enabled
    Aimbot.FOVOutline.Visible = Aimbot.Enabled

    if not Aimbot.Enabled or not Aimbot.Held then
        return
    end

    local target = getClosestAimbotTarget()
    if not target then
        return
    end

    Aimbot.Locked = target.player
    Aimbot.FOVCircle.Color = Aimbot.FOVColorLocked

    local aimPos = target.worldPos
    if Aimbot.Prediction and target.velocity then
        local dist = (Camera.CFrame.Position - target.worldPos).Magnitude
        local ping = 0
        pcall(function()
            ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
        end)
        local travelTime = (dist / 1000) + ping
        aimPos = target.worldPos + target.velocity * travelTime * Aimbot.PredictionAmount * 10
    end

    local newCF = CFrame.new(Camera.CFrame.Position, aimPos)
    if Aimbot.Sensitivity > 0 then
        Camera.CFrame = Camera.CFrame:Lerp(newCF, math.clamp(1 - Aimbot.Sensitivity, 0.01, 1))
    else
        Camera.CFrame = newCF
    end
end

local fovFillGui = Instance.new("ImageLabel")
fovFillGui.Name = "FloppaFOVFill"
fovFillGui.BackgroundTransparency = 1
fovFillGui.Image = "rbxassetid://9812088890"
fovFillGui.ScaleType = Enum.ScaleType.Stretch
fovFillGui.Visible = false
fovFillGui.ZIndex = 1
fovFillGui.Parent = ScreenGui
local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovFillGui

local FOVFillSettings = { Enabled = true, Transp = 0.8, Color = rgb(255, 255, 255) }

local jumpCircles = {}
local jumpWasOnGround = true

local function raycastFloor()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { char }
    local result = Workspace:Raycast(hrp.Position, Vector3.new(0, -50, 0), params)
    if result then return result.Position end
    return nil
end

local function jumpCircleSpawn(floorPos)
    local c = { segments = {}, spawnTime = tick(), pos = floorPos }
    for i = 1, Settings.JumpCircleSides do
        local seg = newDrawing("Line")
        seg.Thickness = 2
        seg.Color = Settings.JumpCircleColor
        seg.Transparency = 1
        seg.Visible = false
        seg.ZIndex = 1
        c.segments[i] = seg
    end
    table.insert(jumpCircles, c)
    if #jumpCircles > 30 then
        local old = table.remove(jumpCircles, 1)
        for _, s in ipairs(old.segments) do pcall(function() s:Remove() end) end
    end
end

local function updateJumpCircles()
    if not Settings.JumpCircles then
        for _, c in ipairs(jumpCircles) do
            for _, s in ipairs(c.segments) do s.Visible = false end
        end
        return
    end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local onGround = (hum.FloorMaterial ~= Enum.Material.Air)

    if jumpWasOnGround and not onGround then
        local floorPos = raycastFloor()
        if floorPos then jumpCircleSpawn(floorPos + Vector3.new(0, 0.05, 0)) end
    end
    if not jumpWasOnGround and onGround then
        local floorPos = raycastFloor()
        if floorPos then jumpCircleSpawn(floorPos + Vector3.new(0, 0.05, 0)) end
    end
    jumpWasOnGround = onGround

    local now = tick()
    local lifetime = Settings.JumpCircleLifetime
    for i = #jumpCircles, 1, -1 do
        local c = jumpCircles[i]
        local elapsed = now - c.spawnTime
        local alpha = elapsed / lifetime
        if alpha >= 1 then
            for _, s in ipairs(c.segments) do pcall(function() s:Remove() end) end
            table.remove(jumpCircles, i)
        else
            local radius = Settings.JumpCircleSize * alpha
            local transparency = clamp(Settings.JumpCircleTransp + alpha * (1 - Settings.JumpCircleTransp), 0, 1)
            local origin = c.pos
            for j, seg in ipairs(c.segments) do
                local a1 = (j / Settings.JumpCircleSides) * math.pi * 2
                local a2 = ((j + 1) / Settings.JumpCircleSides) * math.pi * 2
                local p1 = origin + Vector3.new(math.cos(a1) * radius, 0, math.sin(a1) * radius)
                local p2 = origin + Vector3.new(math.cos(a2) * radius, 0, math.sin(a2) * radius)
                local v1, s1 = Camera:WorldToViewportPoint(p1)
                local v2, s2 = Camera:WorldToViewportPoint(p2)
                if s1 and s2 then
                    seg.From = newVector2(v1.X, v1.Y)
                    seg.To = newVector2(v2.X, v2.Y)
                    seg.Color = Settings.JumpCircleColor
                    seg.Transparency = transparency
                    seg.Visible = true
                else
                    seg.Visible = false
                end
            end
        end
    end
end

local Cross2DGui = Instance.new("Frame")
Cross2DGui.Name = "FloppaCross2D"
Cross2DGui.BackgroundTransparency = 1
Cross2DGui.AnchorPoint = Vector2.new(0.5, 0.5)
Cross2DGui.Size = UDim2.new(0, 0, 0, 0)
Cross2DGui.ZIndex = 5
Cross2DGui.Visible = false
Cross2DGui.Parent = ScreenGui

local Cross2DParts = {}
local Cross2DNameLabel = Instance.new("TextLabel")
Cross2DNameLabel.Name = "ScriptName"
Cross2DNameLabel.BackgroundTransparency = 1
Cross2DNameLabel.Text = Settings.Cross2DName
Cross2DNameLabel.TextColor3 = Settings.Cross2DColor
Cross2DNameLabel.TextStrokeTransparency = 0
Cross2DNameLabel.TextStrokeColor3 = Settings.Cross2DOutlineColor
Cross2DNameLabel.FontFace = TextFont
Cross2DNameLabel.TextSize = 12
Cross2DNameLabel.Size = UDim2.new(0, 200, 0, 14)
Cross2DNameLabel.AnchorPoint = Vector2.new(0.5, 0)
Cross2DNameLabel.Position = UDim2.new(0.5, 0, 1, 6)
Cross2DNameLabel.Visible = false
Cross2DNameLabel.Parent = Cross2DGui

local Cross2DContainer = Instance.new("Frame")
Cross2DContainer.Name = "SpinContainer"
Cross2DContainer.BackgroundTransparency = 1
Cross2DContainer.AnchorPoint = Vector2.new(0.5, 0.5)
Cross2DContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
Cross2DContainer.Size = UDim2.new(0, 0, 0, 0)
Cross2DContainer.ZIndex = 5
Cross2DContainer.Parent = Cross2DGui

local function create2DCrosshair()
    for _, p in ipairs(Cross2DParts) do pcall(function() p:Destroy() end) end
    Cross2DParts = {}

    local style = Settings.Cross2DStyle
    local size = Settings.Cross2DSize
    local thickness = Settings.Cross2DThickness
    local color = Settings.Cross2DColor

    if style == "Dot" then
        local dot = Instance.new("Frame")
        dot.BackgroundColor3 = color
        dot.BorderSizePixel = 0
        dot.Size = UDim2.new(0, thickness * 2, 0, thickness * 2)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.new(0.5, 0, 0.5, 0)
        dot.ZIndex = 5
        dot.Parent = Cross2DContainer
        table.insert(Cross2DParts, dot)

    elseif style == "Circle" then
        local circle = Instance.new("Frame")
        circle.BackgroundTransparency = 1
        circle.BorderSizePixel = 0
        circle.Size = UDim2.new(0, size * 2, 0, size * 2)
        circle.AnchorPoint = Vector2.new(0.5, 0.5)
        circle.Position = UDim2.new(0.5, 0, 0.5, 0)
        circle.ZIndex = 5
        circle.Parent = Cross2DContainer
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle
        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Thickness = thickness
        stroke.Transparency = 0
        stroke.Parent = circle
        table.insert(Cross2DParts, circle)

    elseif style == "Square" then
        local sq = Instance.new("Frame")
        sq.BackgroundTransparency = 1
        sq.BorderSizePixel = 0
        sq.Size = UDim2.new(0, size * 2, 0, size * 2)
        sq.AnchorPoint = Vector2.new(0.5, 0.5)
        sq.Position = UDim2.new(0.5, 0, 0.5, 0)
        sq.ZIndex = 5
        sq.Parent = Cross2DContainer
        local stroke = Instance.new("UIStroke")
        stroke.Color = color
        stroke.Thickness = thickness
        stroke.Parent = sq
        table.insert(Cross2DParts, sq)

    else
        local gap = 2
        local len = size
        local positions = {
            {UDim2.new(0.5, 0, 0.5, -gap), UDim2.new(0, thickness, 0, len), Vector2.new(0.5, 1)},
            {UDim2.new(0.5, 0, 0.5, gap),  UDim2.new(0, thickness, 0, len), Vector2.new(0.5, 0)},
            {UDim2.new(0.5, -gap, 0.5, 0), UDim2.new(0, len, 0, thickness), Vector2.new(1, 0.5)},
            {UDim2.new(0.5, gap, 0.5, 0),  UDim2.new(0, len, 0, thickness), Vector2.new(0, 0.5)},
        }
        for _, pos in ipairs(positions) do
            local line = Instance.new("Frame")
            line.BackgroundColor3 = color
            line.BorderSizePixel = 0
            line.Size = pos[2]
            line.Position = pos[1]
            line.AnchorPoint = pos[3]
            line.ZIndex = 5
            line.Parent = Cross2DContainer
            table.insert(Cross2DParts, line)
        end
    end
end

create2DCrosshair()

local Movement = {
    flyConnection = nil,
    cframeSpeedConnection = nil,
    velocitySpeedConnection = nil,
    noclipConnections = {},
}

function Movement:getHumanoid()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid"), char
end

function Movement:updateWalkSpeed()
    local hum = self:getHumanoid()
    if not hum then return end
    if Settings.SpeedEnabled and Settings.SpeedMethod == "WalkSpeed" then
        hum.WalkSpeed = Settings.SpeedValue
    else
        hum.WalkSpeed = 16
    end
end

function Movement:updateCFrameSpeed()
    if self.cframeSpeedConnection then
        self.cframeSpeedConnection:Disconnect()
        self.cframeSpeedConnection = nil
    end
    if Settings.SpeedEnabled and Settings.SpeedMethod == "CFrame" then
        self.cframeSpeedConnection = RunService.RenderStepped:Connect(function(dt)
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + moveDir * Settings.SpeedValue * dt
            end
        end)
    end
end

function Movement:updateVelocitySpeed()
    if self.velocitySpeedConnection then
        self.velocitySpeedConnection:Disconnect()
        self.velocitySpeedConnection = nil
    end
    if Settings.SpeedEnabled and Settings.SpeedMethod == "Velocity" then
        self.velocitySpeedConnection = RunService.RenderStepped:Connect(function(dt)
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    moveDir.X * Settings.SpeedValue,
                    hrp.AssemblyLinearVelocity.Y,
                    moveDir.Z * Settings.SpeedValue
                )
            end
        end)
    end
end

function Movement:startFly()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true

    if self.flyConnection then self.flyConnection:Disconnect() end
    self.flyConnection = RunService.RenderStepped:Connect(function(dt)
        if not Settings.FlyEnabled then return end
        local c = LocalPlayer.Character
        local root = c and c:FindFirstChild("HumanoidRootPart")
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if not root or not h then return end

        local moveDir = Vector3.zero
        if InputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
        if InputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
        if InputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.RightVector end
        if InputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.RightVector end
        if InputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
        if InputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * Settings.FlySpeed
        end
        root.Velocity = Vector3.zero
        root.CFrame = root.CFrame + moveDir * dt
    end)
end

function Movement:stopFly()
    if self.flyConnection then
        pcall(function() self.flyConnection:Disconnect() end)
        self.flyConnection = nil
    end
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.PlatformStand = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
    end
end

function Movement:updateNoclip()
    if Settings.NoclipEnabled then
        if #self.noclipConnections == 0 then
            table.insert(self.noclipConnections, RunService.Stepped:Connect(function()
                if not Settings.NoclipEnabled then return end
                local char = LocalPlayer.Character
                if not char then return end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end))
        end
    else
        for _, c in ipairs(self.noclipConnections) do
            pcall(function() c:Disconnect() end)
        end
        self.noclipConnections = {}
    end
end

local Freecam = {
    Enabled = false,
    Camera = nil,
    Connections = {},
    Rotation = Vector2.new(0, 0),
    Position = Vector3.zero,
}

function Freecam:enable()
    if self.Enabled then return end
    self.Enabled = true

    local cam = Instance.new("Camera")
    cam.CFrame = Camera.CFrame
    cam.Parent = Workspace

    self.Camera = cam
    self.Position = Camera.CFrame.Position
    self.Rotation = Vector2.new(0, 0)

    Camera.CameraType = Enum.CameraType.Scriptable

    table.insert(self.Connections, InputService.InputChanged:Connect(function(input)
        if not self.Enabled then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            self.Rotation = self.Rotation + Vector2.new(-input.Delta.X, -input.Delta.Y)
            self.Rotation = Vector2.new(
                math.clamp(self.Rotation.X, -80, 80),
                self.Rotation.Y
            )
        end
    end))

    table.insert(self.Connections, RunService.RenderStepped:Connect(function(dt)
        if not self.Enabled then return end
        local speed = Settings.FreecamSpeed
        if InputService:IsKeyDown(Enum.KeyCode.LeftShift) then speed = speed * 3 end

        local move = Vector3.zero
        if InputService:IsKeyDown(Enum.KeyCode.I) then move += cam.CFrame.LookVector end
        if InputService:IsKeyDown(Enum.KeyCode.K) then move -= cam.CFrame.LookVector end
        if InputService:IsKeyDown(Enum.KeyCode.J) then move -= cam.CFrame.RightVector end
        if InputService:IsKeyDown(Enum.KeyCode.L) then move += cam.CFrame.RightVector end
        if InputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if InputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end

        self.Position = self.Position + move * speed * dt

        local targetCF = CFrame.new(self.Position) * CFrame.Angles(0, math.rad(self.Rotation.Y), 0) * CFrame.Angles(math.rad(self.Rotation.X), 0, 0)
        cam.CFrame = cam.CFrame:Lerp(targetCF, math.clamp(Settings.FreecamSmooth, 0.01, 1))
    end))
end

function Freecam:disable()
    if not self.Enabled then return end
    self.Enabled = false
    for _, c in ipairs(self.Connections) do pcall(function() c:Disconnect() end) end
    self.Connections = {}
    if self.Camera then pcall(function() self.Camera:Destroy() end) end
    self.Camera = nil
    Camera.CameraType = Enum.CameraType.Custom
end

local Zoom = { Active = false }

local function updateZoom()
    if Zoom.Active then
        Camera.FieldOfView = Settings.ZoomValue
    elseif not Settings.FOVEnabled then
        Camera.FieldOfView = OrigFOV
    end
end

InputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Settings.ZoomKey and Settings.ZoomEnabled then
        Zoom.Active = true
        updateZoom()
    end
end)

InputService.InputEnded:Connect(function(input)
    if input.KeyCode == Settings.ZoomKey then
        Zoom.Active = false
        updateZoom()
    end
end)

local function updateFOV()
    if Settings.FOVEnabled then
        Camera.FieldOfView = Settings.FOVValue
    elseif not Zoom.Active then
        Camera.FieldOfView = OrigFOV
    end
end

local Desync = {
    Enabled = false,
    Cube = nil,
    LastCF = nil,
    Connection = nil,
}

function Desync:enable()
    if self.Enabled then return end
    self.Enabled = true
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        self.LastCF = hrp.CFrame
    end

    if Settings.DesyncCube and not self.Cube then
        local cube = Instance.new("Part")
        cube.Name = "FloppaDesyncCube"
        cube.Size = Vector3.new(1, 1, 1)
        cube.Material = Enum.Material.Neon
        cube.Color = rgb(255, 0, 0)
        cube.Anchored = true
        cube.CanCollide = false
        cube.CanQuery = false
        cube.Parent = Workspace
        self.Cube = cube
    end

    self.Connection = RunService.RenderStepped:Connect(function()
        if not self.Enabled then return end
        local c = LocalPlayer.Character
        local root = c and c:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if self.LastCF then
            root.CFrame = self.LastCF
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
        if self.Cube then
            self.Cube.CFrame = self.LastCF or root.CFrame
        end
    end)
end

function Desync:disable()
    if not self.Enabled then return end
    self.Enabled = false
    if self.Connection then pcall(function() self.Connection:Disconnect() end) end
    self.Connection = nil
    if self.Cube then pcall(function() self.Cube:Destroy() end) end
    self.Cube = nil
    self.LastCF = nil
end

local function updateDesyncCube()
    if Settings.Desync and Settings.DesyncCube and not Desync.Cube then
        local cube = Instance.new("Part")
        cube.Name = "FloppaDesyncCube"
        cube.Size = Vector3.new(1, 1, 1)
        cube.Material = Enum.Material.Neon
        cube.Color = rgb(255, 0, 0)
        cube.Anchored = true
        cube.CanCollide = false
        cube.CanQuery = false
        cube.Parent = Workspace
        Desync.Cube = cube
    elseif (not Settings.Desync or not Settings.DesyncCube) and Desync.Cube then
        pcall(function() Desync.Cube:Destroy() end)
        Desync.Cube = nil
    end
end

local function teleportToMouse()
    local mousePos = InputService:GetMouseLocation()
    local unitRay = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    local result = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)
    if result then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))
        end
    end
end

InputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if Settings.CtrlClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 and InputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        teleportToMouse()
    end
    if Settings.TPTool and input.KeyCode == Settings.TPToolKey then
        teleportToMouse()
    end
end)

local function applyFullBright()
    if Settings.FullBright then
        Lighting.Brightness = 3
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = rgb(255, 255, 255)
        Lighting.ExposureCompensation = 0.3
    else
        Lighting.Brightness = OrigLighting.Brightness
        Lighting.GlobalShadows = OrigLighting.GlobalShadows
        Lighting.OutdoorAmbient = OrigLighting.OutdoorAmbient
        Lighting.ExposureCompensation = 0
    end
end

local function applyNoFog()
    if Settings.NoFog then
        Lighting.FogStart = 9e9
        Lighting.FogEnd = 9e9
    else
        Lighting.FogStart = OrigLighting.FogStart
        Lighting.FogEnd = OrigLighting.FogEnd
        Lighting.FogColor = OrigLighting.FogColor
    end
end

local function applyAmbient()
    if Settings.AmbientEnabled then
        Lighting.Ambient = Settings.AmbientColor
    else
        Lighting.Ambient = OrigLighting.Ambient
    end
end

local function applyShadows()
    if Settings.RemoveShadows then
        Lighting.GlobalShadows = false
    else
        Lighting.GlobalShadows = not Settings.FullBright and OrigLighting.GlobalShadows or false
    end
end

local function applyShadowColor()
    local cc = Lighting:FindFirstChild("FloppaShadowCC")
    if Settings.ShadowColorEnabled then
        if not cc then
            cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "FloppaShadowCC"
            cc.Parent = Lighting
        end
        cc.Brightness = -0.1
        cc.Contrast = 0.15
        cc.Saturation = 0
        cc.TintColor = Settings.ShadowColor
    else
        if cc then cc:Destroy() end
    end
end

local function applyRemoveGrass()
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if not terrain then return end
    pcall(function() terrain.Decoration = not Settings.RemoveGrass end)
end

local function applySkybox()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not Settings.SkyboxEnabled then
        if sky and OrigSkyData then
            sky.SkyboxBk = OrigSkyData.Bk
            sky.SkyboxDn = OrigSkyData.Dn
            sky.SkyboxFt = OrigSkyData.Ft
            sky.SkyboxLf = OrigSkyData.Lf
            sky.SkyboxRt = OrigSkyData.Rt
            sky.SkyboxUp = OrigSkyData.Up
        elseif sky then
            sky:Destroy()
        end
        return
    end
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = Lighting
    end
    local id = Settings.SkyboxId
    local fullId = string.find(id, "rbxassetid") and id or ("rbxassetid://" .. id)
    sky.SkyboxBk = fullId
    sky.SkyboxDn = fullId
    sky.SkyboxFt = fullId
    sky.SkyboxLf = fullId
    sky.SkyboxRt = fullId
    sky.SkyboxUp = fullId
end

local AuraModels = {
    'Godly', 'Super Sayien', 'North Star', 'Blue Lord',
    'Pink Aura', 'Angel Wing', 'Sweet Heart', 'Ethereal Aura',
}
local AuraModelIDs = {
    ['Godly']         = 'rbxassetid://16699750981',
    ['Super Sayien']  = 'rbxassetid://116109508364297',
    ['North Star']    = 'rbxassetid://83945069652732',
    ['Blue Lord']     = 'rbxassetid://10974316799',
    ['Pink Aura']     = 'rbxassetid://115980859615239',
    ['Angel Wing']    = 'rbxassetid://90022969696073',
    ['Sweet Heart']   = 'rbxassetid://91724768175470',
    ['Ethereal Aura'] = 'rbxassetid://97041568674250',
}
local activeClassicAuras = {}

local PARTICLE_AURA_DATA = {
    { "starlight", "rbxassetid://134645216613107" },
    { "heavenly",  "rbxassetid://139300897520961" },
    { "ribbon",    "rbxassetid://132069507632161" },
    { "sakura",    "rbxassetid://81755778619404"  },
    { "angel",     "rbxassetid://97658130917593"  },
    { "wind",      "rbxassetid://80694081850877"  },
    { "flow",      "rbxassetid://119913533725648" },
    { "star",      "rbxassetid://73754563740680"  },
    { "neon",      "rbxassetid://18498709246"     },
}
local PARTICLE_AURA_NAMES = {}
local particleAuraIdByName = {}
for _, row in ipairs(PARTICLE_AURA_DATA) do
    table.insert(PARTICLE_AURA_NAMES, row[1])
    particleAuraIdByName[row[1]] = row[2]
end
local loadedParticleAuras = {}
local activeParticleAuras = {}

local AuraTrailSettings = {
    Enabled = false,
    Color1 = rgb(0, 86, 255),
    Color2 = rgb(255, 0, 0),
    Lifetime = 0.5,
    Transp1 = 0,
}
local auraTrail = nil

local function refreshAuraTrail()
    local char = LocalPlayer.Character
    if auraTrail then pcall(function() auraTrail:Destroy() end); auraTrail = nil end
    if not char or not AuraTrailSettings.Enabled then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local a0 = Instance.new("Attachment", hrp)
    a0.Name = "FloppaAuraTrailA0"
    a0.Position = Vector3.new(0, 2, 0)
    local a1 = Instance.new("Attachment", hrp)
    a1.Name = "FloppaAuraTrailA1"
    a1.Position = Vector3.new(0, -2, 0)

    auraTrail = Instance.new("Trail")
    auraTrail.Name = "FloppaAuraTrail"
    auraTrail.Attachment0 = a0
    auraTrail.Attachment1 = a1
    auraTrail.Lifetime = AuraTrailSettings.Lifetime
    auraTrail.Color = ColorSequence.new(AuraTrailSettings.Color1, AuraTrailSettings.Color2)
    auraTrail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, AuraTrailSettings.Transp1),
        NumberSequenceKeypoint.new(1, 1),
    })
    auraTrail.LightEmission = 0.5
    auraTrail.Parent = char
end

local function ClassicAura_LoadModel(id)
    local ok, result = pcall(function() return game:GetObjects(id)[1] end)
    if not ok then return nil end
    return result
end
local function ClassicAura_DisableOne(auraName)
    if activeClassicAuras[auraName] then
        for _, v in pairs(activeClassicAuras[auraName]) do
            if v and v.Parent then pcall(function() v:Destroy() end) end
        end
        activeClassicAuras[auraName] = nil
    end
end
local function ClassicAura_EnableOne(char, auraName)
    if not char or not char.Parent then return end
    ClassicAura_DisableOne(auraName)
    local id = AuraModelIDs[auraName]
    if not id then return end
    local model = ClassicAura_LoadModel(id)
    if not model then return end
    local effects = {}
    for _, obj in pairs(model:GetDescendants()) do
        if not obj:IsA('BasePart') then
            pcall(function()
                local clone = obj:Clone()
                local parentName = obj.Parent and obj.Parent.Name
                local target = char:FindFirstChild(parentName)
                if not target then target = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA('BasePart') end
                if target then clone.Parent = target; table.insert(effects, clone) end
            end)
        end
    end
    pcall(function() model:Destroy() end)
    if #effects > 0 then activeClassicAuras[auraName] = effects end
end
local function ClassicAura_RefreshAll()
    local char = LocalPlayer.Character
    if not char then return end
    if not Toggles.ClassicAuraEnabled or not Toggles.ClassicAuraEnabled.Value then
        for _, a in ipairs(AuraModels) do ClassicAura_DisableOne(a) end
        return
    end
    if not Options.ClassicAuraDropdown then return end
    local selectedAuras = Options.ClassicAuraDropdown.Value
    for _, a in ipairs(AuraModels) do ClassicAura_DisableOne(a) end
    if type(selectedAuras) == "table" then
        for name, isSel in pairs(selectedAuras) do
            if isSel then task.spawn(function() ClassicAura_EnableOne(char, name) end) end
        end
    end
end

local function mapCharacterParts(character)
    local parts = {}
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("BasePart") then parts[child.Name] = child end
    end
    return parts
end
local function getParticleAuraTemplate(name)
    local cached = loadedParticleAuras[name]
    if cached then return cached end
    local id = particleAuraIdByName[name]
    if not id then return nil end
    local ok, result = pcall(function() return game:GetObjects(id)[1] end)
    if ok and result then loadedParticleAuras[name] = result; return result end
    return nil
end
local function tintParticleSubtree(root, color)
    if not color or not root then return end
    local seq = ColorSequence.new(color)
    local function tintOne(obj)
        pcall(function()
            if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then obj.Color = seq
            elseif obj:IsA("PointLight") then obj.Color = color end
        end)
    end
    tintOne(root)
    for _, d in ipairs(root:GetDescendants()) do tintOne(d) end
end
local function setParticleEmittersEnabled(root, enabled)
    if not root then return end
    pcall(function() if root:IsA("ParticleEmitter") then root.Enabled = enabled end end)
    for _, d in ipairs(root:GetDescendants()) do
        pcall(function() if d:IsA("ParticleEmitter") then d.Enabled = enabled end end)
    end
end
local function applyParticleAuraToCharacter(character, auraName, color)
    local auraObj = getParticleAuraTemplate(auraName)
    if not auraObj then return {} end
    local localParts = mapCharacterParts(character)
    local cloned = auraObj:Clone()
    local created = {}
    for _, part in ipairs(cloned:GetChildren()) do
        local targetPart = localParts[part.Name]
        if targetPart then
            for _, child in ipairs(part:GetChildren()) do
                pcall(function()
                    local inst = child:Clone()
                    inst.Name = "FloppaAuraParticle"
                    inst.Parent = targetPart
                    if color then tintParticleSubtree(inst, color) end
                    table.insert(created, inst)
                end)
            end
        end
    end
    pcall(function() cloned:Destroy() end)
    for _, p in ipairs(created) do setParticleEmittersEnabled(p, true) end
    return created
end
local function ParticleAura_DisableOne(auraName)
    if activeParticleAuras[auraName] then
        for _, p in ipairs(activeParticleAuras[auraName]) do
            if p then pcall(function() p:Destroy() end) end
        end
        activeParticleAuras[auraName] = nil
    end
end
local function ParticleAura_RefreshAll()
    local char = LocalPlayer.Character
    if not char then return end
    if not Toggles.ParticleAuraEnabled or not Toggles.ParticleAuraEnabled.Value then
        for _, a in ipairs(PARTICLE_AURA_NAMES) do ParticleAura_DisableOne(a) end
        return
    end
    if not Options.ParticleAuraDropdown then return end
    local selectedAuras = Options.ParticleAuraDropdown.Value
    for _, a in ipairs(PARTICLE_AURA_NAMES) do ParticleAura_DisableOne(a) end
    local col = (Options.ParticleAuraColor and Options.ParticleAuraColor.Value) or rgb(133, 220, 255)
    if type(selectedAuras) == "table" then
        for name, isSel in pairs(selectedAuras) do
            if isSel then
                task.spawn(function()
                    local particles = applyParticleAuraToCharacter(char, name, col)
                    activeParticleAuras[name] = particles
                end)
            end
        end
    end
end

local EmoteList = {
    "Dance1", "Dance2", "Dance3",
    "Floss", "Default Dance", "Laugh",
}
local currentEmoteId = nil
local currentEmoteTrack = nil
local emoteIdByName = {
    ["Dance1"] = "rbxassetid://507771019",
    ["Dance2"] = "rbxassetid://507776043",
    ["Dance3"] = "rbxassetid://507777826",
    ["Floss"] = "rbxassetid://5917459365",
    ["Default Dance"] = "rbxassetid://507771019",
    ["Laugh"] = "rbxassetid://507770818",
}

local function stopEmote()
    if currentEmoteTrack then
        pcall(function() currentEmoteTrack:Stop() end)
        currentEmoteTrack = nil
    end
end

local function playEmote(name)
    stopEmote()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = hum
    end
    local id = emoteIdByName[name]
    if not id then return end
    local anim = Instance.new("Animation")
    anim.AnimationId = id
    local ok, track = pcall(function() return animator:LoadAnimation(anim) end)
    if ok and track then
        track.Priority = Enum.AnimationPriority.Action4
        track.Looped = true
        track:Play()
        currentEmoteTrack = track
    end
end

local WatermarkGui = Instance.new("Frame")
WatermarkGui.Name = "FloppaWatermark"
WatermarkGui.BackgroundColor3 = rgb(20, 20, 25)
WatermarkGui.BackgroundTransparency = 0.3
WatermarkGui.BorderSizePixel = 0
WatermarkGui.Size = UDim2.new(0, 260, 0, 42)
WatermarkGui.Position = UDim2.new(0, 20, 0, 60)
WatermarkGui.Visible = false
WatermarkGui.ZIndex = 10
WatermarkGui.Parent = ScreenGui
local wmStroke = Instance.new("UIStroke")
wmStroke.Color = rgb(80, 80, 120)
wmStroke.Thickness = 1
wmStroke.Parent = WatermarkGui

local wmAvatar = Instance.new("ImageLabel")
wmAvatar.Size = UDim2.new(0, 32, 0, 32)
wmAvatar.Position = UDim2.new(0, 5, 0.5, -16)
wmAvatar.BackgroundColor3 = rgb(40, 40, 50)
wmAvatar.BorderSizePixel = 0
wmAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=60&h=60"
wmAvatar.ZIndex = 11
wmAvatar.Parent = WatermarkGui
local wmAvatarCorner = Instance.new("UICorner")
wmAvatarCorner.CornerRadius = UDim.new(1, 0)
wmAvatarCorner.Parent = wmAvatar

local wmTitle = Instance.new("TextLabel")
wmTitle.Size = UDim2.new(0, 130, 0, 18)
wmTitle.Position = UDim2.new(0, 42, 0, 4)
wmTitle.BackgroundTransparency = 1
wmTitle.Text = "Floppa Hub"
wmTitle.TextColor3 = rgb(200, 150, 255)
wmTitle.TextSize = 13
wmTitle.FontFace = TextFont
wmTitle.TextXAlignment = Enum.TextXAlignment.Left
wmTitle.ZIndex = 11
wmTitle.Parent = WatermarkGui

local wmStats = Instance.new("TextLabel")
wmStats.Size = UDim2.new(0, 215, 0, 14)
wmStats.Position = UDim2.new(0, 42, 0, 22)
wmStats.BackgroundTransparency = 1
wmStats.Text = "FPS: 60 | Ping: 0ms | 00:00:00"
wmStats.TextColor3 = rgb(200, 200, 200)
wmStats.TextSize = 11
wmStats.FontFace = TextFont
wmStats.TextXAlignment = Enum.TextXAlignment.Left
wmStats.ZIndex = 11
wmStats.Parent = WatermarkGui

local fpsCounter = 0
local fpsTimer = tick()
local currentFPS = 60

local Window = Library:CreateWindow({
    Title = "Floppa Hub",
    Center = true, AutoShow = true, Resizable = false,
    ShowCustomCursor = true, UnlockMouseWhileOpen = true,
    NotifySide = "Left", TabPadding = 8, MenuFadeTime = 0.2,
})

local Tabs = {
    Visuals = Window:AddTab("Visuals"),
    Combat  = Window:AddTab("Combat"),
    Movement= Window:AddTab("Movement"),
    World   = Window:AddTab("World"),
    Misc    = Window:AddTab("Misc"),
    Emotes  = Window:AddTab("Emotes"),
    ["UI Settings"] = Window:AddTab("UI Settings"),
}

local VMain   = Tabs.Visuals:AddLeftGroupbox("ESP")
local VText   = Tabs.Visuals:AddLeftGroupbox("Text / HP")
local VChams  = Tabs.Visuals:AddLeftGroupbox("Chams")
local VExtra  = Tabs.Visuals:AddRightGroupbox("Skeleton / Tracer")

VMain:AddToggle("esp_on", { Text = "Enable ESP", Default = Settings.Enabled, Callback = function(v) Settings.Enabled = v end })
VMain:AddToggle("esp_box", { Text = "Box", Default = Settings.Boxes, Callback = function(v) Settings.Boxes = v end })
VMain:AddLabel("Box Color 1"):AddColorPicker("c_box1", { Default = Settings.BoxColor1, Title = "Box Color 1",
    Callback = function(v) Settings.BoxColor1 = v end })
VMain:AddLabel("Box Color 2"):AddColorPicker("c_box2", { Default = Settings.BoxColor2, Title = "Box Color 2",
    Callback = function(v) Settings.BoxColor2 = v end })
VMain:AddDivider()
VMain:AddToggle("esp_boxfill", { Text = "Box Fill", Default = Settings.BoxFill, Callback = function(v) Settings.BoxFill = v end })
VMain:AddLabel("Fill Color 1"):AddColorPicker("c_fill1", { Default = Settings.BoxFillColor1, Title = "Fill Color 1",
    Callback = function(v) Settings.BoxFillColor1 = v end })
VMain:AddLabel("Fill Color 2"):AddColorPicker("c_fill2", { Default = Settings.BoxFillColor2, Title = "Fill Color 2",
    Callback = function(v) Settings.BoxFillColor2 = v end })
VMain:AddSlider("esp_filltransp", { Text = "Fill Transparency", Default = Settings.BoxFillTransp,
    Min = 0, Max = 1, Rounding = 2, Compact = false, Callback = function(v) Settings.BoxFillTransp = v end })
VMain:AddInput("boxfill_id", { Default = Settings.BoxFillImage, Text = "Fill Image ID",
    Placeholder = "rbxassetid://...", Finished = false, ClearTextOnFocus = false,
    Callback = function(v) Settings.BoxFillImage = v end })
VMain:AddDivider()
VMain:AddToggle("esp_name", { Text = "Name", Default = Settings.Name_Text, Callback = function(v) Settings.Name_Text = v end })
VMain:AddToggle("esp_dist", { Text = "Distance", Default = Settings.Distance_Text, Callback = function(v) Settings.Distance_Text = v end })
VMain:AddToggle("esp_wep", { Text = "Weapon", Default = Settings.Weapon_Text, Callback = function(v) Settings.Weapon_Text = v end })
VMain:AddToggle("esp_hp", { Text = "Health Bar", Default = Settings.Healthbar, Callback = function(v) Settings.Healthbar = v end })
VMain:AddDivider()
VMain:AddToggle("esp_teamcheck", { Text = "Team Check", Default = Settings.TeamCheck, Callback = function(v) Settings.TeamCheck = v end })
VMain:AddToggle("esp_vischeck", { Text = "Visible Check", Default = Settings.VisibleCheck, Callback = function(v) Settings.VisibleCheck = v end })
VMain:AddSlider("esp_maxdist", { Text = "Render Distance", Default = Settings.RenderDistance,
    Min = 100, Max = 5000, Rounding = 0, Compact = false, Callback = function(v) Settings.RenderDistance = v end })

VText:AddLabel("Name Color"):AddColorPicker("c_name", { Default = Settings.Name_Color, Title = "Name Color",
    Callback = function(v) Settings.Name_Color = v end })
VText:AddLabel("Distance Color"):AddColorPicker("c_dist", { Default = Settings.Distance_Color, Title = "Distance Color",
    Callback = function(v) Settings.Distance_Color = v end })
VText:AddLabel("Weapon Color"):AddColorPicker("c_wep", { Default = Settings.Weapon_Color, Title = "Weapon Color",
    Callback = function(v) Settings.Weapon_Color = v end })
VText:AddSlider("text_size", { Text = "Text Size", Default = Settings.TextSize,
    Min = 6, Max = 24, Rounding = 0, Compact = false, Callback = function(v) Settings.TextSize = v end })
VText:AddDivider()
VText:AddDropdown("hp_pos", { Values = {"Left","Right"}, Default = 1, Multi = false, Text = "HP Position",
    Callback = function(v) Settings.Healthbar_Pos = v end })
VText:AddSlider("hp_width", { Text = "HP Width", Default = Settings.Healthbar_Width,
    Min = 1, Max = 20, Rounding = 0, Compact = false, Callback = function(v) Settings.Healthbar_Width = v end })
VText:AddSlider("hp_offset", { Text = "HP Offset", Default = Settings.Healthbar_Offset,
    Min = 0, Max = 30, Rounding = 0, Compact = false, Callback = function(v) Settings.Healthbar_Offset = v end })
VText:AddToggle("hp_outline", { Text = "HP Outline", Default = Settings.Healthbar_Outline,
    Callback = function(v) Settings.Healthbar_Outline = v end })

VChams:AddToggle("chams_on", { Text = "Chams", Default = Settings.Chams, Callback = function(v) Settings.Chams = v end })
VChams:AddLabel("Chams Fill"):AddColorPicker("c_chamsfill", { Default = Settings.ChamsFill, Title = "Fill Color",
    Callback = function(v) Settings.ChamsFill = v end })
VChams:AddSlider("chams_filltransp", { Text = "Fill Transparency", Default = Settings.ChamsFillTransp,
    Min = 0, Max = 1, Rounding = 2, Compact = false, Callback = function(v) Settings.ChamsFillTransp = v end })
VChams:AddLabel("Chams Outline"):AddColorPicker("c_chamsoutline", { Default = Settings.ChamsOutline, Title = "Outline Color",
    Callback = function(v) Settings.ChamsOutline = v end })
VChams:AddSlider("chams_outlinetransp", { Text = "Outline Transparency", Default = Settings.ChamsOutlineTransp,
    Min = 0, Max = 1, Rounding = 2, Compact = false, Callback = function(v) Settings.ChamsOutlineTransp = v end })
VChams:AddToggle("chams_teamcheck", { Text = "Chams Team Check", Default = Settings.ChamsTeamCheck,
    Callback = function(v) Settings.ChamsTeamCheck = v end })

VExtra:AddToggle("esp_skel", { Text = "Skeleton", Default = Settings.Skeleton, Callback = function(v) Settings.Skeleton = v end })
    :AddColorPicker("c_skel", { Default = Settings.SkeletonColor, Title = "Skeleton Color",
        Callback = function(v) Settings.SkeletonColor = v end })
VExtra:AddToggle("esp_tracer", { Text = "Tracer", Default = Settings.Tracer, Callback = function(v) Settings.Tracer = v end })
    :AddColorPicker("c_tracer", { Default = Settings.TracerColor, Title = "Tracer Color",
        Callback = function(v) Settings.TracerColor = v end })
VExtra:AddDropdown("esp_tracerorigin", { Values = {"Bottom","Center","Mouse"}, Default = 1, Multi = false, Text = "Tracer Origin",
    Callback = function(v) Settings.TracerOrigin = v end })

local CAim = Tabs.Combat:AddLeftGroupbox("Aimbot")
local CFov = Tabs.Combat:AddRightGroupbox("FOV")
local CHit = Tabs.Combat:AddLeftGroupbox("Hitbox Expander")

CAim:AddToggle("aim_on", { Text = "Enable Aimbot", Default = false, Callback = function(v) Aimbot.Enabled = v end })
CAim:AddLabel("Aimbot Key (Hold)"):AddKeyPicker("aim_key", {
    Default = "E", Mode = "Hold", Text = "Aimbot Key", NoUI = false,
    Callback = function() end,
    ChangedCallback = function(newKey)
        local kc = newKey
        if typeof(kc) == "EnumItem" then Aimbot.Key = kc
        elseif typeof(kc) == "string" then
            local ok = pcall(function() Aimbot.Key = Enum.KeyCode[kc] end)
            if not ok then Aimbot.Key = kc end
        end
    end,
})
CAim:AddDropdown("aim_target", { Values = {"Head","HumanoidRootPart","UpperTorso"}, Default = 1, Multi = false, Text = "Lock Part",
    Callback = function(v) Aimbot.LockPart = v end })
CAim:AddSlider("aim_sens", { Text = "Sensitivity", Default = Aimbot.Sensitivity,
    Min = 0.01, Max = 1, Rounding = 2, Compact = false,
    Callback = function(v) Aimbot.Sensitivity = v end })
CAim:AddSlider("aim_maxdist", { Text = "Max Distance", Default = Aimbot.MaxDistance,
    Min = 50, Max = 3000, Rounding = 0, Compact = false,
    Callback = function(v) Aimbot.MaxDistance = v end })
CAim:AddToggle("aim_team", { Text = "Team Check", Default = Aimbot.TeamCheck, Callback = function(v) Aimbot.TeamCheck = v end })
CAim:AddToggle("aim_vis", { Text = "Visible Check", Default = Aimbot.VisCheck, Callback = function(v) Aimbot.VisCheck = v end })
CAim:AddDivider()
CAim:AddToggle("aim_pred", { Text = "Prediction", Default = Aimbot.Prediction,
    Callback = function(v) Aimbot.Prediction = v end })
CAim:AddSlider("aim_predamount", { Text = "Prediction Amount", Default = Aimbot.PredictionAmount,
    Min = 0, Max = 1, Rounding = 2, Compact = false,
    Callback = function(v) Aimbot.PredictionAmount = v end })

CFov:AddSlider("fov_size", { Text = "FOV Radius", Default = Aimbot.FOV,
    Min = 10, Max = 500, Rounding = 0, Compact = false,
    Callback = function(v) Aimbot.FOV = v end })
CFov:AddLabel("FOV Color"):AddColorPicker("c_fovcolor", { Default = Aimbot.FOVColor, Title = "FOV Color",
    Callback = function(v) Aimbot.FOVColor = v end })
CFov:AddLabel("FOV Locked Color"):AddColorPicker("c_fovlocked", { Default = Aimbot.FOVColorLocked, Title = "FOV Locked Color",
    Callback = function(v) Aimbot.FOVColorLocked = v end })
CFov:AddLabel("FOV Outline Color"):AddColorPicker("c_fovoutline", { Default = Aimbot.FOVOutlineColor, Title = "FOV Outline Color",
    Callback = function(v) Aimbot.FOVOutlineColor = v end })
CFov:AddToggle("fov_fill", { Text = "FOV Fill (Image)", Default = FOVFillSettings.Enabled,
    Callback = function(v) FOVFillSettings.Enabled = v end })
CFov:AddSlider("fov_filltransp", { Text = "Fill Transparency", Default = FOVFillSettings.Transp,
    Min = 0, Max = 1, Rounding = 2, Compact = false, Callback = function(v) FOVFillSettings.Transp = v end })
CFov:AddLabel("Fill Color"):AddColorPicker("c_fovfill", { Default = FOVFillSettings.Color, Title = "Fill Color",
    Callback = function(v) FOVFillSettings.Color = v end })

CHit:AddToggle("hb_on", { Text = "Enable Hitbox Expander", Default = Settings.Hitbox,
    Callback = function(v) Settings.Hitbox = v; updateAllHitboxes() end })
CHit:AddToggle("hb_teamcheck", { Text = "Team Check", Default = Settings.HitboxTeamCheck,
    Callback = function(v) Settings.HitboxTeamCheck = v; updateAllHitboxes() end })
CHit:AddSlider("hb_x", { Text = "Size X", Default = Settings.HitboxX, Min = 1, Max = 15, Rounding = 0, Compact = false,
    Callback = function(v) Settings.HitboxX = v; updateAllHitboxes() end })
CHit:AddSlider("hb_y", { Text = "Size Y", Default = Settings.HitboxY, Min = 1, Max = 15, Rounding = 0, Compact = false,
    Callback = function(v) Settings.HitboxY = v; updateAllHitboxes() end })
CHit:AddSlider("hb_z", { Text = "Size Z", Default = Settings.HitboxZ, Min = 1, Max = 15, Rounding = 0, Compact = false,
    Callback = function(v) Settings.HitboxZ = v; updateAllHitboxes() end })
CHit:AddSlider("hb_transp", { Text = "Transparency", Default = Settings.HitboxTransp, Min = 0, Max = 1, Rounding = 2, Compact = false,
    Callback = function(v) Settings.HitboxTransp = v; updateAllHitboxes() end })

local MSpeed = Tabs.Movement:AddLeftGroupbox("Speedhack")
local MFly   = Tabs.Movement:AddLeftGroupbox("Fly")
local MNo    = Tabs.Movement:AddLeftGroupbox("Noclip")
local MFree  = Tabs.Movement:AddRightGroupbox("Freecam")
local MZoom  = Tabs.Movement:AddRightGroupbox("Zoom / FOV")
local MTP    = Tabs.Movement:AddRightGroupbox("Teleport")
local MDesync= Tabs.Movement:AddRightGroupbox("Desync")

MSpeed:AddToggle("speed_on", { Text = "Enable Speedhack", Default = Settings.SpeedEnabled,
    Callback = function(v) Settings.SpeedEnabled = v; Movement:updateCFrameSpeed(); Movement:updateVelocitySpeed() end })
MSpeed:AddDropdown("speed_method", { Values = {"WalkSpeed","CFrame","Velocity"}, Default = 1, Multi = false, Text = "Method",
    Callback = function(v) Settings.SpeedMethod = v; Movement:updateCFrameSpeed(); Movement:updateVelocitySpeed() end })
MSpeed:AddSlider("speed_val", { Text = "Speed", Default = Settings.SpeedValue,
    Min = 16, Max = 500, Rounding = 0, Compact = false, Callback = function(v) Settings.SpeedValue = v end })
MSpeed:AddLabel("Speed Toggle Key"):AddKeyPicker("speed_key", {
    Default = "V", Mode = "Toggle", Text = "Speed Toggle Key", NoUI = false,
    Callback = function(v)
        Settings.SpeedEnabled = v
        Toggles.speed_on:SetValue(v)
        Movement:updateCFrameSpeed(); Movement:updateVelocitySpeed()
    end,
})

MFly:AddToggle("fly_on", { Text = "Enable Fly", Default = Settings.FlyEnabled,
    Callback = function(v)
        Settings.FlyEnabled = v
        if v then Movement:startFly() else Movement:stopFly() end
    end })
MFly:AddSlider("fly_speed", { Text = "Fly Speed", Default = Settings.FlySpeed,
    Min = 10, Max = 500, Rounding = 0, Compact = false, Callback = function(v) Settings.FlySpeed = v end })
MFly:AddLabel("Fly Toggle Key"):AddKeyPicker("fly_key", {
    Default = "F", Mode = "Toggle", Text = "Fly Toggle Key", NoUI = false,
    Callback = function(v)
        Settings.FlyEnabled = v
        Toggles.fly_on:SetValue(v)
        if v then Movement:startFly() else Movement:stopFly() end
    end,
})

MNo:AddToggle("noclip_on", { Text = "Enable Noclip", Default = Settings.NoclipEnabled,
    Callback = function(v) Settings.NoclipEnabled = v; Movement:updateNoclip() end })
MNo:AddLabel("Noclip Toggle Key"):AddKeyPicker("noclip_key", {
    Default = "N", Mode = "Toggle", Text = "Noclip Toggle Key", NoUI = false,
    Callback = function(v)
        Settings.NoclipEnabled = v
        Toggles.noclip_on:SetValue(v)
        Movement:updateNoclip()
    end,
})

MFree:AddToggle("freecam_on", { Text = "Enable Freecam", Default = Settings.Freecam,
    Callback = function(v)
        Settings.Freecam = v
        if v then Freecam:enable() else Freecam:disable() end
    end })
MFree:AddSlider("freecam_speed", { Text = "Speed", Default = Settings.FreecamSpeed,
    Min = 5, Max = 500, Rounding = 0, Compact = false, Callback = function(v) Settings.FreecamSpeed = v end })
MFree:AddSlider("freecam_smooth", { Text = "Smoothness", Default = Settings.FreecamSmooth,
    Min = 0.01, Max = 1, Rounding = 2, Compact = false, Callback = function(v) Settings.FreecamSmooth = v end })

MZoom:AddToggle("zoom_on", { Text = "Enable Zoom (Z)", Default = Settings.ZoomEnabled,
    Callback = function(v) Settings.ZoomEnabled = v end })
MZoom:AddSlider("zoom_value", { Text = "Zoom FOV", Default = Settings.ZoomValue,
    Min = 5, Max = 120, Rounding = 0, Compact = false,
    Callback = function(v)
        Settings.ZoomValue = v
        if Zoom.Active then updateZoom() end
    end })
MZoom:AddToggle("fov_on", { Text = "Enable FOV Changer", Default = Settings.FOVEnabled,
    Callback = function(v) Settings.FOVEnabled = v; updateFOV() end })
MZoom:AddSlider("fov_changer", { Text = "FOV Value", Default = Settings.FOVValue,
    Min = 30, Max = 150, Rounding = 0, Compact = false,
    Callback = function(v) Settings.FOVValue = v; updateFOV() end })

MTP:AddToggle("ctrlclicktp", { Text = "Ctrl + Click TP", Default = Settings.CtrlClickTP,
    Callback = function(v) Settings.CtrlClickTP = v end })
MTP:AddToggle("tptool", { Text = "TP Tool", Default = Settings.TPTool,
    Callback = function(v) Settings.TPTool = v end })
MTP:AddLabel("TP Tool Key"):AddKeyPicker("tptool_key", {
    Default = "T", Mode = "Press", Text = "TP Tool Key", NoUI = false,
    Callback = function()
        if Settings.TPTool then teleportToMouse() end
    end,
    ChangedCallback = function(newKey)
        local kc = newKey
        if typeof(kc) == "EnumItem" then Settings.TPToolKey = kc
        elseif typeof(kc) == "string" then
            local ok = pcall(function() Settings.TPToolKey = Enum.KeyCode[kc] end)
            if ok then Settings.TPToolKey = Enum.KeyCode[kc] end
        end
    end,
})

MDesync:AddToggle("desync_on", { Text = "Enable Desync", Default = Settings.Desync,
    Callback = function(v)
        Settings.Desync = v
        if v then Desync:enable() else Desync:disable() end
    end })
MDesync:AddToggle("desync_cube", { Text = "Show Desync Cube", Default = Settings.DesyncCube,
    Callback = function(v)
        Settings.DesyncCube = v
        updateDesyncCube()
    end })

local WLight = Tabs.World:AddLeftGroupbox("Lighting")
local WSky   = Tabs.World:AddRightGroupbox("Skybox")
local WAmb   = Tabs.World:AddRightGroupbox("Ambient / Fog")
local WWm    = Tabs.World:AddLeftGroupbox("Watermark")

WLight:AddToggle("fullbright", { Text = "FullBright", Default = Settings.FullBright,
    Callback = function(v) Settings.FullBright = v; applyFullBright() end })
WLight:AddToggle("remove_shadows", { Text = "Remove Shadows", Default = Settings.RemoveShadows,
    Callback = function(v) Settings.RemoveShadows = v; applyShadows() end })
WLight:AddToggle("shadow_color_on", { Text = "Custom Shadow Color", Default = Settings.ShadowColorEnabled,
    Callback = function(v) Settings.ShadowColorEnabled = v; applyShadowColor() end })
WLight:AddLabel("Shadow Color"):AddColorPicker("c_shadow", { Default = Settings.ShadowColor, Title = "Shadow Color",
    Callback = function(v) Settings.ShadowColor = v; applyShadowColor() end })
WLight:AddToggle("remove_grass", { Text = "Remove Grass", Default = Settings.RemoveGrass,
    Callback = function(v) Settings.RemoveGrass = v; applyRemoveGrass() end })

WSky:AddToggle("skybox_on", { Text = "Enable Skybox", Default = Settings.SkyboxEnabled,
    Callback = function(v) Settings.SkyboxEnabled = v; applySkybox() end })
WSky:AddDropdown("skybox_id", {
    Values = {"fairy story","city","night","chill"},
    Default = 1, Multi = false, Text = "Skybox",
    Callback = function(v)
        if v == "fairy story" then Settings.SkyboxId = "16573649975"
        elseif v == "city" then Settings.SkyboxId = "168949100"
        elseif v == "night" then Settings.SkyboxId = "143962526"
        elseif v == "chill" then Settings.SkyboxId = "3017752195" end
        if Settings.SkyboxEnabled then applySkybox() end
    end,
})

WAmb:AddToggle("nofog", { Text = "No Fog", Default = Settings.NoFog,
    Callback = function(v) Settings.NoFog = v; applyNoFog() end })
WAmb:AddToggle("ambient_on", { Text = "Custom Ambient", Default = Settings.AmbientEnabled,
    Callback = function(v) Settings.AmbientEnabled = v; applyAmbient() end })
WAmb:AddLabel("Ambient Color"):AddColorPicker("c_ambient", { Default = Settings.AmbientColor, Title = "Ambient Color",
    Callback = function(v) Settings.AmbientColor = v; applyAmbient() end })

WWm:AddToggle("watermark_on", { Text = "Enable Watermark", Default = Settings.Watermark,
    Callback = function(v)
        Settings.Watermark = v
        WatermarkGui.Visible = v
    end })

local MiscSelf = Tabs.Misc:AddLeftGroupbox("Self Chams")
local MiscCross = Tabs.Misc:AddLeftGroupbox("2D Crosshair")
local MiscJump = Tabs.Misc:AddLeftGroupbox("Jump Circles")
local MiscClassic = Tabs.Misc:AddRightGroupbox("Classic Aura")
local MiscParticle = Tabs.Misc:AddRightGroupbox("Particle Aura")
local MiscTrail = Tabs.Misc:AddRightGroupbox("Aura Trail")

MiscSelf:AddToggle("self_chams", { Text = "Self Chams (ForceField)", Default = Settings.SelfChams,
    Callback = function(v) Settings.SelfChams = v; updateSelfChams() end })
MiscSelf:AddLabel("Self Color"):AddColorPicker("c_self", { Default = Settings.SelfChamsColor, Title = "Self Chams Color",
    Callback = function(v) Settings.SelfChamsColor = v; updateSelfChams() end })
MiscSelf:AddSlider("self_transp", { Text = "Self Transparency", Default = Settings.SelfChamsTransp,
    Min = 0, Max = 1, Rounding = 2, Compact = false,
    Callback = function(v) Settings.SelfChamsTransp = v; updateSelfChams() end })

MiscCross:AddToggle("cross2d", { Text = "Enable 2D Crosshair", Default = Settings.Cross2D,
    Callback = function(v)
        Settings.Cross2D = v
        Cross2DGui.Visible = v
    end })
MiscCross:AddDropdown("cross2d_style", { Values = {"Cross","Dot","Circle","Square"}, Default = 1, Multi = false, Text = "Style",
    Callback = function(v) Settings.Cross2DStyle = v; create2DCrosshair() end })
MiscCross:AddLabel("Crosshair Color"):AddColorPicker("c_cross2d", { Default = Settings.Cross2DColor, Title = "Color",
    Callback = function(v)
        Settings.Cross2DColor = v
        Cross2DNameLabel.TextColor3 = v
        create2DCrosshair()
    end })
MiscCross:AddSlider("cross2d_size", { Text = "Size", Default = Settings.Cross2DSize,
    Min = 2, Max = 50, Rounding = 0, Compact = false,
    Callback = function(v) Settings.Cross2DSize = v; create2DCrosshair() end })
MiscCross:AddSlider("cross2d_thick", { Text = "Thickness", Default = Settings.Cross2DThickness,
    Min = 1, Max = 10, Rounding = 0, Compact = false,
    Callback = function(v) Settings.Cross2DThickness = v; create2DCrosshair() end })
MiscCross:AddToggle("cross2d_outline", { Text = "Outline", Default = Settings.Cross2DOutline,
    Callback = function(v) Settings.Cross2DOutline = v; create2DCrosshair() end })
MiscCross:AddLabel("Outline Color"):AddColorPicker("c_cross2d_outline", { Default = Settings.Cross2DOutlineColor, Title = "Outline Color",
    Callback = function(v)
        Settings.Cross2DOutlineColor = v
        Cross2DNameLabel.TextStrokeColor3 = v
        create2DCrosshair()
    end })
MiscCross:AddToggle("cross2d_spin", { Text = "Spin", Default = Settings.Cross2DSpin,
    Callback = function(v) Settings.Cross2DSpin = v end })
MiscCross:AddSlider("cross2d_spinspeed", { Text = "Spin Speed", Default = Settings.Cross2DSpinSpeed,
    Min = 10, Max = 720, Rounding = 0, Compact = false, Callback = function(v) Settings.Cross2DSpinSpeed = v end })
MiscCross:AddToggle("cross2d_showname", { Text = "Show Script Name", Default = Settings.Cross2DShowName,
    Callback = function(v) Settings.Cross2DShowName = v; Cross2DNameLabel.Visible = v end })
MiscCross:AddInput("cross2d_name", { Default = Settings.Cross2DName, Text = "Script Name",
    Placeholder = "Script name...", Finished = false, ClearTextOnFocus = false,
    Callback = function(v) Settings.Cross2DName = v; Cross2DNameLabel.Text = v end })

MiscJump:AddToggle("jumpcircles", { Text = "Jump Circles", Default = Settings.JumpCircles,
    Callback = function(v) Settings.JumpCircles = v end })
MiscJump:AddLabel("Jump Circle Color"):AddColorPicker("c_jumpc", { Default = Settings.JumpCircleColor, Title = "Jump Circle Color",
    Callback = function(v) Settings.JumpCircleColor = v end })
MiscJump:AddSlider("jumpc_size", { Text = "Jump Circle Size", Default = Settings.JumpCircleSize,
    Min = 0.5, Max = 15, Rounding = 1, Compact = false, Callback = function(v) Settings.JumpCircleSize = v end })
MiscJump:AddSlider("jumpc_lifetime", { Text = "Jump Circle Lifetime", Default = Settings.JumpCircleLifetime,
    Min = 0.1, Max = 5, Rounding = 1, Compact = false, Callback = function(v) Settings.JumpCircleLifetime = v end })
MiscJump:AddSlider("jumpc_transp", { Text = "Jump Circle Transparency", Default = Settings.JumpCircleTransp,
    Min = 0, Max = 1, Rounding = 2, Compact = false, Callback = function(v) Settings.JumpCircleTransp = v end })
MiscJump:AddSlider("jumpc_sides", { Text = "Jump Circle Sides", Default = Settings.JumpCircleSides,
    Min = 8, Max = 100, Rounding = 0, Compact = false,
    Callback = function(v)
        Settings.JumpCircleSides = v
        for _, c in ipairs(jumpCircles) do
            for _, s in ipairs(c.segments) do pcall(function() s:Remove() end) end
        end
        jumpCircles = {}
    end })

MiscClassic:AddToggle("ClassicAuraEnabled", {
    Text = "Enable Classic Aura", Default = false,
    Callback = function() ClassicAura_RefreshAll() end,
})
MiscClassic:AddDropdown("ClassicAuraDropdown", {
    Values = AuraModels, Default = {}, Multi = true, Text = "Select Auras",
    Callback = function() ClassicAura_RefreshAll() end,
})

MiscParticle:AddToggle("ParticleAuraEnabled", {
    Text = "Enable Particle Aura", Default = false,
    Callback = function() ParticleAura_RefreshAll() end,
})
MiscParticle:AddLabel("Aura Color"):AddColorPicker("ParticleAuraColor", {
    Default = rgb(133, 220, 255), Title = "Particle Aura Color",
    Callback = function() ParticleAura_RefreshAll() end,
})
MiscParticle:AddDivider()
MiscParticle:AddDropdown("ParticleAuraDropdown", {
    Values = PARTICLE_AURA_NAMES, Default = {}, Multi = true, Text = "Select Auras",
    Callback = function() ParticleAura_RefreshAll() end,
})

MiscTrail:AddToggle("auratrail_on", { Text = "Enable Trail", Default = AuraTrailSettings.Enabled,
    Callback = function(v) AuraTrailSettings.Enabled = v; refreshAuraTrail() end })
MiscTrail:AddLabel("Color 1"):AddColorPicker("c_auratrail1", { Default = AuraTrailSettings.Color1, Title = "Trail Color 1",
    Callback = function(v) AuraTrailSettings.Color1 = v; refreshAuraTrail() end })
MiscTrail:AddLabel("Color 2"):AddColorPicker("c_auratrail2", { Default = AuraTrailSettings.Color2, Title = "Trail Color 2",
    Callback = function(v) AuraTrailSettings.Color2 = v; refreshAuraTrail() end })
MiscTrail:AddSlider("auratrail_life", { Text = "Lifetime", Default = AuraTrailSettings.Lifetime,
    Min = 0.1, Max = 3, Rounding = 1, Compact = false,
    Callback = function(v) AuraTrailSettings.Lifetime = v; refreshAuraTrail() end })
MiscTrail:AddSlider("auratrail_transp", { Text = "Start Transparency", Default = AuraTrailSettings.Transp1,
    Min = 0, Max = 1, Rounding = 2, Compact = false,
    Callback = function(v) AuraTrailSettings.Transp1 = v; refreshAuraTrail() end })

local EmoteBox = Tabs.Emotes:AddLeftGroupbox("Emotes")
EmoteBox:AddDropdown("emote_select", { Values = EmoteList, Default = 1, Multi = false, Text = "Select Emote",
    Callback = function(v) currentEmoteId = v end })
EmoteBox:AddButton("Play", function()
    if currentEmoteId then playEmote(currentEmoteId) end
end)
EmoteBox:AddButton("Stop", function() stopEmote() end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")
MenuGroup:AddToggle("KeybindMenuOpen", { Default = Library.KeybindFrame.Visible, Text = "Open Keybind Menu",
    Callback = function(v) Library.KeybindFrame.Visible = v end })
MenuGroup:AddToggle("ShowCustomCursor", { Text = "Custom Cursor", Default = true,
    Callback = function(v) Library.ShowCustomCursor = v end })
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function() Library:Unload() end)

local KeybindBox = Tabs["UI Settings"]:AddRightGroupbox("Keybinds")
KeybindBox:AddLabel("Speed: V  (Toggle)")
KeybindBox:AddLabel("Fly: F  (Toggle)")
KeybindBox:AddLabel("Noclip: N  (Toggle)")
KeybindBox:AddLabel("Zoom: Z  (Hold)")
KeybindBox:AddLabel("TP Tool: T  (Press)")
KeybindBox:AddLabel("Aimbot: E  (Hold)")
KeybindBox:AddLabel("Freecam: Enabled via toggle")
KeybindBox:AddLabel("Freecam Move: I/J/K/L")
KeybindBox:AddLabel("Freecam Up/Down: Space / LeftCtrl")
KeybindBox:AddLabel("Freecam Speed Boost: LeftShift")
KeybindBox:AddLabel("Menu: RightShift")

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("FloppaHub")
SaveManager:SetFolder("FloppaHub/universal")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

local function onCharacter(player)
    if player == LocalPlayer then return end
    if not Esp.Players[player.Name] then Esp.CreateObject(player) end
    if Esp.Players[player.Name] then Esp.Players[player.Name].RefreshDescendants() end
    task.wait(0.2)
    applyHitbox(player)
end

local function onPlayerAdded(player)
    if player == LocalPlayer then return end
    Esp.CreateObject(player)
    player.CharacterAdded:Connect(function() onCharacter(player) end)
    if player.Character then onCharacter(player) end
end

local function onPlayerRemoving(player)
    if Esp.Players[player.Name] then Esp.Players[player.Name].Destroy() end
    originalSizes[player] = nil
    visibleCache[player.Name] = nil
    Aimbot.Locked = nil
end

for _, p in ipairs(Players:GetPlayers()) do onPlayerAdded(p) end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if Settings.SelfChams then selfChamsApply() end
    if AuraTrailSettings.Enabled then refreshAuraTrail() end
    if Toggles.ClassicAuraEnabled and Toggles.ClassicAuraEnabled.Value then
        task.wait(0.5)
        ClassicAura_RefreshAll()
    end
    if Toggles.ParticleAuraEnabled and Toggles.ParticleAuraEnabled.Value then
        task.wait(0.5)
        ParticleAura_RefreshAll()
    end
    if Settings.FlyEnabled then Movement:startFly() end
    if Settings.Desync then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then Desync.LastCF = hrp.CFrame end
    end
end)

Esp.Loop = RunService:BindToRenderStep("FloppaHub_ESP", 400, Esp.Update)

RunService.RenderStepped:Connect(function(dt)
    updateAllHitboxes()
    updateAimbot()
    updateJumpCircles()
    Movement:updateWalkSpeed()
    Movement:updateNoclip()
    updateSelfChams()
    updateDesyncCube()

    local mousePos = InputService:GetMouseLocation()

    Cross2DGui.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
    if Settings.Cross2D then
        Cross2DGui.Visible = true
        Cross2DNameLabel.Visible = Settings.Cross2DShowName
        Cross2DNameLabel.TextColor3 = Settings.Cross2DColor
        Cross2DNameLabel.TextStrokeColor3 = Settings.Cross2DOutlineColor
        Cross2DNameLabel.FontFace = TextFont

        if Settings.Cross2DSpin and (Settings.Cross2DStyle == "Cross" or Settings.Cross2DStyle == "Square") then
            Settings.Cross2DRotation = (Settings.Cross2DRotation + Settings.Cross2DSpinSpeed * dt) % 360
            Cross2DContainer.Rotation = Settings.Cross2DRotation
        else
            Cross2DContainer.Rotation = 0
        end
    else
        Cross2DGui.Visible = false
    end

    if FOVFillSettings.Enabled and Aimbot.Enabled then
        local d = Aimbot.FOV * 2
        fovFillGui.Size = dim_offset(d, d)
        fovFillGui.Position = dim_offset(mousePos.X - Aimbot.FOV, mousePos.Y - Aimbot.FOV)
        fovFillGui.ImageTransparency = FOVFillSettings.Transp
        fovFillGui.ImageColor3 = FOVFillSettings.Color
        fovFillGui.Visible = true
    else
        fovFillGui.Visible = false
    end

    if Settings.Watermark then
        fpsCounter = fpsCounter + 1
        if tick() - fpsTimer >= 1 then
            currentFPS = fpsCounter
            fpsCounter = 0
            fpsTimer = tick()
        end
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        local timeStr = os.date("%H:%M:%S")
        wmStats.Text = string.format("FPS: %d | Ping: %dms | %s", currentFPS, ping, timeStr)
    end
end)

Library:OnUnload(function()
    if Esp.Loop then
        pcall(function() RunService:UnbindFromRenderStep("FloppaHub_ESP") end)
        Esp.Loop = nil
    end
    for _, Data in pairs(Esp.Players) do pcall(function() Data.Destroy() end) end
    for _, c in pairs(Esp.Connections) do pcall(function() c:Disconnect() end) end
    pcall(function() ScreenGui:Destroy() end)
    for _, p in ipairs(Players:GetPlayers()) do resetHitbox(p) end
    pcall(function() Aimbot.Tracer:Remove() end)
    pcall(function() Aimbot.FOVCircle:Remove() end)
    pcall(function() Aimbot.FOVOutline:Remove() end)
    pcall(function() fovFillGui:Destroy() end)
    for _, c in ipairs(jumpCircles) do
        for _, s in ipairs(c.segments) do pcall(function() s:Remove() end) end
    end
    selfChamsRevert()
    Movement:stopFly()
    Freecam:disable()
    Desync:disable()
    Camera.FieldOfView = OrigFOV
    for _, a in ipairs(AuraModels) do pcall(function() ClassicAura_DisableOne(a) end) end
    for _, a in ipairs(PARTICLE_AURA_NAMES) do pcall(function() ParticleAura_DisableOne(a) end) end
    if auraTrail then pcall(function() auraTrail:Destroy() end) end
    stopEmote()
    Library.Unloaded = true
end)
