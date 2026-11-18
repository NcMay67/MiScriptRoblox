-- 99 Nights in the Forest
-- Luna UI skeleton only.
-- This file contains no game logic, RemoteEvents, farms, ESP or teleports.

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
    ConfigSettings = {
        ConfigFolder = "NC_HUB_99_Nights",
    },
})

local function addSection(tab, name, description)
    local section = tab:CreateSection(name)

    if description then
        section:CreateParagraph({
            Title = name,
            Text = description,
        })
    end

    return section
end

-- Introduction
local Introduction = Window:CreateTab({
    Name = "Introduction",
    Icon = "home",
    ImageSource = "Material",
    ShowTitle = true,
})
addSection(Introduction, "Welcome to Synvextia Hub", "Main information and status for the 99 Nights module.")
addSection(Introduction, "Information", "General information about this module.")
addSection(Introduction, "Features", "All 99 Nights features will be connected in their corresponding sections.")
addSection(Introduction, "Refresh", "Refreshable information and status controls.")

-- Main
local Main = Window:CreateTab({
    Name = "Main",
    Icon = "home",
    ImageSource = "Material",
    ShowTitle = true,
})
addSection(Main, "Infinite Dupe Saplings", "Sapling duplication and planting controls.")
addSection(Main, "Auto Plant", "Automatic sapling planting controls.")
addSection(Main, "Auto Fuel Campfire", "Automatic campfire fuel controls.")
addSection(Main, "Auto Compress", "Automatic item compression controls.")
addSection(Main, "Auto Consume", "Automatic food consumption controls.")
addSection(Main, "Landmarks", "Map landmark and reveal controls.")
addSection(Main, "Send to Volcano", "Volcano item controls.")
addSection(Main, "Auto Tree Chop", "Automatic tree chopping controls.")

-- Combat
local Combat = Window:CreateTab({
    Name = "Combat",
    Icon = "gavel",
    ImageSource = "Material",
    ShowTitle = true,
})
addSection(Combat, "Godmode", "Health and survival protection controls.")
addSection(Combat, "Kill Aura", "Nearby mob combat controls.")
addSection(Combat, "Auto Escape", "Automatic escape and campfire return controls.")
addSection(Combat, "Auto Bandage", "Automatic bandage and healing controls.")
addSection(Combat, "Hitbox Settings", "Combat hitbox configuration.")
addSection(Combat, "Select Mobs", "Mob selection for combat features.")
addSection(Combat, "Silent Aim", "Silent aim configuration.")
addSection(Combat, "Revive Players", "Player revive controls.")
addSection(Combat, "Auto Stun", "Automatic stun controls.")

-- Teleport
local Teleport = Window:CreateTab({
    Name = "Teleport",
    Icon = "launch",
    ImageSource = "Material",
    ShowTitle = true,
})
addSection(Teleport, "Teleport Locations", "Main map teleport locations.")
addSection(Teleport, "TP to Caves", "Cave teleport controls.")
addSection(Teleport, "TP to Lost Children", "Lost child teleport controls.")
addSection(Teleport, "Teleport to Chest", "Chest selection and teleport controls.")

-- Bring Items
local Bring = Window:CreateTab({
    Name = "Bring Items",
    Icon = "perm_media",
    ImageSource = "Material",
    ShowTitle = true,
})
addSection(Bring, "Quick Actions", "One-click item actions.")
addSection(Bring, "Bring Items", "General item bring controls.")
addSection(Bring, "Armor", "Armor item controls.")
addSection(Bring, "Weapons", "Weapon item controls.")
addSection(Bring, "Equipment", "Equipment item controls.")
addSection(Bring, "Food", "Food item controls.")
addSection(Bring, "Vegetables", "Vegetable item controls.")
addSection(Bring, "Mob Drops", "Mob drop item controls.")
addSection(Bring, "Others", "Other item controls.")
addSection(Bring, "Containers", "Container item controls.")

-- Auto Farm
local AutoDays = Window:CreateTab({
    Name = "Auto Farm",
    Icon = "wb_sunny",
    ImageSource = "Material",
    ShowTitle = true,
})
addSection(AutoDays, "Day Auto Farm", "Automatic day farming controls.")
addSection(AutoDays, "Auto Cook Food", "Automatic food cooking controls.")

-- Scanner
local Scanner = Window:CreateTab({
    Name = "Scanner",
    Icon = "find_in_page",
    ImageSource = "Material",
    ShowTitle = true,
})
addSection(Scanner, "Auto Scanner", "Automatic map scanning controls.")

-- Misc
local Misc = Window:CreateTab({
    Name = "Misc",
    Icon = "card_giftcard",
    ImageSource = "Material",
    ShowTitle = true,
})
addSection(Misc, "Remove Fog", "Fog visibility controls.")
addSection(Misc, "Anti Void", "Anti-void controls.")
addSection(Misc, "Fly", "Fly controls.")
addSection(Misc, "Movement", "Movement settings.")
addSection(Misc, "Performance Monitor", "Performance information and controls.")
addSection(Misc, "Visual", "Visual settings.")
addSection(Misc, "Universal Scripts", "Universal script tools.")
addSection(Misc, "Tools", "Additional tools.")
addSection(Misc, "Anti AFK", "Anti-AFK controls.")
addSection(Misc, "Server Hop", "Server hopping controls.")

-- ESP
local ESP = Window:CreateTab({
    Name = "ESP",
    Icon = "visibility",
    ImageSource = "Material",
    ShowTitle = true,
})
addSection(ESP, "Global ESP Settings", "Shared ESP settings.")
addSection(ESP, "Player ESP", "Player ESP controls.")
addSection(ESP, "World Item ESP", "World item ESP controls.")
addSection(ESP, "Chest ESP", "Chest ESP controls.")
addSection(ESP, "Mob ESP", "Mob ESP controls.")

-- Stats
local Stats = Window:CreateTab({
    Name = "Stats",
    Icon = "assessment",
    ImageSource = "Material",
    ShowTitle = true,
})
addSection(Stats, "Game Stats", "Game statistics.")
addSection(Stats, "Environment", "Environment information.")
addSection(Stats, "Campfire", "Campfire information.")
addSection(Stats, "Player", "Player information.")
addSection(Stats, "Session & System", "Session and system information.")
addSection(Stats, "Controls", "Control and key information.")

-- Settings
local Settings = Window:CreateTab({
    Name = "Settings",
    Icon = "settings",
    ImageSource = "Material",
    ShowTitle = true,
})
addSection(Settings, "Config", "Configuration controls.")
addSection(Settings, "Discord Webhook", "Discord webhook configuration.")
addSection(Settings, "PC Keybinds", "Keyboard shortcut configuration.")

-- Credits
local Credits = Window:CreateTab({
    Name = "Credits",
    Icon = "badge",
    ImageSource = "Material",
    ShowTitle = true,
})
addSection(Credits, "Credits", "99 Nights module credits.")
