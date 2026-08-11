--[[
    NC HUB - MURDER MYSTERY 2 EDITION
    AUTOR: hidjcjgg
    ESTILO: BENTO BOX FUTURISTA (MORADO/AZUL)
]]

local TiempoInicio = os.time()
local LP = game.Players.LocalPlayer
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- 1. CONFIGURACIÓN DE LA VENTANA
local Window = WindUI:CreateWindow({
    Title = "NC HUB | MM2",
    Author = "By hidjcjgg",
    Folder = "NCHUBScripts",
    Icon = "solar:danger-bold",
    Theme = "Dark",
    Size = UDim2.fromOffset(580, 460),
    NewElements = true,
    Topbar = { Height = 44, ButtonsType = "Mac" }
})

-- 2. SECCIONES DEL SIDEBAR
local SeccionPrincipal = Window:Section({ Title = "PARTIDA" })
local SeccionPersonaje = Window:Section({ Title = "JUGADOR" })
local SeccionSistema = Window:Section({ Title = "SISTEMA" })

-- 3. PESTAÑA: DASHBOARD (HOME)
local HomeTab = SeccionPrincipal:Tab({ Title = "Dashboard", Icon = "solar:home-2-bold" })
local PerfilCard = HomeTab:Section({ Title = "👤 ESTADO DEL JUGADOR", Box = true })
local UserLabel = PerfilCard:Section({ Title = "Usuario: " .. LP.Name })
local TimeLabel = PerfilCard:Section({ Title = "⏳ Sesión: 0h 0m 0s" })

task.spawn(function()
    while true do
        local s = os.time() - TiempoInicio
        local m, h = math.floor(s/60), math.floor(s/3600)
        TimeLabel:SetTitle(string.format("⏳ Sesión: %dh %dm %ds", h, m%60, s%60))
        task.wait(1)
    end
end)

-- 4. PESTAÑA: MM2 HACKS
local MM2Tab = SeccionPrincipal:Tab({ Title = "MM2 Hacks", Icon = "solar:ghost-bold" })
local RolesESP = false
local AutoGrab = false

local MM2Visuals = MM2Tab:Section({ Title = "👁️ VISUALES", Box = true })
MM2Visuals:Toggle({
    Title = "Revelar Roles (ESP)",
    Callback = function(state)
        RolesESP = state
        task.spawn(function()
            while RolesESP do
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local color = Color3.fromRGB(0, 255, 0) -- Inocente (Verde)
                        local hasKnife = p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")
                        local hasGun = p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")
                        
                        if hasKnife then 
                            color = Color3.fromRGB(255, 0, 0) -- Murder (Rojo)
                        elseif hasGun then 
                            color = Color3.fromRGB(0, 0, 255) -- Sheriff (Azul)
                        end
                        
                        local h = p.Character:FindFirstChild("Highlight") or Instance.new("Highlight", p.Character)
                        h.FillColor = color
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.Enabled = true
                    end
                end
                task.wait(1)
            end
            for _, p in pairs(game.Players:GetPlayers()) do 
                if p.Character and p.Character:FindFirstChild("Highlight") then 
                    p.Character.Highlight:Destroy() 
                end 
            end
        end)
    end
})

local MM2Combat = MM2Tab:Section({ Title = "🔫 COMBATE", Box = true })
MM2Combat:Toggle({
    Title = "Auto-Grab Gun (Teleport)",
    Callback = function(state)
        AutoGrab = state
        task.spawn(function()
            while AutoGrab do
                pcall(function()
                    for _, v in pairs(workspace:GetDescendants()) do
                        if (v.Name == "GunDrop" or v.Name == "Gun") and v:IsA("Model") then
                            local handle = v:FindFirstChild("Handle") or v:FindFirstChildWhichIsA("BasePart")
                            if handle and not v.Parent:FindFirstChild("Humanoid") then
                                LP.Character.HumanoidRootPart.CFrame = handle.CFrame
                                task.wait(1)
                            end
                        end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
})

-- 5. PESTAÑA: MOVIMIENTO
local MoveTab = SeccionPersonaje:Tab({ Title = "Movimiento", Icon = "solar:walking-bold" })
MoveTab:Slider({ Title = "Velocidad", Default = 16, Min = 16, Max = 100, Callback = function(v) LP.Character.Humanoid.WalkSpeed = v end })
MoveTab:Slider({ Title = "Salto", Default = 50, Min = 50, Max = 150, Callback = function(v) LP.Character.Humanoid.JumpPower = v end })

-- 6. PESTAÑA: SISTEMA
local SisTab = SeccionSistema:Tab({ Title = "Herramientas", Icon = "solar:settings-bold" })
SisTab:Button({ Title = "Dark Dex", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end })
SisTab:Button({ Title = "SimpleSpy", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))() end })
SisTab:Button({ Title = "Cerrar Hub", Callback = function() Window:Destroy() end })
