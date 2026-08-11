-- ==========================================
-- NC HUB | OFFICIAL LOADER
-- ==========================================
local PlaceId = game.PlaceId
local BaseURL = "https://raw.githubusercontent.com/NcMay67/MiScriptRoblox/refs/heads/main/"

-- Diccionario de Juegos (ID = Nombre del archivo en GitHub)
local Games = {
    [15197136141] = "FactoryTycoon.lua",
    [131795157971706] = "TSL.lua",
    [142823291]    = "MM2.lua",
    [118055952211055] = "HackABusiness.lua",
    [127634932179327] = "KickBall.lua",
    [71785281157268] = "GemCrusher.lua"
}

-- Determinamos qué archivo cargar
local scriptToLoad = Games[PlaceId] or "Universal.lua"

-- Notificación en consola para depuración
print("------------------------------------------")
print("[NC HUB] Cargando sistema modular...")
print("[NC HUB] Juego Detectado (ID): " .. PlaceId)
print("[NC HUB] Archivo a cargar: " .. scriptToLoad)
print("------------------------------------------")

-- Ejecución del script
local success, err = pcall(function()
    loadstring(game:HttpGet(BaseURL .. scriptToLoad))()
end)

if not success then
    warn("[NC HUB] Error crítico al cargar: " .. tostring(err))
    -- Respaldo: Intentar cargar el Universal si el específico falla
    pcall(function()
        loadstring(game:HttpGet(BaseURL .. "Universal.lua"))()
    end)
end
