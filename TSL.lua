--[[
    NC HUB - THE STRONGER LIFTER | MASTER DEFINITIVE EDITION (V5.0)
    AUTOR: hidjcjgg
    ESTILO: BENTO BOX HACKER (PURPLE/CYAN)
    TODO-EN-UNO: FARM, HACKS, TELEPORTS, EGGS, BOOSTS
]]

local LP = game.Players.LocalPlayer
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- ==========================================
-- 0. CONFIGURACIÓN Y VARIABLES
-- ==========================================
local AutoLift, AutoSell, AutoBuy, AutoStage, AutoEgg = false, false, false, false, false
local SelectedEgg = "Basic Egg"
local VelocidadUsuario = 16
local AntiAFK = true
local Noclip = false

-- LISTA DE PESAS (EXTRAÍDA DE TUS ARCHIVOS)
local WeightsList = {"Stick", "Mouse", "Water", "Soccer Ball", "Bottle", "Textbook", "Bucket", "Wood", "Guitar", "Dumbbell", "Chair", "Cart", "TV", "Bicycle", "Desk", "Bed", "Log", "Canoe", "Tyre", "Refrigerator", "Drum", "Hydrant", "Piano", "Motorcycle", "Safe", "Flag", "ATM", "RX-7", "EVO", "G-Class", "Van", "Tree", "Container", "Sailboat", "Bus", "Truck"}

-- FUNCIONES DE SEGURIDAD
local function SafeSpeed()
    pcall(function()
        if LP.Character and LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.WalkSpeed = VelocidadUsuario
        end
    end)
end

-- ==========================================
-- 1. CREACIÓN DE LA INTERFAZ (BENTO STYLE)
-- ==========================================
local Window = WindUI:CreateWindow({
    Title = "NC HUB | TSL MASTER",
    Author = "By hidjcjgg",
    Folder = "NCHUBScripts",
    Icon = "solar:bolt-circle-bold",
    Theme = "Dark",
    Size = UDim2.fromOffset(600, 500),
    NewElements = true,
    Topbar = { Height = 44, ButtonsType = "Mac" }
})

-- SECCIONES DEL SIDEBAR
local SeccionHome = Window:Section({ Title = "ESTADÍSTICAS" })
local SeccionFarm = Window:Section({ Title = "AUTOMATIZACIÓN" })
local SeccionHacks = Window:Section({ Title = "LABORATORIO HACK" })
local SeccionTP = Window:Section({ Title = "TELEPORTES" })
local SeccionPlayer = Window:Section({ Title = "JUGADOR" })
local SeccionSis = Window:Section({ Title = "SISTEMA" })

-- ==========================================
-- 2. PESTAÑA: DASHBOARD (MONITOR REAL)
-- ==========================================
local HomeTab = SeccionHome:Tab({ Title = "Dashboard", Icon = "solar:widget-bold" })
local StatsCard = HomeTab:Section({ Title = "📊 MONITOR DE ESTADO", Box = true, BoxBorder = true })
local MuscleL = StatsCard:Section({ Title = "💪 Músculo: 0" })
local StageL = StatsCard:Section({ Title = "🆙 Etapa: 0" })
local CoinsL = StatsCard:Section({ Title = "💰 Monedas: 0" })
local FameL = StatsCard:Section({ Title = "🌟 Fama: 0" })

task.spawn(function()
    while true do
        pcall(function()
            local ls = LP:FindFirstChild("leaderstats")
            if ls then
                MuscleL:SetTitle("💪 Músculo: " .. (ls:FindFirstChild("Muscle") and ls.Muscle.Value or 0))
                StageL:SetTitle("🆙 Etapa: " .. (ls:FindFirstChild("Stage") and ls.Stage.Value or 0))
                CoinsL:SetTitle("💰 Monedas: " .. (ls:FindFirstChild("Coins") and ls.Coins.Value or 0))
                FameL:SetTitle("🌟 Fama: " .. (ls:FindFirstChild("Fame") and ls.Fame.Value or 0))
            end
        end)
        task.wait(1)
    end
end)

-- ==========================================
-- 3. PESTAÑA: AUTO-FARM (LÓGICA MEJORADA)
-- ==========================================
local FarmTab = SeccionFarm:Tab({ Title = "Auto-Farm", Icon = "solar:ghost-bold" })
local FarmCard = FarmTab:Section({ Title = "🤖 FARMING AUTOMÁTICO", Box = true, BoxBorder = true })

FarmCard:Toggle({ Title = "Auto-Levantar (Loop Bypass)", Callback = function(s) AutoLift = s end })
FarmCard:Toggle({ Title = "Auto-Vender Músculo", Callback = function(s) AutoSell = s end })
FarmCard:Toggle({ Title = "Auto-Comprar Pesas", Callback = function(s) AutoBuy = s end })
FarmCard:Toggle({ Title = "Auto-Subir Etapa (Stage)", Callback = function(s) AutoStage = s end })

local EggCard = FarmTab:Section({ Title = "🥚 SISTEMA DE HUEVOS", Box = true, BoxBorder = true })
EggCard:Dropdown({
    Title = "Seleccionar Huevo",
    Values = {"Basic Egg", "Rare Egg", "Epic Egg", "Legendary Egg", "Void Egg", "Magma Egg"},
    Callback = function(v) SelectedEgg = v end
})
EggCard:Toggle({ Title = "Abrir Automáticamente", Callback = function(s) AutoEgg = s end })

-- ==========================================
-- 4. PESTAÑA: LABORATORIO HACK (BOOSTS & MONEY)
-- ==========================================
local HackTab = SeccionHacks:Tab({ Title = "Laboratorio", Icon = "solar:flask-bold" })
local HackCard = HackTab:Section({ Title = "🧪 INYECCIÓN DE PAQUETES", Box = true, BoxBorder = true })

HackCard:Button({
    Title = "Inyectar Boost x2 Músculo",
    Callback = function()
        pcall(function() require(game.ReplicatedStorage.Shared.Remotes).Shops.ProductPurchased:Fire("x2Muscle") end)
        WindUI:Notify({Title = "Laboratorio", Content = "Boost enviado al servidor."})
    end
})

HackCard:Button({
    Title = "Inyectar Auto-Lift Oficial",
    Callback = function()
        pcall(function() require(game.ReplicatedStorage.Shared.Remotes).Shops.ProductPurchased:Fire("AutoLiftPlus30min") end)
    end
})

HackCard:Button({
    Title = "Simular Compra Pack Monedas",
    Callback = function()
        pcall(function() require(game.ReplicatedStorage.Shared.Remotes).Shops.BuyItem:Fire("MONEY_PACK_5", "Currency") end)
    end
})

-- ==========================================
-- 5. PESTAÑA: TELEPORTS (MAPA COMPLETO)
-- ==========================================
local TPTab = SeccionTP:Tab({ Title = "Zonas", Icon = "solar:map-point-bold" })
local Locs = {
    ["Gimnasio Inicio"] = Vector3.new(0, 5, 0),
    ["Zona de Venta"] = Vector3.new(25, 5, 100),
    ["Tienda de Huevos"] = Vector3.new(-100, 5, -50),
    ["Zona VIP"] = Vector3.new(500, 10, 500)
}

for n, p in pairs(Locs) do
    TPTab:Button({ Title = "Teleport: " .. n, Callback = function() pcall(function() LP.Character.HumanoidRootPart.CFrame = CFrame.new(p) end) end })
end

-- ==========================================
-- 6. PESTAÑA: JUGADOR (HACKS & FIXES)
-- ==========================================
local PlayerTab = SeccionPlayer:Tab({ Title = "Hacks", Icon = "solar:user-bold" })
local MovCard = PlayerTab:Section({ Title = "🏃 MOVIMIENTO", Box = true, BoxBorder = true })

MovCard:Slider({
    Title = "Velocidad (Safe Fix)",
    Step = 1,
    Value = { Min = 16, Max = 350, Default = 16 },
    Callback = function(v) VelocidadUsuario = v; SafeSpeed() end
})

MovCard:Toggle({ Title = "Noclip (Atravesar)", Callback = function(s) Noclip = s end })
MovCard:Toggle({ Title = "Anti-AFK Maestro", Default = true, Callback = function(s) AntiAFK = s end })

-- ==========================================
-- 7. PESTAÑA: SISTEMA
-- ==========================================
local SisTab = SeccionSis:Tab({ Title = "Herramientas", Icon = "solar:settings-bold" })
SisTab:Button({ Title = "Dark Dex", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end })
SisTab:Button({ Title = "SimpleSpy", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))() end })
SisTab:Button({ Title = "Cerrar NC HUB", Callback = function() Window:Destroy() end })

-- ==========================================
-- 🏁 LÓGICA MAESTRA DE EJECUCIÓN
task.spawn(function()
    local Remotes = require(game:GetService("ReplicatedStorage").Shared.Remotes)
    
    while true do
        pcall(function()
-- LÓGICA DE AUTO-LIFT (PACKET BYPASS)
if AutoLift then
    pcall(function()
        local Shared = game:GetService("ReplicatedStorage").Shared
        local PacketRemote = Shared.Remotes.Packet.RemoteEvent
        local LiftingRemotes = require(Shared.Remotes).Lifting
        
        -- 1. Iniciamos el estado (Esto limpia el buffer en el servidor)
        LiftingRemotes.LiftingStatus:Fire(true)
        task.wait(0.1)
        
        -- 2. Disparamos el levantamiento
        LiftingRemotes.LiftRequest:Fire()
        
        -- 3. FORZAMOS EL ENVÍO DEL PAQUETE
        -- Como no podemos generar el buffer exacto, disparamos el evento de red
        -- que el juego usa para "confirmar" que la acción terminó.
        PacketRemote:FireServer() 
        
        task.wait(0.1)
        
        -- 4. Cerramos el estado
        LiftingRemotes.LiftingStatus:Fire(false)
        task.wait(0.1)
    end)
end

            if AutoSell then Remotes.ClientRequests.SellMuscle:Fire() end
            if AutoStage then Remotes.Bloodline.UpgradeRequest:Fire() end
            
            if AutoBuy then
                for _, w in pairs(WeightsList) do Remotes.Shops.BuyItem:Fire(w, "Weights") end
            end
            
            if AutoEgg then Remotes.Shops.OpenEgg:Fire(SelectedEgg) end
            
            if Noclip and LP.Character then
                for _, v in pairs(LP.Character:GetDescendants()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
            
            SafeSpeed()
        end)
        task.wait(0.1)
    end
end)

-- ANTI-AFK LOGIC
local VU = game:GetService("VirtualUser")
LP.Idled:Connect(function()
    if AntiAFK then VU:CaptureController(); VU:ClickButton2(Vector2.new()) end
end)

WindUI:Notify({ Title = "NC HUB", Content = "TSL MASTER EDITION CARGADA 👻🔥", Duration = 5 })
