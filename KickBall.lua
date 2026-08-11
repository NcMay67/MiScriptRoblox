--[[
    NC HUB - KICK TO SPACE EDITION
    AUTOR: hidjcjgg
    ESTILO: BENTO BOX FUTURISTA (MORADO/AZUL)
]]

local TiempoInicio = os.time()
local LP = game.Players.LocalPlayer
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- 1. CONFIGURACIÓN DE LA VENTANA
local Window = WindUI:CreateWindow({
    Title = "NC HUB | KICK BALL",
    Author = "By hidjcjgg",
    Folder = "NCHUBScripts",
    Icon = "solar:football-bold",
    Theme = "Dark",
    Size = UDim2.fromOffset(580, 460),
    NewElements = true,
    Topbar = { Height = 44, ButtonsType = "Mac" }
})

-- 2. SECCIONES DEL SIDEBAR
local SeccionPrincipal = Window:Section({ Title = "ENTRENAMIENTO" })
local SeccionPersonaje = Window:Section({ Title = "JUGADOR" })
local SeccionSistema = Window:Section({ Title = "SISTEMA" })

-- 3. PESTAÑA: DASHBOARD (HOME)
local HomeTab = SeccionPrincipal:Tab({ Title = "Dashboard", Icon = "solar:home-2-bold" })
local StatsCard = HomeTab:Section({ Title = "⚡ TUS ESTADÍSTICAS", Box = true, BoxBorder = true })
local PowerLabel = StatsCard:Section({ Title = "⚡ Power: 0" })
local RebirthLabel = StatsCard:Section({ Title = "🔄 Rebirths: 0" })

-- Monitor en tiempo real
task.spawn(function()
    while true do
        pcall(function()
            local ls = LP:FindFirstChild("leaderstats")
            if ls then
                PowerLabel:SetTitle("⚡ Power: " .. (ls:FindFirstChild("Power") and ls.Power.Value or 0))
                RebirthLabel:SetTitle("🔄 Rebirths: " .. (ls:FindFirstChild("Rebirths") and ls.Rebirths.Value or 0))
            end
        end)
        task.wait(1)
    end
end)

-- 4. PESTAÑA: TRAMPAS (FARM)
local FarmTab = SeccionPrincipal:Tab({ Title = "Auto-Farm", Icon = "solar:bolt-bold" })
local AutoKick, AutoUpgrade = false, false

FarmTab:Toggle({ Title = "Auto-Kick (Entrenamiento)", Callback = function(s) AutoKick = s end })
FarmTab:Toggle({ Title = "Auto-Comprar Mejoras (Power)", Callback = function(s) AutoUpgrade = s end })

-- 5. PESTAÑA: MOVIMIENTO
local MovTab = SeccionPersonaje:Tab({ Title = "Movimiento", Icon = "solar:walking-bold" })
MovTab:Slider({ Title = "Velocidad", Min = 16, Max = 200, Default = 16, Callback = function(v) LP.Character.Humanoid.WalkSpeed = v end })
MovTab:Slider({ Title = "Salto", Min = 50, Max = 300, Default = 50, Callback = function(v) LP.Character.Humanoid.JumpPower = v end })

-- 6. PESTAÑA: SISTEMA
local SisTab = SeccionSistema:Tab({ Title = "Herramientas", Icon = "solar:settings-bold" })
SisTab:Button({ Title = "Dark Dex", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end })
SisTab:Button({ Title = "SimpleSpy", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))() end })
SisTab:Button({ Title = "Cerrar Hub", Callback = function() Window:Destroy() end })

-- ==========================================
-- 🏁 LÓGICA MAESTRA (KICK BALL ENGINE)
-- ==========================================
task.spawn(function()
    while true do
        pcall(function()
            -- 1. Auto Kick (Usando MookNet Reliable)
            if AutoKick then
                local mookNet = game:GetService("ReplicatedStorage"):FindFirstChild("MookNet")
                if mookNet and mookNet:FindFirstChild("Reliable") then
                    -- Como usa buffer binario, simulamos la pulsación del cliente o evento de patada
                    -- Disparamos un evento simulado de patada si está disponible
                    local args = { [1] = buffer.create(16), [2] = {} }
                    mookNet.Reliable:FireServer(unpack(args))
                end
            end

            -- 2. Auto Upgrade (Usando UpgradeRemote que descubrimos)
            if AutoUpgrade then
                local upgradeRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
                if upgradeRemote and upgradeRemote:FindFirstChild("UpgradeRequest") then
                    upgradeRemote.UpgradeRequest:FireServer("PowerUpgrade")
                end
            end
        end)
        task.wait(0.2)
    end
end)
