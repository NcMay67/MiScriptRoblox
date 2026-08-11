--[[
    NC HUB - FACTORY TYCOON EDITION
    AUTOR: hidjcjgg
    ESTILO: BENTO BOX FUTURISTA (MORADO/AZUL)
]]

local TiempoInicio = os.time()
local LP = game.Players.LocalPlayer
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- 1. CONFIGURACIÓN DE LA VENTANA
local Window = WindUI:CreateWindow({
    Title = "NC HUB | FACTORY",
    Author = "By hidjcjgg",
    Folder = "NCHUBScripts",
    Icon = "solar:factory-bold",
    Theme = "Dark",
    Size = UDim2.fromOffset(580, 460),
    NewElements = true,
    Topbar = { Height = 44, ButtonsType = "Mac" }
})

-- 2. SECCIONES DEL SIDEBAR
local SeccionPrincipal = Window:Section({ Title = "OPERACIONES" })
local SeccionPersonaje = Window:Section({ Title = "JUGADOR" })
local SeccionSistema = Window:Section({ Title = "SISTEMA" })

-- 3. PESTAÑA: DASHBOARD (HOME)
local HomeTab = SeccionPrincipal:Tab({ Title = "Dashboard", Icon = "solar:home-2-bold" })
local StatsCard = HomeTab:Section({ Title = "📊 ESTADO DE LA FÁBRICA", Box = true })
local MoneyLabel = StatsCard:Section({ Title = "Efectivo: $0" })
local GemsLabel = StatsCard:Section({ Title = "Gemas: 0" })
local TimeLabel = StatsCard:Section({ Title = "⏳ Sesión: 0h 0m 0s" })

task.spawn(function()
    while true do
        pcall(function()
            local df = LP:WaitForChild("DataFolder", 5)
            if df then
                MoneyLabel:SetTitle("💵 Efectivo: $" .. (df:FindFirstChild("Money") and df.Money.Value or 0))
                GemsLabel:SetTitle("💎 Gemas: " .. (df:FindFirstChild("Gems") and df.Gems.Value or 0))
            end
            local s = os.time() - TiempoInicio
            local m, h = math.floor(s/60), math.floor(s/3600)
            TimeLabel:SetTitle(string.format("⏳ Sesión: %dh %dm %ds", h, m%60, s%60))
        end)
        task.wait(1)
    end
end)

-- 4. PESTAÑA: AUTOMATIZACIÓN (FARM)
local FarmTab = SeccionPrincipal:Tab({ Title = "Auto-Farm", Icon = "solar:ghost-bold" })
local AutoCollect, AutoBuy, AutoRebirth = false, false, false

FarmTab:Toggle({ Title = "Auto-Cobrar Dinero", Callback = function(s) AutoCollect = s end })
FarmTab:Toggle({ Title = "Auto-Comprar (No funciona, Próximamente)", Callback = function(s) AutoBuy = s end })
FarmTab:Toggle({ Title = "Auto-Rebirth", Callback = function(s) AutoRebirth = s end })

-- 5. PESTAÑA: MOVIMIENTO (JUGADOR)
local MoveTab = SeccionPersonaje:Tab({ Title = "Movimiento", Icon = "solar:walking-bold" })
MoveTab:Slider({ Title = "Velocidad", Default = 16, Min = 16, Max = 250, Callback = function(v) LP.Character.Humanoid.WalkSpeed = v end })
MoveTab:Slider({ Title = "Salto", Default = 50, Min = 50, Max = 300, Callback = function(v) LP.Character.Humanoid.JumpPower = v end })

-- 6. PESTAÑA: SISTEMA
local SisTab = SeccionSistema:Tab({ Title = "Herramientas", Icon = "solar:settings-bold" })
SisTab:Button({ Title = "Dark Dex", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end })
SisTab:Button({ Title = "SimpleSpy", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))() end })
SisTab:Button({ Title = "Cerrar Hub", Callback = function() Window:Destroy() end })

-- ==========================================
-- 🏁 MOTOR DE EJECUCIÓN (LÓGICA FÁBRICA)
-- ==========================================
task.spawn(function()
    local Events = game:GetService("ReplicatedStorage"):WaitForChild("Events")
    
    while true do
        local tycoon = LP:FindFirstChild("TycoonOwned") and LP.TycoonOwned.Value
        
        if tycoon then
            -- 1. Auto Collect
            if AutoCollect then
                pcall(function() 
                    local collectPart = tycoon:FindFirstChild("Build") and tycoon.Build:FindFirstChild("Collect")
                    if collectPart then Events.CollectMoney:FireServer(collectPart) end
                end)
            end
            
            -- 2. Smart Auto-Buy
            if AutoBuy then
                pcall(function()
                    for _, v in pairs(tycoon.Buttons:GetChildren()) do
                        if v:FindFirstChild("Price") and v:FindFirstChild("IsButtonVisible") and v.IsButtonVisible.Value then
                            if not (v:FindFirstChild("GamepassID") or v:FindFirstChild("ProductID")) then
                                if LP.DataFolder.Money.Value >= v.Price.Value then
                                    Events.ButtonUsed:FireServer(v.Name)
                                end
                            end
                        end
                    end
                end)
            end
            
            -- 3. Auto Rebirth (El glitch del 653)
            if AutoRebirth then
                pcall(function() Events.RequestRebirth:FireServer(653, 653, tycoon) end)
            end
        end
        task.wait(0.5)
    end
end)