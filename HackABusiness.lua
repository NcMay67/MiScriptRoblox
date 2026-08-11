--[[
    NC HUB - HACK A BUSINESS EDITION
    AUTOR: hidjcjgg
    ESTILO: BENTO BOX FUTURISTA (MORADO/AZUL)
]]

local TiempoInicio = os.time()
local LP = game.Players.LocalPlayer
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- 1. CONFIGURACIÓN DE LA VENTANA
local Window = WindUI:CreateWindow({
    Title = "NC HUB | HACK BIZ",
    Author = "By hidjcjgg",
    Folder = "NCHUBScripts",
    Icon = "solar:cup-bold",
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
local StatsCard = HomeTab:Section({ Title = "📊 ESTADO DEL NEGOCIO", Box = true })
local MoneyLabel = StatsCard:Section({ Title = "💵 Dinero: $0" })
local FilesLabel = StatsCard:Section({ Title = "💾 Archivos: 0" })
local TimeLabel = StatsCard:Section({ Title = "⏳ Sesión: 0h 0m 0s" })

task.spawn(function()
    while true do
        pcall(function()
            local ls = LP:FindFirstChild("leaderstats")
            if ls then
                MoneyLabel:SetTitle("💵 Dinero: $" .. (ls:FindFirstChild("Money") and ls.Money.Value or 0))
                FilesLabel:SetTitle("💾 Archivos: " .. (ls:FindFirstChild("Files") and ls.Files.Value or 0))
            end
            local s = os.time() - TiempoInicio
            local m, h = math.floor(s/60), math.floor(s/3600)
            TimeLabel:SetTitle(string.format("⏳ Sesión: %dh %dm %ds", h, m%60, s%60))
        end)
        task.wait(1)
    end
end)

-- 4. PESTAÑA: AUTO-HACKER (FARM)
local FarmTab = SeccionPrincipal:Tab({ Title = "Auto-Hacker", Icon = "solar:ghost-bold" })
local AutoHABCollect, AutoHABDeposit, AutoHABBuy, AutoHABRob = false, false, false, false

FarmTab:Toggle({ Title = "Auto-Collect (Money)", Callback = function(s) AutoHABCollect = s end })
FarmTab:Toggle({ Title = "Auto-Deposit (Files)", Callback = function(s) AutoHABDeposit = s end })
FarmTab:Toggle({ Title = "Auto-Rob Files", Callback = function(s) AutoHABRob = s end })
FarmTab:Toggle({ Title = "Auto-Buy Business", Callback = function(s) AutoHABBuy = s end })

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
-- 🏁 MOTOR DE EJECUCIÓN (HACK A BUSINESS)
-- ==========================================
task.spawn(function()
    local Events = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ToServer")
    
    while true do
        if AutoHABCollect then pcall(function() Events.Collect:FireServer() end) end
        if AutoHABDeposit then pcall(function() Events.Deposit:FireServer() end) end
        
        if AutoHABRob then
            pcall(function()
                Events.RobSecondaryCurrency:FireServer("start")
                task.wait(0.1)
                Events.RobSecondaryCurrency:FireServer("end")
            end)
        end
        
        if AutoHABBuy then
            pcall(function()
                for i = 1, 50 do
                    local uidD = string.format("D%03d", i)
                    local uidF = string.format("F%03d", i)
                    Events.BuyObject:FireServer(uidD)
                    Events.BuyObject:FireServer(uidF)
                end
            end)
        end
        task.wait(0.5)
    end
end)
