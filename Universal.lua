-- ==========================================
-- NC HUB | UNIVERSAL
-- ==========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local TiempoInicio = os.time()

-- ==========================================
-- CARGA PROPIA DE NC HUB
-- ==========================================
local function CreateLoadingScreen()
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "NC_HUB_LOADING"
    Gui.IgnoreGuiInset = true
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 999999

    pcall(function()
        Gui.Parent = gethui and gethui() or CoreGui
    end)

    if not Gui.Parent then
        Gui.Parent = LP:WaitForChild("PlayerGui")
    end

    local Background = Instance.new("Frame")
    Background.BackgroundColor3 = Color3.fromRGB(7, 8, 14)
    Background.BorderSizePixel = 0
    Background.Size = UDim2.fromScale(1, 1)
    Background.Parent = Gui

    local Card = Instance.new("Frame")
    Card.AnchorPoint = Vector2.new(0.5, 0.5)
    Card.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
    Card.BorderSizePixel = 0
    Card.Position = UDim2.fromScale(0.5, 0.5)
    Card.Size = UDim2.fromOffset(330, 130)
    Card.Parent = Background

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 14)
    Corner.Parent = Card

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(152, 97, 255)
    Stroke.Thickness = 1.5
    Stroke.Parent = Card

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Position = UDim2.fromOffset(18, 20)
    Title.Size = UDim2.new(1, -36, 0, 32)
    Title.Text = "NC HUB"
    Title.TextColor3 = Color3.fromRGB(235, 235, 255)
    Title.TextSize = 25
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Card

    local Subtitle = Instance.new("TextLabel")
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.Position = UDim2.fromOffset(18, 54)
    Subtitle.Size = UDim2.new(1, -36, 0, 20)
    Subtitle.Text = "Cargando sistema..."
    Subtitle.TextColor3 = Color3.fromRGB(160, 171, 203)
    Subtitle.TextSize = 13
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = Card

    local BarBackground = Instance.new("Frame")
    BarBackground.BackgroundColor3 = Color3.fromRGB(29, 34, 51)
    BarBackground.BorderSizePixel = 0
    BarBackground.Position = UDim2.fromOffset(18, 94)
    BarBackground.Size = UDim2.new(1, -36, 0, 7)
    BarBackground.Parent = Card

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = BarBackground

    local Bar = Instance.new("Frame")
    Bar.BackgroundColor3 = Color3.fromRGB(166, 98, 255)
    Bar.BorderSizePixel = 0
    Bar.Size = UDim2.fromScale(0, 1)
    Bar.Parent = BarBackground

    local BarGradient = Instance.new("UIGradient")
    BarGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(110, 226, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(166, 98, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(231, 109, 255))
    })
    BarGradient.Parent = Bar

    local BarFillCorner = Instance.new("UICorner")
    BarFillCorner.CornerRadius = UDim.new(1, 0)
    BarFillCorner.Parent = Bar

    return function()
        Subtitle.Text = "NC HUB listo"

        TweenService:Create(
            Bar,
            TweenInfo.new(0.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {Size = UDim2.fromScale(1, 1)}
        ):Play()

        task.wait(0.8)

        TweenService:Create(
            Background,
            TweenInfo.new(0.25),
            {BackgroundTransparency = 1}
        ):Play()

        TweenService:Create(
            Card,
            TweenInfo.new(0.25),
            {BackgroundTransparency = 1}
        ):Play()

        for _, Object in ipairs(Card:GetDescendants()) do
            if Object:IsA("TextLabel") then
                TweenService:Create(Object, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
            elseif Object:IsA("UIStroke") then
                TweenService:Create(Object, TweenInfo.new(0.2), {Transparency = 1}):Play()
            elseif Object:IsA("Frame") then
                TweenService:Create(Object, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            end
        end

        task.wait(0.3)
        Gui:Destroy()
    end
end

local FinishLoading = CreateLoadingScreen()

-- ==========================================
-- STARLIGHT
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

    DefaultSize = UDim2.fromOffset(580, 390),

    KeySystem = {
        Enabled = false
    },

    Discord = {
        Enabled = false
    }
})

FinishLoading()

-- ==========================================
-- FUNCIONES BASE
-- ==========================================
local function GetCharacter()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function GetHumanoid()
    return GetCharacter():FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    return GetCharacter():FindFirstChild("HumanoidRootPart")
end

local function GetTimeText()
    local Seconds = os.time() - TiempoInicio
    local Hours = math.floor(Seconds / 3600)
    local Minutes = math.floor(Seconds / 60) % 60
    local RemainingSeconds = Seconds % 60

    return string.format("%dh %dm %ds", Hours, Minutes, RemainingSeconds)
end

-- ==========================================
-- VARIABLES
-- ==========================================
local WalkSpeed = 16
local InfiniteJump = false
local Noclip = false
local ESP = false

local Fly = false
local FlySpeed = 80
local FlyUpUntil = 0
local FlyDownUntil = 0

local OriginalCollision = {}

-- ==========================================
-- SECCIONES
-- ==========================================
local HomeSection = Window:CreateTabSection("HOME")
local MovementSection = Window:CreateTabSection("MOVIMIENTO")
local VisualSection = Window:CreateTabSection("VISUAL")
local ToolsSection = Window:CreateTabSection("SISTEMA")

local HomeTab = HomeSection:CreateTab({
    Name = "Inicio",
    Columns = 2
}, "home")

local MovementTab = MovementSection:CreateTab({
    Name = "Movimiento",
    Columns = 2
}, "movement")

local FlyTab = MovementSection:CreateTab({
    Name = "Fly",
    Columns = 2
}, "fly")

local VisualTab = VisualSection:CreateTab({
    Name = "ESP",
    Columns = 2
}, "esp")

local ToolsTab = ToolsSection:CreateTab({
    Name = "Tools",
    Columns = 2
}, "tools")

-- ==========================================
-- HOME
-- ==========================================
local ProfileBox = HomeTab:CreateGroupbox({
    Name = "PERFIL",
    Column = 1,
    Style = 2
}, "profile")

ProfileBox:CreateLabel({
    Name = LP.DisplayName
}, "display_name")

ProfileBox:CreateLabel({
    Name = "@" .. LP.Name
}, "username")

ProfileBox:CreateLabel({
    Name = "Cuenta: " .. LP.AccountAge .. " días"
}, "account_age")

local StatusBox = HomeTab:CreateGroupbox({
    Name = "SESIÓN",
    Column = 2,
    Style = 2
}, "session")

local TimeLabel = StatusBox:CreateLabel({
    Name = "Tiempo: 0h 0m 0s"
}, "time")

StatusBox:CreateLabel({
    Name = "Status: Operacional"
}, "status")

-- ==========================================
-- MOVIMIENTO
-- ==========================================
local SpeedBox = MovementTab:CreateGroupbox({
    Name = "VELOCIDAD",
    Column = 1,
    Style = 2
}, "speed")

local SpeedLabel = SpeedBox:CreateLabel({
    Name = "Actual: 16"
}, "speed_label")

local function SetWalkSpeed(Value)
    WalkSpeed = Value

    local Humanoid = GetHumanoid()
    if Humanoid then
        Humanoid.WalkSpeed = WalkSpeed
    end

    SpeedLabel:Set({
        Name = "Actual: " .. WalkSpeed
    })
end

SpeedBox:CreateButton({
    Name = "Normal | 16",
    Style = 1,
    CenterContent = true,
    Callback = function()
        SetWalkSpeed(16)
    end
}, "speed_16")

SpeedBox:CreateButton({
    Name = "Rápido | 32",
    Style = 1,
    CenterContent = true,
    Callback = function()
        SetWalkSpeed(32)
    end
}, "speed_32")

SpeedBox:CreateButton({
    Name = "Turbo | 50",
    Style = 1,
    CenterContent = true,
    Callback = function()
        SetWalkSpeed(50)
    end
}, "speed_50")

SpeedBox:CreateButton({
    Name = "Máximo | 75",
    Style = 1,
    CenterContent = true,
    Callback = function()
        SetWalkSpeed(75)
    end
}, "speed_75")

local MovementBox = MovementTab:CreateGroupbox({
    Name = "MOVIMIENTO",
    Column = 2,
    Style = 2
}, "movement_options")

MovementBox:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        InfiniteJump = Value
    end
}, "infinite_jump")

MovementBox:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        Noclip = Value
    end
}, "noclip")

-- ==========================================
-- FLY
-- ==========================================
local FlyMainBox = FlyTab:CreateGroupbox({
    Name = "FLY",
    Column = 1,
    Style = 2
}, "fly_main")

FlyMainBox:CreateToggle({
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
                    local Velocity = Vector3.zero

                    Gyro.CFrame = Camera.CFrame

                    local Look = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
                    local Right = Vector3.new(Camera.CFrame.RightVector.X, 0, Camera.CFrame.RightVector.Z)

                    if Direction.Magnitude > 0 and Look.Magnitude > 0 and Right.Magnitude > 0 then
                        local Horizontal = (Look.Unit * Direction:Dot(Look.Unit))
                            + (Right.Unit * Direction:Dot(Right.Unit))

                        if Horizontal.Magnitude > 0 then
                            Velocity = Horizontal.Unit * FlySpeed
                        end
                    end

                    if os.clock() < FlyUpUntil then
                        Velocity = Velocity + Vector3.new(0, FlySpeed, 0)
                    elseif os.clock() < FlyDownUntil then
                         Velocity = Velocity + Vector3.new(0, -FlySpeed, 0)
                    end

                    Force.Velocity = Velocity
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

FlyMainBox:CreateButton({
    Name = "Subir",
    Style = 1,
    CenterContent = true,
    Callback = function()
        if Fly then
            FlyUpUntil = os.clock() + 0.35
        end
    end
}, "fly_up")

FlyMainBox:CreateButton({
    Name = "Bajar",
    Style = 1,
    CenterContent = true,
    Callback = function()
        if Fly then
            FlyDownUntil = os.clock() + 0.35
        end
    end
}, "fly_down")

local FlySpeedBox = FlyTab:CreateGroupbox({
    Name = "VELOCIDAD DE FLY",
    Column = 2,
    Style = 2
}, "fly_speed")

local FlySpeedLabel = FlySpeedBox:CreateLabel({
    Name = "Actual: 80"
}, "fly_speed_label")

local function SetFlySpeed(Value)
    FlySpeed = Value

    FlySpeedLabel:Set({
        Name = "Actual: " .. FlySpeed
    })
end

FlySpeedBox:CreateButton({
    Name = "Lento | 30",
    Style = 1,
    CenterContent = true,
    Callback = function()
        SetFlySpeed(30)
    end
}, "fly_30")

FlySpeedBox:CreateButton({
    Name = "Normal | 80",
    Style = 1,
    CenterContent = true,
    Callback = function()
        SetFlySpeed(80)
    end
}, "fly_80")

FlySpeedBox:CreateButton({
    Name = "Rápido | 150",
    Style = 1,
    CenterContent = true,
    Callback = function()
        SetFlySpeed(150)
    end
}, "fly_150")

FlySpeedBox:CreateButton({
    Name = "Máximo | 250",
    Style = 1,
    CenterContent = true,
    Callback = function()
        SetFlySpeed(250)
    end
}, "fly_250")

-- ==========================================
-- ESP
-- ==========================================
local ESPBox = VisualTab:CreateGroupbox({
    Name = "ESP",
    Column = 1,
    Style = 2
}, "esp_box")

local function AddESP(Character)
    if not Character or Character:FindFirstChild("NC_ESP") then
        return
    end

    local Highlight = Instance.new("Highlight")
    Highlight.Name = "NC_ESP"
    Highlight.FillColor = Color3.fromRGB(166, 98, 255)
    Highlight.OutlineColor = Color3.fromRGB(106, 235, 255)
    Highlight.FillTransparency = 0.55
    Highlight.OutlineTransparency = 0
    Highlight.Parent = Character
end

local function RemoveESP(Character)
    local Highlight = Character and Character:FindFirstChild("NC_ESP")
    if Highlight then
        Highlight:Destroy()
    end
end

ESPBox:CreateToggle({
    Name = "ESP Jugadores",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        ESP = Value

        for _, Player in ipairs(Players:GetPlayers()) do
            if Player ~= LP then
                if Value then
                    AddESP(Player.Character)
                else
                    RemoveESP(Player.Character)
                end
            end
        end
    end
}, "esp_toggle")

-- ==========================================
-- TOOLS
-- ==========================================
local DeveloperBox = ToolsTab:CreateGroupbox({
    Name = "DEVELOPER TOOLS",
    Column = 1,
    Style = 2
}, "developer_tools")

DeveloperBox:CreateButton({
    Name = "Cargar Dark Dex",
    Style = 1,
    CenterContent = true,
    Callback = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"
        ))()
    end
}, "dark_dex")

DeveloperBox:CreateButton({
    Name = "Cargar SimpleSpy",
    Style = 1,
    CenterContent = true,
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
    Style = 2,
    CenterContent = true,
    Callback = function()
        Starlight:Destroy()
    end
}, "close")

-- ==========================================
-- MOTORES
-- ==========================================
UserInputService.JumpRequest:Connect(function()
    if Fly then
        FlyUpUntil = os.clock() + 0.35
        return
    end

    if InfiniteJump then
        local Humanoid = GetHumanoid()
        if Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Stepped:Connect(function()
    local Character = LP.Character
    if not Character then return end

    for _, Part in ipairs(Character:GetDescendants()) do
        if Part:IsA("BasePart") then
            if Noclip then
                if OriginalCollision[Part] == nil then
                    OriginalCollision[Part] = Part.CanCollide
                end
                Part.CanCollide = false
            elseif OriginalCollision[Part] ~= nil then
                Part.CanCollide = OriginalCollision[Part]
                OriginalCollision[Part] = nil
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function(Character)
        if ESP then
            task.wait(1)
            AddESP(Character)
        end
    end)
end)

LP.CharacterAdded:Connect(function()
    task.wait(1)
    SetWalkSpeed(WalkSpeed)
end)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            TimeLabel:Set({
                Name = "Tiempo: " .. GetTimeText()
            })
        end)
    end
end)
