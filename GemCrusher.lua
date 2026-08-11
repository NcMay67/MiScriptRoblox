--[[
    NC HUB - BUILD A GEM CRUSHER
    Dashboard y herramientas autorizadas
    Autor: hidjcjgg
]]

--==================================================
-- SERVICIOS PRINCIPALES
--==================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TiempoInicio = os.time()
local Jugador = Players.LocalPlayer

--==================================================
-- CARGAR WINDUI
--==================================================

local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

--==================================================
-- SERVICIOS DEL JUEGO
--==================================================

local Paquetes = ReplicatedStorage:WaitForChild("Packages")
local Remotos = ReplicatedStorage:WaitForChild("Remotes")

local ServicioDatos
local DatosCargados, ErrorDatos = pcall(function()
    ServicioDatos = require(
        Paquetes:WaitForChild("DataService")
    ).client
end)

if not DatosCargados or not ServicioDatos then
    warn("No se pudo cargar DataService:", ErrorDatos)
end

--==================================================
-- CREAR VENTANA
--==================================================

local Ventana = WindUI:CreateWindow({
    Title = "NC HUB | Gem Crusher",
    Author = "By hidjcjgg",
    Folder = "NCHUBScripts",
    Icon = "solar:gem-bold",
    Theme = "Dark",
    Size = UDim2.fromOffset(580, 460),
    NewElements = true,
    Topbar = {
        Height = 44,
        ButtonsType = "Mac"
    }
})

--==================================================
-- PESTAÑAS
--==================================================

local PestanaInicio = Ventana:Tab({
    Title = "Dashboard",
    Icon = "solar:home-2-bold"
})

local PestanaJugador = Ventana:Tab({
    Title = "Jugador",
    Icon = "solar:user-bold"
})

local PestanaRenacer = Ventana:Tab({
    Title = "Rebirth",
    Icon = "solar:restart-bold"
})

local PestanaSistema = Ventana:Tab({
    Title = "Sistema",
    Icon = "solar:settings-bold"
})

--==================================================
-- FUNCIONES AUXILIARES
--==================================================

local function ObtenerDato(clave, valorPredeterminado)
    if not ServicioDatos then
        return valorPredeterminado
    end

    local Exito, Valor = pcall(function()
        return ServicioDatos:get(clave)
    end)

    if Exito and Valor ~= nil then
        return Valor
    end

    return valorPredeterminado
end

local function FormatearNumero(valor)
    valor = tonumber(valor) or 0

    local Sufijos = {
        {1e15, "Q"},
        {1e12, "T"},
        {1e9, "B"},
        {1e6, "M"},
        {1e3, "K"}
    }

    for _, Datos in ipairs(Sufijos) do
        local Cantidad = Datos[1]
        local Sufijo = Datos[2]

        if valor >= Cantidad then
            return string.format("%.1f%s", valor / Cantidad, Sufijo)
        end
    end

    return tostring(math.floor(valor))
end

local function ObtenerHumanoide()
    local Personaje = Jugador.Character
        or Jugador.CharacterAdded:Wait()

    return Personaje:FindFirstChildOfClass("Humanoid")
end

--==================================================
-- DASHBOARD
--==================================================

local SeccionEstadisticas = PestanaInicio:Section({
    Title = "📊 ESTADÍSTICAS",
    Box = true,
    BoxBorder = true
})

local EtiquetaDinero = SeccionEstadisticas:Section({
    Title = "💵 Dinero: $0"
})

local EtiquetaRenacimientos = SeccionEstadisticas:Section({
    Title = "🔁 Rebirths: 0"
})

local EtiquetaPoder = SeccionEstadisticas:Section({
    Title = "⚡ Poder: 0"
})

local EtiquetaVelocidad = SeccionEstadisticas:Section({
    Title = "🏃 Velocidad: 0"
})

local EtiquetaSuerte = SeccionEstadisticas:Section({
    Title = "🍀 Suerte: 0"
})

local function ActualizarDashboard()
    local Dinero = ObtenerDato("money", 0)
    local Renacimientos = ObtenerDato("rebirth", 0)
    local Poder = ObtenerDato("power", 0)
    local Velocidad = ObtenerDato("speed", 0)
    local Suerte = ObtenerDato("luck", 0)

    EtiquetaDinero:SetTitle(
        "💵 Dinero: $" .. FormatearNumero(Dinero)
    )

    EtiquetaRenacimientos:SetTitle(
        "🔁 Rebirths: " .. FormatearNumero(Renacimientos)
    )

    EtiquetaPoder:SetTitle(
        "⚡ Poder: " .. FormatearNumero(Poder)
    )

    EtiquetaVelocidad:SetTitle(
        "🏃 Velocidad: " .. FormatearNumero(Velocidad)
    )

    EtiquetaSuerte:SetTitle(
        "🍀 Suerte: " .. FormatearNumero(Suerte)
    )
end

-- Actualización inicial
ActualizarDashboard()

-- Actualización mediante señales de DataService
if ServicioDatos then
    local ClavesDatos = {
        "money",
        "rebirth",
        "power",
        "speed",
        "luck"
    }

    for _, Clave in ipairs(ClavesDatos) do
        pcall(function()
            local Senal = ServicioDatos:getChangedSignal(Clave)

            if Senal then
                Senal:Connect(ActualizarDashboard)
            end
        end)
    end
end

-- Actualización alternativa usando leaderstats.Money
task.spawn(function()
    local Leaderstats = Jugador:FindFirstChild("leaderstats")
        or Jugador:WaitForChild("leaderstats", 10)

    if not Leaderstats then
        return
    end

    local Dinero = Leaderstats:FindFirstChild("Money")

    if Dinero then
        Dinero:GetPropertyChangedSignal("Value"):Connect(function()
            EtiquetaDinero:SetTitle(
                "💵 Dinero: $" .. FormatearNumero(Dinero.Value)
            )
        end)
    end
end)

--==================================================
-- JUGADOR
--==================================================

local SeccionMovimiento = PestanaJugador:Section({
    Title = "MOVIMIENTO",
    Box = true,
    BoxBorder = true
})

SeccionMovimiento:Slider({
    Title = "Velocidad",
    Value = {
        Min = 16,
        Max = 100,
        Default = 16
    },
    Step = 1,
    Callback = function(Valor)
        local Humanoide = ObtenerHumanoide()

        if Humanoide then
            Humanoide.WalkSpeed = tonumber(Valor) or 16
        end
    end
})

SeccionMovimiento:Slider({
    Title = "Salto",
    Value = {
        Min = 50,
        Max = 150,
        Default = 50
    },
    Step = 1,
    Callback = function(Valor)
        local Humanoide = ObtenerHumanoide()

        if Humanoide then
            Humanoide.UseJumpPower = true
            Humanoide.JumpPower = tonumber(Valor) or 50
        end
    end
})

--==================================================
-- REBIRTH
--==================================================

local SeccionRenacimiento = PestanaRenacer:Section({
    Title = "SOLICITUDES DE REBIRTH",
    Box = true,
    BoxBorder = true
})

local RemotoRenacer = Remotos:FindFirstChild("MakeRebirth")
local RenacerOcupado = false

local function SolicitarRenacer(Modo)
    if not RemotoRenacer then
        warn("No se encontró Remotes.MakeRebirth")
        return
    end

    if RenacerOcupado then
        return
    end

    RenacerOcupado = true

    local Exito, Error = pcall(function()
        if Modo == "Max" then
            RemotoRenacer:FireServer("Max")
        else
            RemotoRenacer:FireServer()
        end
    end)

    if not Exito then
        warn("Error al solicitar el rebirth:", Error)
    end

    task.delay(0.5, function()
        RenacerOcupado = false
    end)
end

SeccionRenacimiento:Button({
    Title = "Solicitar 1 rebirth",
    Callback = function()
        SolicitarRenacer("Individual")
    end
})

SeccionRenacimiento:Button({
    Title = "Solicitar máximo permitido",
    Callback = function()
        SolicitarRenacer("Max")
    end
})

-- Información de los datos encontrados
local SeccionInformacion = PestanaRenacer:Section({
    Title = "INFORMACIÓN DETECTADA",
    Box = true,
    BoxBorder = true
})

SeccionInformacion:Section({
    Title = "Remote confirmado: MakeRebirth"
})

SeccionInformacion:Section({
    Title = "Datos: money, rebirth, power, speed y luck"
})

SeccionInformacion:Section({
    Title = "OreReportBatch: evento recibido del servidor"
})

--==================================================
-- SISTEMA Y HERRAMIENTAS
--==================================================

local SeccionHerramientas = PestanaSistema:Section({
    Title = "HERRAMIENTAS",
    Box = true,
    BoxBorder = true
})

SeccionHerramientas:Button({
    Title = "Actualizar dashboard",
    Callback = function()
        ActualizarDashboard()
    end
})

SeccionHerramientas:Button({
    Title = "Mostrar datos detectados",
    Callback = function()
        print("money:", ObtenerDato("money", 0))
        print("rebirth:", ObtenerDato("rebirth", 0))
        print("power:", ObtenerDato("power", 0))
        print("speed:", ObtenerDato("speed", 0))
        print("luck:", ObtenerDato("luck", 0))
        print("conveyor:", ObtenerDato("conveyor", 0))
        print("pads:", ObtenerDato("pads", 0))
        print("drills:", ObtenerDato("drills", 0))
    end
})

--==================================================
-- DARK DEX
--==================================================

SeccionHerramientas:Button({
    Title = "Abrir Dark Dex",
    Callback = function()
        local Exito, Resultado = pcall(function()
            return loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"
            ))()
        end)

        if not Exito then
            warn("Error al cargar Dark Dex:", Resultado)
        end
    end
})

--==================================================
-- SIMPLESPY
--==================================================

SeccionHerramientas:Button({
    Title = "Abrir SimpleSpy",
    Callback = function()
        local Exito, Resultado = pcall(function()
            return loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"
            ))()
        end)

        if not Exito then
            warn("Error al cargar SimpleSpy:", Resultado)
        end
    end
})

--==================================================
-- CERRAR HUB
--==================================================

SeccionHerramientas:Button({
    Title = "Cerrar Hub",
    Callback = function()
        if Ventana and Ventana.Destroy then
            Ventana:Destroy()
        end
    end
})

--==================================================
-- ACTUALIZACIÓN DE SEGURIDAD
--==================================================

task.spawn(function()
    while task.wait(2) do
        pcall(ActualizarDashboard)
    end
end)