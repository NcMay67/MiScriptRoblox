-- =========================================================
-- NEXUS NC Interface | v0.2
-- Biblioteca original para NC HUB
-- =========================================================

-- [[ 01. SERVICIOS ]]
local NX = {}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer
local Runtime = (getgenv and getgenv()) or _G

-- [[ 02. TEMA ]]
NX.Theme = {
    Background = Color3.fromRGB(17, 18, 25),
    Surface = Color3.fromRGB(25, 27, 36),
    Surface2 = Color3.fromRGB(41, 44, 56),
    Purple = Color3.fromRGB(57, 61, 78),
    Accent = Color3.fromRGB(117, 164, 206),
    Cian = Color3.fromRGB(123, 201, 201),
    Rose = Color3.fromRGB(224, 138, 175),
    Text = Color3.fromRGB(241, 243, 248),
    Muted = Color3.fromRGB(166, 171, 190),
    Stroke = Color3.fromRGB(78, 83, 105),
    MacRed = Color3.fromRGB(255, 95, 86),
    MacYellow = Color3.fromRGB(255, 189, 46),
    MacGreen = Color3.fromRGB(39, 201, 63)
}

function NX:SetTheme(tokens)
    for key, value in pairs(tokens or {}) do
        if self.Theme[key] and typeof(value) == "Color3" then
            self.Theme[key] = value
        end
    end
end
-- [[ 02.5. TEMAS, TAMAÑO Y CONFIGURACIÓN ]]
local HttpService = game:GetService("HttpService")

local function copyTable(source)
    local copy = {}
    for key, value in pairs(source or {}) do copy[key] = value end
    return copy
end

NX.Themes = {
    Default = copyTable(NX.Theme),
    Midnight = {
        Background = Color3.fromRGB(11, 13, 20),
        Surface = Color3.fromRGB(19, 22, 31),
        Surface2 = Color3.fromRGB(33, 37, 49),
        Purple = Color3.fromRGB(53, 57, 73),
        Accent = Color3.fromRGB(117, 164, 206),
        Cian = Color3.fromRGB(123, 201, 201),
        Rose = Color3.fromRGB(224, 138, 175),
        Text = Color3.fromRGB(241, 243, 248),
        Muted = Color3.fromRGB(166, 171, 190),
        Stroke = Color3.fromRGB(78, 83, 105),
        MacRed = Color3.fromRGB(255, 95, 86),
        MacYellow = Color3.fromRGB(255, 189, 46),
        MacGreen = Color3.fromRGB(39, 201, 63)
    },
    Void = {
        Background = Color3.fromRGB(12, 10, 18),
        Surface = Color3.fromRGB(23, 18, 32),
        Surface2 = Color3.fromRGB(38, 30, 51),
        Purple = Color3.fromRGB(67, 47, 88),
        Accent = Color3.fromRGB(174, 113, 255),
        Cian = Color3.fromRGB(152, 235, 255),
        Rose = Color3.fromRGB(240, 135, 193),
        Text = Color3.fromRGB(247, 242, 255),
        Muted = Color3.fromRGB(190, 179, 209),
        Stroke = Color3.fromRGB(100, 79, 124),
        MacRed = Color3.fromRGB(255, 95, 86),
        MacYellow = Color3.fromRGB(255, 189, 46),
        MacGreen = Color3.fromRGB(39, 201, 63)
    }
}

NX.ActiveTheme = "Default"

function NX:RegisterTheme(name, tokens)
    if type(name) ~= "string" or name == "" then return false end
    if type(tokens) ~= "table" then return false end
    self.Themes[name] = copyTable(tokens)
    return true
end

function NX:UseTheme(name)
    local tokens = type(name) == "table" and name or self.Themes[name]
    if type(tokens) ~= "table" then return false end
    self:SetTheme(tokens)
    if type(name) == "string" then self.ActiveTheme = name end
    return true
end

function NX:GetThemeNames()
    local names = {}
    for name in pairs(self.Themes) do table.insert(names, name) end
    table.sort(names)
    return names
end
-- Tema oficial de NEXUS NC
NX:UseTheme("Void")


function NX:ResolveWindowSize(width, height)
    local camera = workspace.CurrentCamera
    if not camera then return UDim2.fromOffset(width, height) end

    local viewport = camera.ViewportSize
    local safeWidth = math.max(310, viewport.X - 32)
    local safeHeight = math.max(240, viewport.Y - 80)
    return UDim2.fromOffset(
        math.min(width, safeWidth),
        math.min(height, safeHeight)
    )
end

NX.Storage = {
    Folder = "NCHUBScripts/NexusNC"
}

local function storageAvailable()
    return type(readfile) == "function"
        and type(writefile) == "function"
        and type(isfile) == "function"
        and type(makefolder) == "function"
end

local function safeFileName(name)
    return tostring(name or "default"):gsub("[^%w%-%_]", "_")
end

local function ensureFolder()
    if not storageAvailable() then return false end
    pcall(function()
        if type(isfolder) == "function" and not isfolder("NCHUBScripts") then
            makefolder("NCHUBScripts")
        end
        if type(isfolder) == "function" and not isfolder(NX.Storage.Folder) then
            makefolder(NX.Storage.Folder)
        end
    end)
    return true
end

function NX:HasStorage()
    return storageAvailable()
end

function NX:SaveConfig(name, data)
    if type(data) ~= "table" or not ensureFolder() then
        return false, "Storage no disponible"
    end

    local path = self.Storage.Folder .. "/" .. safeFileName(name) .. ".json"
    local ok, result = pcall(function()
        writefile(path, HttpService:JSONEncode(data))
    end)
    return ok, result
end

function NX:LoadConfig(name)
    if not storageAvailable() then return nil, "Storage no disponible" end

    local path = self.Storage.Folder .. "/" .. safeFileName(name) .. ".json"
    if not isfile(path) then return nil, "No existe" end

    local ok, result = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if ok then return result end
    return nil, result
end

function NX:DeleteConfig(name)
    if type(delfile) ~= "function" or not storageAvailable() then
        return false, "Storage no disponible"
    end

    local path = self.Storage.Folder .. "/" .. safeFileName(name) .. ".json"
    if not isfile(path) then return false, "No existe" end
    local ok, result = pcall(function() delfile(path) end)
    return ok, result
end
-- [[ 02.75. VÍNCULOS DE CONFIGURACIÓN ]]
NX.Bindings = {}

local function serializeValue(value)
    local kind = typeof(value)

    if kind == "Color3" then
        return {
            __NexusType = "Color3",
            R = value.R,
            G = value.G,
            B = value.B
        }
    end

    if kind == "EnumItem" then
        return {
            __NexusType = "EnumItem",
            EnumType = tostring(value.EnumType):gsub("Enum%.", ""),
            Name = value.Name
        }
    end

    if type(value) == "table" then
        local result = {}
        for key, item in pairs(value) do
            result[key] = serializeValue(item)
        end
        return result
    end

    return value
end

local function deserializeValue(value)
    if type(value) ~= "table" then return value end

    if value.__NexusType == "Color3" then
        return Color3.new(value.R or 0, value.G or 0, value.B or 0)
    end

    if value.__NexusType == "EnumItem" then
        local enumType = Enum[value.EnumType]
        return enumType and enumType[value.Name] or nil
    end

    local result = {}
    for key, item in pairs(value) do
        result[key] = deserializeValue(item)
    end
    return result
end

function NX:Bind(id, control, options)
    if type(id) ~= "string" or id == "" then
        return nil, "Bind necesita un identificador"
    end
    if type(control) ~= "table" or type(control.Get) ~= "function" or type(control.Set) ~= "function" then
        return nil, "Control no compatible"
    end

    options = options or {}
    self.Bindings[id] = {
        Control = control,
        Serialize = options.Serialize,
        Deserialize = options.Deserialize
    }
    self:Log("Control vinculado:", id)
    return control
end

function NX:Unbind(id)
    if not self.Bindings[id] then return false end
    self.Bindings[id] = nil
    return true
end

function NX:ClearBindings()
    table.clear(self.Bindings)
end

function NX:CollectBindings()
    local result = {}

    for id, binding in pairs(self.Bindings) do
        local ok, value = pcall(function()
            return binding.Control:Get()
        end)

        if ok then
            if binding.Serialize then
                local success, custom = pcall(binding.Serialize, value)
                result[id] = success and custom or serializeValue(value)
            else
                result[id] = serializeValue(value)
            end
        end
    end

    return result
end

function NX:ApplyBindings(data)
    if type(data) ~= "table" then return false, "Datos inválidos" end

    for id, value in pairs(data) do
        local binding = self.Bindings[id]
        if binding then
            local decoded = binding.Deserialize and binding.Deserialize(value) or deserializeValue(value)
            pcall(function()
                binding.Control:Set(decoded)
            end)
        end
    end

    return true
end

function NX:SaveBindings(name, extra)
    local data = {
        Version = "NEXUS_NC_BINDINGS_1",
        Values = self:CollectBindings(),
        Extra = extra or {}
    }
    return self:SaveConfig(name, data)
end

function NX:LoadBindings(name)
    local data, err = self:LoadConfig(name)
    if not data then return nil, err end
    if type(data.Values) ~= "table" then return nil, "Archivo incompatible" end

    local ok, applyErr = self:ApplyBindings(data.Values)
    if not ok then return nil, applyErr end
    return data.Extra or {}
end
-- [[ 02.9. PERFILES DE PREFERENCIAS ]]
NX.Profiles = {
    IndexName = "__nexus_profiles"
}

local function profileName(name)
    name = tostring(name or "")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    return name
end

local function readProfileIndex()
    local data = NX:LoadConfig(NX.Profiles.IndexName)
    if type(data) ~= "table" or type(data.Profiles) ~= "table" then
        return { Profiles = {} }
    end
    return data
end

local function writeProfileIndex(index)
    return NX:SaveConfig(NX.Profiles.IndexName, index)
end

local function findProfile(index, name)
    for position, item in ipairs(index.Profiles) do
        if item:lower() == name:lower() then
            return position, item
        end
    end
    return nil, nil
end

function NX:ListProfiles()
    local index = readProfileIndex()
    table.sort(index.Profiles, function(a, b) return a:lower() < b:lower() end)
    return index.Profiles
end

function NX:SaveProfile(name, extra)
    name = profileName(name)
    if name == "" then return false, "Nombre de perfil vacío" end

    local ok, err = self:SaveBindings("profile_" .. name, extra)
    if not ok then return false, err end

    local index = readProfileIndex()
    local _, found = findProfile(index, name)
    if not found then
        table.insert(index.Profiles, name)
        local saved, indexErr = writeProfileIndex(index)
        if not saved then return false, indexErr end
    end

    self:Log("Perfil guardado:", name)
    return true
end

function NX:LoadProfile(name)
    name = profileName(name)
    if name == "" then return nil, "Nombre de perfil vacío" end
    return self:LoadBindings("profile_" .. name)
end

function NX:DeleteProfile(name)
    name = profileName(name)
    if name == "" then return false, "Nombre de perfil vacío" end

    local index = readProfileIndex()
    local position, storedName = findProfile(index, name)
    if not position then return false, "Perfil no existe" end

    local deleted, err = self:DeleteConfig("profile_" .. storedName)
    if not deleted then return false, err end

    table.remove(index.Profiles, position)
    local saved, indexErr = writeProfileIndex(index)
    if not saved then return false, indexErr end

    self:Log("Perfil borrado:", storedName)
    return true
end

function NX:HasProfile(name)
    name = profileName(name)
    if name == "" then return false end

    local index = readProfileIndex()
    local _, found = findProfile(index, name)
    return found ~= nil
end
-- [[ 02.95. ALMACENES DE PERFILES POR MÓDULO ]]
function NX:ProfileStore(namespace)
    namespace = safeFileName(namespace or "default")

    local store = {
        Namespace = namespace,
        IndexName = "__nexus_profiles_" .. namespace,
        Prefix = "profile_" .. namespace .. "_"
    }

    local function readIndex()
        local data = NX:LoadConfig(store.IndexName)
        if type(data) ~= "table" or type(data.Profiles) ~= "table" then
            return { Profiles = {} }
        end
        return data
    end

    local function saveIndex(index)
        return NX:SaveConfig(store.IndexName, index)
    end

    local function normalize(name)
        return profileName(name)
    end

    local function find(index, name)
        for position, item in ipairs(index.Profiles) do
            if item:lower() == name:lower() then return position, item end
        end
        return nil, nil
    end

    function store:List()
        local index = readIndex()
        table.sort(index.Profiles, function(a, b) return a:lower() < b:lower() end)
        return index.Profiles
    end

    function store:Save(name, extra)
        name = normalize(name)
        if name == "" then return false, "Nombre de perfil vacío" end

        local ok, err = NX:SaveBindings(self.Prefix .. name, extra)
        if not ok then return false, err end

        local index = readIndex()
        local _, found = find(index, name)
        if not found then
            table.insert(index.Profiles, name)
            local saved, indexErr = saveIndex(index)
            if not saved then return false, indexErr end
        end
        return true
    end

    function store:Load(name)
        name = normalize(name)
        if name == "" then return nil, "Nombre de perfil vacío" end
        return NX:LoadBindings(self.Prefix .. name)
    end

    function store:Delete(name)
        name = normalize(name)
        if name == "" then return false, "Nombre de perfil vacío" end

        local index = readIndex()
        local position, storedName = find(index, name)
        if not position then return false, "Perfil no existe" end

        local deleted, err = NX:DeleteConfig(self.Prefix .. storedName)
        if not deleted then return false, err end

        table.remove(index.Profiles, position)
        return saveIndex(index)
    end

    function store:Has(name)
        local index = readIndex()
        local _, found = find(index, normalize(name))
        return found ~= nil
    end

    return store
end

-- [[ 03. UTILIDADES VISUALES ]]
local Util = {}

function Util.Make(class, props)
    local object = Instance.new(class)
    for key, value in pairs(props or {}) do object[key] = value end
    return object
end

function Util.Round(object, radius)
    return Util.Make("UICorner", {
        CornerRadius = UDim.new(0, radius or 10),
        Parent = object
    })
end

function Util.Stroke(object, color, transparency)
    return Util.Make("UIStroke", {
        Color = color or NX.Theme.Stroke,
        Thickness = 1,
        Transparency = transparency or 0.3,
        Parent = object
    })
end

function Util.Text(parent, value, size, font, color)
    return Util.Make("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = font or Enum.Font.Gotham,
        Text = value or "",
        TextColor3 = color or NX.Theme.Text,
        TextSize = size or 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = parent
    })
end

function Util.Tween(object, duration, properties)
    return TweenService:Create(object, TweenInfo.new(
        duration or 0.16,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    ), properties)
end

function Util.GuiParent()
    local parent
    pcall(function() parent = gethui and gethui() or CoreGui end)
    return parent or Player:WaitForChild("PlayerGui")
end

-- [[ 04. NÚCLEO: LIMPIEZA Y ESTADO ]]
local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({ Tasks = {}, Destroyed = false }, Maid)
end

function Maid:_Clean(item)
    local kind = typeof(item)
    if kind == "RBXScriptConnection" then
        item:Disconnect()
    elseif kind == "Instance" then
        item:Destroy()
    elseif type(item) == "function" then
        item()
    elseif type(item) == "table" then
        local method = item.Destroy or item.Disconnect
        if type(method) == "function" then method(item) end
    end
end

function Maid:Give(item)
    if self.Destroyed then
        self:_Clean(item)
        return item
    end
    table.insert(self.Tasks, item)
    return item
end

function Maid:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    for index = #self.Tasks, 1, -1 do
        local item = self.Tasks[index]
        self.Tasks[index] = nil
        pcall(function() self:_Clean(item) end)
    end
end

NX.Maid = Maid

local Value = {}
Value.__index = Value

function Value.new(default)
    return setmetatable({
        Current = default,
        Listeners = {},
        Destroyed = false
    }, Value)
end

function Value:Get()
    return self.Current
end

function Value:Set(nextValue)
    if self.Destroyed or self.Current == nextValue then return end
    self.Current = nextValue
    for _, callback in pairs(self.Listeners) do
        task.spawn(function() pcall(callback, nextValue) end)
    end
end

function Value:OnChanged(callback)
    local token = {}
    if self.Destroyed then
        return { Disconnect = function() end }
    end
    self.Listeners[token] = callback
    return { Disconnect = function() self.Listeners[token] = nil end }
end

function Value:Destroy()
    self.Destroyed = true
    table.clear(self.Listeners)
end

function NX:Value(default)
    return Value.new(default)
end
-- [[ 04.25. REGISTRO DE OVERLAYS ]]
NX.Overlays = Runtime.NEXUS_NC_OVERLAYS or {}
Runtime.NEXUS_NC_OVERLAYS = NX.Overlays

function NX:TrackOverlay(maid)
    if type(maid) ~= "table" or type(maid.Destroy) ~= "function" then
        return maid
    end

    if self.Overlays[maid] then return maid end
    self.Overlays[maid] = true

    local originalDestroy = maid.Destroy
    function maid:Destroy()
        NX.Overlays[self] = nil
        return originalDestroy(self)
    end

    return maid
end

function NX:ClearOverlays()
    local active = {}
    for maid in pairs(self.Overlays) do table.insert(active, maid) end

    for _, maid in ipairs(active) do
        pcall(function() maid:Destroy() end)
    end
end
-- [[ 04.5. TASK RUNNER ]]
NX.Loops = Runtime.NEXUS_NC_LOOPS or {}
Runtime.NEXUS_NC_LOOPS = NX.Loops

function NX:StartLoop(id, interval, callback, runImmediately)
    id = tostring(id or "")
    if id == "" then return nil, "Loop necesita un identificador" end
    if type(callback) ~= "function" then return nil, "Callback inválido" end

    interval = math.max(tonumber(interval) or 0.5, 0.03)
    self:StopLoop(id)

    local token = {
        Id = id,
        Active = true,
        Interval = interval,
        Runs = 0,
        Failures = 0
    }
    self.Loops[id] = token

    task.spawn(function()
        local function run()
            if not token.Active then return false end

            local ok, result = pcall(callback, token)
            if ok then
                token.Runs = token.Runs + 1
                if result == false then
                    token.Active = false
                    return false
                end
            else
                token.Failures = token.Failures + 1
                self:Log("Error en loop", id, result)
            end
            return token.Active
        end

        if runImmediately and not run() then
            self.Loops[id] = nil
            return
        end

        while token.Active do
            task.wait(interval)
            if not run() then break end
        end

        if self.Loops[id] == token then
            self.Loops[id] = nil
        end
    end)

    return token
end

function NX:StopLoop(id)
    local token = self.Loops[tostring(id)]
    if not token then return false end
    token.Active = false
    self.Loops[tostring(id)] = nil
    return true
end

function NX:IsLoopRunning(id)
    local token = self.Loops[tostring(id)]
    return token ~= nil and token.Active == true
end

function NX:GetLoop(id)
    return self.Loops[tostring(id)]
end

function NX:StopAllLoops()
    local active = {}
    for id in pairs(self.Loops) do table.insert(active, id) end
    for _, id in ipairs(active) do self:StopLoop(id) end
end

-- [[ 05. ENTRADA MÓVIL ]]
local Input = {}

function Input.Drag(handle, target, maid)
    local active = false
    local activeInput
    local startInput
    local startPosition

    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        return maid and maid:Give(connection) or connection
    end

    local function update(input)
        local delta = input.Position - startInput
        target.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end

    connect(handle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            active = true
            activeInput = input
            startInput = input.Position
            startPosition = target.Position
        end
    end)

    connect(UIS.InputChanged, function(input)
        if not active then return end
        if activeInput.UserInputType == Enum.UserInputType.Touch then
            if input == activeInput then update(input) end
        elseif input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)

    connect(UIS.InputEnded, function(input)
        if input == activeInput then
            active = false
            activeInput = nil
        end
    end)
end

-- [[ 06. VENTANA Y NAVEGACIÓN ]]
function NX:Window(config)
    config = config or {}

    local previous = Runtime.NEXUS_NC_ACTIVE_WINDOW
    if previous and type(previous.Destroy) == "function" then
        pcall(function() previous:Destroy() end)
    end

    local parent = Util.GuiParent()
    local leftover = parent:FindFirstChild("NEXUS_NC")
    if leftover then leftover:Destroy() end

    local app = {
    Tabs = {},
    TabsByName = {},
    Sections = {},
    ActiveTab = nil,
    Maid = Maid.new(),
    Destroyed = false
}


    function app:Connect(signal, callback)
        return self.Maid:Give(signal:Connect(callback))
    end

    function app:Destroy()
        if self.Destroyed then return end
        self.Destroyed = true
        if Runtime.NEXUS_NC_ACTIVE_WINDOW == self then
            Runtime.NEXUS_NC_ACTIVE_WINDOW = nil
        end
        NX:StopAllLoops()
        NX:ClearOverlays()
        self.Maid:Destroy()
    end

    local gui = Util.Make("ScreenGui", {
        Name = "NEXUS_NC",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 100,
        Parent = parent
    })
    app.Gui = gui
    app.Maid:Give(gui)
    Runtime.NEXUS_NC_ACTIVE_WINDOW = app

    app:Connect(gui.AncestryChanged, function(_, newParent)
        if newParent == nil and not app.Destroyed then app:Destroy() end
    end)

    local main = Util.Make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = NX.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = NX:ResolveWindowSize(config.Width or 520, config.Height or 350),
        Parent = gui
    })
    Util.Round(main, 20)
    Util.Stroke(main, NX.Theme.Accent, 0.15)
    app.Main = main

    local topbar = Util.Make("Frame", {
        BackgroundColor3 = NX.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 44),
        Parent = main
    })
    Util.Round(topbar, 16)
    Util.Make("Frame", {
        BackgroundColor3 = NX.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -16),
        Size = UDim2.new(1, 0, 0, 16),
        Parent = topbar
    })

    local dragZone = Util.Make("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -112, 1, 0),
        Text = "",
        Parent = topbar
    })
    Input.Drag(dragZone, main, app.Maid)

    local title = Util.Text(topbar, config.Title or "NC HUB", 18, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(18, 0)
    title.Size = UDim2.new(0, 145, 1, 0)

    local subtitle = Util.Text(topbar, config.Subtitle or "", 12, Enum.Font.Gotham, NX.Theme.Muted)
    subtitle.Position = UDim2.fromOffset(172, 0)
    subtitle.Size = UDim2.new(1, -266, 1, 0)
    app.TitleLabel = title
app.SubtitleLabel = subtitle

function app:SetTitle(value)
    title.Text = tostring(value)
end

function app:SetSubtitle(value)
    subtitle.Text = tostring(value)
end

function app:GetTab(name)
    return self.TabsByName[tostring(name)]
end

function app:GetTabs()
    local names = {}
    for _, tab in ipairs(self.Tabs) do
        if tab.Visible then table.insert(names, tab.Name) end
    end
    return names
end

function app:SelectTab(tabOrName)
    local tab = type(tabOrName) == "table" and tabOrName or self:GetTab(tabOrName)
    if not tab or not tab.Visible or tab.Disabled then return false end
    tab:Open()
    return true
end

function app:SetVisible(visible)
    main.Visible = visible == true
end


    local mac = Util.Make("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundColor3 = NX.Theme.Surface2,
    BackgroundTransparency = 0.08,
    BorderSizePixel = 0,
    Position = UDim2.new(1, -13, 0.5, 0),
    Size = UDim2.fromOffset(90, 30),
    Parent = topbar
})
Util.Round(mac, 11)
Util.Stroke(mac, NX.Theme.Stroke, 0.35)

local miniBar = Util.Make("Frame", {
    BackgroundColor3 = NX.Theme.Surface2,
    BackgroundTransparency = 0.03,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, -66, 0, 10),
    Size = UDim2.fromOffset(132, 40),
    Visible = false,
    Parent = gui
})
Util.Round(miniBar, 13)
Util.Stroke(miniBar, NX.Theme.Accent, 0.18)

local miniAccent = Util.Make("Frame", {
    BackgroundColor3 = NX.Theme.Accent,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(0, 10),
    Size = UDim2.fromOffset(3, 20),
    Parent = miniBar
})
Util.Round(miniAccent, 99)

local grip = Util.Make("TextButton", {
    AutoButtonColor = false,
    BackgroundColor3 = NX.Theme.Surface,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(6, 4),
    Size = UDim2.fromOffset(34, 32),
    Text = "",
    Parent = miniBar
})
Util.Round(grip, 10)

-- Agarre de tres puntos horizontal, pensado para arrastrar en móvil.
for index = 1, 3 do
    local dot = Util.Make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = NX.Theme.Muted,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10 + (index - 1) * 7, 16),
        Size = UDim2.fromOffset(3, 3),
        Parent = grip
    })
    Util.Round(dot, 99)
end

local miniLogo = Util.Make("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = NX.Theme.Cian,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 49, 0.5, 0),
    Size = UDim2.fromOffset(8, 8),
    Parent = miniBar
})
Util.Round(miniLogo, 99)

local restore = Util.Make("TextButton", {
    AutoButtonColor = false,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(63, 0),
    Size = UDim2.new(1, -69, 1, 0),
    Text = "NC HUB",
    TextColor3 = NX.Theme.Text,
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = miniBar
})

    Input.Drag(grip, miniBar, app.Maid)

    local normalSize = main.Size
    local normalPosition = main.Position
    local minimized = false

    local function miniTarget()
        return UDim2.new(
            miniBar.Position.X.Scale,
            miniBar.Position.X.Offset + 66,
            miniBar.Position.Y.Scale,
            miniBar.Position.Y.Offset + 20
        )
    end

    local function minimize()
        if minimized then return end
        minimized = true
        miniBar.Position = UDim2.new(0.5, -66, 0, 10)
        Util.Tween(main, 0.24, {
            Size = UDim2.fromOffset(132, 40),
            Position = miniTarget()
        }):Play()
        task.wait(0.25)
        if app.Destroyed then return end
        main.Visible = false
        main.Size = normalSize
        main.Position = normalPosition
        miniBar.Visible = true
        miniBar.Size = UDim2.fromOffset(86, 30)
        Util.Tween(miniBar, 0.18, { Size = UDim2.fromOffset(126, 38) }):Play()
    end

    local function restoreWindow()
        if not minimized then return end
        minimized = false
        miniBar.Visible = false
        main.Visible = true
        main.Size = UDim2.fromOffset(126, 38)
        main.Position = miniTarget()
        Util.Tween(main, 0.28, {
            Size = normalSize,
            Position = normalPosition
        }):Play()
    end

    local function macButton(color, x, callback)
        local button = Util.Make("TextButton", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            AutoButtonColor = false,
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(x, 14),
            Size = UDim2.fromOffset(13, 13),
            Text = "",
            Parent = mac
        })
        Util.Round(button, 99)
        app:Connect(button.InputBegan, function(input)
            if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1 then
                Util.Tween(button, 0.08, { Size = UDim2.fromOffset(15, 15) }):Play()
            end
        end)
        app:Connect(button.InputEnded, function(input)
            if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1 then
                Util.Tween(button, 0.10, { Size = UDim2.fromOffset(12, 12) }):Play()
            end
        end)
        app:Connect(button.MouseButton1Click, callback)
    end

    macButton(NX.Theme.MacRed, 16, function() app:Destroy() end)
    macButton(NX.Theme.MacYellow, 45, minimize)
    macButton(NX.Theme.MacGreen, 74, function()
        main.Position = UDim2.fromScale(0.5, 0.5)
    end)
    app:Connect(restore.MouseButton1Click, restoreWindow)

    local sidebar = Util.Make("ScrollingFrame", {
        Active = true,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = NX.Theme.Surface,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        ClipsDescendants = true,
        Position = UDim2.fromOffset(0, 44),
        ScrollBarImageColor3 = NX.Theme.Accent,
        ScrollBarThickness = 3,
        Size = UDim2.new(0, 130, 1, -44),
        Parent = main
    })
    Util.Round(sidebar, 20)
    Util.Make("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        Parent = sidebar
    })
    Util.Make("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sidebar
    })

    local content = Util.Make("Frame", {
        BackgroundColor3 = NX.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(130, 44),
        Size = UDim2.new(1, -130, 1, -44),
        Parent = main
    })
    Util.Round(content, 20)

    function app:Section(name)
        local section = { App = self }
        local header = Util.Text(sidebar, "   " .. name, 11, Enum.Font.GothamBold, NX.Theme.Muted)
header.Size = UDim2.new(1, 0, 0, 20)
header.TextXAlignment = Enum.TextXAlignment.Left
header.TextTransparency = 0.16

local sectionMarker = Util.Make("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = NX.Theme.Cian,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    Position = UDim2.new(0, 0, 0.5, 0),
    Size = UDim2.fromOffset(3, 12),
    Parent = header
})
Util.Round(sectionMarker, 99)


        function section:Tab(name)
            local tab = {
    App = app,
    Name = tostring(name),
    Visible = true,
    Disabled = false
}

            local button = Util.Make("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = NX.Theme.Surface,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 34),
                Text = name,
                TextColor3 = NX.Theme.Muted,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sidebar
            })
            Util.Round(button, 9)
            Util.Make("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                Parent = button
            })
        local activeMarker = Util.Make("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = NX.Theme.Cian,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.new(0, -15, 0.5, 0),
    Size = UDim2.fromOffset(0, 20),
    Parent = button
})
Util.Round(activeMarker, 99)


            local page = Util.Make("ScrollingFrame", {
                Active = true,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                CanvasSize = UDim2.new(),
                ScrollBarImageColor3 = NX.Theme.Accent,
                ScrollBarThickness = 4,
                Size = UDim2.fromScale(1, 1),
                Visible = false,
                Parent = content
            })
            Util.Make("UIPadding", {
                PaddingLeft = UDim.new(0, 11),
                PaddingRight = UDim.new(0, 11),
                PaddingTop = UDim.new(0, 11),
                PaddingBottom = UDim.new(0, 11),
                Parent = page
            })
            Util.Make("UIListLayout", {
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = page
            })

            tab.Button = button
            tab.Page = page
            tab.ActiveMarker = activeMarker
            
            function tab:SetName(value)
    value = tostring(value)
    if app.TabsByName[self.Name] == self then
        app.TabsByName[self.Name] = nil
    end
    self.Name = value
    button.Text = value
    app.TabsByName[value] = self
end

function tab:SetVisible(visible)
    self.Visible = visible == true
    button.Visible = self.Visible

    if not self.Visible then
        page.Visible = false
        if app.ActiveTab == self then
            for _, other in ipairs(app.Tabs) do
                if other.Visible and not other.Disabled then
                    other:Open()
                    break
                end
            end
        end
    end
end

function tab:SetDisabled(disabled)
    self.Disabled = disabled == true
    button.TextTransparency = self.Disabled and 0.45 or 0
    button.BackgroundTransparency = self.Disabled and 0.35 or 0
end


            function tab:Open()
    if not tab.Visible or tab.Disabled then return end

    for _, other in ipairs(app.Tabs) do
        other.Page.Visible = false
        other.Button.TextColor3 = NX.Theme.Muted
        Util.Tween(other.Button, 0.14, {
            BackgroundColor3 = NX.Theme.Surface
        }):Play()

        if other.ActiveMarker then
            Util.Tween(other.ActiveMarker, 0.14, {
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(0, 20)
            }):Play()
        end
    end

    page.Visible = true
    button.TextColor3 = NX.Theme.Text
    Util.Tween(button, 0.16, {
        BackgroundColor3 = NX.Theme.Purple
    }):Play()

    if activeMarker then
        Util.Tween(activeMarker, 0.16, {
            BackgroundTransparency = 0,
            Size = UDim2.fromOffset(3, 20)
        }):Play()
    end

    app.ActiveTab = tab
end

function tab:Card(title)
    local card = { Frame = nil, Maid = app.Maid }

    function card:Add(component, config)
        return NX:CreateComponent(component, self, config)
    end

    local frame = Util.Make("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = NX.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = page
    })
    Util.Round(frame, 12)
Util.Make("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, NX.Theme.Surface2),
        ColorSequenceKeypoint.new(1, NX.Theme.Surface)
    }),
    Rotation = 90,
    Parent = frame
})
Util.Stroke(frame, NX.Theme.Stroke, 0.35)


    Util.Make("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingTop = UDim.new(0, 11),
        PaddingBottom = UDim.new(0, 11),
        Parent = frame
    })

    Util.Make("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = frame
    })

    if title then
        local heading = Util.Text(frame, title, 12, Enum.Font.GothamBold, NX.Theme.Cian)
        heading.Size = UDim2.new(1, 0, 0, 18)
    end

    card.Frame = frame
    return card
end

            app:Connect(button.MouseButton1Click, function() tab:Open() end)
app.TabsByName[tab.Name] = tab
table.insert(app.Tabs, tab)

            if #app.Tabs == 1 then tab:Open() end
            return tab
        end

        return section
    end

    return app
end
-- [[ 07. COMPONENTES ]]
local function componentMaid(card)
    return card and card.Maid
end

function NX:Label(card, value)
    local item = Util.Text(card.Frame, value, 13, Enum.Font.Gotham, NX.Theme.Text)
    item.Size = UDim2.new(1, 0, 0, 22)

    return {
        Set = function(_, nextValue) item.Text = tostring(nextValue) end,
        Get = function() return item.Text end,
        SetVisible = function(_, visible) item.Visible = visible end
    }
end

function NX:Button(card, config)
    config = config or {}

    local disabled = config.Disabled == true
    local variant = config.Variant or "primary"

    local function getColor()
        if variant == "danger" then return NX.Theme.MacRed end
        if variant == "success" then return NX.Theme.MacGreen end
        if variant == "secondary" then return NX.Theme.Surface2 end
        return config.Color or NX.Theme.Purple
    end

    local baseColor = getColor()
    local item = Util.Make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = baseColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        Text = config.Name or "Button",
        TextColor3 = NX.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        Parent = card.Frame
    })
    Util.Round(item, 10)

    local stroke = Util.Stroke(item, baseColor, 0.58)

    local function paint(pressed)
        local transparency = disabled and 0.45 or 0
        local strokeTransparency = disabled and 0.84 or (pressed and 0.12 or 0.58)

        Util.Tween(item, 0.10, {
            BackgroundTransparency = transparency
        }):Play()
        Util.Tween(stroke, 0.10, {
            Transparency = strokeTransparency
        }):Play()
    end

    local function setDisabled(value)
        disabled = value == true
        item.TextTransparency = disabled and 0.45 or 0
        paint(false)
    end

    local maid = componentMaid(card)
    if maid then
        maid:Give(item.InputBegan:Connect(function(input)
            if disabled then return end
            if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1 then
                paint(true)
            end
        end))

        maid:Give(item.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch
                or input.UserInputType == Enum.UserInputType.MouseButton1 then
                paint(false)
            end
        end))

        maid:Give(item.MouseButton1Click:Connect(function()
            if not disabled and config.Callback then
                config.Callback()
            end
        end))
    end

    setDisabled(disabled)

    return {
        SetText = function(_, value) item.Text = tostring(value) end,
        SetVisible = function(_, visible) item.Visible = visible end,
        SetDisabled = function(_, value) setDisabled(value) end
    }
end

function NX:Toggle(card, config)
    config = config or {}
    local state = NX:Value(config.Default == true)
    local disabled = config.Disabled == true

    local row = Util.Make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        Text = "",
        Parent = card.Frame
    })
    Util.Round(row, 10)

    local name = Util.Text(row, config.Name or "Toggle", 13, Enum.Font.GothamMedium)
    name.Position = UDim2.fromOffset(11, 0)
    name.Size = UDim2.new(1, -65, 1, 0)

    local track = Util.Make("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = NX.Theme.Purple,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -11, 0.5, 0),
        Size = UDim2.fromOffset(36, 20),
        Parent = row
    })
    Util.Round(track, 99)

    local knob = Util.Make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = NX.Theme.Text,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Parent = track
    })
    Util.Round(knob, 99)

    local function paint(value)
        Util.Tween(track, 0.13, {
            BackgroundColor3 = value and NX.Theme.Cian or NX.Theme.Purple
        }):Play()
        Util.Tween(knob, 0.13, {
            Position = UDim2.new(value and 1 or 0, value and -10 or 10, 0.5, 0)
        }):Play()
    end

    local function set(value, notify)
        value = value == true
        if state:Get() == value then
            paint(value)
            return
        end
        paint(value)
        state:Set(value)
        if notify and config.Callback then config.Callback(value) end
    end

    local maid = componentMaid(card)
    if maid then
        maid:Give(row.MouseButton1Click:Connect(function()
            if not disabled then set(not state:Get(), true) end
        end))
        maid:Give(state)
    end
    paint(state:Get())

    return {
        Set = function(_, value) set(value, true) end,
        Get = function() return state:Get() end,
        OnChanged = function(_, callback) return state:OnChanged(callback) end,
        SetVisible = function(_, visible) row.Visible = visible end,
        SetDisabled = function(_, value)
            disabled = value == true
            row.BackgroundTransparency = disabled and 0.45 or 0
            name.TextTransparency = disabled and 0.45 or 0
        end
    }
end

function NX:Slider(card, config)
    config = config or {}

    local min = config.Min or 0
    local max = config.Max or 100
    local step = config.Step or 1
    local state = NX:Value(config.Default or min)
    local disabled = config.Disabled == true

    local holder = Util.Make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 54),
        Parent = card.Frame
    })

    local name = Util.Text(holder, config.Name or "Slider", 13, Enum.Font.GothamMedium)
    name.Size = UDim2.new(0.7, 0, 0, 20)

    local valueText = Util.Text(holder, "", 13, Enum.Font.GothamBold, NX.Theme.Cian)
    valueText.AnchorPoint = Vector2.new(1, 0)
    valueText.Position = UDim2.new(1, 0, 0, 0)
    valueText.Size = UDim2.new(0.3, 0, 0, 20)
    valueText.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Util.Make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 32),
        Size = UDim2.new(1, 0, 0, 6),
        Text = "",
        Parent = holder
    })
    Util.Round(bar, 99)

    local fill = Util.Make("Frame", {
        BackgroundColor3 = NX.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        Parent = bar
    })
    Util.Round(fill, 99)

    local knob = Util.Make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = NX.Theme.Text,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(14, 14),
        Parent = bar
    })
    Util.Round(knob, 99)

    local dragging = false
    local activeInput

    local function normalize(value)
        value = math.clamp(value, min, max)
        value = math.floor((value - min) / step + 0.5) * step + min
        return math.clamp(value, min, max)
    end

    local function paint(value)
        local range = math.max(max - min, 0.0001)
        local percent = (value - min) / range
        fill.Size = UDim2.fromScale(percent, 1)
        knob.Position = UDim2.fromScale(percent, 0.5)
        valueText.Text = tostring(value)
    end

    local function set(value, notify)
        value = normalize(value)
        if state:Get() == value then
            paint(value)
            return
        end
        paint(value)
        state:Set(value)
        if notify and config.Callback then config.Callback(value) end
    end

    local function fromPosition(x)
        local percent = math.clamp(
            (x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1),
            0,
            1
        )
        set(min + (max - min) * percent, true)
    end

    local maid = componentMaid(card)
    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        if maid then maid:Give(connection) end
    end

    -- Solo responde el slider cuya barra inició el toque.
    connect(bar.InputBegan, function(input)
        if disabled then return end
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            activeInput = input
            fromPosition(input.Position.X)
        end
    end)

    connect(UIS.InputChanged, function(input)
        if not dragging then return end
        if activeInput.UserInputType == Enum.UserInputType.Touch then
            if input == activeInput then fromPosition(input.Position.X) end
        elseif input.UserInputType == Enum.UserInputType.MouseMovement then
            fromPosition(input.Position.X)
        end
    end)

    connect(UIS.InputEnded, function(input)
        if input == activeInput then
            dragging = false
            activeInput = nil
        end
    end)

    if maid then maid:Give(state) end
    state.Current = normalize(state:Get())
    paint(state:Get())

    return {
        Set = function(_, value) set(value, true) end,
        Get = function() return state:Get() end,
        OnChanged = function(_, callback) return state:OnChanged(callback) end,
        SetVisible = function(_, visible) holder.Visible = visible end,
        SetDisabled = function(_, value)
            disabled = value == true
            name.TextTransparency = disabled and 0.45 or 0
            valueText.TextTransparency = disabled and 0.45 or 0
        end
    }
end
-- [[ 07.25. COMPONENTES DE LAYOUT ]]
local function layoutCard(card)
    return card and card.Frame
end

function NX:Paragraph(card, config)
    config = config or {}

    local holder = Util.Make("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = NX.Theme.Surface2,
        BackgroundTransparency = config.Boxed == false and 1 or 0,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = layoutCard(card)
    })
    Util.Round(holder, 10)

    if config.Boxed ~= false then
        Util.Stroke(holder, NX.Theme.Stroke, 0.55)
    end

    Util.Make("UIPadding", {
        PaddingLeft = UDim.new(0, config.Boxed == false and 0 or 11),
        PaddingRight = UDim.new(0, config.Boxed == false and 0 or 11),
        PaddingTop = UDim.new(0, config.Boxed == false and 0 or 10),
        PaddingBottom = UDim.new(0, config.Boxed == false and 0 or 10),
        Parent = holder
    })
    Util.Make("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = holder
    })

    local title = Util.Text(holder, config.Title or "Información", 13, Enum.Font.GothamBold, config.Color or NX.Theme.Text)
    title.AutomaticSize = Enum.AutomaticSize.Y
    title.Size = UDim2.new(1, 0, 0, 0)
    title.TextWrapped = true

    local content = Util.Text(holder, config.Content or "", 12, Enum.Font.Gotham, NX.Theme.Muted)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Size = UDim2.new(1, 0, 0, 0)
    content.TextWrapped = true
    content.TextYAlignment = Enum.TextYAlignment.Top

    return {
        SetTitle = function(_, value) title.Text = tostring(value) end,
        SetContent = function(_, value) content.Text = tostring(value) end,
        SetVisible = function(_, visible) holder.Visible = visible end
    }
end

function NX:Divider(card, text)
    local holder = Util.Make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, text and 19 or 9),
        Parent = layoutCard(card)
    })

    Util.Make("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = NX.Theme.Stroke,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(text and 0.3 or 1, text and -5 or 0, 0, 1),
        Parent = holder
    })

    if text then
        local label = Util.Text(holder, tostring(text), 10, Enum.Font.GothamBold, NX.Theme.Muted)
        label.AnchorPoint = Vector2.new(0.5, 0.5)
        label.Position = UDim2.new(0.5, 0, 0.5, 0)
        label.Size = UDim2.new(0.38, 0, 1, 0)
        label.TextXAlignment = Enum.TextXAlignment.Center

        Util.Make("Frame", {
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = NX.Theme.Stroke,
            BorderSizePixel = 0,
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0.3, -5, 0, 1),
            Parent = holder
        })
    end

    return {
        SetVisible = function(_, visible) holder.Visible = visible end
    }
end

function NX:Space(card, height)
    local spacer = Util.Make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height or 8),
        Parent = layoutCard(card)
    })

    return {
        SetHeight = function(_, value)
            spacer.Size = UDim2.new(1, 0, 0, value or 8)
        end,
        SetVisible = function(_, visible) spacer.Visible = visible end
    }
end

function NX:Badge(card, config)
    if type(config) ~= "table" then config = { Text = tostring(config) } end

    local color = config.Color or NX.Theme.Cian
    local badge = Util.Make("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = color,
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 0, 24),
        Text = config.Text or "Etiqueta",
        TextColor3 = color,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = layoutCard(card)
    })
    Util.Round(badge, 8)
    Util.Make("UIPadding", {
        PaddingLeft = UDim.new(0, 9),
        PaddingRight = UDim.new(0, 9),
        Parent = badge
    })

    return {
        Set = function(_, value) badge.Text = tostring(value) end,
        SetColor = function(_, value)
            badge.BackgroundColor3 = value
            badge.TextColor3 = value
        end,
        SetVisible = function(_, visible) badge.Visible = visible end
    }
end
-- [[ 07.3. CONTENEDORES COLAPSABLES ]]
function NX:Accordion(card, config)
    config = config or {}

    local state = NX:Value(config.Default == true)
    local disabled = config.Disabled == true

    local holder = Util.Make("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = card.Frame
    })
    Util.Round(holder, 11)
    Util.Stroke(holder, NX.Theme.Stroke, 0.48)
    Util.Make("UIListLayout", {
        Padding = UDim.new(0, 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = holder
    })

    local header = Util.Make("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 39),
        Text = "",
        Parent = holder
    })

    local title = Util.Text(header, config.Name or "Sección", 13, Enum.Font.GothamMedium)
    title.Position = UDim2.fromOffset(12, 0)
    title.Size = UDim2.new(1, -58, 1, 0)

    local arrow = Util.Text(header, "⌄", 18, Enum.Font.GothamBold, NX.Theme.Cian)
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -12, 0.5, -1)
    arrow.Size = UDim2.fromOffset(18, 20)
    arrow.TextXAlignment = Enum.TextXAlignment.Center

    local content = Util.Make("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        Parent = holder
    })
    Util.Make("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 1),
        PaddingBottom = UDim.new(0, 10),
        Parent = content
    })
    Util.Make("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = content
    })

    local function set(value, notify)
        value = value == true
        content.Visible = value
        arrow.Text = value and "⌃" or "⌄"
        state:Set(value)
        if notify and config.Callback then config.Callback(value) end
    end

    local maid = componentMaid(card)
    if maid then
        maid:Give(state)
        maid:Give(header.MouseButton1Click:Connect(function()
            if not disabled then set(not state:Get(), true) end
        end))
    end

    set(state:Get(), false)

    local accordion = {
        Frame = content,
        Maid = maid
    }

    function accordion:Set(value)
        set(value, true)
    end

    function accordion:Get()
        return state:Get()
    end

    function accordion:OnChanged(callback)
        return state:OnChanged(callback)
    end

    function accordion:SetTitle(value)
        title.Text = tostring(value)
    end

    function accordion:SetVisible(value)
        holder.Visible = value
    end

    function accordion:SetDisabled(value)
        disabled = value == true
        title.TextTransparency = disabled and 0.45 or 0
        arrow.TextTransparency = disabled and 0.45 or 0
    end

    return accordion
end
-- [[ 07.4. COMPONENTES DE DASHBOARD ]]
function NX:KeyValue(card, config)
    config = config or {}

    local row = Util.Make("Frame", {
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 32),
        Parent = card.Frame
    })
    Util.Round(row, 8)

    local name = Util.Text(row, config.Name or "Dato", 12, Enum.Font.Gotham, NX.Theme.Muted)
    name.Position = UDim2.fromOffset(10, 0)
    name.Size = UDim2.new(0.58, 0, 1, 0)

    local value = Util.Text(row, tostring(config.Value or "—"), 12, Enum.Font.GothamBold, config.Color or NX.Theme.Text)
    value.AnchorPoint = Vector2.new(1, 0)
    value.Position = UDim2.new(1, -10, 0, 0)
    value.Size = UDim2.new(0.42, 0, 1, 0)
    value.TextXAlignment = Enum.TextXAlignment.Right

    return {
        Set = function(_, nextValue) value.Text = tostring(nextValue) end,
        SetName = function(_, nextName) name.Text = tostring(nextName) end,
        SetColor = function(_, color) value.TextColor3 = color end,
        SetVisible = function(_, visible) row.Visible = visible end
    }
end

function NX:Stat(card, config)
    config = config or {}

    local holder = Util.Make("Frame", {
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 58),
        Parent = card.Frame
    })
    Util.Round(holder, 10)
    Util.Stroke(holder, NX.Theme.Stroke, 0.62)

    local accent = Util.Make("Frame", {
        BackgroundColor3 = config.Color or NX.Theme.Cian,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 8),
        Size = UDim2.fromOffset(3, 42),
        Parent = holder
    })
    Util.Round(accent, 99)

    local name = Util.Text(holder, config.Name or "Estadística", 11, Enum.Font.GothamMedium, NX.Theme.Muted)
    name.Position = UDim2.fromOffset(13, 8)
    name.Size = UDim2.new(1, -26, 0, 17)

    local value = Util.Text(holder, tostring(config.Value or "0"), 19, Enum.Font.GothamBold, NX.Theme.Text)
    value.Position = UDim2.fromOffset(13, 25)
    value.Size = UDim2.new(1, -26, 0, 25)

    return {
        Set = function(_, nextValue) value.Text = tostring(nextValue) end,
        SetName = function(_, nextName) name.Text = tostring(nextName) end,
        SetColor = function(_, color) accent.BackgroundColor3 = color end,
        SetVisible = function(_, visible) holder.Visible = visible end
    }
end

function NX:Progress(card, config)
    config = config or {}

    local maximum = math.max(tonumber(config.Max) or 100, 1)
    local current = math.clamp(tonumber(config.Value) or 0, 0, maximum)

    local holder = Util.Make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 52),
        Parent = card.Frame
    })

    local name = Util.Text(holder, config.Name or "Progreso", 12, Enum.Font.GothamMedium)
    name.Size = UDim2.new(0.68, 0, 0, 19)

    local amount = Util.Text(holder, "", 12, Enum.Font.GothamBold, config.Color or NX.Theme.Cian)
    amount.AnchorPoint = Vector2.new(1, 0)
    amount.Position = UDim2.new(1, 0, 0, 0)
    amount.Size = UDim2.new(0.32, 0, 0, 19)
    amount.TextXAlignment = Enum.TextXAlignment.Right

    local track = Util.Make("Frame", {
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 31),
        Size = UDim2.new(1, 0, 0, 8),
        Parent = holder
    })
    Util.Round(track, 99)

    local fill = Util.Make("Frame", {
        BackgroundColor3 = config.Color or NX.Theme.Cian,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        Parent = track
    })
    Util.Round(fill, 99)

    local function format(value, max)
        if config.Format then return tostring(config.Format(value, max)) end
        return string.format("%s / %s", tostring(value), tostring(max))
    end

    local function set(value, max, instant)
        if max ~= nil then maximum = math.max(tonumber(max) or maximum, 1) end
        current = math.clamp(tonumber(value) or 0, 0, maximum)
        amount.Text = format(current, maximum)
        local size = UDim2.fromScale(current / maximum, 1)
        if instant then
            fill.Size = size
        else
            Util.Tween(fill, 0.16, { Size = size }):Play()
        end
    end

    set(current, maximum, true)

    return {
        Set = function(_, value, max) set(value, max, false) end,
        Get = function() return current, maximum end,
        SetName = function(_, nextName) name.Text = tostring(nextName) end,
        SetColor = function(_, color)
            fill.BackgroundColor3 = color
            amount.TextColor3 = color
        end,
        SetVisible = function(_, visible) holder.Visible = visible end
    }
end

-- [[ 07.5. CONTROLES DE FORMULARIO ]]
function NX:Input(card, config)
    config = config or {}

    local numeric = config.Numeric == true
    local finishedOnly = config.Finished == true
    local disabled = config.Disabled == true
    local state = NX:Value(config.Default or "")

    local holder = Util.Make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 62),
        Parent = card.Frame
    })

    local name = Util.Text(holder, config.Name or "Input", 13, Enum.Font.GothamMedium)
    name.Size = UDim2.new(1, 0, 0, 19)

    local box = Util.Make("TextBox", {
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        ClearTextOnFocus = config.ClearOnFocus == true,
        PlaceholderColor3 = NX.Theme.Muted,
        PlaceholderText = config.Placeholder or "Escribe aquí",
        Position = UDim2.fromOffset(0, 26),
        Size = UDim2.new(1, 0, 0, 32),
        Text = "",
        TextColor3 = NX.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder
    })
    Util.Round(box, 9)
    local boxStroke = Util.Stroke(box, NX.Theme.Stroke, 0.52)
    Util.Make("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = box
    })

    local function sanitize(value)
        value = tostring(value or "")
        if not numeric then return value end

        value = value:gsub("[^%d%.-]", "")
        local minus = value:sub(1, 1) == "-" and "-" or ""
        value = value:gsub("%-", "")
        local firstDot = value:find("%.")
        if firstDot then
            value = value:sub(1, firstDot) .. value:sub(firstDot + 1):gsub("%.", "")
        end
        return minus .. value
    end

    local function output(value)
        return numeric and tonumber(value) or value
    end

    local function set(value, notify)
        value = sanitize(value)
        if box.Text ~= value then box.Text = value end
        if state:Get() == value then return end

        state:Set(value)
        if notify and config.Callback then config.Callback(output(value)) end
    end

    local maid = componentMaid(card)
    if maid then
        maid:Give(state)
        maid:Give(box:GetPropertyChangedSignal("Text"):Connect(function()
            if not disabled and not finishedOnly then set(box.Text, true) end
        end))
        maid:Give(box.Focused:Connect(function()
    if not disabled then
        Util.Tween(boxStroke, 0.12, {
            Color = NX.Theme.Cian,
            Transparency = 0.08
        }):Play()
    end
end))

maid:Give(box.FocusLost:Connect(function()
    Util.Tween(boxStroke, 0.12, {
        Color = NX.Theme.Stroke,
        Transparency = 0.52
    }):Play()

    if not disabled then
        set(box.Text, true)
    end
end))
    end

    set(config.Default or "", false)

    return {
        Set = function(_, value) set(value, true) end,
        Get = function() return output(state:Get()) end,
        OnChanged = function(_, callback)
            return state:OnChanged(function(value) callback(output(value)) end)
        end,
        SetVisible = function(_, visible) holder.Visible = visible end,
        SetDisabled = function(_, value)
            disabled = value == true
            box.TextEditable = not disabled
            box.BackgroundTransparency = disabled and 0.45 or 0
            name.TextTransparency = disabled and 0.45 or 0
        end
    }
end

function NX:Dropdown(card, config)
    config = config or {}

    local values = config.Values or {}
    local searchable = config.Searchable ~= false
    local disabled = config.Disabled == true
    local selected = NX:Value(nil)
    local open = false

    local holder = Util.Make("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = card.Frame
    })
    Util.Make("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = holder
    })

    local title = Util.Text(holder, config.Name or "Dropdown", 13, Enum.Font.GothamMedium)
    title.Size = UDim2.new(1, 0, 0, 19)

    local selectButton = Util.Make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        Text = "",
        Parent = holder
    })
    Util.Round(selectButton, 9)

    local selectedText = Util.Text(selectButton, config.Placeholder or "Seleccionar", 13, Enum.Font.Gotham, NX.Theme.Muted)
    selectedText.Position = UDim2.fromOffset(10, 0)
    selectedText.Size = UDim2.new(1, -40, 1, 0)

    local arrow = Util.Text(selectButton, "⌄", 18, Enum.Font.GothamBold, NX.Theme.Cian)
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -11, 0.5, -1)
    arrow.Size = UDim2.fromOffset(18, 20)
    arrow.TextXAlignment = Enum.TextXAlignment.Center

    local list = Util.Make("ScrollingFrame", {
        Active = true,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        ClipsDescendants = true,
        ScrollBarImageColor3 = NX.Theme.Accent,
        ScrollBarThickness = 3,
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        Parent = holder
    })
    Util.Round(list, 9)
    Util.Stroke(list, NX.Theme.Stroke, 0.45)
    Util.Make("UIPadding", {
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 7),
        PaddingBottom = UDim.new(0, 7),
        Parent = list
    })
    Util.Make("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = list
    })

    local search = Util.Make("TextBox", {
        BackgroundColor3 = NX.Theme.Background,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        PlaceholderColor3 = NX.Theme.Muted,
        PlaceholderText = "Buscar",
        Size = UDim2.new(1, 0, 0, 30),
        Text = "",
        TextColor3 = NX.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = searchable,
        Parent = list
    })
    Util.Round(search, 8)
    Util.Make("UIPadding", {
        PaddingLeft = UDim.new(0, 9),
        PaddingRight = UDim.new(0, 9),
        Parent = search
    })

    local options = Util.Make("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = list
    })
    Util.Make("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = options
    })

    local function display(value)
        if value == nil then return config.Placeholder or "Seleccionar" end
        if config.Format then return tostring(config.Format(value)) end
        return tostring(value)
    end

    local function set(value, notify)
        if selected:Get() == value then return end
        selected:Set(value)
        selectedText.Text = display(value)
        selectedText.TextColor3 = value == nil and NX.Theme.Muted or NX.Theme.Text
        if notify and config.Callback then config.Callback(value) end
    end

    local function filtered()
        local query = searchable and search.Text:lower() or ""
        local result = {}
        for _, value in ipairs(values) do
            if query == "" or tostring(value):lower():find(query, 1, true) then
                table.insert(result, value)
            end
        end
        return result
    end

    local function resize(count)
        if not open then return end
        local rows = math.min(math.max(count, 1), 5)
        local searchHeight = searchable and 35 or 0
        list.Size = UDim2.new(1, 0, 0, rows * 31 + searchHeight + 14)
    end

    local function rebuild()
        for _, child in ipairs(options:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end

        local matches = filtered()
        if #matches == 0 then
            local empty = Util.Text(options, "Sin resultados", 12, Enum.Font.Gotham, NX.Theme.Muted)
            empty.Size = UDim2.new(1, 0, 0, 28)
            empty.TextXAlignment = Enum.TextXAlignment.Center
        else
            for _, value in ipairs(matches) do
                local option = Util.Make("TextButton", {
                    AutoButtonColor = false,
                    BackgroundColor3 = selected:Get() == value and NX.Theme.Purple or NX.Theme.Background,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 28),
                    Text = display(value),
                    TextColor3 = NX.Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = options
                })
                Util.Round(option, 7)
                Util.Make("UIPadding", {
                    PaddingLeft = UDim.new(0, 9),
                    PaddingRight = UDim.new(0, 9),
                    Parent = option
                })
                local maid = componentMaid(card)
                local connection = option.MouseButton1Click:Connect(function()
                    set(value, true)
                    open = false
                    list.Visible = false
                    list.Size = UDim2.new(1, 0, 0, 0)
                    arrow.Text = "⌄"
                end)
                if maid then maid:Give(connection) end
            end
        end
        resize(#matches)
    end

    local function setOpen(value)
        if disabled then return end
        open = value == true
        list.Visible = open
        arrow.Text = open and "⌃" or "⌄"
        if open then
            rebuild()
        else
            list.Size = UDim2.new(1, 0, 0, 0)
        end
    end

    local maid = componentMaid(card)
    if maid then
        maid:Give(selected)
        maid:Give(selectButton.MouseButton1Click:Connect(function()
            setOpen(not open)
        end))
        maid:Give(search:GetPropertyChangedSignal("Text"):Connect(rebuild))
    end

    if type(config.Default) == "number" then
        set(values[config.Default], false)
    elseif config.Default ~= nil then
        set(config.Default, false)
    else
        selectedText.Text = display(nil)
    end

    return {
        Set = function(_, value) set(value, true) end,
        Get = function() return selected:Get() end,
        OnChanged = function(_, callback) return selected:OnChanged(callback) end,
        Refresh = function(_, nextValues)
            values = nextValues or {}
            if open then rebuild() end
        end,
        SetVisible = function(_, visible) holder.Visible = visible end,
        SetDisabled = function(_, value)
            disabled = value == true
            selectButton.BackgroundTransparency = disabled and 0.45 or 0
            title.TextTransparency = disabled and 0.45 or 0
            if disabled then setOpen(false) end
        end
    }
end
-- [[ 07.6. CONTROLES AVANZADOS ]]
function NX:Segment(card, config)
    config = config or {}

    local values = config.Values or {}
    local disabled = config.Disabled == true
    local state = NX:Value(config.Default or values[1])
    local buttons = {}

    local holder = Util.Make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 63),
        Parent = card.Frame
    })

    local title = Util.Text(holder, config.Name or "Modo", 13, Enum.Font.GothamMedium)
    title.Size = UDim2.new(1, 0, 0, 19)

    local rail = Util.Make("ScrollingFrame", {
        Active = true,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        Position = UDim2.fromOffset(0, 26),
        ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X,
        Size = UDim2.new(1, 0, 0, 34),
        Parent = holder
    })
    Util.Round(rail, 9)
    Util.Make("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        Parent = rail
    })
    Util.Make("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = rail
    })

    local function display(value)
        if config.Format then return tostring(config.Format(value)) end
        return tostring(value)
    end

    local function paint()
        for value, button in pairs(buttons) do
            local chosen = state:Get() == value
            button.BackgroundColor3 = chosen and NX.Theme.Purple or NX.Theme.Background
            button.TextColor3 = chosen and NX.Theme.Text or NX.Theme.Muted
        end
    end

    local function set(value, notify)
        if state:Get() == value then
            paint()
            return
        end
        state:Set(value)
        paint()
        if notify and config.Callback then config.Callback(value) end
    end

    local function rebuild()
        for _, child in ipairs(rail:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        table.clear(buttons)

        for _, value in ipairs(values) do
            local button = Util.Make("TextButton", {
                AutoButtonColor = false,
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = NX.Theme.Background,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 0, 1, 0),
                Text = display(value),
                TextColor3 = NX.Theme.Muted,
                TextSize = 11,
                Font = Enum.Font.GothamMedium,
                Parent = rail
            })
            Util.Round(button, 7)
            Util.Make("UIPadding", {
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                Parent = button
            })
            buttons[value] = button

            local maid = componentMaid(card)
            local connection = button.MouseButton1Click:Connect(function()
                if not disabled then set(value, true) end
            end)
            if maid then maid:Give(connection) end
        end
        paint()
    end

    local maid = componentMaid(card)
    if maid then maid:Give(state) end
    rebuild()
    if state:Get() ~= nil then set(state:Get(), false) end

    return {
        Set = function(_, value) set(value, true) end,
        Get = function() return state:Get() end,
        OnChanged = function(_, callback) return state:OnChanged(callback) end,
        Refresh = function(_, nextValues)
            values = nextValues or {}
            if #values > 0 and not table.find(values, state:Get()) then
                state.Current = values[1]
            end
            rebuild()
        end,
        SetVisible = function(_, visible) holder.Visible = visible end,
        SetDisabled = function(_, value)
            disabled = value == true
            title.TextTransparency = disabled and 0.45 or 0
            rail.BackgroundTransparency = disabled and 0.45 or 0
        end
    }
end

function NX:MultiDropdown(card, config)
    config = config or {}

    local values = config.Values or {}
    local searchable = config.Searchable ~= false
    local disabled = config.Disabled == true
    local selected = {}
    local changed = NX:Value(0)
    local open = false

    local holder = Util.Make("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = card.Frame
    })
    Util.Make("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = holder
    })

    local title = Util.Text(holder, config.Name or "Selección múltiple", 13, Enum.Font.GothamMedium)
    title.Size = UDim2.new(1, 0, 0, 19)

    local selectButton = Util.Make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        Text = "",
        Parent = holder
    })
    Util.Round(selectButton, 9)
    local selectStroke = Util.Stroke(selectButton, NX.Theme.Stroke, 0.52)
    local summary = Util.Text(selectButton, config.Placeholder or "Seleccionar opciones", 13, Enum.Font.Gotham, NX.Theme.Muted)
    summary.Position = UDim2.fromOffset(10, 0)
    summary.Size = UDim2.new(1, -40, 1, 0)

    local arrow = Util.Text(selectButton, "⌄", 18, Enum.Font.GothamBold, NX.Theme.Cian)
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -11, 0.5, -1)
    arrow.Size = UDim2.fromOffset(18, 20)
    arrow.TextXAlignment = Enum.TextXAlignment.Center

    local list = Util.Make("ScrollingFrame", {
        Active = true,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        ClipsDescendants = true,
        ScrollBarImageColor3 = NX.Theme.Accent,
        ScrollBarThickness = 3,
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        Parent = holder
    })
    Util.Round(list, 9)
    Util.Stroke(list, NX.Theme.Stroke, 0.45)
    Util.Make("UIPadding", {
        PaddingLeft = UDim.new(0, 7),
        PaddingRight = UDim.new(0, 7),
        PaddingTop = UDim.new(0, 7),
        PaddingBottom = UDim.new(0, 7),
        Parent = list
    })
    Util.Make("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = list
    })

    local search = Util.Make("TextBox", {
        BackgroundColor3 = NX.Theme.Background,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        PlaceholderColor3 = NX.Theme.Muted,
        PlaceholderText = "Buscar",
        Size = UDim2.new(1, 0, 0, 30),
        Text = "",
        TextColor3 = NX.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Visible = searchable,
        Parent = list
    })
    Util.Round(search, 8)
    Util.Make("UIPadding", {
        PaddingLeft = UDim.new(0, 9),
        PaddingRight = UDim.new(0, 9),
        Parent = search
    })

    local options = Util.Make("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = list
    })
    Util.Make("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = options
    })

    local function copySelection()
        local result = {}
        for _, value in ipairs(values) do
            if selected[value] then table.insert(result, value) end
        end
        return result
    end

    local function updateSummary()
        local listValues = copySelection()
        if #listValues == 0 then
            summary.Text = config.Placeholder or "Seleccionar opciones"
            summary.TextColor3 = NX.Theme.Muted
        elseif #listValues == 1 then
            summary.Text = tostring(listValues[1])
            summary.TextColor3 = NX.Theme.Text
        else
            summary.Text = tostring(#listValues) .. " opciones seleccionadas"
            summary.TextColor3 = NX.Theme.Text
        end
    end

    local function emit()
        changed:Set(changed:Get() + 1)
        if config.Callback then config.Callback(copySelection()) end
    end

    local function filtered()
        local query = searchable and search.Text:lower() or ""
        local result = {}
        for _, value in ipairs(values) do
            if query == "" or tostring(value):lower():find(query, 1, true) then
                table.insert(result, value)
            end
        end
        return result
    end

    local function resize(count)
        if not open then return end
        local rows = math.min(math.max(count, 1), 5)
        list.Size = UDim2.new(1, 0, 0, rows * 31 + (searchable and 35 or 0) + 14)
    end

    local function rebuild()
        for _, child in ipairs(options:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end

        local matches = filtered()
        if #matches == 0 then
            local empty = Util.Text(options, "Sin resultados", 12, Enum.Font.Gotham, NX.Theme.Muted)
            empty.Size = UDim2.new(1, 0, 0, 28)
            empty.TextXAlignment = Enum.TextXAlignment.Center
        else
            for _, value in ipairs(matches) do
                local chosen = selected[value] == true
                local option = Util.Make("TextButton", {
                    AutoButtonColor = false,
                    BackgroundColor3 = chosen and NX.Theme.Purple or NX.Theme.Background,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 28),
                    Text = tostring(value),
                    TextColor3 = NX.Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = options
                })
                Util.Round(option, 7)
                Util.Make("UIPadding", {
                    PaddingLeft = UDim.new(0, 9),
                    PaddingRight = UDim.new(0, 9),
                    Parent = option
                })

                local check = Util.Text(option, chosen and "✓" or "", 14, Enum.Font.GothamBold, NX.Theme.Cian)
                check.AnchorPoint = Vector2.new(1, 0.5)
                check.Position = UDim2.new(1, -8, 0.5, 0)
                check.Size = UDim2.fromOffset(18, 18)
                check.TextXAlignment = Enum.TextXAlignment.Center

                local maid = componentMaid(card)
                local connection = option.MouseButton1Click:Connect(function()
                    selected[value] = not selected[value] or nil
                    updateSummary()
                    emit()
                    rebuild()
                end)
                if maid then maid:Give(connection) end
            end
        end
        resize(#matches)
    end

    local function setOpen(value)
        if disabled then return end
        open = value == true
        list.Visible = open
        arrow.Text = open and "⌃" or "⌄"
        Util.Tween(selectStroke, 0.12, {
        Color = open and NX.Theme.Cian or NX.Theme.Stroke,
        Transparency = open and 0.10 or 0.52
    }):Play()

    Util.Tween(selectButton, 0.12, {
        BackgroundColor3 = open and NX.Theme.Surface or NX.Theme.Surface2
    }):Play()
    end

    local function set(valuesToSelect, notify)
        table.clear(selected)
        for _, value in ipairs(valuesToSelect or {}) do
            selected[value] = true
        end
        updateSummary()
        if notify then emit() end
        if open then rebuild() end
    end

    local maid = componentMaid(card)
    if maid then
        maid:Give(changed)
        maid:Give(selectButton.MouseButton1Click:Connect(function()
            setOpen(not open)
        end))
        maid:Give(search:GetPropertyChangedSignal("Text"):Connect(rebuild))
    end

    set(config.Default or {}, false)

    return {
        Set = function(_, nextValues) set(nextValues, true) end,
        Get = function() return copySelection() end,
        Clear = function() set({}, true) end,
        OnChanged = function(_, callback)
            return changed:OnChanged(function() callback(copySelection()) end)
        end,
        Refresh = function(_, nextValues)
            values = nextValues or {}
            local preserved = copySelection()
            set(preserved, false)
            if open then rebuild() end
        end,
        SetVisible = function(_, visible) holder.Visible = visible end,
        SetDisabled = function(_, value)
            disabled = value == true
            selectButton.BackgroundTransparency = disabled and 0.45 or 0
            title.TextTransparency = disabled and 0.45 or 0
            if disabled then setOpen(false) end
        end
    }
end
function NX:ColorPicker(card, config)
    config = config or {}

    local defaultPalette = {
        Color3.fromRGB(117, 164, 206),
        Color3.fromRGB(123, 201, 201),
        Color3.fromRGB(224, 138, 175),
        Color3.fromRGB(255, 189, 46),
        Color3.fromRGB(255, 95, 86),
        Color3.fromRGB(39, 201, 63),
        Color3.fromRGB(174, 113, 255),
        Color3.fromRGB(241, 243, 248)
    }

    local palette = config.Palette or defaultPalette
    local disabled = config.Disabled == true
    local state = NX:Value(config.Default or NX.Theme.Accent)
    local open = false

    local holder = Util.Make("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = card.Frame
    })
    Util.Make("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = holder
    })

    local title = Util.Text(holder, config.Name or "Color", 13, Enum.Font.GothamMedium)
    title.Size = UDim2.new(1, 0, 0, 19)

    local selectButton = Util.Make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        Text = "",
        Parent = holder
    })
    Util.Round(selectButton, 9)

    local preview = Util.Make("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = state:Get(),
    BorderSizePixel = 0,
    Position = UDim2.new(0, 10, 0.5, 0),
    Size = UDim2.fromOffset(20, 20),
    Parent = selectButton
})


    Util.Round(preview, 6)
    Util.Stroke(preview, NX.Theme.Text, 0.55)

    local hexText = Util.Text(selectButton, "", 13, Enum.Font.Gotham, NX.Theme.Text)
    hexText.Position = UDim2.fromOffset(40, 0)
    hexText.Size = UDim2.new(1, -72, 1, 0)

    local arrow = Util.Text(selectButton, "⌄", 18, Enum.Font.GothamBold, NX.Theme.Cian)
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -11, 0.5, -1)
    arrow.Size = UDim2.fromOffset(18, 20)
    arrow.TextXAlignment = Enum.TextXAlignment.Center

    local paletteBox = Util.Make("Frame", {
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        Parent = holder
    })
    Util.Round(paletteBox, 10)
    Util.Stroke(paletteBox, NX.Theme.Stroke, 0.45)
    Util.Make("UIPadding", {
        PaddingLeft = UDim.new(0, 9),
        PaddingRight = UDim.new(0, 9),
        PaddingTop = UDim.new(0, 9),
        PaddingBottom = UDim.new(0, 9),
        Parent = paletteBox
    })

    Util.Make("UIGridLayout", {
        CellPadding = UDim2.fromOffset(7, 7),
        CellSize = UDim2.fromOffset(34, 34),
        FillDirectionMaxCells = 6,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = paletteBox
    })

    local function toHex(color)
        local red = math.floor(color.R * 255 + 0.5)
        local green = math.floor(color.G * 255 + 0.5)
        local blue = math.floor(color.B * 255 + 0.5)
        return string.format("#%02X%02X%02X", red, green, blue)
    end

    local function paint(color)
        preview.BackgroundColor3 = color
        hexText.Text = toHex(color)
    end

    local function set(color, notify)
        if typeof(color) ~= "Color3" then return end
        if state:Get() == color then
            paint(color)
            return
        end
        paint(color)
        state:Set(color)
        if notify and config.Callback then config.Callback(color) end
    end

    local function redraw()
        for _, child in ipairs(paletteBox:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for _, color in ipairs(palette) do
            local chosen = state:Get() == color
            local option = Util.Make("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = color,
                BorderSizePixel = 0,
                Text = chosen and "✓" or "",
                TextColor3 = NX.Theme.Background,
                TextSize = 15,
                Font = Enum.Font.GothamBold,
                Parent = paletteBox
            })
            Util.Round(option, 9)
            Util.Stroke(option, chosen and NX.Theme.Text or NX.Theme.Stroke, chosen and 0.05 or 0.5)

            local maid = componentMaid(card)
            local connection = option.MouseButton1Click:Connect(function()
                set(color, true)
                redraw()
            end)
            if maid then maid:Give(connection) end
        end

        local rows = math.max(1, math.ceil(#palette / 6))
        paletteBox.Size = UDim2.new(1, 0, 0, rows * 41 + 11)
    end

    local function setOpen(value)
        if disabled then return end
        open = value == true
        paletteBox.Visible = open
        arrow.Text = open and "⌃" or "⌄"
        if open then redraw() end
    end

    local maid = componentMaid(card)
    if maid then
        maid:Give(state)
        maid:Give(selectButton.MouseButton1Click:Connect(function()
            setOpen(not open)
        end))
    end

    paint(state:Get())

    return {
        Set = function(_, color) set(color, true) end,
        Get = function() return state:Get() end,
        OnChanged = function(_, callback) return state:OnChanged(callback) end,
        SetPalette = function(_, nextPalette)
            palette = nextPalette or {}
            if open then redraw() end
        end,
        SetVisible = function(_, visible) holder.Visible = visible end,
        SetDisabled = function(_, value)
            disabled = value == true
            selectButton.BackgroundTransparency = disabled and 0.45 or 0
            title.TextTransparency = disabled and 0.45 or 0
            if disabled then setOpen(false) end
        end
    }
end

function NX:ColorInput(card, config)
    config = config or {}

    local disabled = config.Disabled == true
    local state = NX:Value(config.Default or NX.Theme.Accent)

    local function toHex(color)
        return string.format("#%02X%02X%02X",
            math.floor(color.R * 255 + 0.5),
            math.floor(color.G * 255 + 0.5),
            math.floor(color.B * 255 + 0.5)
        )
    end

    local function fromHex(text)
        text = tostring(text or ""):upper():gsub("%s", "")
        text = text:gsub("^#", "")
        if #text ~= 6 or not text:match("^[0-9A-F]+$") then return nil end

        local red = tonumber(text:sub(1, 2), 16)
        local green = tonumber(text:sub(3, 4), 16)
        local blue = tonumber(text:sub(5, 6), 16)
        if not red or not green or not blue then return nil end
        return Color3.fromRGB(red, green, blue)
    end

    local holder = Util.Make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 62),
        Parent = card.Frame
    })

    local title = Util.Text(holder, config.Name or "Color exacto", 13, Enum.Font.GothamMedium)
    title.Size = UDim2.new(1, 0, 0, 19)

    local box = Util.Make("TextBox", {
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        ClearTextOnFocus = false,
        PlaceholderColor3 = NX.Theme.Muted,
        PlaceholderText = "#RRGGBB",
        Position = UDim2.fromOffset(0, 26),
        Size = UDim2.new(1, 0, 0, 32),
        Text = "",
        TextColor3 = NX.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder
    })
    Util.Round(box, 9)
    Util.Make("UIPadding", {
        PaddingLeft = UDim.new(0, 40),
        PaddingRight = UDim.new(0, 10),
        Parent = box
    })

    local preview = Util.Make("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = state:Get(),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        Parent = box
    })
    Util.Round(preview, 6)
    Util.Stroke(preview, NX.Theme.Text, 0.55)

    local function set(color, notify)
        if typeof(color) ~= "Color3" then return end
        state:Set(color)
        preview.BackgroundColor3 = color
        box.Text = toHex(color)
        if notify and config.Callback then config.Callback(color) end
    end

    local maid = componentMaid(card)
    if maid then
        maid:Give(state)
        maid:Give(box.FocusLost:Connect(function()
            if disabled then return end
            local color = fromHex(box.Text)
            if color then
                set(color, true)
            else
                box.Text = toHex(state:Get())
            end
        end))
    end

    set(state:Get(), false)

    return {
        Set = function(_, color) set(color, true) end,
        Get = function() return state:Get() end,
        OnChanged = function(_, callback) return state:OnChanged(callback) end,
        SetVisible = function(_, visible) holder.Visible = visible end,
        SetDisabled = function(_, value)
            disabled = value == true
            box.TextEditable = not disabled
            box.BackgroundTransparency = disabled and 0.45 or 0
            title.TextTransparency = disabled and 0.45 or 0
        end
    }
end

function NX:Keybind(card, config)
    config = config or {}

    local disabled = config.Disabled == true
    local listening = false
    local key = nil
    local state = NX:Value(nil)

    local function parse(value)
        if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
            return value
        end
        if type(value) == "string" then
            return Enum.KeyCode[value]
        end
        return nil
    end

    local holder = Util.Make("Frame", {
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        Parent = card.Frame
    })
    Util.Round(holder, 10)

    local name = Util.Text(holder, config.Name or "Keybind", 13, Enum.Font.GothamMedium)
    name.Position = UDim2.fromOffset(11, 0)
    name.Size = UDim2.new(1, -130, 1, 0)

    local bindButton = Util.Make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        AutoButtonColor = false,
        BackgroundColor3 = NX.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(104, 26),
        Text = "Sin tecla",
        TextColor3 = NX.Theme.Muted,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        Parent = holder
    })
    Util.Round(bindButton, 7)

    local function format(value)
        if not value then return "Sin tecla" end
        return value.Name
    end

    local function render()
        bindButton.Text = listening and "Pulsa una tecla" or format(key)
        bindButton.TextColor3 = listening and NX.Theme.Cian or (key and NX.Theme.Text or NX.Theme.Muted)
    end

    local function set(value, notify)
        key = parse(value)
        state:Set(key)
        render()
        if notify and config.Changed then config.Changed(key) end
    end

    local maid = componentMaid(card)
    if maid then
        maid:Give(state)
        maid:Give(bindButton.MouseButton1Click:Connect(function()
            if disabled then return end
            listening = not listening
            render()
        end))
        maid:Give(UIS.InputBegan:Connect(function(input, processed)
            if processed then return end

            if listening then
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    set(input.KeyCode, true)
                end
                return
            end

            if key and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key then
                if config.Callback then config.Callback(key) end
            end
        end))
    end

    set(config.Default, false)

    return {
        Set = function(_, value) set(value, true) end,
        Get = function() return key end,
        OnChanged = function(_, callback) return state:OnChanged(callback) end,
        SetVisible = function(_, visible) holder.Visible = visible end,
        SetDisabled = function(_, value)
            disabled = value == true
            bindButton.BackgroundTransparency = disabled and 0.45 or 0
            name.TextTransparency = disabled and 0.45 or 0
            if disabled then
                listening = false
                render()
            end
        end
    }
end

-- [[ 07.75. OVERLAYS Y DIÁLOGOS ]]
local function overlayGui(name, order)
    return Util.Make("ScreenGui", {
        Name = name,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = order or 999997,
        Parent = Util.GuiParent()
    })
end

function NX:Dialog(config)
    config = config or {}

    local maid = NX:TrackOverlay(Maid.new())
    local closed = false
    local gui = overlayGui("NEXUS_NC_DIALOG", 999997)
    maid:Give(gui)

    local backdrop = Util.Make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        Parent = gui
    })

    local panel = Util.Make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = NX.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.54),
        Size = UDim2.fromOffset(config.Width or 300, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = gui
    })
    Util.Round(panel, 16)
    Util.Stroke(panel, NX.Theme.Accent, 0.16)
    Util.Make("UIPadding", {
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        PaddingTop = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15),
        Parent = panel
    })
    Util.Make("UIListLayout", {
        Padding = UDim.new(0, 9),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = panel
    })

    local title = Util.Text(panel, config.Title or "NC HUB", 17, Enum.Font.GothamBold)
    title.Size = UDim2.new(1, 0, 0, 23)

    local content = Util.Text(panel, config.Content or "", 12, Enum.Font.Gotham, NX.Theme.Muted)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Size = UDim2.new(1, 0, 0, 0)
    content.TextWrapped = true
    content.TextYAlignment = Enum.TextYAlignment.Top

    local actions = Util.Make("Frame", {
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Parent = panel
    })
    Util.Make("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = actions
    })

    local function close(result)
        if closed then return end
        closed = true
        Util.Tween(backdrop, 0.16, { BackgroundTransparency = 1 }):Play()
        Util.Tween(panel, 0.16, {
            Position = UDim2.fromScale(0.5, 0.54),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.18)
        maid:Destroy()
        if config.OnClose then config.OnClose(result) end
    end

    local function buttonColor(variant)
        if variant == "danger" then return NX.Theme.MacRed end
        if variant == "secondary" then return NX.Theme.Surface2 end
        return NX.Theme.Accent
    end

    for _, definition in ipairs(config.Buttons or {}) do
        local button = Util.Make("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = buttonColor(definition.Variant),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),
            Text = definition.Name or "Aceptar",
            TextColor3 = definition.Variant == "secondary" and NX.Theme.Text or NX.Theme.Background,
            TextSize = 13,
            Font = Enum.Font.GothamMedium,
            Parent = actions
        })
        Util.Round(button, 9)

        maid:Give(button.MouseButton1Click:Connect(function()
            local result = definition.Result
            if definition.Callback then definition.Callback(result) end
            if definition.Close ~= false then close(result) end
        end))
    end

    if #(config.Buttons or {}) == 0 then
        local button = Util.Make("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = NX.Theme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),
            Text = "Aceptar",
            TextColor3 = NX.Theme.Background,
            TextSize = 13,
            Font = Enum.Font.GothamMedium,
            Parent = actions
        })
        Util.Round(button, 9)
        maid:Give(button.MouseButton1Click:Connect(function() close(true) end))
    end

    if config.CloseOnBackdrop == true then
        maid:Give(backdrop.MouseButton1Click:Connect(function() close(false) end))
    end

    Util.Tween(backdrop, 0.18, { BackgroundTransparency = 0.42 }):Play()
    Util.Tween(panel, 0.20, { Position = UDim2.fromScale(0.5, 0.5) }):Play()

    return {
        Close = close,
        SetTitle = function(_, value) title.Text = tostring(value) end,
        SetContent = function(_, value) content.Text = tostring(value) end,
        IsOpen = function() return not closed end
    }
end

function NX:Confirm(config)
    config = config or {}

    return self:Dialog({
        Title = config.Title or "Confirmar acción",
        Content = config.Content or "¿Deseas continuar?",
        CloseOnBackdrop = config.CloseOnBackdrop == true,
        OnClose = config.OnClose,
        Buttons = {
            {
                Name = config.CancelText or "Cancelar",
                Variant = "secondary",
                Result = false,
                Callback = function()
                    if config.Callback then config.Callback(false) end
                end
            },
            {
                Name = config.ConfirmText or "Confirmar",
                Variant = config.Danger == true and "danger" or "primary",
                Result = true,
                Callback = function()
                    if config.Callback then config.Callback(true) end
                end
            }
        }
    })
end
-- [[ 07.9. EXTENSIONES Y DIAGNÓSTICO ]]
NX.Components = {}
NX.Diagnostics = {
    Enabled = false,
    Prefix = "[NEXUS NC]"
}

function NX:SetDiagnostics(enabled)
    self.Diagnostics.Enabled = enabled == true
end

function NX:Log(...)
    if self.Diagnostics.Enabled then
        print(self.Diagnostics.Prefix, ...)
    end
end

function NX:RegisterComponent(name, factory)
    if type(name) ~= "string" or name == "" then
        return false, "Nombre inválido"
    end
    if type(factory) ~= "function" then
        return false, "Factory inválida"
    end

    self.Components[name] = factory
    self:Log("Componente registrado:", name)
    return true
end

function NX:UnregisterComponent(name)
    if not self.Components[name] then return false end
    self.Components[name] = nil
    self:Log("Componente eliminado:", name)
    return true
end

function NX:HasComponent(name)
    return type(self.Components[name]) == "function"
end

function NX:GetComponents()
    local list = {}
    for name in pairs(self.Components) do table.insert(list, name) end
    table.sort(list)
    return list
end

function NX:CreateComponent(name, card, config)
    local factory = self.Components[name]
    if type(factory) ~= "function" then
        self:Log("Componente no encontrado:", tostring(name))
        return nil, "Componente no encontrado: " .. tostring(name)
    end

    local ok, result = pcall(factory, self, card, config or {})
    if not ok then
        self:Log("Error creando", name, result)
        return nil, result
    end
    return result
end

function NX:RegisterBuiltins()
    self:RegisterComponent("Label", function(lib, card, config)
        return lib:Label(card, config.Text or "")
    end)

    self:RegisterComponent("Button", function(lib, card, config)
        return lib:Button(card, config)
    end)

    self:RegisterComponent("Toggle", function(lib, card, config)
        return lib:Toggle(card, config)
    end)

    self:RegisterComponent("Slider", function(lib, card, config)
        return lib:Slider(card, config)
    end)

    self:RegisterComponent("Input", function(lib, card, config)
        return lib:Input(card, config)
    end)

    self:RegisterComponent("Dropdown", function(lib, card, config)
        return lib:Dropdown(card, config)
    end)
    
    self:RegisterComponent("Segment", function(lib, card, config)
    return lib:Segment(card, config)
end)


    self:RegisterComponent("MultiDropdown", function(lib, card, config)
        return lib:MultiDropdown(card, config)
    end)

    self:RegisterComponent("ColorPicker", function(lib, card, config)
        return lib:ColorPicker(card, config)
    end)
    
    self:RegisterComponent("ColorInput", function(lib, card, config)
    return lib:ColorInput(card, config)
end)
    
    self:RegisterComponent("ProfilePanel", function(lib, card, config)
    return lib:ProfilePanel(card, config)
end)


    self:RegisterComponent("Paragraph", function(lib, card, config)
        return lib:Paragraph(card, config)
    end)

    self:RegisterComponent("Divider", function(lib, card, config)
        return lib:Divider(card, config.Text)
    end)
end

NX:RegisterBuiltins()
-- Auto-vínculo opcional: usa Bind = "mi_id" en un control.
NX._AutoBindWrapped = NX._AutoBindWrapped or {}

function NX:EnableAutoBinding()
    local function wrap(methodName)
        if self._AutoBindWrapped[methodName] then return end

        local original = self[methodName]
        if type(original) ~= "function" then return end

        self[methodName] = function(lib, card, config, ...)
            local handle = original(lib, card, config, ...)

            if type(config) == "table"
                and type(config.Bind) == "string"
                and config.Bind ~= ""
                and type(handle) == "table"
                and type(handle.Get) == "function"
                and type(handle.Set) == "function" then
                lib:Bind(config.Bind, handle, config.BindOptions)
            end

            return handle
        end

        self._AutoBindWrapped[methodName] = true
    end

    wrap("Toggle")
    wrap("Slider")
    wrap("Input")
    wrap("Dropdown")
    wrap("Segment")
    wrap("MultiDropdown")
    wrap("ColorPicker")
    wrap("ColorInput")
    wrap("Keybind")
end

NX:EnableAutoBinding()

-- [[ 07.95. PANEL DE PERFILES ]]
function NX:ProfilePanel(card, config)
    config = config or {}

    local store = self:ProfileStore(config.Namespace or "default")
    local status = self:Label(card, config.StatusText or "Perfil: ninguno")

    local nameInput = self:Input(card, {
        Name = config.NameLabel or "Nombre del perfil",
        Placeholder = config.Placeholder or "Ejemplo: Farm"
    })

    local profileList = self:Dropdown(card, {
        Name = config.ListLabel or "Perfiles guardados",
        Placeholder = config.ListPlaceholder or "Seleccionar perfil",
        Values = store:List(),
        Searchable = true,
        Callback = function(value)
            nameInput:Set(value)
            status:Set("Perfil seleccionado: " .. tostring(value))
        end
    })

    local function refresh()
        profileList:Refresh(store:List())
    end

    local function getName()
        return tostring(nameInput:Get() or "")
    end

    local save = self:Button(card, {
        Name = config.SaveText or "Guardar perfil",
        Callback = function()
            local name = getName()
            local ok, err = store:Save(name, config.Extra)
            if ok then
                refresh()
                profileList:Set(name)
                status:Set("Perfil guardado: " .. name)
                if config.OnSave then config.OnSave(name) end
            else
                status:Set("Error: " .. tostring(err))
            end
        end
    })

    local load = self:Button(card, {
        Name = config.LoadText or "Cargar perfil",
        Callback = function()
            local name = getName()
            local extra, err = store:Load(name)
            if extra then
                status:Set("Perfil cargado: " .. name)
                if config.OnLoad then config.OnLoad(name, extra) end
            else
                status:Set("Error: " .. tostring(err))
            end
        end
    })

    local delete = self:Button(card, {
        Name = config.DeleteText or "Borrar perfil",
        Callback = function()
            local name = getName()
            local ok, err = store:Delete(name)
            if ok then
                refresh()
                status:Set("Perfil borrado: " .. name)
                if config.OnDelete then config.OnDelete(name) end
            else
                status:Set("Error: " .. tostring(err))
            end
        end
    })

    return {
        Store = store,
        Refresh = refresh,
        Save = function(_, name) return store:Save(name or getName(), config.Extra) end,
        Load = function(_, name) return store:Load(name or getName()) end,
        Delete = function(_, name) return store:Delete(name or getName()) end,
        GetName = getName,
        SetName = function(_, name) nameInput:Set(name) end,
        GetProfiles = function() return store:List() end,
        Status = status,
        SaveButton = save,
        LoadButton = load,
        DeleteButton = delete
    }
end

-- [[ 08. FEEDBACK ]]
-- Gestor de notificaciones apiladas.
NX.NotificationService = Runtime.NEXUS_NC_NOTIFICATION_SERVICE or {
    Host = nil,
    Maid = nil,
    Count = 0
}
Runtime.NEXUS_NC_NOTIFICATION_SERVICE = NX.NotificationService

function NX:_GetNotificationHost()
    local service = self.NotificationService

    if service.Host and service.Host.Parent then
        return service.Host
    end

    local maid = self:TrackOverlay(Maid.new())
    local gui = Util.Make("ScreenGui", {
        Name = "NEXUS_NC_NOTIFICATIONS",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 999998,
        Parent = Util.GuiParent()
    })
    maid:Give(gui)

    local holder = Util.Make("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -16, 1, -18),
        Size = UDim2.fromOffset(245, 0),
        Parent = gui
    })
    Util.Make("UIListLayout", {
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = holder
    })

    service.Host = holder
    service.Maid = maid
    return holder
end

function NX:Notify(title, message, options)
    if type(title) == "table" then
        options = title
        title = options.Title
        message = options.Content or options.Message
    end

    options = options or {}
    local holder = self:_GetNotificationHost()
    local service = self.NotificationService
    service.Count = service.Count + 1

    local maid = Maid.new()
    local closed = false
    local accent = options.Color or NX.Theme.Cian

    local box = Util.Make("Frame", {
        BackgroundColor3 = NX.Theme.Surface,
        BorderSizePixel = 0,
        LayoutOrder = service.Count,
        Size = UDim2.new(1, 0, 0, 68),
        Parent = holder
    })
    Util.Round(box, 12)
    Util.Stroke(box, accent, 0.22)

    local accentBar = Util.Make("Frame", {
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 10),
        Size = UDim2.fromOffset(3, 48),
        Parent = box
    })
    Util.Round(accentBar, 99)

    local heading = Util.Text(box, title or "NC HUB", 13, Enum.Font.GothamBold, NX.Theme.Text)
    heading.Position = UDim2.fromOffset(13, 8)
    heading.Size = UDim2.new(1, -45, 0, 18)

    local body = Util.Text(box, message or "", 11, Enum.Font.Gotham, NX.Theme.Muted)
    body.Position = UDim2.fromOffset(13, 28)
    body.Size = UDim2.new(1, -28, 0, 29)
    body.TextWrapped = true
    body.TextYAlignment = Enum.TextYAlignment.Top

    local closeButton = Util.Make("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -8, 0, 6),
        Size = UDim2.fromOffset(22, 22),
        Text = "×",
        TextColor3 = NX.Theme.Muted,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = box
    })

    local function close()
        if closed then return end
        closed = true

        Util.Tween(box, 0.16, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0)
        }):Play()
        Util.Tween(heading, 0.12, { TextTransparency = 1 }):Play()
        Util.Tween(body, 0.12, { TextTransparency = 1 }):Play()
        Util.Tween(closeButton, 0.12, { TextTransparency = 1 }):Play()
        task.wait(0.18)
        maid:Destroy()
        if box.Parent then box:Destroy() end
    end

    maid:Give(closeButton.MouseButton1Click:Connect(close))

    if type(options.Action) == "function" then
        local action = Util.Make("TextButton", {
            AnchorPoint = Vector2.new(1, 1),
            AutoButtonColor = false,
            BackgroundColor3 = NX.Theme.Surface2,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -9, 1, -7),
            Size = UDim2.fromOffset(70, 20),
            Text = options.ActionText or "Abrir",
            TextColor3 = accent,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            Parent = box
        })
        Util.Round(action, 6)
        maid:Give(action.MouseButton1Click:Connect(function()
            options.Action()
            close()
        end))
        body.Size = UDim2.new(1, -105, 0, 29)
    end

    box.BackgroundTransparency = 1
    heading.TextTransparency = 1
    body.TextTransparency = 1
    closeButton.TextTransparency = 1
    Util.Tween(box, 0.18, { BackgroundTransparency = 0 }):Play()
    Util.Tween(heading, 0.14, { TextTransparency = 0 }):Play()
    Util.Tween(body, 0.14, { TextTransparency = 0 }):Play()
    Util.Tween(closeButton, 0.14, { TextTransparency = 0 }):Play()

    local duration = tonumber(options.Duration)
    if duration == nil then duration = 3 end
    if duration > 0 then
        task.delay(duration, close)
    end

    return {
        Close = close,
        SetTitle = function(_, value) heading.Text = tostring(value) end,
        SetContent = function(_, value) body.Text = tostring(value) end
    }
end

function NX:Notify(title, message, options)
    if type(title) == "table" then
        options = title
        title = options.Title
        message = options.Content or options.Message
    end

    options = options or {}
    local holder = self:_GetNotificationHost()
    local service = self.NotificationService
    service.Count = service.Count + 1

    local maid = Maid.new()
    local closed = false
    local accent = options.Color or NX.Theme.Cian

    local box = Util.Make("Frame", {
        BackgroundColor3 = NX.Theme.Surface,
        BorderSizePixel = 0,
        LayoutOrder = service.Count,
        Size = UDim2.new(1, 0, 0, 68),
        Parent = holder
    })
    Util.Round(box, 12)
    Util.Stroke(box, accent, 0.22)

    local accentBar = Util.Make("Frame", {
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 10),
        Size = UDim2.fromOffset(3, 48),
        Parent = box
    })
    Util.Round(accentBar, 99)

    local heading = Util.Text(box, title or "NC HUB", 13, Enum.Font.GothamBold, NX.Theme.Text)
    heading.Position = UDim2.fromOffset(13, 8)
    heading.Size = UDim2.new(1, -45, 0, 18)

    local body = Util.Text(box, message or "", 11, Enum.Font.Gotham, NX.Theme.Muted)
    body.Position = UDim2.fromOffset(13, 28)
    body.Size = UDim2.new(1, -28, 0, 29)
    body.TextWrapped = true
    body.TextYAlignment = Enum.TextYAlignment.Top

    local closeButton = Util.Make("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -8, 0, 6),
        Size = UDim2.fromOffset(22, 22),
        Text = "×",
        TextColor3 = NX.Theme.Muted,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = box
    })

    local function close()
        if closed then return end
        closed = true

        Util.Tween(box, 0.16, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0)
        }):Play()
        Util.Tween(heading, 0.12, { TextTransparency = 1 }):Play()
        Util.Tween(body, 0.12, { TextTransparency = 1 }):Play()
        Util.Tween(closeButton, 0.12, { TextTransparency = 1 }):Play()
        task.wait(0.18)
        maid:Destroy()
        if box.Parent then box:Destroy() end
    end

    maid:Give(closeButton.MouseButton1Click:Connect(close))

    if type(options.Action) == "function" then
        local action = Util.Make("TextButton", {
            AnchorPoint = Vector2.new(1, 1),
            AutoButtonColor = false,
            BackgroundColor3 = NX.Theme.Surface2,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -9, 1, -7),
            Size = UDim2.fromOffset(70, 20),
            Text = options.ActionText or "Abrir",
            TextColor3 = accent,
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            Parent = box
        })
        Util.Round(action, 6)
        maid:Give(action.MouseButton1Click:Connect(function()
            options.Action()
            close()
        end))
        body.Size = UDim2.new(1, -105, 0, 29)
    end

    box.BackgroundTransparency = 1
    heading.TextTransparency = 1
    body.TextTransparency = 1
    closeButton.TextTransparency = 1
    Util.Tween(box, 0.18, { BackgroundTransparency = 0 }):Play()
    Util.Tween(heading, 0.14, { TextTransparency = 0 }):Play()
    Util.Tween(body, 0.14, { TextTransparency = 0 }):Play()
    Util.Tween(closeButton, 0.14, { TextTransparency = 0 }):Play()

    local duration = tonumber(options.Duration)
    if duration == nil then duration = 3 end
    if duration > 0 then
        task.delay(duration, close)
    end

    return {
        Close = close,
        SetTitle = function(_, value) heading.Text = tostring(value) end,
        SetContent = function(_, value) body.Text = tostring(value) end
    }
end

function NX:Loading(config)
    config = config or {}
    local maid = NX:TrackOverlay(Maid.new())

    local gui = Util.Make("ScreenGui", {
        Name = "NEXUS_NC_LOADING",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 999999,
        Parent = Util.GuiParent()
    })
    maid:Give(gui)

    local background = Util.Make("Frame", {
        BackgroundColor3 = NX.Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = gui
    })

    local card = Util.Make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = NX.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(320, 125),
        Parent = background
    })
    Util.Round(card, 16)
    Util.Stroke(card, NX.Theme.Accent, 0.1)

    local mark = Util.Text(card, "N", 22, Enum.Font.GothamBold, NX.Theme.Cian)
    mark.BackgroundColor3 = NX.Theme.Purple
    mark.BackgroundTransparency = 0.1
    mark.Position = UDim2.fromOffset(18, 18)
    mark.Size = UDim2.fromOffset(35, 35)
    mark.TextXAlignment = Enum.TextXAlignment.Center
    Util.Round(mark, 10)

    local title = Util.Text(card, config.Title or "NC HUB", 21, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(63, 19)
    title.Size = UDim2.new(1, -82, 0, 26)

    local status = Util.Text(card, config.Text or "Preparando interfaz", 13, Enum.Font.Gotham, NX.Theme.Muted)
    status.Position = UDim2.fromOffset(18, 64)
    status.Size = UDim2.new(1, -36, 0, 18)

    local track = Util.Make("Frame", {
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(18, 94),
        Size = UDim2.new(1, -36, 0, 7),
        Parent = card
    })
    Util.Round(track, 99)

    local fill = Util.Make("Frame", {
        BackgroundColor3 = NX.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        Parent = track
    })
    Util.Round(fill, 99)
    Util.Make("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, NX.Theme.Accent),
            ColorSequenceKeypoint.new(0.5, NX.Theme.Cian),
            ColorSequenceKeypoint.new(1, NX.Theme.Rose)
        }),
        Parent = fill
    })

    return function(endText)
        status.Text = endText or "Listo"
        Util.Tween(fill, 0.6, { Size = UDim2.fromScale(1, 1) }):Play()
        task.wait(0.75)
        Util.Tween(background, 0.25, { BackgroundTransparency = 1 }):Play()
        Util.Tween(card, 0.25, { BackgroundTransparency = 1 }):Play()

        for _, object in ipairs(card:GetDescendants()) do
            if object:IsA("TextLabel") then
                Util.Tween(object, 0.2, { TextTransparency = 1 }):Play()
            elseif object:IsA("Frame") then
                Util.Tween(object, 0.2, { BackgroundTransparency = 1 }):Play()
            elseif object:IsA("UIStroke") then
                Util.Tween(object, 0.2, { Transparency = 1 }):Play()
            end
        end

        task.wait(0.3)
        maid:Destroy()
    end
end

return NX
