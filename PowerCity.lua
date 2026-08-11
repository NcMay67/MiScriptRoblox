-- ==========================================
-- NC HUB | POWER A CITY
-- ==========================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

-- ==========================================
-- REMOTES KNIT DEL JUEGO
-- ==========================================
local Services = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_knit@1.7.0")
    :WaitForChild("knit")
    :WaitForChild("Services")

local function GetRemote(ServiceName, RemoteName)
    return Services
        :WaitForChild(ServiceName)
        :WaitForChild("RF")
        :WaitForChild(RemoteName)
end

local function Invoke(ServiceName, RemoteName, ...)
    local Success, Result = pcall(function(...)
        return GetRemote(ServiceName, RemoteName):InvokeServer(...)
    end, ...)

    return Success, Result
end

local function GetValue(Name)
    local Folders = {
        LP:FindFirstChild("leaderstats"),
        LP:FindFirstChild("PlayerData"),
        LP:FindFirstChild("DataFolder")
    }

    for _, Folder in ipairs(Folders) do
        if Folder then
            local Value = Folder:FindFirstChild(Name, true)

            if Value and Value:IsA("ValueBase") then
                return Value.Value
            end

            local Attribute = Folder:GetAttribute(Name)
            if Attribute ~= nil then
                return Attribute
            end
        end
    end

    return "—"
end

local function FormatNumber(Value)
    local Number = tonumber(Value)

    if not Number then
        return tostring(Value)
    end

    if Number >= 1000000000 then
        return string.format("%.2fB", Number / 1000000000)
    elseif Number >= 1000000 then
        return string.format("%.2fM", Number / 1000000)
    elseif Number >= 1000 then
        return string.format("%.2fK", Number / 1000)
    end

    return string.format("%.0f", Number)
end

local function Notify(Title, Content)
    WindUI:Notify({
        Title = Title,
        Content = Content,
        Duration = 4
    })
end

-- ==========================================
-- VENTANA
-- ==========================================
local Window = WindUI:CreateWindow({
    Title = "NC HUB | POWER CITY",
    Author = "By hidjcjgg",
    Folder = "NCHUBScripts",
    Icon = "solar:bolt-bold",
    Theme = "Dark",
    Size = UDim2.fromOffset(600, 470),
    NewElements = true,
    Topbar = {
        Height = 44,
        ButtonsType = "Mac"
    }
})

local SeccionRed = Window:Section({
    Title = "RED ELÉCTRICA"
})

local SeccionAcciones = Window:Section({
    Title = "OPERACIONES"
})

local SeccionSistema = Window:Section({
    Title = "SISTEMA"
})

-- ==========================================
-- DASHBOARD
-- ==========================================
local DashboardTab = SeccionRed:Tab({
    Title = "Dashboard",
    Icon = "solar:home-2-bold"
})

local StatsCard = DashboardTab:Section({
    Title = "⚡ ESTADO DE TU RED",
    Box = true,
    BoxBorder = true
})

local CashLabel = StatsCard:Section({
    Title = "💵 Cash: cargando..."
})

local ExpansionLabel = StatsCard:Section({
    Title = "🗺️ Expansión: cargando..."
})

local OfflineLabel = StatsCard:Section({
    Title = "💤 Ganancia offline: cargando..."
})

local ElectricityLabel = StatsCard:Section({
    Title = "⚡ Electricidad total: cargando..."
})

local StolenLabel = StatsCard:Section({
    Title = "🕵️ Electricidad robada: cargando..."
})

local ZoneLabel = StatsCard:Section({
    Title = "📍 Zona prioritaria: cargando..."
})

local WallLabel = StatsCard:Section({
    Title = "🧱 Nivel de pared: cargando..."
})

local function RefreshDashboard()
    CashLabel:SetTitle("💵 Cash: $" .. FormatNumber(GetValue("Cash")))
    OfflineLabel:SetTitle("💤 Ganancia offline: $" .. FormatNumber(GetValue("OfflineCashUnclaimed")))
    ElectricityLabel:SetTitle("⚡ Electricidad total: " .. FormatNumber(GetValue("LifetimeElectricity")))
    StolenLabel:SetTitle("🕵️ Electricidad robada: " .. FormatNumber(GetValue("LifetimeElectricityStolen")))
    ZoneLabel:SetTitle("📍 Zona prioritaria: " .. FormatNumber(GetValue("PriorityCityZone")))
    WallLabel:SetTitle("🧱 Nivel de pared: " .. FormatNumber(GetValue("Wall")))

    local Success, Level = Invoke("PlotService", "GetExpansionLevel")

    if Success then
        ExpansionLabel:SetTitle("🗺️ Expansión: nivel " .. FormatNumber(Level))
    else
        ExpansionLabel:SetTitle("🗺️ Expansión: no disponible")
    end
end

DashboardTab:Button({
    Title = "Actualizar Dashboard",
    Callback = function()
        RefreshDashboard()
        Notify("Power City", "Datos actualizados.")
    end
})

-- ==========================================
-- ACCIONES NORMALES CONFIRMADAS
-- ==========================================
local OperationsTab = SeccionAcciones:Tab({
    Title = "Acciones",
    Icon = "solar:bolt-bold"
})

local MoneyCard = OperationsTab:Section({
    Title = "💵 CASH Y PARCELA",
    Box = true,
    BoxBorder = true
})

MoneyCard:Button({
    Title = "Cobrar ganancias offline",
    Desc = "El servidor revisa si tienes una recompensa pendiente.",
    Callback = function()
        local Success, Result = Invoke("PaycheckService", "CollectPaycheck")

        if Success then
            Notify("Ganancias offline", "Solicitud enviada al servidor.")
        else
            Notify("Ganancias offline", "Error: " .. tostring(Result))
        end

        task.wait(0.5)
        RefreshDashboard()
    end
})

MoneyCard:Button({
    Title = "Comprar siguiente expansión",
    Desc = "El servidor revisa tu Cash, requisitos y nivel actual.",
    Callback = function()
        local Success, Result = Invoke("PlotService", "BuyExpansion")

        if Success then
            Notify("Expansión", "Solicitud enviada al servidor.")
        else
            Notify("Expansión", "Error: " .. tostring(Result))
        end

        task.wait(0.5)
        RefreshDashboard()
    end
})

local CityCard = OperationsTab:Section({
    Title = "🏙️ CIUDAD",
    Box = true,
    BoxBorder = true
})

CityCard:Button({
    Title = "Mejorar ciudad 4",
    Desc = "Usa el ID de ciudad que capturaste: 4.",
    Callback = function()
        local Success, Result = Invoke("CityService", "UpgradeCity", "4")

        if Success then
            Notify("Ciudad", "Solicitud de mejora enviada.")
        else
            Notify("Ciudad", "Error: " .. tostring(Result))
        end
    end
})

local GeneratorCard = OperationsTab:Section({
    Title = "⚡ GENERADOR CAPTURADO",
    Box = true,
    BoxBorder = true
})

GeneratorCard:Button({
    Title = "Comprar Large Nuclear Plant",
    Desc = "Compra normal del generador que capturaste.",
    Callback = function()
        local Success, Result = Invoke("ShopService", "BuyItem", "LargeNuclearPlant")

        if Success then
            Notify("Generador", "Solicitud de compra enviada.")
        else
            Notify("Generador", "Error: " .. tostring(Result))
        end
    end
})

GeneratorCard:Button({
    Title = "Colocar Large Nuclear Plant",
    Desc = "Zona 8 | X 7.5 | Z -7.5 | Rotación 0. Úsalo solo si sigue libre.",
    Callback = function()
        local Success, Result = Invoke(
            "BuildService",
            "PlaceBuilding",
            "8",
            "LargeNuclearPlant",
            7.5,
            -7.5,
            0
        )

        if Success then
            Notify("Generador", "Solicitud de colocación enviada.")
        else
            Notify("Generador", "Error: " .. tostring(Result))
        end
    end
})

-- ==========================================
-- GUÍA DEL JUEGO
-- ==========================================
local GuideTab = SeccionRed:Tab({
    Title = "Guía",
    Icon = "solar:info-circle-bold"
})

local GuideCard = GuideTab:Section({
    Title = "🧠 RED ELÉCTRICA",
    Box = true,
    BoxBorder = true
})

GuideCard:Section({
    Title = "Los generadores producen energía según su tipo, zona y clima."
})

GuideCard:Section({
    Title = "Las baterías guardan el excedente de energía."
})

GuideCard:Section({
    Title = "Las ciudades convierten energía suministrada en Cash/s."
})

GuideCard:Section({
    Title = "Las paredes y tokens mejoran Cash, defensa y tiempo offline."
})

-- ==========================================
-- SISTEMA
-- ==========================================
local SystemTab = SeccionSistema:Tab({
    Title = "Herramientas",
    Icon = "solar:settings-bold"
})

SystemTab:Button({
    Title = "Cargar Dark Dex",
    Callback = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"
        ))()
    end
})

SystemTab:Button({
    Title = "Cargar SimpleSpy",
    Callback = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"
        ))()
    end
})

SystemTab:Button({
    Title = "Cerrar Hub",
    Callback = function()
        Window:Destroy()
    end
})

-- ==========================================
-- ACTUALIZACIÓN LIGERA
-- ==========================================
task.spawn(function()
    while task.wait(5) do
        pcall(RefreshDashboard)
    end
end)

RefreshDashboard()

WindUI:Notify({
    Title = "NC HUB | POWER CITY",
    Content = "Módulo cargado correctamente.",
    Duration = 5
})
