-- =========================================================
-- NC HUB | Factory Tycoon
-- By hidjcjgg
-- Módulo NEXUS NC — PlaceId: 15197136141
-- =========================================================

local BASE_URL = "https://raw.githubusercontent.com/NcMay67/MiScriptRoblox/refs/heads/main/"
local NX = loadstring(game:HttpGet(BASE_URL .. "NexusNc.lua"))()

local FinishLoading = NX:Loading({
    Title = "NC HUB",
    Text = "Cargando Factory Tycoon"
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local StartedAt = os.time()

local Window = NX:Window({
    Title = "NC HUB",
    Subtitle = "By hidjcjgg",
    Width = 520,
    Height = 350
})

-- =========================================================
-- UTILIDADES DEL JUEGO
-- =========================================================

local function getDataFolder()
    return LocalPlayer:FindFirstChild("DataFolder")
end

local function getNumber(folder, name)
    if not folder then return 0 end

    local value = folder:FindFirstChild(name)
    if value and (value:IsA("NumberValue") or value:IsA("IntValue")) then
        return value.Value
    end

    return 0
end

local function getTycoon()
    local owned = LocalPlayer:FindFirstChild("TycoonOwned")
    if owned and owned.Value and owned.Value:IsA("Instance") then
        return owned.Value
    end

    return nil
end

local function getEvents()
    return ReplicatedStorage:FindFirstChild("Events")
end

local function getHumanoid()
    local character = LocalPlayer.Character
    if not character then return nil end
    return character:FindFirstChildOfClass("Humanoid")
end

local function formatNumber(value)
    value = tonumber(value) or 0

    if value >= 1000000000 then
        return string.format("%.1fB", value / 1000000000)
    elseif value >= 1000000 then
        return string.format("%.1fM", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fK", value / 1000)
    end

    return tostring(math.floor(value))
end

local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%dh %dm %ds", hours, minutes, secs)
end

local function hasRobuxRequirement(button)
    return button:FindFirstChild("GamepassID")
        or button:FindFirstChild("GamePassID")
        or button:FindFirstChild("ProductID")
        or button:FindFirstChild("DevProductID")
        or button:FindFirstChild("DeveloperProductID")
end

local function stopFactoryLoop(id)
    if NX:IsLoopRunning(id) then
        NX:StopLoop(id)
    end
end

local function startFactoryLoop(id, interval, callback)
    if NX:IsLoopRunning(id) then return end

    NX:StartLoop(id, interval, function()
        local ok, err = pcall(callback)
        if not ok then
            warn("[NC HUB Factory] " .. tostring(err))
        end
    end, true)
end

-- =========================================================
-- DASHBOARD
-- =========================================================

local FactorySection = Window:Section("FACTORY TYCOON")
local DashboardTab = FactorySection:Tab("Inicio")

local OverviewCard = DashboardTab:Card("ESTADO DE LA FÁBRICA")

local MoneyStat = NX:Stat(OverviewCard, {
    Name = "Efectivo",
    Value = "$0",
    Color = NX.Theme.Cian
})

local GemsStat = NX:Stat(OverviewCard, {
    Name = "Gemas",
    Value = "0",
    Color = NX.Theme.Rose
})

local FactoryStatus = NX:KeyValue(OverviewCard, {
    Name = "Fábrica",
    Value = "Buscando...",
    Color = NX.Theme.Accent
})

local SessionStatus = NX:KeyValue(OverviewCard, {
    Name = "Sesión",
    Value = "0h 0m 0s",
    Color = NX.Theme.Cian
})

NX:Paragraph(OverviewCard, {
    Title = "Información",
    Content = "Los valores se leen desde DataFolder. Las automatizaciones solo actúan sobre la fábrica asignada a tu jugador.",
    Boxed = false
})

-- =========================================================
-- AUTOMATIZACIÓN
-- =========================================================

local AutomationTab = FactorySection:Tab("Automatización")
local AutomationCard = AutomationTab:Card("AUTO-FARM")
local AutomationStatus = NX:Label(AutomationCard, "Estado: ninguna automatización activa")

local AutoCollectEnabled = false
local AutoBuyEnabled = false
local AutoRebirthEnabled = false

local function updateAutomationStatus()
    local active = {}

    if AutoCollectEnabled then table.insert(active, "Cobrar") end
    if AutoBuyEnabled then table.insert(active, "Comprar") end
    if AutoRebirthEnabled then table.insert(active, "Rebirth") end

    if #active == 0 then
        AutomationStatus:Set("Estado: ninguna automatización activa")
    else
        AutomationStatus:Set("Activas: " .. table.concat(active, " · "))
    end
end

NX:Toggle(AutomationCard, {
    Name = "Auto-Cobrar dinero",
    Default = false,
    Bind = "factory_auto_collect",
    Callback = function(enabled)
        AutoCollectEnabled = enabled == true

        if AutoCollectEnabled then
            startFactoryLoop("factory_auto_collect", 0.75, function()
                local tycoon = getTycoon()
                local events = getEvents()
                if not tycoon or not events then return end

                local build = tycoon:FindFirstChild("Build")
                local collectPart = build and build:FindFirstChild("Collect")
                local collectRemote = events:FindFirstChild("CollectMoney")

                if collectPart and collectRemote and collectRemote:IsA("RemoteEvent") then
                    collectRemote:FireServer(collectPart)
                end
            end)
        else
            stopFactoryLoop("factory_auto_collect")
        end

        updateAutomationStatus()
    end
})

NX:Toggle(AutomationCard, {
    Name = "Auto-Comprar mejoras",
    Default = false,
    Bind = "factory_auto_buy",
    Callback = function(enabled)
        AutoBuyEnabled = enabled == true

        if AutoBuyEnabled then
            startFactoryLoop("factory_auto_buy", 0.8, function()
                local tycoon = getTycoon()
                local data = getDataFolder()
                local events = getEvents()
                if not tycoon or not data or not events then return end

                local buttons = tycoon:FindFirstChild("Buttons")
                local buyRemote = events:FindFirstChild("ButtonUsed")
                local money = getNumber(data, "Money")
                if not buttons or not buyRemote or not buyRemote:IsA("RemoteEvent") then return end

                -- Compra una mejora por ciclo para evitar ráfagas de remotes.
                for _, button in ipairs(buttons:GetChildren()) do
                    local price = button:FindFirstChild("Price")
                    local visible = button:FindFirstChild("IsButtonVisible")

                    if price and visible and visible.Value == true
                        and not hasRobuxRequirement(button)
                        and money >= price.Value then
                        buyRemote:FireServer(button.Name)
                        break
                    end
                end
            end)
        else
            stopFactoryLoop("factory_auto_buy")
        end

        updateAutomationStatus()
    end
})

NX:Paragraph(AutomationCard, {
    Title = "Compra protegida",
    Content = "Auto-Comprar ignora botones con GamepassID, ProductID y DevProductID. Solo intenta compras normales con el dinero disponible.",
    Boxed = false
})

local BoostCard = AutomationTab:Card("X5 BOOST")
local BoostStatus = NX:Label(BoostCard, "Estado: listo para activar")

NX:Button(BoostCard, {
    Name = "Activar X5 Boost",
    Callback = function()
        local data = getDataFolder()
        local boost = data and data:FindFirstChild("Money5xBoost")

        if boost and (boost:IsA("NumberValue") or boost:IsA("IntValue")) then
            boost.Value = os.time() + 999999
            BoostStatus:Set("Estado: Boost x5 activado")
            NX:Notify("X5 Boost", "Boost de dinero activado localmente.", {
                Color = NX.Theme.Rose,
                Duration = 4
            })
        else
            BoostStatus:Set("Estado: Money5xBoost no fue encontrado")
            NX:Notify("X5 Boost", "No se encontró Money5xBoost en DataFolder.", {
                Color = NX.Theme.MacYellow,
                Duration = 4
            })
        end
    end
})

NX:Paragraph(BoostCard, {
    Title = "Boost recuperado",
    Content = "Usa el valor local Money5xBoost recuperado de tu código original.",
    Boxed = false
})

local RebirthCard = AutomationTab:Card("REBIRTH")
local RebirthStatus = NX:Label(RebirthCard, "Estado: desactivado")

NX:Toggle(RebirthCard, {
    Name = "Auto-Rebirth",
    Default = false,
    Bind = "factory_auto_rebirth",
    Callback = function(enabled)
        AutoRebirthEnabled = enabled == true

        if AutoRebirthEnabled then
            startFactoryLoop("factory_auto_rebirth", 2, function()
                local tycoon = getTycoon()
                local events = getEvents()
                local rebirthRemote = events and events:FindFirstChild("RequestRebirth")

                if tycoon and rebirthRemote and rebirthRemote:IsA("RemoteEvent") then
                    rebirthRemote:FireServer(653, 653, tycoon)
                end
            end)
            RebirthStatus:Set("Estado: comprobando requisitos cada 2 segundos")
        else
            stopFactoryLoop("factory_auto_rebirth")
            RebirthStatus:Set("Estado: desactivado")
        end

        updateAutomationStatus()
    end
})

-- =========================================================
-- JUGADOR
-- =========================================================

local PlayerSection = Window:Section("JUGADOR")
local MovementTab = PlayerSection:Tab("Movimiento")
local MovementCard = MovementTab:Card("VELOCIDAD Y SALTO")

local WalkSpeed = 16
local JumpPower = 50

NX:Slider(MovementCard, {
    Name = "Velocidad",
    Min = 16,
    Max = 120,
    Step = 1,
    Default = 16,
    Bind = "factory_walk_speed",
    Callback = function(value)
        WalkSpeed = value
        local humanoid = getHumanoid()
        if humanoid then humanoid.WalkSpeed = WalkSpeed end
    end
})

NX:Slider(MovementCard, {
    Name = "Salto",
    Min = 50,
    Max = 200,
    Step = 1,
    Default = 50,
    Bind = "factory_jump_power",
    Callback = function(value)
        JumpPower = value
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = JumpPower
        end
    end
})

NX:Paragraph(MovementCard, {
    Title = "Persistencia",
    Content = "La velocidad y el salto seleccionados se vuelven a aplicar cuando tu personaje reaparece.",
    Boxed = false
})

-- =========================================================
-- SISTEMA Y PERFILES
-- =========================================================

local SystemSection = Window:Section("SISTEMA")
local ProfilesTab = SystemSection:Tab("Perfiles")
local ProfilesCard = ProfilesTab:Card("PERFILES DE FACTORY")

NX:ProfilePanel(ProfilesCard, {
    Namespace = "FactoryTycoon",
    StatusText = "Perfil de Factory: ninguno",
    Placeholder = "Ejemplo: Farm rápido",
    Extra = {
        Module = "FactoryTycoon",
        PlaceId = game.PlaceId
    }
})

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
        Window:Destroy()
    end
})

-- =========================================================
-- SINCRONIZACIÓN Y CARGA
-- =========================================================

if not NX:IsLoopRunning("factory_dashboard") then
    NX:StartLoop("factory_dashboard", 1, function()
        local data = getDataFolder()
        local money = getNumber(data, "Money")
        local gems = getNumber(data, "Gems")
        local tycoon = getTycoon()

        MoneyStat:Set("$" .. formatNumber(money))
        GemsStat:Set(formatNumber(gems))
        FactoryStatus:Set(tycoon and "Asignada" or "Esperando parcela")
        SessionStatus:Set(formatTime(os.time() - StartedAt))
    end, true)
end

if not NX:IsLoopRunning("factory_movement_sync") then
    NX:StartLoop("factory_movement_sync", 1, function()
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = WalkSpeed
            humanoid.UseJumpPower = true
            humanoid.JumpPower = JumpPower
        end
    end, true)
end

FinishLoading("Factory Tycoon listo")
NX:Notify("NC HUB", "Factory Tycoon cargado", {
    Color = NX.Theme.Cian,
    Duration = 4
})
