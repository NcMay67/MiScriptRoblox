-- ==========================================
-- NC HUB | SLIME TYCOON
-- ==========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer

local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

-- ==========================================
-- FUNCIONES BASE
-- ==========================================
local TycoonFolder = Workspace:WaitForChild("Slime Tycoon"):WaitForChild("Tycoons")
local RebirthRemote = ReplicatedStorage:WaitForChild("RebirthEvent (Don't Move)")

local function GetStat(Name)
    local Leaderstats = LP:FindFirstChild("leaderstats")
    local Value = Leaderstats and Leaderstats:FindFirstChild(Name)

    if Value and Value:IsA("ValueBase") then
        return Value.Value
    end

    return 0
end

local function FormatNumber(Number)
    Number = tonumber(Number) or 0

    if Number >= 1000000000 then
        return string.format("%.2fB", Number / 1000000000)
    elseif Number >= 1000000 then
        return string.format("%.2fM", Number / 1000000)
    elseif Number >= 1000 then
        return string.format("%.2fK", Number / 1000)
    end

    return tostring(math.floor(Number))
end

local function GetMyTycoon()
    for _, Tycoon in ipairs(TycoonFolder:GetChildren()) do
        local Owner = Tycoon:FindFirstChild("Owner")

        if Owner and Owner.Value == LP then
            return Tycoon
        end
    end

    return nil
end

local function GetRoot()
    local Character = LP.Character
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

local function TouchPart(Part)
    local Root = GetRoot()

    if Root and Part and Part:IsA("BasePart") then
        pcall(function()
            firetouchinterest(Root, Part, 0)
            firetouchinterest(Root, Part, 1)
        end)
    end
end

local function IsRobuxButton(Button)
    local Gamepass = Button:FindFirstChild("Gamepass")
    local DevProduct = Button:FindFirstChild("DevProduct")

    if Gamepass and Gamepass.Value >= 1 then
        return true
    end

    if DevProduct and DevProduct.Value >= 1 then
        return true
    end

    return false
end

-- ==========================================
-- VENTANA
-- ==========================================
local Window = WindUI:CreateWindow({
    Title = "NC HUB | SLIME TYCOON",
    Author = "By hidjcjgg",
    Folder = "NCHUBScripts",
    Icon = "solar:drop-bold",
    Theme = "Dark",
    Size = UDim2.fromOffset(600, 460),
    NewElements = true,
    Topbar = {
        Height = 44,
        ButtonsType = "Mac"
    }
})

local SeccionSlime = Window:Section({
    Title = "SLIME TYCOON"
})

local SeccionSistema = Window:Section({
    Title = "SISTEMA"
})

-- ==========================================
-- VARIABLES
-- ==========================================
local AutoCollect = false
local AutoBuy = false
local AutoRebirth = false

-- ==========================================
-- DASHBOARD
-- ==========================================
local DashboardTab = SeccionSlime:Tab({
    Title = "Dashboard",
    Icon = "solar:home-2-bold"
})

local StatsCard = DashboardTab:Section({
    Title = "🟢 ESTADO DE TU TYCOON",
    Box = true,
    BoxBorder = true
})

local CashLabel = StatsCard:Section({
    Title = "💵 Cash: cargando..."
})

local TokensLabel = StatsCard:Section({
    Title = "🪙 Tokens: cargando..."
})

local RebirthsLabel = StatsCard:Section({
    Title = "♻️ Rebirths: cargando..."
})

local ToCollectLabel = StatsCard:Section({
    Title = "📦 Dinero para cobrar: cargando..."
})

local TycoonLabel = StatsCard:Section({
    Title = "🏭 Tycoon: buscando..."
})

local function RefreshDashboard()
    local Tycoon = GetMyTycoon()

    CashLabel:SetTitle("💵 Cash: $" .. FormatNumber(GetStat("Cash")))
    TokensLabel:SetTitle("🪙 Tokens: " .. FormatNumber(GetStat("Tokens")))
    RebirthsLabel:SetTitle("♻️ Rebirths: " .. FormatNumber(GetStat("Rebirths")))

    if Tycoon then
        local ToCollect = Tycoon:FindFirstChild("CurrencyToCollect")
        local Amount = ToCollect and ToCollect.Value or 0

        ToCollectLabel:SetTitle("📦 Dinero para cobrar: $" .. FormatNumber(Amount))
        TycoonLabel:SetTitle("🏭 Tycoon: " .. Tycoon.Name)
    else
        ToCollectLabel:SetTitle("📦 Dinero para cobrar: reclama una parcela")
        TycoonLabel:SetTitle("🏭 Tycoon: no encontrado")
    end
end

DashboardTab:Button({
    Title = "Actualizar Dashboard",
    Callback = function()
        RefreshDashboard()

        WindUI:Notify({
            Title = "Slime Tycoon",
            Content = "Dashboard actualizado.",
            Duration = 3
        })
    end
})

-- ==========================================
-- AUTOMATIZACIÓN
-- ==========================================
local FarmTab = SeccionSlime:Tab({
    Title = "Auto Farm",
    Icon = "solar:bolt-bold"
})

local FarmCard = FarmTab:Section({
    Title = "🤖 AUTOMATIZACIÓN",
    Box = true,
    BoxBorder = true
})

FarmCard:Toggle({
    Title = "Auto-Cobrar Cash",
    Desc = "Toca tu colector automáticamente.",
    Callback = function(State)
        AutoCollect = State
    end
})

FarmCard:Toggle({
    Title = "Auto-Buy sin Robux",
    Desc = "Compra botones de Cash y Tokens. Ignora Gamepasses y DevProducts.",
    Callback = function(State)
        AutoBuy = State
    end
})

FarmCard:Toggle({
    Title = "Auto-Rebirth",
    Desc = "Intenta renacer cuando el juego lo permita.",
    Callback = function(State)
        AutoRebirth = State
    end
})

local WarningCard = FarmTab:Section({
    Title = "⚠️ NOTA",
    Box = true,
    BoxBorder = true
})

WarningCard:Section({
    Title = "Auto-Buy usa los botones físicos oficiales de tu propia parcela."
})

WarningCard:Section({
    Title = "No toca botones que tengan Gamepass o DevProduct."
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
-- MOTORES DEL TYCOON
-- ==========================================
task.spawn(function()
    while task.wait(0.45) do
        local Tycoon = GetMyTycoon()

        if Tycoon then
            if AutoCollect then
                local Essentials = Tycoon:FindFirstChild("Essentials")
                local Giver = Essentials and Essentials:FindFirstChild("Giver")

                TouchPart(Giver)
            end

            if AutoBuy then
                local Buttons = Tycoon:FindFirstChild("Buttons")
                local Cash = GetStat("Cash")
                local Tokens = GetStat("Tokens")

                if Buttons then
                    for _, Button in ipairs(Buttons:GetChildren()) do
                        local Touch = Button:FindFirstChild("Touch")
                        local Price = Button:FindFirstChild("Price")
                        local TokenPrice = Button:FindFirstChild("Tokens")

                        if Touch and not IsRobuxButton(Button) then
                            local CanBuyWithCash = Price and Cash >= Price.Value
                            local CanBuyWithTokens = TokenPrice and Tokens >= TokenPrice.Value

                            if CanBuyWithCash or CanBuyWithTokens then
                                TouchPart(Touch)
                                task.wait(0.08)
                            end
                        end
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if AutoRebirth then
            pcall(function()
                local CanRebirth = LP:FindFirstChild("CanRebirth")

                if not CanRebirth or CanRebirth.Value == true then
                    RebirthRemote:FireServer()
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        pcall(RefreshDashboard)
    end
end)

RefreshDashboard()

WindUI:Notify({
    Title = "NC HUB | SLIME TYCOON",
    Content = "Módulo cargado correctamente.",
    Duration = 5
})
