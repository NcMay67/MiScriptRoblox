-- 99 Nights in the Forest
-- Luna UI connected to the separated functions module.
-- No WindUI or legacy UI is used here.

local Functions = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/NcMay67/MiScriptRoblox/main/99Nights_Luna_Functions.lua"
))()

local Luna = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/NcMay67/Luna-Interface-Suite/master/source.lua"
))()

local Window = Luna:CreateWindow({
    Name = "NC HUB - 99 Nights",
    Subtitle = "Luna Interface Suite",
    LogoID = "6031097225",
    LoadingEnabled = true,
    LoadingTitle = "NC HUB - 99 Nights",
    LoadingSubtitle = "Luna Interface Suite",
    ConfigSettings = {ConfigFolder = "NC_HUB_99_Nights"},
})

local function section(tab, name, description)
    local result = tab:CreateSection(name)
    if description then
        result:CreateParagraph({Title = name, Text = description})
    end
    return result
end

local function notify(title, text)
    Luna:Notification({Title = title, Content = text, ImageSource = "Material"})
end

local function safe(callback)
    local ok, err = pcall(callback)
    if not ok then
        warn("[99 Nights] " .. tostring(err))
        notify("99 Nights", tostring(err))
    end
end

local Introduction = Window:CreateTab({Name = "Introduction", Icon = "home", ImageSource = "Material", ShowTitle = true})
local intro = section(Introduction, "Welcome to Synvextia Hub", "Luna interface connected to the separated 99 Nights functions.")
intro:CreateButton({
    Name = "Refresh Player Stats",
    Callback = function()
        local stats = Functions.GetStats()
        notify("Player Stats", string.format("Health: %.0f / %.0f | Players: %d", stats.Health, stats.MaxHealth, stats.PlayerCount))
    end,
})
section(Introduction, "Information", "The interface and game functions are separated into independent modules.")
section(Introduction, "Features", "Functions are connected to their corresponding Luna section.")
section(Introduction, "Refresh", "Use the controls in each tab to refresh or run a function.")

local Main = Window:CreateTab({Name = "Main", Icon = "home", ImageSource = "Material", ShowTitle = true})
local mainSaplings = section(Main, "Infinite Dupe Saplings", "Sapling functions will be connected here.")
mainSaplings:CreateButton({Name = "Scan Saplings", Callback = function()
    local found = Functions.FindByName("Sapling")
    notify("Saplings", "Found: " .. tostring(#found))
end})
section(Main, "Auto Plant", "Automatic planting functions.")
local fuel = section(Main, "Auto Fuel Campfire", "Item bring functions connected to campfire actions.")
fuel:CreateButton({Name = "Bring Nearby Items", Callback = function()
    safe(function()
        local folder = Functions.GetItems()
        if not folder then return notify("Items", "Items folder not found") end
        local root = Functions.GetRoot()
        local moved = Functions.BringItems(folder:GetChildren(), root and root.Position)
        notify("Items", "Moved: " .. tostring(moved))
    end)
end})
section(Main, "Auto Compress", "Compression functions.")
section(Main, "Auto Consume", "Food consumption functions.")
section(Main, "Landmarks", "Landmark lookup and teleport functions.")
local volcano = section(Main, "Send to Volcano", "Volcano item functions.")
volcano:CreateButton({Name = "Find Volcano", Callback = function()
    local object = Functions.GetLandmark("Volcano")
    notify("Volcano", object and object:GetFullName() or "Not found")
end})
section(Main, "Auto Tree Chop", "Tree functions.")

local Combat = Window:CreateTab({Name = "Combat", Icon = "gavel", ImageSource = "Material", ShowTitle = true})
local godmode = section(Combat, "Godmode", "Combat and survival functions.")
godmode:CreateButton({Name = "Read Health", Callback = function()
    local stats = Functions.GetStats()
    notify("Health", string.format("%.0f / %.0f", stats.Health, stats.MaxHealth))
end})
local mobs = section(Combat, "Kill Aura", "Mob discovery functions.")
mobs:CreateButton({Name = "Scan Mobs", Callback = function()
    notify("Mobs", "Found: " .. tostring(#Functions.GetMobs()))
end})
section(Combat, "Auto Escape", "Escape functions.")
section(Combat, "Auto Bandage", "Healing functions.")
section(Combat, "Hitbox Settings", "Hitbox configuration.")
section(Combat, "Select Mobs", "Mob selection.")
section(Combat, "Silent Aim", "Aim functions.")
section(Combat, "Revive Players", "Revive functions.")
section(Combat, "Auto Stun", "Stun functions.")

local Teleport = Window:CreateTab({Name = "Teleport", Icon = "launch", ImageSource = "Material", ShowTitle = true})
local locations = section(Teleport, "Teleport Locations", "Find and teleport to map landmarks.")
local locationInput = "Camp"
locations:CreateInput({Name = "Landmark Name", PlaceholderText = "Camp", CurrentValue = "Camp", Enter = true, Callback = function(value)
    locationInput = value
end})
locations:CreateButton({Name = "Teleport to Landmark", Callback = function()
    safe(function()
        local object = Functions.GetLandmark(locationInput)
        if not object then return notify("Teleport", "Landmark not found") end
        if object:IsA("Model") then
            Functions.TeleportModel(object)
        else
            Functions.TeleportPart(object)
        end
    end)
end})
section(Teleport, "TP to Caves", "Cave teleport functions.")
section(Teleport, "TP to Lost Children", "Lost child teleport functions.")
local chest = section(Teleport, "Teleport to Chest", "Chest lookup and teleport functions.")
local chestName = "Chest"
chest:CreateInput({Name = "Chest Name", PlaceholderText = "Chest", CurrentValue = "Chest", Enter = true, Callback = function(value)
    chestName = value
end})
chest:CreateButton({Name = "Teleport to Chest", Callback = function()
    safe(function()
        local object = Functions.FindFirstByName(chestName, Functions.GetItems() or workspace)
        if not object then return notify("Chest", "Chest not found") end
        if object:IsA("Model") then Functions.TeleportModel(object) else Functions.TeleportPart(object) end
    end)
end})

local Bring = Window:CreateTab({Name = "Bring Items", Icon = "perm_media", ImageSource = "Material", ShowTitle = true})
local quick = section(Bring, "Quick Actions", "Bring item functions.")
quick:CreateButton({Name = "Bring All Nearby Items", Callback = function()
    safe(function()
        local folder = Functions.GetItems()
        if not folder then return notify("Items", "Items folder not found") end
        local root = Functions.GetRoot()
        local moved = Functions.BringItems(folder:GetChildren(), root and root.Position)
        notify("Items", "Moved: " .. tostring(moved))
    end)
end})
section(Bring, "Bring Items", "General item functions.")
section(Bring, "Armor", "Armor functions.")
section(Bring, "Weapons", "Weapon functions.")
section(Bring, "Equipment", "Equipment functions.")
section(Bring, "Food", "Food functions.")
section(Bring, "Vegetables", "Vegetable functions.")
section(Bring, "Mob Drops", "Mob drop functions.")
section(Bring, "Others", "Other item functions.")
section(Bring, "Containers", "Container functions.")

local AutoDays = Window:CreateTab({Name = "Auto Farm", Icon = "wb_sunny", ImageSource = "Material", ShowTitle = true})
section(AutoDays, "Day Auto Farm", "Day farming functions.")
section(AutoDays, "Auto Cook Food", "Cooking functions.")
local Scanner = Window:CreateTab({Name = "Scanner", Icon = "find_in_page", ImageSource = "Material", ShowTitle = true})
local scanner = section(Scanner, "Auto Scanner", "Workspace scanning functions.")
scanner:CreateButton({Name = "Scan Workspace", Callback = function()
    notify("Scanner", "Objects: " .. tostring(#workspace:GetDescendants()))
end})

local Misc = Window:CreateTab({Name = "Misc", Icon = "settings", ImageSource = "Material", ShowTitle = true})
local fog = section(Misc, "Remove Fog", "Fog functions.")
fog:CreateButton({Name = "Remove Fog Now", Callback = function()
    notify("Fog", Functions.RemoveFog() and "Fog removed" or "Boundaries not found")
end})
local movement = section(Misc, "Movement", "Movement functions.")
movement:CreateSlider({Name = "WalkSpeed", Range = {16, 150}, Increment = 1, CurrentValue = 16, Callback = function(value)
    Functions.SetWalkSpeed(value)
end})
movement:CreateSlider({Name = "JumpPower", Range = {50, 200}, Increment = 1, CurrentValue = 50, Callback = function(value)
    Functions.SetJumpPower(value)
end})
section(Misc, "Anti Void", "Anti-void functions.")
section(Misc, "Fly", "Fly functions.")
section(Misc, "Performance Monitor", "Performance functions.")
section(Misc, "Visual", "Visual functions.")
section(Misc, "Universal Scripts", "Universal functions.")
section(Misc, "Tools", "Tool functions.")
local antiAfk = section(Misc, "Anti AFK", "Anti-AFK functions.")
antiAfk:CreateParagraph({Title = "Status", Text = "The Anti-AFK function will be connected here."})
section(Misc, "Server Hop", "Server functions.")

local ESP = Window:CreateTab({Name = "ESP", Icon = "visibility", ImageSource = "Material", ShowTitle = true})
local espSettings = section(ESP, "Global ESP Settings", "Shared ESP functions.")
espSettings:CreateButton({Name = "Clear All ESP", Callback = function()
    Functions.ClearAllESP()
end})
local playerEsp = section(ESP, "Player ESP", "Player ESP functions.")
playerEsp:CreateToggle({Name = "Show Players", CurrentValue = false, Callback = function(enabled)
    if enabled then
        for _, player in ipairs(Functions.GetPlayers()) do
            if player ~= Functions.LocalPlayer and player.Character then
                Functions.CreateESP(player.Character, player.Name, Color3.fromRGB(100, 180, 255))
            end
        end
    else
        Functions.ClearAllESP()
    end
end})
section(ESP, "World Item ESP", "World item ESP functions.")
section(ESP, "Chest ESP", "Chest ESP functions.")
section(ESP, "Mob ESP", "Mob ESP functions.")

local Stats = Window:CreateTab({Name = "Stats", Icon = "assessment", ImageSource = "Material", ShowTitle = true})
local stats = section(Stats, "Game Stats", "Game statistics functions.")
local statsParagraph = stats:CreateParagraph({Title = "Current Stats", Text = "Press refresh to read current values."})
stats:CreateButton({Name = "Refresh Stats", Callback = function()
    local value = Functions.GetStats()
    statsParagraph:Set({Text = string.format("Health: %.0f / %.0f\nPlayers: %d\nUserId: %d", value.Health, value.MaxHealth, value.PlayerCount, value.UserId)})
end})
section(Stats, "Environment", "Environment functions.")
section(Stats, "Campfire", "Campfire functions.")
section(Stats, "Player", "Player functions.")
section(Stats, "Session & System", "Session functions.")
section(Stats, "Controls", "Control functions.")

local Settings = Window:CreateTab({Name = "Settings", Icon = "settings", ImageSource = "Material", ShowTitle = true})
section(Settings, "Config", "Configuration functions.")
section(Settings, "Discord Webhook", "Webhook functions.")
section(Settings, "PC Keybinds", "Keybind functions.")

local Credits = Window:CreateTab({Name = "Credits", Icon = "badge", ImageSource = "Material", ShowTitle = true})
section(Credits, "Credits", "99 Nights functions are kept separate from the Luna UI.")
