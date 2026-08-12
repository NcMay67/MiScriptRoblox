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
-- CARGA NC HUB
-- ==========================================
local function CreateLoading()
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
    Background.BackgroundColor3 = Color3.fromRGB(6, 7, 12)
    Background.BorderSizePixel = 0
    Background.Size = UDim2.fromScale(1, 1)
    Background.Parent = Gui

    local Card = Instance.new("Frame")
    Card.AnchorPoint = Vector2.new(0.5, 0.5)
    Card.BackgroundColor3 = Color3.fromRGB(14, 17, 27)
    Card.BorderSizePixel = 0
    Card.Position = UDim2.fromScale(0.5, 0.5)
    Card.Size = UDim2.fromOffset(340, 145)
    Card.Parent = Background

    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 16)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(153, 99, 255)
    Stroke.Thickness = 1.5
    Stroke.Parent = Card

    local Symbol = Instance.new("TextLabel")
    Symbol.BackgroundTransparency = 1
    Symbol.Font = Enum.Font.GothamBold
    Symbol.Position = UDim2.fromOffset(18, 18)
    Symbol.Size = UDim2.fromOffset(36, 36)
    Symbol.Text = "✦"
    Symbol.TextColor3 = Color3.fromRGB(179, 115, 255)
    Symbol.TextSize = 32
    Symbol.Parent = Card

    local Spin = TweenService:Create(
        Symbol,
        TweenInfo.new(0.9, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
        {Rotation = 360}
    )
    Spin:Play()

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Position = UDim2.fromOffset(62, 20)
    Title.Size = UDim2.new(1, -80, 0, 28)
    Title.Text = "NC HUB"
    Title.TextColor3 = Color3.fromRGB(242, 242, 255)
    Title.TextSize = 23
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Card

    local Status = Instance.new("TextLabel")
    Status.BackgroundTransparency = 1
    Status.Font = Enum.Font.Gotham
    Status.Position = UDim2.fromOffset(20, 65)
    Status.Size = UDim2.new(1, -40, 0, 20)
    Status.Text = "Preparando interfaz"
    Status.TextColor3 = Color3.fromRGB(164, 174, 207)
    Status.TextSize = 13
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Card

    local Track = Instance.new("Frame")
    Track.BackgroundColor3 = Color3.fromRGB(31, 37, 56)
    Track.BorderSizePixel = 0
    Track.Position = UDim2.fromOffset(20, 105)
    Track.Size = UDim2.new(1, -40, 0, 7)
    Track.Parent = Card
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.BackgroundColor3 = Color3.fromRGB(156, 102, 255)
    Fill.BorderSizePixel = 0
    Fill.Size = UDim2.fromScale(0, 1)
    Fill.Parent = Track
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(94, 226, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(157, 101, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 107, 255))
    })
    Gradient.Parent = Fill

    return function()
        Status.Text = "NC HUB listo"
        TweenService:Create(Fill, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.fromScale(1, 1)
        }):Play()

        task.wait(0.9)
        Spin:Cancel()

        TweenService:Create(Background, TweenInfo.new(0.25), {
            BackgroundTransparency = 1
        }):Play()

        TweenService:Create(Card, TweenInfo.new(0.25), {
            BackgroundTransparency = 1
        }):Play()

        for _, Object in ipairs(Card:GetDescendants()) do
            if Object:IsA("TextLabel") then
                TweenService:Create(Object, TweenInfo.new(0.2), {
                    TextTransparency = 1
                }):Play()
            elseif Object:IsA("UIStroke") then
                TweenService:Create(Object, TweenInfo.new(0.2), {
                    Transparency = 1
                }):Play()
            elseif Object:IsA("Frame") then
                TweenService:Create(Object, TweenInfo.new(0.2), {
                    BackgroundTransparency = 1
                }):Play()
            end
        end

        task.wait(0.3)
        Gui:Destroy()
    end
end

local FinishLoading = CreateLoading()

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

-- La carga propia se queda por encima mientras Starlight termina de crear su GUI.
task.spawn(function()
    local Limit = os.clock() + 5

    while not Window.Instance and os.clock() < Limit do
        task.wait()
    end

    task.wait(0.9)
    FinishLoading()
end)

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
    local Remaining = Seconds % 60

    return string.format("%dh %dm %ds", Hours, Minutes, Remaining)
end

-- ==========================================
-- SLIDER TÁCTIL PROPIO
-- ==========================================
local function CreateTouchSlider(Groupbox, Settings)
    local Slider = {
        Value = Settings.Default
    }

    task.spawn(function()
        while not Groupbox.ParentingItem do
            task.wait()
        end

        local Holder = Instance.new("Frame")
        Holder.Name = "NC_SLIDER_" .. Settings.Name
        Holder.BackgroundTransparency = 1
        Holder.Size = UDim2.new(1, 0, 0, 54)
        Holder.Parent = Groupbox.ParentingItem

        local Name = Instance.new("TextLabel")
        Name.BackgroundTransparency = 1
        Name.Font = Enum.Font.GothamMedium
        Name.Position = UDim2.fromOffset(6, 0)
        Name.Size = UDim2.new(0.65, 0, 0, 22)
        Name.Text = Settings.Name
        Name.TextColor3 = Color3.fromRGB(218, 223, 239)
        Name.TextSize = 13
        Name.TextXAlignment = Enum.TextXAlignment.Left
        Name.Parent = Holder

        local Value = Instance.new("TextLabel")
        Value.BackgroundTransparency = 1
        Value.Font = Enum.Font.GothamBold
        Value.Position = UDim2.new(0.65, 0, 0, 0)
        Value.Size = UDim2.new(0.35, -6, 0, 22)
        Value.TextColor3 = Color3.fromRGB(172, 145, 255)
        Value.TextSize = 13
        Value.TextXAlignment = Enum.TextXAlignment.Right
        Value.Parent = Holder

        local Bar = Instance.new("TextButton")
        Bar.AutoButtonColor = false
        Bar.BackgroundColor3 = Color3.fromRGB(38, 45, 68)
        Bar.BorderSizePixel = 0
        Bar.Position = UDim2.fromOffset(7, 31)
        Bar.Size = UDim2.new(1, -14, 0, 6)
        Bar.Text = ""
        Bar.Parent = Holder
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

        local Fill = Instance.new("Frame")
        Fill.AnchorPoint = Vector2.new(0, 0.5)
        Fill.BackgroundColor3 = Color3.fromRGB(159, 105, 255)
        Fill.BorderSizePixel = 0
        Fill.Position = UDim2.fromScale(0, 0.5)
        Fill.Size = UDim2.fromScale(0, 1)
        Fill.Parent = Bar
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

        local Gradient = Instance.new("UIGradient")
        Gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(106, 227, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(176, 103, 255))
        })
        Gradient.Parent = Fill

        local Knob = Instance.new("Frame")
        Knob.AnchorPoint = Vector2.new(0.5, 0.5)
        Knob.BackgroundColor3 = Color3.fromRGB(238, 238, 255)
        Knob.BorderSizePixel = 0
        Knob.Position = UDim2.fromScale(0, 0.5)
        Knob.Size = UDim2.fromOffset(14, 14)
        Knob.Parent = Bar
        Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

        local Dragging = false
        local ActiveInput = nil

        local function SetValue(NewValue)
            local Min = Settings.Min
            local Max = Settings.Max
            local Step = Settings.Step or 1

            NewValue = math.clamp(NewValue, Min, Max)
            NewValue = math.floor((NewValue - Min) / Step + 0.5) * Step + Min
            NewValue = math.clamp(NewValue, Min, Max)

            Slider.Value = NewValue

            local Percent = (NewValue - Min) / (Max - Min)
            Fill.Size = UDim2.fromScale(Percent, 1)
            Knob.Position = UDim2.fromScale(Percent, 0.5)
            Value.Text = tostring(NewValue)

            if Settings.Callback then
                Settings.Callback(NewValue)
            end
        end

        local function SetFromX(X)
            local Percent = math.clamp(
                (X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
                0,
                1
            )

            SetValue(Settings.Min + (Settings.Max - Settings.Min) * Percent)
        end

        Bar.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.Touch
                or Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                ActiveInput = Input
                SetFromX(Input.Position.X)
            end
        end)

        UserInputService.InputChanged:Connect(function(Input)
            if not Dragging then
                return
            end

            if ActiveInput.UserInputType == Enum.UserInputType.Touch then
                if Input.UserInputType == Enum.UserInputType.Touch then
                    SetFromX(Input.Position.X)
                end
            elseif Input.UserInputType == Enum.UserInputType.MouseMovement then
                SetFromX(Input.Position.X)
            end
        end)

        UserInputService.InputEnded:Connect(function(Input)
            if not Dragging then
                return
            end

            if Input == ActiveInput
                or Input.UserInputType == Enum.UserInputType.MouseButton1
                or Input.UserInputType == Enum.UserInputType.Touch then
                Dragging = false
                ActiveInput = nil
            end
        end)

        SetValue(Settings.Default)
    end)

    return Slider
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
-- TABS
-- ==========================================
local HomeSection = Window:CreateTabSection("INICIO")
local MovementSection = Window:CreateTabSection("MOVIMIENTO")
local VisualSection = Window:CreateTabSection("VISUAL")
local ToolsSection = Window:CreateTabSection("SISTEMA")

local HomeTab = HomeSection:CreateTab({Name = "Home", Columns = 2}, "home")
local MovementTab = MovementSection:CreateTab({Name = "Movimiento", Columns = 2}, "movement")
local FlyTab = MovementSection:CreateTab({Name = "Fly", Columns = 2}, "fly")
local VisualTab = VisualSection:CreateTab({Name = "ESP", Columns = 2}, "esp")
local ToolsTab = ToolsSection:CreateTab({Name = "Tools", Columns = 2}, "tools")

-- ==========================================
-- HOME
-- ==========================================
local ProfileBox = HomeTab:CreateGroupbox({
    Name = "PERFIL",
    Column = 1,
    Style = 2
}, "profile")

ProfileBox:CreateLabel({Name = LP.DisplayName}, "display")
ProfileBox:CreateLabel({Name = "@" .. LP.Name}, "username")
ProfileBox:CreateLabel({Name = "Cuenta: " .. LP.AccountAge .. " días"}, "age")

local SessionBox = HomeTab:CreateGroupbox({
    Name = "SESIÓN",
    Column = 2,
    Style = 2
}, "session")

local TimeLabel = SessionBox:CreateLabel({Name = "Tiempo: 0h 0m 0s"}, "time")
SessionBox:CreateLabel({Name = "Status: Operacional"}, "status")

-- ==========================================
-- MOVIMIENTO
-- ==========================================
local SpeedBox = MovementTab:CreateGroupbox({
    Name = "VELOCIDAD",
    Column = 1,
    Style = 2
}, "speed")

CreateTouchSlider(SpeedBox, {
    Name = "Velocidad",
    Min = 16,
    Max = 256,
    Step = 1,
    Default = 16,
    Callback = function(Value)
        WalkSpeed = Value
        local Humanoid = GetHumanoid()
        if Humanoid then
            Humanoid.WalkSpeed = Value
        end
    end
})

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
local FlyBox = FlyTab:CreateGroupbox({
    Name = "FLY",
    Column = 1,
    Style = 2
}, "fly")

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
            FlyUpUntil = os.clock() + 0.55

            local Force = Instance.new("BodyVelocity")
            Force.Name = "NC_FlyForce"
            Force.MaxForce = Vector3.new(9e9, 9e9, 9e9)
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
                    local ForceObject = Root:FindFirstChild("NC_FlyForce")
                    local GyroObject = Root:FindFirstChild("NC_FlyGyro")
                    if ForceObject then ForceObject:Destroy() end
                    if GyroObject then GyroObject:Destroy() end
                end

                if Humanoid and Humanoid.Parent then
                    Humanoid.PlatformStand = false
                    Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)
        end
    end
}, "fly_toggle")

FlyBox:CreateButton({
    Name = "Subir",
    Style = 1,
    CenterContent = true,
    Callback = function()
        if Fly then
            FlyUpUntil = os.clock() + 0.4
        end
    end
}, "up")

FlyBox:CreateButton({
    Name = "Bajar",
    Style = 1,
    CenterContent = true,
    Callback = function()
        if Fly then
            FlyDownUntil = os.clock() + 0.4
        end
    end
}, "down")

local FlySpeedBox = FlyTab:CreateGroupbox({
    Name = "VELOCIDAD",
    Column = 2,
    Style = 2
}, "fly_speed")

CreateTouchSlider(FlySpeedBox, {
    Name = "Velocidad Fly",
    Min = 10,
    Max = 400,
    Step = 5,
    Default = 80,
    Callback = function(Value)
        FlySpeed = Value
    end
})

-- ==========================================
-- ESP
-- ==========================================
local ESPBox = VisualTab:CreateGroupbox({
    Name = "ESP",
    Column = 1,
    Style = 2
}, "esp")

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
    if Highlight then Highlight:Destroy() end
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
    Name = "TOOLS",
    Column = 1,
    Style = 2
}, "dev")

DeveloperBox:CreateButton({
    Name = "Cargar Dark Dex",
    Style = 1,
    CenterContent = true,
    Callback = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"
        ))()
    end
}, "dex")

DeveloperBox:CreateButton({
    Name = "Cargar SimpleSpy",
    Style = 1,
    CenterContent = true,
    Callback = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"
        ))()
    end
}, "spy")

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
        FlyUpUntil = os.clock() + 0.4
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

    if not Character then
        return
    end

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

    local Humanoid = GetHumanoid()

    if Humanoid then
        Humanoid.WalkSpeed = WalkSpeed
    end
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
