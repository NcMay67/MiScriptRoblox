-- NC HUB | Universal.lua
-- Interfaz propia: NEXUS NC Interface

local BASE_URL = "https://raw.githubusercontent.com/NcMay67/MiScriptRoblox/refs/heads/main/"
local NX = loadstring(game:HttpGet(BASE_URL .. "NexusNc.lua"))()

local FinishLoading = NX:Loading({
    Title = "NC HUB",
    Text = "Preparando módulo universal"
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local StartedAt = os.time()

local Window = NX:Window({
    Title = "NC HUB",
    Subtitle = "By hidjcjgg",
    Width = 520,
    Height = 350
})

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
    local Character = getCharacter()
    return Character:FindFirstChildOfClass("Humanoid")
        or Character:WaitForChild("Humanoid")
end

local function getRoot()
    local Character = getCharacter()
    return Character:FindFirstChild("HumanoidRootPart")
        or Character:WaitForChild("HumanoidRootPart")
end

-- =========================================================
-- INICIO
-- =========================================================
local HomeSection = Window:Section("INICIO")
local HomeTab = HomeSection:Tab("Inicio")

local ProfileCard = HomeTab:Card("PERFIL")
NX:Label(ProfileCard, "Usuario: " .. LocalPlayer.Name)
NX:Label(ProfileCard, "Apodo: " .. LocalPlayer.DisplayName)
NX:Label(ProfileCard, "Cuenta: " .. tostring(LocalPlayer.AccountAge) .. " días")

local GameName = "Juego desconocido"
pcall(function()
    GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
end)

local GameCard = HomeTab:Card("SESIÓN")
NX:Label(GameCard, "Juego: " .. GameName)
NX:Label(GameCard, "Place ID: " .. tostring(game.PlaceId))
local PlayerCountLabel = NX:Label(GameCard, "Servidor: 0 / " .. tostring(Players.MaxPlayers))
local TimeLabel = NX:Label(GameCard, "Tiempo activo: 0h 0m 0s")

-- =========================================================
-- MOVIMIENTO
-- =========================================================
local MovementSection = Window:Section("TRAMPAS")
local MovementTab = MovementSection:Tab("Movimiento")

local SpeedCard = MovementTab:Card("VELOCIDAD Y SALTO")
local SpeedValue = 16
local JumpValue = 50

NX:Slider(SpeedCard, {
    Name = "Velocidad",
    Min = 16,
    Max = 120,
    Step = 1,
    Default = 16,
    Callback = function(Value)
        SpeedValue = Value
        getHumanoid().WalkSpeed = SpeedValue
    end
})

NX:Slider(SpeedCard, {
    Name = "Salto",
    Min = 50,
    Max = 200,
    Step = 1,
    Default = 50,
    Callback = function(Value)
        JumpValue = Value
        local Humanoid = getHumanoid()
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = JumpValue
    end
})

LocalPlayer.CharacterAdded:Connect(function(Character)
    task.wait(0.8)
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        Humanoid.WalkSpeed = SpeedValue
        Humanoid.UseJumpPower = true
        Humanoid.JumpPower = JumpValue
    end
end)

local UtilityCard = MovementTab:Card("UTILIDADES")
local InfiniteJump = false
local Noclip = false

NX:Toggle(UtilityCard, {
    Name = "Salto infinito",
    Callback = function(State)
        InfiniteJump = State
    end
})

NX:Toggle(UtilityCard, {
    Name = "Noclip",
    Callback = function(State)
        Noclip = State
    end
})

UserInputService.JumpRequest:Connect(function()
    if InfiniteJump then
        getHumanoid():ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local OriginalCollision = {}

local function restoreCollision()
    for Part, OriginalState in pairs(OriginalCollision) do
        if Part and Part.Parent then
            Part.CanCollide = OriginalState
        end
    end
    table.clear(OriginalCollision)
end

RunService.Stepped:Connect(function()
    if Noclip then
        local Character = LocalPlayer.Character
        if Character then
            for _, Object in ipairs(Character:GetDescendants()) do
                if Object:IsA("BasePart") then
                    if OriginalCollision[Object] == nil then
                        OriginalCollision[Object] = Object.CanCollide
                    end
                    Object.CanCollide = false
                end
            end
        end
    elseif next(OriginalCollision) then
        restoreCollision()
    end
end)

-- =========================================================
-- FLY PRO
-- =========================================================
local FlyCard = MovementTab:Card("FLY PRO")
local FlyEnabled = false
local FlySpeed = 60
local FlyVelocity
local FlyGyro
local FlyConnection
local LiftUntil = 0

-- El botón de salto del móvil también sube durante el Fly.
UserInputService.JumpRequest:Connect(function()
    if FlyEnabled then
        LiftUntil = os.clock() + 0.20
    end
end)

local function stopFly()
    FlyEnabled = false

    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    if FlyVelocity then
        FlyVelocity:Destroy()
        FlyVelocity = nil
    end

    if FlyGyro then
        FlyGyro:Destroy()
        FlyGyro = nil
    end

    local Humanoid = LocalPlayer.Character
        and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

    if Humanoid then
        Humanoid.AutoRotate = true
        Humanoid.PlatformStand = false
    end
end

local function startFly()
    stopFly()
    FlyEnabled = true

    local Humanoid = getHumanoid()
    local Root = getRoot()

    Humanoid.AutoRotate = false
    Humanoid.PlatformStand = false

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.Name = "NC_FlyVelocity"
    FlyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    FlyVelocity.P = 18000
    FlyVelocity.Velocity = Vector3.new(0, 45, 0)
    FlyVelocity.Parent = Root

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.Name = "NC_FlyGyro"
    FlyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    FlyGyro.P = 35000
    FlyGyro.D = 900
    FlyGyro.Parent = Root

    -- Impulso inicial: evita que quede pegado al suelo.
    LiftUntil = os.clock() + 0.24

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not FlyEnabled or not Root.Parent or not Humanoid.Parent then
            return
        end

        local Camera = workspace.CurrentCamera
        local Direction = Humanoid.MoveDirection
        local Vertical = 0

        if os.clock() < LiftUntil then
            Vertical = 45
        elseif UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            Vertical = FlySpeed
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            Vertical = -FlySpeed
        end

        FlyVelocity.Velocity = Direction * FlySpeed + Vector3.new(0, Vertical, 0)

        local Look = Camera.CFrame.LookVector
        local FlatLook = Vector3.new(Look.X, 0, Look.Z)
        if FlatLook.Magnitude > 0.05 then
            FlyGyro.CFrame = CFrame.lookAt(Root.Position, Root.Position + FlatLook)
        end
    end)
end

NX:Toggle(FlyCard, {
    Name = "Activar Fly Pro",
    Callback = function(State)
        if State then
            startFly()
        else
            stopFly()
        end
    end
})

NX:Slider(FlyCard, {
    Name = "Velocidad de vuelo",
    Min = 20,
    Max = 180,
    Step = 1,
    Default = 60,
    Callback = function(Value)
        FlySpeed = Value
    end
})

LocalPlayer.CharacterAdded:Connect(function()
    if FlyEnabled then
        task.wait(0.8)
        startFly()
    end
end)
-- =========================================================
-- VISUALES
-- =========================================================
local VisualSection = Window:Section("VISUALES")
local VisualTab = VisualSection:Tab("ESP")
local ESPCard = VisualTab:Card("JUGADORES")
local ESPEnabled = false

local function removeESP(Player)
    local Character = Player.Character
    if Character then
        local Highlight = Character:FindFirstChild("NC_ESP")
        if Highlight then
            Highlight:Destroy()
        end
    end
end

local function applyESP(Player)
    if Player == LocalPlayer or not ESPEnabled then
        return
    end

    local Character = Player.Character
    if not Character then
        return
    end

    local Highlight = Character:FindFirstChild("NC_ESP")
    if not Highlight then
        Highlight = Instance.new("Highlight")
        Highlight.Name = "NC_ESP"
        Highlight.FillColor = Color3.fromRGB(129, 84, 235)
        Highlight.FillTransparency = 0.55
        Highlight.OutlineColor = Color3.fromRGB(85, 219, 255)
        Highlight.OutlineTransparency = 0
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.Parent = Character
    end

    Highlight.Enabled = true
end

local function preparePlayerESP(Player)
    if Player == LocalPlayer then
        return
    end

    Player.CharacterAdded:Connect(function(Character)
        task.wait(0.35)
        if ESPEnabled and Character.Parent then
            applyESP(Player)
        end
    end)
end

for _, Player in ipairs(Players:GetPlayers()) do
    preparePlayerESP(Player)
end

Players.PlayerAdded:Connect(preparePlayerESP)
Players.PlayerRemoving:Connect(removeESP)

NX:Toggle(ESPCard, {
    Name = "ESP de jugadores",
    Callback = function(State)
        ESPEnabled = State

        for _, Player in ipairs(Players:GetPlayers()) do
            if State then
                applyESP(Player)
            else
                removeESP(Player)
            end
        end
    end
})

-- =========================================================
-- SISTEMA
-- =========================================================
local SystemSection = Window:Section("SISTEMA")
local SystemTab = SystemSection:Tab("Sistema")
local SystemCard = SystemTab:Card("NC HUB")
local AntiAFK = false

NX:Toggle(SystemCard, {
    Name = "Anti-AFK",
    Callback = function(State)
        AntiAFK = State
    end
})

NX:Button(SystemCard, {
    Name = "Cerrar NC HUB",
    Callback = function()
        stopFly()
        restoreCollision()

        for _, Player in ipairs(Players:GetPlayers()) do
            removeESP(Player)
        end

        Window:Destroy()
    end
})

LocalPlayer.Idled:Connect(function()
    if AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end
end)

-- =========================================================
-- ACTUALIZACIÓN DEL PANEL DE INICIO
-- =========================================================
task.spawn(function()
    while Window.Gui and Window.Gui.Parent do
        local TotalSeconds = os.time() - StartedAt
        local Hours = math.floor(TotalSeconds / 3600)
        local Minutes = math.floor((TotalSeconds % 3600) / 60)
        local Seconds = TotalSeconds % 60

        TimeLabel:Set(string.format(
            "Tiempo activo: %dh %dm %ds",
            Hours,
            Minutes,
            Seconds
        ))

        PlayerCountLabel:Set(
            "Servidor: "
                .. tostring(#Players:GetPlayers())
                .. " / "
                .. tostring(Players.MaxPlayers)
        )

        task.wait(1)
    end
end)
-- =========================================================
-- NEXUS NC LAB | Prueba temporal v0.3
-- =========================================================
local LabSection = Window:Section("NEXUS LAB")
local LabTab = LabSection:Tab("Controles")
local LabCard = LabTab:Card("INPUT Y DROPDOWN")

local LabStatus = NX:Label(LabCard, "Estado: esperando prueba")

NX:Input(LabCard, {
    Name = "Texto de prueba",
    Placeholder = "Escribe cualquier cosa",
    Callback = function(value)
        LabStatus:Set("Texto: " .. tostring(value))
    end
})

NX:Input(LabCard, {
    Name = "Número de prueba",
    Placeholder = "Solo números",
    Numeric = true,
    Finished = true,
    Callback = function(value)
        LabStatus:Set("Número: " .. tostring(value or 0))
    end
})

NX:Dropdown(LabCard, {
    Name = "Modo de interfaz",
    Values = {"Normal", "Compacto", "Minimal"},
    Default = 1,
    Callback = function(value)
        LabStatus:Set("Modo: " .. tostring(value))
    end
})

NX:Dropdown(LabCard, {
    Name = "Lista con búsqueda",
    Placeholder = "Elige una opción",
    Values = {
        "Factory Tycoon",
        "Murder Mystery 2",
        "Slime Tycoon",
        "Power a City",
        "Build a Gem Crusher",
        "The Stronger Lifter",
        "Kick to Space"
    },
    Searchable = true,
    Callback = function(value)
        LabStatus:Set("Juego: " .. tostring(value))
    end
})
local DialogCard = LabTab:Card("DIÁLOGOS")

NX:Button(DialogCard, {
    Name = "Probar confirmación",
    Callback = function()
        NX:Confirm({
            Title = "Prueba de NEXUS NC",
            Content = "Este diálogo se creó con la nueva librería. ¿Funciona bien?",
            ConfirmText = "Sí, funciona",
            CancelText = "Cerrar",
            Callback = function(answer)
                if answer then
                    LabStatus:Set("Confirmación: todo funciona")
                else
                    LabStatus:Set("Confirmación: cerrada")
                end
            end
        })
    end
})

NX:Button(DialogCard, {
    Name = "Probar diálogo informativo",
    Callback = function()
        NX:Dialog({
            Title = "NEXUS NC v0.4",
            Content = "Los diálogos ahora son propios, móviles y se cierran limpiamente.",
            Buttons = {
                {
                    Name = "Entendido",
                    Variant = "primary",
                    Result = true
                }
            }
        })
    end
})
local LayoutCard = LabTab:Card("LAYOUT")

NX:Badge(LayoutCard, {
    Text = "NEXUS NC v0.5",
    Color = NX.Theme.Cian
})

NX:Paragraph(LayoutCard, {
    Title = "Tarjeta informativa",
    Content = "Esto es un Paragraph: sirve para mostrar información organizada dentro de cualquier módulo."
})

NX:Divider(LayoutCard, "SEPARADOR")

NX:Paragraph(LayoutCard, {
    Title = "Sin contenedor",
    Content = "Esta variante usa Boxed = false y sirve para textos más simples.",
    Boxed = false
})

NX:Space(LayoutCard, 4)
NX:Label(LayoutCard, "Fin de la prueba de layout")
local MultiCard = LabTab:Card("SELECCIÓN MÚLTIPLE")
local MultiStatus = NX:Label(MultiCard, "Elegidos: ninguno")

NX:MultiDropdown(MultiCard, {
    Name = "Módulos de prueba",
    Placeholder = "Seleccionar módulos",
    Searchable = true,
    Values = {
        "Inicio",
        "Movimiento",
        "ESP",
        "Sistema",
        "Factory Tycoon",
        "Murder Mystery 2",
        "Slime Tycoon",
        "Power a City"
    },
    Default = {"Inicio", "ESP"},
    Callback = function(values)
        if #values == 0 then
            MultiStatus:Set("Elegidos: ninguno")
        else
            MultiStatus:Set("Elegidos: " .. table.concat(values, ", "))
        end
    end
})
local ColorCard = LabTab:Card("COLOR PICKER")

local ColorBadge = NX:Badge(ColorCard, {
    Text = "COLOR ACTIVO",
    Color = NX.Theme.Cian
})

NX:ColorPicker(ColorCard, {
    Name = "Color de prueba",
    Default = NX.Theme.Cian,
    Callback = function(color)
        ColorBadge:SetColor(color)
        LabStatus:Set("Color: " .. string.format(
            "RGB(%d, %d, %d)",
            math.floor(color.R * 255 + 0.5),
            math.floor(color.G * 255 + 0.5),
            math.floor(color.B * 255 + 0.5)
        ))
    end
})
local StorageCard = LabTab:Card("CONFIGURACIÓN LOCAL")
local StorageStatus = NX:Label(StorageCard, "Estado: sin probar")

NX:Button(StorageCard, {
    Name = "Guardar prueba local",
    Callback = function()
        local ok, err = NX:SaveConfig("nexus_lab_test", {
            Version = "0.7",
            Theme = NX.ActiveTheme,
            SavedAt = os.time()
        })

        StorageStatus:Set(ok and "Estado: guardado local correcto" or "Error: " .. tostring(err))
    end
})

NX:Button(StorageCard, {
    Name = "Leer prueba local",
    Callback = function()
        local data, err = NX:LoadConfig("nexus_lab_test")
        if data then
            StorageStatus:Set("Leído: tema " .. tostring(data.Theme))
        else
            StorageStatus:Set("Error: " .. tostring(err))
        end
    end
})

NX:Button(StorageCard, {
    Name = "Borrar prueba local",
    Callback = function()
        local ok, err = NX:DeleteConfig("nexus_lab_test")
        StorageStatus:Set(ok and "Estado: prueba borrada" or "Error: " .. tostring(err))
    end
})
-- Prueba de extensión: componente creado fuera del núcleo.
NX:RegisterComponent("EstadoNexus", function(lib, card, config)
    return lib:Paragraph(card, {
        Title = config.Title or "Estado",
        Content = config.Content or "Sin contenido",
        Color = config.Color or lib.Theme.Cian
    })
end)

local ExtensionCard = LabTab:Card("EXTENSIONES")

ExtensionCard:Add("EstadoNexus", {
    Title = "Componente propio",
    Content = "Este Paragraph fue creado usando RegisterComponent y Card:Add, sin editar el núcleo de NEXUS NC.",
    Color = NX.Theme.Rose
})

ExtensionCard:Add("Divider", {
    Text = "REGISTRO ACTIVO"
})

ExtensionCard:Add("Label", {
    Text = "NEXUS NC ya admite extensiones modulares"
})
local BindCard = LabTab:Card("PREFERENCIAS VINCULADAS")
local BindStatus = NX:Label(BindCard, "Estado: cambia valores y guarda")

NX:Toggle(BindCard, {
    Name = "Opción guardable",
    Default = false,
    Bind = "lab_toggle"
})

NX:Slider(BindCard, {
    Name = "Número guardable",
    Min = 0,
    Max = 100,
    Default = 25,
    Bind = "lab_slider"
})

NX:Input(BindCard, {
    Name = "Texto guardable",
    Placeholder = "Escribe algo",
    Bind = "lab_input"
})

NX:ColorPicker(BindCard, {
    Name = "Color guardable",
    Default = NX.Theme.Cian,
    Bind = "lab_color"
})


NX:Bind("lab_toggle", BindToggle)
NX:Bind("lab_slider", BindSlider)
NX:Bind("lab_input", BindInput)
NX:Bind("lab_color", BindColor)

NX:Button(BindCard, {
    Name = "Guardar preferencias",
    Callback = function()
        local ok, err = NX:SaveBindings("nexus_bindings_lab", {
            Source = "NEXUS LAB"
        })
        BindStatus:Set(ok and "Estado: preferencias guardadas" or "Error: " .. tostring(err))
    end
})

NX:Button(BindCard, {
    Name = "Cargar preferencias",
    Callback = function()
        local extra, err = NX:LoadBindings("nexus_bindings_lab")
        if extra then
            BindStatus:Set("Estado: preferencias restauradas")
        else
            BindStatus:Set("Error: " .. tostring(err))
        end
    end
})
local ProfileCard = LabTab:Card("PERFILES")
local ProfileStatus = NX:Label(ProfileCard, "Estado: crea un perfil")

local ProfileNameInput = NX:Input(ProfileCard, {
    Name = "Nombre del perfil",
    Placeholder = "Ejemplo: Farm"
})

local ProfileList = NX:Dropdown(ProfileCard, {
    Name = "Perfiles guardados",
    Placeholder = "Seleccionar perfil",
    Values = NX:ListProfiles(),
    Searchable = true,
    Callback = function(value)
        ProfileNameInput:Set(value)
        ProfileStatus:Set("Perfil seleccionado: " .. tostring(value))
    end
})

local function refreshProfiles()
    ProfileList:Refresh(NX:ListProfiles())
end

NX:Button(ProfileCard, {
    Name = "Guardar perfil",
    Callback = function()
        local name = ProfileNameInput:Get()
        local ok, err = NX:SaveProfile(name, {
            CreatedFrom = "NEXUS LAB"
        })

        if ok then
            refreshProfiles()
            ProfileList:Set(name)
            ProfileStatus:Set("Perfil guardado: " .. tostring(name))
        else
            ProfileStatus:Set("Error: " .. tostring(err))
        end
    end
})

NX:Button(ProfileCard, {
    Name = "Cargar perfil",
    Callback = function()
        local name = ProfileNameInput:Get()
        local extra, err = NX:LoadProfile(name)
        ProfileStatus:Set(extra and "Perfil cargado: " .. tostring(name) or "Error: " .. tostring(err))
    end
})

NX:Button(ProfileCard, {
    Name = "Borrar perfil",
    Callback = function()
        local name = ProfileNameInput:Get()
        local ok, err = NX:DeleteProfile(name)

        if ok then
            refreshProfiles()
            ProfileStatus:Set("Perfil borrado: " .. tostring(name))
        else
            ProfileStatus:Set("Error: " .. tostring(err))
        end
    end
})
local AccordionCard = LabTab:Card("ACCORDION")
local AccordionStatus = NX:Label(AccordionCard, "Estado: cerrado")

local TestAccordion = NX:Accordion(AccordionCard, {
    Name = "Controles avanzados",
    Default = false,
    Callback = function(open)
        AccordionStatus:Set(open and "Estado: abierto" or "Estado: cerrado")
    end
})

NX:Paragraph(TestAccordion, {
    Title = "Grupo plegable",
    Content = "Los controles dentro de este grupo se esconden para ahorrar espacio en móvil.",
    Boxed = false
})

NX:Toggle(TestAccordion, {
    Name = "Toggle interno",
    Callback = function(state)
        AccordionStatus:Set("Toggle interno: " .. tostring(state))
    end
})

NX:Slider(TestAccordion, {
    Name = "Slider interno",
    Min = 0,
    Max = 10,
    Default = 5,
    Callback = function(value)
        AccordionStatus:Set("Slider interno: " .. tostring(value))
    end
})

NX:Button(TestAccordion, {
    Name = "Botón interno",
    Callback = function()
        AccordionStatus:Set("Botón interno correcto")
    end
})
local CleanupCard = LabTab:Card("LIMPIEZA DE UI")

NX:Button(CleanupCard, {
    Name = "Probar cierre total",
    Callback = function()
        NX:Notify("Prueba activa", "Esta notificación y el diálogo deben desaparecer al cerrar.")

        NX:Dialog({
            Title = "Prueba de limpieza",
            Content = "Toca el botón rojo. NC HUB, este diálogo y la notificación deben desaparecer juntos.",
            Buttons = {
                {
                    Name = "Cerrar NC HUB",
                    Variant = "danger",
                    Callback = function()
                        Window:Destroy()
                    end
                }
            }
        })
    end
})
local DashboardCard = LabTab:Card("DASHBOARD EN VIVO")

local LiveKeyValue = NX:KeyValue(DashboardCard, {
    Name = "Estado del monitor",
    Value = "Iniciando",
    Color = NX.Theme.Cian
})

local LiveStat = NX:Stat(DashboardCard, {
    Name = "Segundos activos",
    Value = "0",
    Color = NX.Theme.Rose
})

local LiveProgress = NX:Progress(DashboardCard, {
    Name = "Ciclo de prueba",
    Value = 0,
    Max = 20,
    Color = NX.Theme.Cian,
    Format = function(value, max)
        return tostring(value) .. " / " .. tostring(max)
    end
})

task.spawn(function()
    local seconds = 0
    while Window.Gui and Window.Gui.Parent do
        seconds = seconds + 1
        local cycle = seconds % 21

        LiveKeyValue:Set(cycle == 20 and "Completado" or "Actualizando")
        LiveStat:Set(tostring(seconds))
        LiveProgress:Set(cycle, 20)

        task.wait(1)
    end
end)

FinishLoading("NC HUB listo")
NX:Notify("NC HUB", "Módulo universal cargado")
