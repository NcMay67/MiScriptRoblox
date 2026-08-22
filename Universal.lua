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

local function setHubActivity(Id, Active, Config)
    if Active then
        Config = Config or {}
        Config.Module = "Universal"
        NX:ReportActivity(Id, Config)
    else
        NX:RemoveActivity(Id)
    end
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
        setHubActivity("universal_infinite_jump", State, {
            Name = "Salto infinito",
            Category = "Movimiento",
            Description = "Salto extra activado"
        })
    end
})


NX:Toggle(UtilityCard, {
    Name = "Noclip",
    Callback = function(State)
        Noclip = State
        setHubActivity("universal_noclip", State, {
            Name = "Noclip",
            Category = "Movimiento",
            Description = "Colisiones desactivadas"
        })
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
-- El joystick usa la dirección de la cámara: mirar arriba y
-- avanzar sube; mirar abajo y avanzar baja. Sin botones extra.
-- =========================================================
local FlyCard = MovementTab:Card("FLY PRO")
local FlyEnabled = false
local FlySpeed = 60
local FlyVelocity
local FlyGyro
local FlyConnection
local FlyControls
local LiftUntil = 0

local function getFlyControls()
    if FlyControls then
        return FlyControls
    end

    pcall(function()
        local PlayerModule = LocalPlayer:WaitForChild("PlayerScripts")
            :WaitForChild("PlayerModule")
        FlyControls = require(PlayerModule):GetControls()
    end)

    return FlyControls
end

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
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

local function startFly()
    stopFly()
    FlyEnabled = true

    local Humanoid = getHumanoid()
    local Root = getRoot()
    local Controls = getFlyControls()

    Humanoid.AutoRotate = false
    Humanoid.PlatformStand = true

    FlyVelocity = Instance.new("BodyVelocity")
    FlyVelocity.Name = "NC_FlyVelocity"
    FlyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    FlyVelocity.P = 18000
    FlyVelocity.Velocity = Vector3.new(0, 0, 0)
    FlyVelocity.Parent = Root

    FlyGyro = Instance.new("BodyGyro")
    FlyGyro.Name = "NC_FlyGyro"
    FlyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    FlyGyro.P = 35000
    FlyGyro.D = 900
    FlyGyro.CFrame = Root.CFrame
    FlyGyro.Parent = Root

    -- Despegue único. Después no vuelve a subir solo.
    LiftUntil = os.clock() + 0.18

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not FlyEnabled or not Root.Parent or not Humanoid.Parent then
            return
        end

        local Camera = workspace.CurrentCamera
        if not Camera then
            return
        end

        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

        local MoveVector = Vector3.new(0, 0, 0)
        if Controls then
            MoveVector = Controls:GetMoveVector()
        else
            local MoveDirection = Humanoid.MoveDirection
            MoveVector = Vector3.new(MoveDirection.X, 0, -MoveDirection.Z)
        end

        local CameraFrame = Camera.CFrame
        local Direction = CameraFrame.RightVector * MoveVector.X
            + CameraFrame.LookVector * -MoveVector.Z

        if Direction.Magnitude > 0.05 then
            Direction = Direction.Unit * FlySpeed
        else
            Direction = Vector3.new(0, 0, 0)
        end

        if os.clock() < LiftUntil then
            Direction = Direction + Vector3.new(0, math.max(35, FlySpeed * 0.70), 0)
        end

        FlyVelocity.Velocity = Direction
        FlyGyro.CFrame = CameraFrame
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

        setHubActivity("universal_fly", State, {
            Name = "Fly Pro",
            Category = "Movimiento",
            Description = "Vuelo relativo a cámara",
            Stop = stopFly
        })
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
-- SISTEMA Y PERFILES
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

-- =========================================================
-- NEXUS NC 2.0: CONTROL CENTER
-- =========================================================
local ControlTab = SystemSection:Tab("Control")
local HubStateCard = ControlTab:Card("ESTADO DEL HUB")

local ControlModuleValue = NX:KeyValue(HubStateCard, {
    Name = "Módulo activo",
    Value = "Universal"
})

local ControlThemeValue = NX:KeyValue(HubStateCard, {
    Name = "Tema activo",
    Value = NX.ActiveTheme or "Void"
})

local ControlStorageValue = NX:KeyValue(HubStateCard, {
    Name = "Guardado local",
    Value = NX:HasStorage() and "Disponible" or "No disponible"
})

local ActivityCard = ControlTab:Card("ACTIVIDADES")

local ActivityCount = NX:Stat(ActivityCard, {
    Name = "Funciones activas",
    Value = "0",
    Color = NX.Theme.Cian
})

local LoopCount = NX:Stat(ActivityCard, {
    Name = "Loops activos",
    Value = "0",
    Color = NX.Theme.Accent
})

local ActivitySummary = NX:Paragraph(ActivityCard, {
    Title = "Sin actividades activas",
    Content = "Las funciones que actives en NC HUB aparecerán aquí."
})

local function refreshControlCenter()
    local Activities = NX:GetActivities()
    local Loops = NX:GetActiveLoops()
    local Lines = {}

    for _, Activity in ipairs(Activities) do
        table.insert(Lines, "• " .. Activity.Name .. " — " .. Activity.Category)
    end

    ActivityCount:Set(tostring(#Activities))
    LoopCount:Set(tostring(#Loops))
    ControlModuleValue:Set("Universal")
    ControlThemeValue:Set(NX.ActiveTheme or "Void")
    ControlStorageValue:Set(NX:HasStorage() and "Disponible" or "No disponible")

    if #Lines == 0 then
        ActivitySummary:SetTitle("Sin actividades activas")
        ActivitySummary:SetContent("Las funciones que actives en NC HUB aparecerán aquí.")
    else
        ActivitySummary:SetTitle("Actividades en ejecución")
        ActivitySummary:SetContent(table.concat(Lines, "\n"))
    end
end

NX:Button(ActivityCard, {
    Name = "Actualizar estado",
    Variant = "secondary",
    Callback = refreshControlCenter
})

refreshControlCenter()

local ProfilesTab = SystemSection:Tab("Perfiles")
        
-- =========================================================
-- UBICACIONES GUARDADAS
-- Cada juego conserva su propia lista de ubicaciones.
-- =========================================================
local LocationsTab = SystemSection:Tab("Ubicaciones")
local LocationsCard = LocationsTab:Card("TELETRANSPORTE")
local LocationsStorageName = "UniversalLocations_" .. tostring(game.PlaceId)
local SavedLocations = {}
local SelectedLocationName = nil
local LocationDropdown
local LocationStatus = NX:Label(LocationsCard, "Ubicaciones: cargando...")

local function trimText(Value)
    return tostring(Value or ""):match("^%s*(.-)%s*$")
end

local function packCFrame(Value)
    local X, Y, Z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Value:GetComponents()

    return {
        X = X,
        Y = Y,
        Z = Z,
        R00 = R00,
        R01 = R01,
        R02 = R02,
        R10 = R10,
        R11 = R11,
        R12 = R12,
        R20 = R20,
        R21 = R21,
        R22 = R22
    }
end

local function unpackCFrame(Data)
    if type(Data) ~= "table" then
        return nil
    end

    local Numbers = {
        Data.X, Data.Y, Data.Z,
        Data.R00, Data.R01, Data.R02,
        Data.R10, Data.R11, Data.R12,
        Data.R20, Data.R21, Data.R22
    }

    for _, Value in ipairs(Numbers) do
        if type(Value) ~= "number" then
            return nil
        end
    end

    return CFrame.new(
        Data.X, Data.Y, Data.Z,
        Data.R00, Data.R01, Data.R02,
        Data.R10, Data.R11, Data.R12,
        Data.R20, Data.R21, Data.R22
    )
end

local function findSavedLocation(Name)
    for Index, Entry in ipairs(SavedLocations) do
        if Entry.Name == Name then
            return Entry, Index
        end
    end

    return nil, nil
end

local function getLocationNames()
    local Names = {}

    for _, Entry in ipairs(SavedLocations) do
        table.insert(Names, Entry.Name)
    end

    table.sort(Names, function(A, B)
        return A:lower() < B:lower()
    end)

    return Names
end

local function saveLocations()
    local Success, Reason = NX:SaveConfig(LocationsStorageName, {
        Version = 1,
        PlaceId = game.PlaceId,
        Locations = SavedLocations
    })

    if not Success then
        NX:Notify("Ubicaciones", "No se pudo guardar: " .. tostring(Reason))
        return false
    end

    return true
end

local function updateLocationStatus()
    if #SavedLocations == 0 then
        LocationStatus:Set("Ubicaciones: ninguna guardada")
    else
        LocationStatus:Set("Ubicaciones guardadas: " .. tostring(#SavedLocations))
    end
end

local function refreshLocationList(PreferredName)
    local Names = getLocationNames()

    if LocationDropdown then
        LocationDropdown:Refresh(Names)

        if PreferredName and table.find(Names, PreferredName) then
            LocationDropdown:Set(PreferredName)
        elseif SelectedLocationName and table.find(Names, SelectedLocationName) then
            LocationDropdown:Set(SelectedLocationName)
        else
            SelectedLocationName = nil
            LocationDropdown:Set(nil)
        end
    end

    updateLocationStatus()
end

local LoadedLocationData = NX:LoadConfig(LocationsStorageName)

if type(LoadedLocationData) == "table" and type(LoadedLocationData.Locations) == "table" then
    for _, Entry in ipairs(LoadedLocationData.Locations) do
        if type(Entry) == "table"
            and type(Entry.Name) == "string"
            and unpackCFrame(Entry.CFrame) then
            table.insert(SavedLocations, {
                Name = Entry.Name,
                CFrame = Entry.CFrame
            })
        end
    end
end

local LocationNameInput = NX:Input(LocationsCard, {
    Name = "Nombre de ubicación",
    Placeholder = "Ejemplo: Mina, tienda o casa",
    ClearOnFocus = false,
    Finished = true
})

LocationDropdown = NX:Dropdown(LocationsCard, {
    Name = "Ubicación guardada",
    Placeholder = "Elige una ubicación",
    Values = getLocationNames(),
    Callback = function(Name)
        SelectedLocationName = Name
    end
})

NX:Button(LocationsCard, {
    Name = "Guardar mi ubicación actual",
    Variant = "success",
    Callback = function()
        local Name = trimText(LocationNameInput:Get())

        if Name == "" then
            NX:Notify("Ubicaciones", "Primero escribe un nombre para la ubicación")
            return
        end

        local Root = getRoot()
        local Existing, Index = findSavedLocation(Name)
        local Entry = {
            Name = Name,
            CFrame = packCFrame(Root.CFrame)
        }

        if Existing then
            SavedLocations[Index] = Entry
        else
            table.insert(SavedLocations, Entry)
        end

        if saveLocations() then
            refreshLocationList(Name)
            NX:Notify("Ubicaciones", "Guardada: " .. Name)
        end
    end
})

NX:Button(LocationsCard, {
    Name = "Teletransportarme a la seleccionada",
    Callback = function()
        if not SelectedLocationName then
            NX:Notify("Ubicaciones", "Elige una ubicación de la lista")
            return
        end

        local Entry = findSavedLocation(SelectedLocationName)
        local TargetCFrame = Entry and unpackCFrame(Entry.CFrame)

        if not TargetCFrame then
            NX:Notify("Ubicaciones", "La ubicación seleccionada no es válida")
            return
        end

        local Root = getRoot()
        Root.CFrame = TargetCFrame + Vector3.new(0, 3, 0)
        NX:Notify("Ubicaciones", "Teletransportado a: " .. SelectedLocationName)
    end
})

NX:Button(LocationsCard, {
    Name = "Borrar ubicación seleccionada",
    Variant = "danger",
    Callback = function()
        if not SelectedLocationName then
            NX:Notify("Ubicaciones", "Elige una ubicación para borrarla")
            return
        end

        local _, Index = findSavedLocation(SelectedLocationName)

        if not Index then
            NX:Notify("Ubicaciones", "No encontré esa ubicación")
            return
        end

        local RemovedName = SelectedLocationName
        table.remove(SavedLocations, Index)
        SelectedLocationName = nil

        if saveLocations() then
            refreshLocationList()
            NX:Notify("Ubicaciones", "Borrada: " .. RemovedName)
        end
    end
})

refreshLocationList()

-- =========================================================
-- HERRAMIENTAS
-- =========================================================
local ToolsTab = SystemSection:Tab("Herramientas")
local ToolsCard = ToolsTab:Card("UTILIDADES")

NX:Button(ToolsCard, {
    Name = "Abrir Dark Dex",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end
})

NX:Button(ToolsCard, {
    Name = "Abrir SimpleSpy",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))()
    end
})

NX:Button(ToolsCard, {
    Name = "Cerrar NC HUB",
    Variant = "danger",
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

FinishLoading("NC HUB listo")
NX:Notify("NC HUB", "Módulo universal cargado")
