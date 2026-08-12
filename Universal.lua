--[[
    NC HUB | UNIVERSAL EDITION
    VISUAL: AURORA CORE
    UI: Starlight Interface Suite

    Starlight Interface Suite by Nebula Softworks
    Used privately by NC HUB.
]]

-- ==========================================
-- 0. SERVICIOS Y VARIABLES
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local TiempoInicio = os.time()

-- ==========================================
-- 1. CARGA DE STARLIGHT
-- ==========================================
local Starlight = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Nebula-Softworks/Starlight-Interface-Suite/master/Source.lua"
))()

pcall(function()
    Starlight:SetTheme("Nebula")
end)

local Window = Starlight:CreateWindow({
    Name = "NC HUB",
    Subtitle = "By hidjcjgg",

    LoadingEnabled = false,
    BuildWarnings = false,
    InterfaceAdvertisingPrompts = false,
    NotifyOnCallbackError = true,

    ConfigurationSettings = {
        Enabled = false,
        RootFolder = nil,
        FolderName = nil
    },

    DefaultSize = UDim2.fromOffset(620, 430),

    KeySystem = {
        Enabled = false
    },

    Discord = {
        Enabled = false
    }
})

-- ==========================================
-- 2. FUNCIONES BASE
-- ==========================================
local function GetCharacter()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function GetHumanoid()
    local Character = GetCharacter()
    return Character:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local Character = GetCharacter()
    return Character:FindFirstChild("HumanoidRootPart")
end

local function FormatTime()
    local Segundos = os.time() - TiempoInicio
    local Horas = math.floor(Segundos / 3600)
    local Minutos = math.floor(Segundos / 60) % 60
    local SegundosRestantes = Segundos % 60

    return string.format("%dh %dm %ds", Horas, Minutos, SegundosRestantes)
end

-- ==========================================
-- 3. VARIABLES DE FUNCIONES
-- ==========================================
local InfiniteJump = false
local Noclip = false
local ESP = false
local Fly = false
local FlySpeed = 80

local CollisionState = {}

-- ==========================================
-- 4. SECCIONES Y TABS
-- ==========================================
local CoreSection = Window:CreateTabSection("NC CORE")
local MovementSection = Window:CreateTabSection("MOVEMENT")
local VisualSection = Window:CreateTabSection("VISUALS")
local SystemSection = Window:CreateTabSection("TOOLS")

local HomeTab = CoreSection:CreateTab({
    Name = "Home",
    Columns = 2
}, "nc_home")

local MoveTab = MovementSection:CreateTab({
    Name = "Movement",
    Columns = 2
}, "nc_movement")

local FlyTab = MovementSection:CreateTab({
    Name = "Fly",
    Columns = 2
}, "nc_fly")

local VisualTab = VisualSection:CreateTab({
    Name = "Visuals",
    Columns = 2
}, "nc_visuals")

local ToolsTab = SystemSection:CreateTab({
    Name = "Tools",
    Columns = 2
}, "nc_tools")

-- ==========================================
-- 5. HOME | DASHBOARD AURORA
-- ==========================================
local IdentityBox = HomeTab:CreateGroupbox({
    Name = "IDENTIDAD DIGITAL",
    Column = 1,
    Style = 2
}, "identity")

IdentityBox:CreateParagraph({
    Name = LP.DisplayName,
    Content = "@" .. LP.Name .. "\nCuenta creada hace " .. LP.AccountAge .. " días."
}, "profile")

IdentityBox:CreateParagraph({
    Name = "NC HUB",
    Content = "Aurora Core Edition\nSistema modular activo."
}, "hub_status")

local SessionBox = HomeTab:CreateGroupbox({
    Name = "MONITOR DE SESIÓN",
    Column = 2,
    Style = 2
}, "session")

local SessionLabel = SessionBox:CreateParagraph({
    Name = "TIEMPO ACTIVO",
    Content = "Calculando..."
}, "session_time")

SessionBox:CreateParagraph({
    Name = "ESTADO",
    Content = "NC HUB operativo.\nListo para cualquier juego."
}, "system_state")

HomeTab:CreateGroupbox({
    Name = "BIENVENIDO",
    Column = 1,
    Style = 1
}, "welcome"):CreateParagraph({
    Name = "HECHO PARA TI",
    Content = "Este es tu hub universal.\nLos módulos de juegos se cargan por separado desde el loader."
}, "welcome_text")

-- ==========================================
-- 6. MOVEMENT
-- ==========================================
local MobilityBox = MoveTab:CreateGroupbox({
    Name = "MOVILIDAD",
    Column = 1,
    Style = 2
}, "mobility")

MobilityBox:CreateSlider({
    Name = "WalkSpeed",
    CurrentValue = 16,
    Range = {16, 256},
    Increment = 1,
    Suffix = " studs",
    Callback = function(Value)
        local Humanoid = GetHumanoid()

        if Humanoid then
            Humanoid.WalkSpeed = Value
        end
    end
}, "walkspeed")

MobilityBox:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        InfiniteJump = Value
    end
}, "infinite_jump")

local NoclipBox = MoveTab:CreateGroupbox({
    Name = "COLISIÓN",
    Column = 2,
    Style = 2
}, "collision")

NoclipBox:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        Noclip = Value
    end
}, "noclip")

NoclipBox:CreateParagraph({
    Name = "INFO",
    Content = "Al apagar Noclip, el hub restaura la colisión original de tu personaje."
}, "noclip_info")

-- ==========================================
-- 7. FLY
-- ==========================================
local FlyBox = FlyTab:CreateGroupbox({
    Name = "VUELO AURORA",
    Column = 1,
    Style = 2
}, "fly_main")

FlyBox:CreateSlider({
    Name = "Fly Speed",
    CurrentValue = 80,
    Range = {10, 400},
    Increment = 5,
    Suffix = " studs",
    Callback = function(Value)
        FlySpeed = Value
    end
}, "fly_speed")

FlyBox:CreateToggle({
    Name = "Activar Fly",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        Fly = Value

        local Root = GetRoot()
        local Humanoid = GetHumanoid()

        if not Root or not Humanoid then
            return
        end

        if Fly then
            local OldForce = Root:FindFirstChild("NC_FlyForce")
            local OldGyro = Root:FindFirstChild("NC_FlyGyro")

            if OldForce then OldForce:Destroy() end
            if OldGyro then OldGyro:Destroy() end

            Humanoid.PlatformStand = true

            local Force = Instance.new("BodyVelocity")
            Force.Name = "NC_FlyForce"
            Force.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            Force.Velocity = Vector3.zero
            Force.Parent = Root

            local Gyro = Instance.new("BodyGyro")
            Gyro.Name = "NC_FlyGyro"
            Gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            Gyro.P = 9000
            Gyro.Parent = Root

            task.spawn(function()
                while Fly and Root.Parent and Humanoid.Parent do
                    local Camera = workspace.CurrentCamera
                    local Direction = Humanoid.MoveDirection

                    Gyro.CFrame = Camera.CFrame

                    if Direction.Magnitude > 0 then
                        local FlatLook = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
                        local FlatRight = Vector3.new(Camera.CFrame.RightVector.X, 0, Camera.CFrame.RightVector.Z)

                        if FlatLook.Magnitude > 0 and FlatRight.Magnitude > 0 then
                            local Move = (FlatLook.Unit * Direction:Dot(FlatLook.Unit))
                                + (FlatRight.Unit * Direction:Dot(FlatRight.Unit))

                            Force.Velocity = Move * FlySpeed
                        end
                    else
                        Force.Velocity = Vector3.zero
                    end

                    task.wait()
                end

                if Root and Root.Parent then
                    local ExistingForce = Root:FindFirstChild("NC_FlyForce")
                    local ExistingGyro = Root:FindFirstChild("NC_FlyGyro")

                    if ExistingForce then ExistingForce:Destroy() end
                    if ExistingGyro then ExistingGyro:Destroy() end
                end

                if Humanoid and Humanoid.Parent then
                    Humanoid.PlatformStand = false
                    Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)
        end
    end
}, "fly_toggle")

FlyTab:CreateGroupbox({
    Name = "CONTROLES",
    Column = 2,
    Style = 1
}, "fly_info"):CreateParagraph({
    Name = "MODO MÓVIL",
    Content = "Usa el joystick para moverte.\nEl personaje mira hacia la cámara mientras vuelas."
}, "fly_description")

-- ==========================================
-- 8. VISUALS
-- ==========================================
local ESPBox = VisualTab:CreateGroupbox({
    Name = "PLAYER ESP",
    Column = 1,
    Style = 2
}, "esp")

ESPBox:CreateToggle({
    Name = "ESP Jugadores",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        ESP = Value

        for _, Player in ipairs(Players:GetPlayers()) do
            if Player ~= LP and Player.Character then
                local Highlight = Player.Character:FindFirstChild("NC_ESP")

                if Value then
                    if not Highlight then
                        Highlight = Instance.new("Highlight")
                        Highlight.Name = "NC_ESP"
                        Highlight.FillColor = Color3.fromRGB(166, 98, 255)
                        Highlight.OutlineColor = Color3.fromRGB(106, 235, 255)
                        Highlight.FillTransparency = 0.55
                        Highlight.OutlineTransparency = 0
                        Highlight.Parent = Player.Character
                    end
                elseif Highlight then
                    Highlight:Destroy()
                end
            end
        end
    end
}, "player_esp")

VisualTab:CreateGroupbox({
    Name = "AURORA VISUALS",
    Column = 2,
    Style = 1
}, "visual_info"):CreateParagraph({
    Name = "COLOR DEL HUB",
    Content = "Violeta + cian sobre negro espacial.\nDiseñado para mantener buena visibilidad en móvil."
}, "visual_theme")

-- ==========================================
-- 9. TOOLS
-- ==========================================
local DevBox = ToolsTab:CreateGroupbox({
    Name = "DEVELOPER TOOLS",
    Column = 1,
    Style = 2
}, "dev_tools")

DevBox:CreateButton({
    Name = "Cargar Dark Dex",
    CenterContent = true,
    Style = 1,
    Callback = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"
        ))()
    end
}, "dark_dex")

DevBox:CreateButton({
    Name = "Cargar SimpleSpy",
    CenterContent = true,
    Style = 1,
    Callback = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"
        ))()
    end
}, "simple_spy")

local SystemBox = ToolsTab:CreateGroupbox({
    Name = "SISTEMA",
    Column = 2,
    Style = 2
}, "system")

SystemBox:CreateButton({
    Name = "Cerrar NC HUB",
    CenterContent = true,
    Style = 2,
    Callback = function()
        Starlight:Destroy()
    end
}, "close_hub")

SystemBox:CreateParagraph({
    Name = "NC HUB | AURORA CORE",
    Content = "Universal Edition\nDiseño personalizado para hidjcjgg."
}, "hub_version")

-- ==========================================
-- 10. MOTORES UNIVERSALES
-- ==========================================
UserInputService.JumpRequest:Connect(function()
    if InfiniteJump then
        local Humanoid = GetHumanoid()

        if Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Stepped:Connect(function()
    local Character = LP.Character

    if not Character then
        return
    end

    for _, Part in ipairs(Character:GetDescendants()) do
        if Part:IsA("BasePart") then
            if Noclip then
                if CollisionState[Part] == nil then
                    CollisionState[Part] = Part.CanCollide
                end

                Part.CanCollide = false
            elseif CollisionState[Part] ~= nil then
                Part.CanCollide = CollisionState[Part]
                CollisionState[Part] = nil
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function(Character)
        if not ESP then
            return
        end

        task.wait(1)

        local Highlight = Instance.new("Highlight")
        Highlight.Name = "NC_ESP"
        Highlight.FillColor = Color3.fromRGB(166, 98, 255)
        Highlight.OutlineColor = Color3.fromRGB(106, 235, 255)
        Highlight.FillTransparency = 0.55
        Highlight.OutlineTransparency = 0
        Highlight.Parent = Character
    end)
end)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            SessionLabel:Set({
                Name = "TIEMPO ACTIVO",
                Content = FormatTime() .. "\nNC HUB sigue operativo."
            })
        end)
    end
end)
