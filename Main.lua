local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Roams", "Ocean")

local Info = Window:NewTab("INFO")
local Tab1 = Window:NewTab("Combat🟢")
local Tab4 = Window:NewTab("Rage🟢")
local Tab2 = Window:NewTab("ESP🟢")
local Tab3 = Window:NewTab("Exploits🟠")

local INFOSECTION = Info:NewSection("INFO")

local Section4 = Tab1:NewSection("Aimbot(Coming Soon)")
local Section1 = Tab1:NewSection("Gun Mods🟢")
local Section2 = Tab2:NewSection("ESP🟢")
local Section3 = Tab3:NewSection("Exploits🟠")
local Section5 = Tab4:NewSection("Silent Aim🟢")

INFOSECTION:NewLabel("STATUS⬇️")
INFOSECTION:NewLabel("🟢 - Undetected")
INFOSECTION:NewLabel("🟠 - May Be Detected")
INFOSECTION:NewLabel("🔴 - Detected")

INFOSECTION:NewKeybind("Toggle UI", "", Enum.KeyCode.End, function()
	Library:ToggleUI()
end)




Section1:NewToggle("Recoil", "ToggleInfo", function(state)
    _G.Recoil = state
    while _G.Recoil == true do
        wait(.1)
        for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if v.ClassName == "Tool" then
                local gun = require(v.ConfigMods.CConfig)
                print(v)
                gun.gunRecoilMin = 0
                gun.gunRecoilMax = 0
                gun.AimGunRecoilMin = 0
                gun.AimGunRecoilMax = 0
                gun.KickbackMin = 0
                gun.KickbackMax = 0
                gun.AimKickbackMin = 0
                gun.AimKickbackMax = 0
                gun.SideKickMin = 0
                gun.SideKickMax = 0
                gun.AimSideKickMin = 0
                gun.AimSideKickMax = 0
                wait(.1)
            end
        end
    end
end)

Section1:NewToggle("No Spread", "ToggleInfo", function(state)
    _G.Recoil1 = state
    while _G.Recoil1 == true do
        wait(.1)
        for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if v.ClassName == "Tool" then
                local gun = require(v.ConfigMods.CConfig)
                print(v)
                gun.BulletSpread = 0
                wait(.1)
            end
        end
    end
end)

Section1:NewToggle("No Drop Off", "ToggleInfo", function(state)
    _G.Recoil2 = state
    while _G.Recoil2 == true do
        wait(.1)
        for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if v.ClassName == "Tool" then
                local gun = require(v.ConfigMods.CConfig)
                print(v)
                gun.BulletSpeed = 99999
                wait(.1)
            end
        end
    end
end)

Section3:NewToggle("High Jump(Be Carefull)", "", function(state)
    _G.Recoil10 = state
    if _G.Recoil10 then
        game.Workspace.Gravity = 10
    else
        game.Workspace.Gravity = 196.1999969482422
    end
end)

Section5:NewToggle("Silent Aim", "", function(state)
    SilentAimSettings.Enabled = not SilentAimSettings.Enabled
end)
Section5:NewDropdown("Target Part", "", {"Head", "Torso", "HumanoidRootPart"}, function(currentOption)
    SilentAimSettings.TargetPart = currentOption
end)

Section5:NewSlider("FOV Radius", "SliderInfo", 500, 20, function(s)
    SilentAimSettings.FOVRadius = s
end)
Section5:NewColorPicker("FOV Color", "", Color3.fromRGB(255,255,255), function(color)
   SilentAimSettings.FOVColor = color
    -- Second argument is the default color
end)
Section5:NewSlider("FOV Thickness", "SliderInfo", 10, 1, function(s)
    SilentAimSettings.FOVThickness = s
end)
Section5:NewSlider("FOV Sides", "SliderInfo", 200, 1, function(s)
    SilentAimSettings.FOVSides = s
end)







local function API_Check()
    if Drawing == nil then
        return "No"
    else
        return "Yes"
    end
end

local Find_Required = API_Check()

if Find_Required == "No" then
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "Exunys Developer";
        Text = "ESP script could not be loaded because your exploit is unsupported.";
        Duration = math.huge;
        Button1 = "OK"
    })

    return
end




getgenv().SilentAimSettings = {
   Enabled = false,
   
   VisibleCheck = true,
   TargetPart = "Torso",
   
   FOVRadius = 130,
   FOVVisible = true,

   FOVColor = Color3.fromRGB(255,255,255),
   FOVThickness = 1,
   FOVSides = 100,
}
print(SilentAimSettings.Enabled)
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local GetChildren = game.GetChildren
local GetPlayers = Players.GetPlayers
local WorldToScreen = Camera.WorldToScreenPoint
local WorldToViewportPoint = Camera.WorldToViewportPoint
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget
local FindFirstChild = game.FindFirstChild
local RenderStepped = RunService.RenderStepped
local GuiInset = GuiService.GetGuiInset
local GetMouseLocation = UserInputService.GetMouseLocation

local resume = coroutine.resume
local create = coroutine.create

local ValidTargetParts = {"Head", "HumanoidRootPart"}
local PredictionAmount = 0
local Aiming = false

local fov_circle = Drawing.new("Circle")
fov_circle.Thickness = 1
fov_circle.NumSides = 100
fov_circle.Radius = 180
fov_circle.Filled = false
fov_circle.Visible = false
fov_circle.ZIndex = 999
fov_circle.Transparency = 1
fov_circle.Color = SilentAimSettings.FOVColor

local ExpectedArguments = {
   FindPartOnRayWithIgnoreList = {
       ArgCountRequired = 3,
       Args = {
           "Instance", "Ray", "table", "boolean", "boolean"
       }
   },
   FindPartOnRayWithWhitelist = {
       ArgCountRequired = 3,
       Args = {
           "Instance", "Ray", "table", "boolean"
       }
   },
   FindPartOnRay = {
       ArgCountRequired = 2,
       Args = {
           "Instance", "Ray", "Instance", "boolean", "boolean"
       }
   },
   Raycast = {
       ArgCountRequired = 3,
       Args = {
           "Instance", "Vector3", "Vector3", "RaycastParams"
       }
   }
}

local function getPositionOnScreen(Vector)
   local Vec3, OnScreen = WorldToScreen(Camera, Vector)
   return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

local function ValidateArguments(Args, RayMethod)
   local Matches = 0
   if #Args < RayMethod.ArgCountRequired then
       return false
   end
   for Pos, Argument in next, Args do
       if typeof(Argument) == RayMethod.Args[Pos] then
           Matches = Matches + 1
       end
   end
   return Matches >= RayMethod.ArgCountRequired
end

local function getDirection(Origin, Position)
   return (Position - Origin).Unit * 1000
end

local function getMousePosition()
   return GetMouseLocation(UserInputService)
end

local function IsPlayerVisible(Player)
   local PlayerCharacter = Player.Character
   local LocalPlayerCharacter = LocalPlayer.Character
   
   if not (PlayerCharacter or LocalPlayerCharacter) then return end
   
   local PlayerRoot = FindFirstChild(PlayerCharacter, SilentAimSettings.TargetPart) or FindFirstChild(PlayerCharacter, "HumanoidRootPart")
   
   if not PlayerRoot then return end
   
   local CastPoints, IgnoreList = {PlayerRoot.Position, LocalPlayerCharacter, PlayerCharacter}, {LocalPlayerCharacter, PlayerCharacter}
   local ObscuringObjects = #GetPartsObscuringTarget(Camera, CastPoints, IgnoreList)
   
   return ((ObscuringObjects == 0 and true) or (ObscuringObjects > 0 and false))
end

local function getClosestPlayer()
   local Closest
   local DistanceToMouse
   for _, Player in next, GetPlayers(Players) do
       if Player == LocalPlayer then continue end

       local Character = Player.Character
       if not Character then continue end
       
       if SilentAimSettings.VisibleCheck and not IsPlayerVisible(Player) then continue end

       local HumanoidRootPart = FindFirstChild(Character, "HumanoidRootPart")
       local Humanoid = FindFirstChild(Character, "Humanoid")
       if not HumanoidRootPart or not Humanoid or Humanoid and Humanoid.Health <= 0 then continue end

       local ScreenPosition, OnScreen = getPositionOnScreen(HumanoidRootPart.Position)
       if not OnScreen then continue end

       local Distance = (getMousePosition() - ScreenPosition).Magnitude
       if Distance <= (DistanceToMouse or SilentAimSettings.FOVRadius or 2000) then
           Closest = (Character[SilentAimSettings.TargetPart])
           DistanceToMouse = Distance
       end
   end
   return Closest
end

resume(create(function()
   RenderStepped:Connect(function()
       fov_circle.Visible = SilentAimSettings.Enabled
       fov_circle.Color = SilentAimSettings.FOVColor
       fov_circle.Radius = SilentAimSettings.FOVRadius
       fov_circle.Position = getMousePosition()
       fov_circle.Thickness = SilentAimSettings.FOVThickness
       fov_circle.NumSides = SilentAimSettings.FOVSides
   end)
end))

local aim_c_1
aim_c_1 = UserInputService.InputBegan:Connect(function(input)
   if input.UserInputType == Enum.UserInputType.MouseButton1 and SilentAimSettings.Enabled == true then
       Aiming = true
   end
end)

local aim_c_2
aim_c_2 = UserInputService.InputEnded:Connect(function(input)
   if input.UserInputType == Enum.UserInputType.MouseButton1 then
       Aiming = false
   end
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
   local Method = getnamecallmethod()
   local Arguments = {...}
   local self = Arguments[1]
   if Aiming and self == workspace and not checkcaller() then
       if Method == "FindPartOnRayWithIgnoreList" then
           if ValidateArguments(Arguments, ExpectedArguments.FindPartOnRayWithIgnoreList) then
               local A_Ray = Arguments[2]

               local HitPart = getClosestPlayer()
               if HitPart then
                   local Origin = A_Ray.Origin
                   local Direction = getDirection(Origin, HitPart.Position)
                   Arguments[2] = Ray.new(Origin, Direction)

                   return oldNamecall(unpack(Arguments))
               end
           end
       end
   end
   return oldNamecall(...)
end))


local ESP = loadstring(game:HttpGet("https://kiriot22.com/releases/ESP.lua"))()
ESP:Toggle(true)
ESP.Players = false
ESP.Traces = false
ESP.Names = false
ESP.Boxes = false
ESP.NPCs = false
ESP.Items = false
ESP.Enemies = false
Section2:NewToggle("ESP Master Switch", "ToggleInfo", function(state)
    ESP.Players = state
end)

Section2:NewToggle("ESP Box", "ToggleInfo", function(state)
    ESP.Boxes = state
end)

Section2:NewToggle("ESP Info", "ToggleInfo", function(state)
    ESP.Names = state
end)



Section2:NewColorPicker("ESP Color", "", Color3.fromRGB(255,255,255), function(color)
    while wait() do
        ESP.Color = color
    end
end)

ESPInfo:Cheat("Label", "Items show up as 'Purple'")
ESPInfo:Cheat("Label", "Players show up as 'White'")
ESPInfo:Cheat("Label", "NPCs show up as 'Lime'")
ESPInfo:Cheat("Label", "")
ESPInfo:Cheat("Label", "Normal Enemies show up as 'Red'")
ESPInfo:Cheat("Label", "Magical Enemies show up as 'Cyan'")
ESPInfo:Cheat("Label", "Legendary Enemies show up as 'Yellow'")
ESPInfo:Cheat("Label", "")
ESPInfo:Cheat("Label", "Entities over 700 studs away don't show up")

-- Item ESP Info
ItemINFO:Cheat("Label", "Items out of range don't appear on list")

-- Don't mind this ugly shit
while true do
    -- Get Enemies
    local shit = workspace.NPCS:GetChildren()
    for i = 1, #shit do local v = shit[i]
        local model = v:FindFirstChildOfClass("Model")
        if model and v:FindFirstChild("Status") and model:FindFirstChild("HumanoidRootPart") and not model:FindFirstChild("EGG") and v.Status:FindFirstChild("Dead") and v.Status.Dead.Value == false then
            -- Add ESP
            if not v:FindFirstChild("ChatInfo") then
                local s = v.Status
                ESP:Add(model.HumanoidRootPart,{
                    Name = v.Name,
                    Color = BrickColor.new(s:FindFirstChild("Legendary") and s.Legendary.Value and "Bright yellow" or s:FindFirstChild("Magical") and s.Magical.Value and "Cyan" or "Really red").Color,
                    IsEnabled = "Enemies"
                })
                Instance.new("Part",model).Name = "EGG"
            elseif v:FindFirstChild("ChatInfo") and ESP.NPCs then
                ESP:Add(v,{
                    Name = v.Name,
                    Color = BrickColor.new("Lime green").Color,
                    IsEnabled = "NPCs"
                })
                Instance.new("Part",model).Name = "EGG"
            end
        end
    end
    wait()
    -- Get Items
    local shit = workspace.Items:GetChildren()
    table.sort(shit, function(a,b)
        return a.Name < b.Name
    end)
    for i = 1, #shit do local v = shit[i]
        if v.PrimaryPart and not v:FindFirstChild("EGG") then
            -- Add ESP
            ESP:Add(v, {
                Name = v.Name,
                Color = BrickColor.new("Magenta").Color,
                IsEnabled = v.Name
            })
            ESP[v.Name] = false
            ItemESP:Cheat("Checkbox", v.Name, function(State)
                ESP[v.Name] = State
            end)
            -- Remember
            Instance.new("Part",v).Name = "EGG"
        end
    end
end

