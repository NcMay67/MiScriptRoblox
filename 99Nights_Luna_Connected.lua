-- 99 Nights in the Forest: Luna renderer for the extracted real callbacks.
-- Run from an executor with readfile/loadstring access to these local artifacts.
local function loadRemote(url)
    return assert(loadstring(game:HttpGet(url), "@" .. url))()
end
local Functions = loadRemote("https://raw.githubusercontent.com/NcMay67/MiScriptRoblox/main/99Nights_Luna_Functions.lua")
local Luna = loadRemote("https://raw.githubusercontent.com/NcMay67/Luna-Interface-Suite/master/source.lua")

local Window = Luna:CreateWindow({
    Name = "Synvextia Hub - 99 Nights",
    Subtitle = "Luna Interface Suite",
    LogoID = "6031097225",
    LoadingEnabled = true,
    LoadingTitle = "Synvextia Hub - 99 Nights",
    LoadingSubtitle = "Luna Interface Suite",
    ConfigSettings = {ConfigFolder = "Synvextia_99_Nights"},
})

local tabs, sections = {}, {}
local function getTab(name)
    if not tabs[name] then
        tabs[name] = Window:CreateTab({Name = name, Icon = "home", ImageSource = "Material", ShowTitle = true})
    end
    return tabs[name]
end
local function getSection(tabName, sectionName)
    local key = tabName .. "\0" .. sectionName
    if not sections[key] then
        sections[key] = getTab(tabName):CreateSection(sectionName)
    end
    return sections[key]
end

for _, control in ipairs(Functions.Controls) do
    local section = getSection(control.Tab or "Main", control.Section or "Controls")
    local common = {Name = control.Title, Description = control.Description}
    if control.Type == "Button" then
        common.Callback = control.Callback
        section:CreateButton(common)
    elseif control.Type == "Toggle" then
        common.CurrentValue = control.Default == true
        common.Callback = control.Callback
        section:CreateToggle(common)
    elseif control.Type == "Slider" then
        local range = control.Range or {0, 100}
        common.Range = {range[1] or 0, range[2] or 100}
        common.Increment = control.Increment or 1
        common.CurrentValue = control.Default or common.Range[1]
        common.Callback = control.Callback
        section:CreateSlider(common)
    elseif control.Type == "Dropdown" then
        common.Options = control.Values or {}
        common.CurrentOption = control.Value or {}
        common.MultipleOptions = control.Multi == true
        common.Callback = control.Callback
        section:CreateDropdown(common)
    elseif control.Type == "Input" then
        common.PlaceholderText = control.Placeholder or ""
        common.CurrentValue = control.Value or ""
        common.Enter = true
        common.Callback = control.Callback
        section:CreateInput(common)
    elseif control.Type == "Paragraph" then
        section:CreateParagraph({Title = control.Title, Text = control.Description})
    end
end

return {Window = Window, Functions = Functions, Tabs = tabs, Sections = sections}
