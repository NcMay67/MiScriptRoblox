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
        Size = UDim2.fromOffset(config.Width or 520, config.Height or 350),
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
        Size = UDim2.new(1, -94, 1, 0),
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

    local mac = Util.Make("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = NX.Theme.Surface2,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(78, 28),
        Parent = topbar
    })
    Util.Round(mac, 9)
    Util.Stroke(mac, NX.Theme.Stroke, 0.55)

    local miniBar = Util.Make("Frame", {
        BackgroundColor3 = NX.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -145, 0, 82),
        Size = UDim2.fromOffset(126, 38),
        Visible = false,
        Parent = gui
    })
    Util.Round(miniBar, 12)
    Util.Stroke(miniBar, NX.Theme.Accent, 0.25)

    local grip = Util.Make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(4, 4),
        Size = UDim2.fromOffset(28, 30),
        Text = "",
        Parent = miniBar
    })
    Util.Round(grip, 9)

    for index = 1, 3 do
        local dot = Util.Make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = NX.Theme.Muted,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 0, 7 + index * 7),
            Size = UDim2.fromOffset(3, 3),
            Parent = grip
        })
        Util.Round(dot, 99)
    end

    local restore = Util.Make("TextButton", {
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(37, 0),
        Size = UDim2.new(1, -41, 1, 0),
        Text = "N  NC HUB",
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
            miniBar.Position.X.Offset + 63,
            miniBar.Position.Y.Scale,
            miniBar.Position.Y.Offset + 19
        )
    end

    local function minimize()
        if minimized then return end
        minimized = true
        Util.Tween(main, 0.24, {
            Size = UDim2.fromOffset(126, 38),
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
            Size = UDim2.fromOffset(12, 12),
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

    macButton(NX.Theme.MacRed, 15, function() app:Destroy() end)
    macButton(NX.Theme.MacYellow, 39, minimize)
    macButton(NX.Theme.MacGreen, 63, function()
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
        local header = Util.Text(sidebar, name, 11, Enum.Font.GothamBold, NX.Theme.Muted)
        header.Size = UDim2.new(1, 0, 0, 20)

        function section:Tab(name)
            local tab = { App = app }
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

            function tab:Open()
                for _, other in ipairs(app.Tabs) do
                    other.Page.Visible = false
                    other.Button.BackgroundColor3 = NX.Theme.Surface
                    other.Button.TextColor3 = NX.Theme.Muted
                end
                page.Visible = true
                button.BackgroundColor3 = NX.Theme.Purple
                button.TextColor3 = NX.Theme.Text
                app.ActiveTab = tab
            end

            function tab:Card(title)
                local card = { Frame = nil, Maid = app.Maid }
                local frame = Util.Make("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = NX.Theme.Surface,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 0),
                    Parent = page
                })
                Util.Round(frame, 12)
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

    local item = Util.Make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = NX.Theme.Purple,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        Text = config.Name or "Button",
        TextColor3 = NX.Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        Parent = card.Frame
    })
    Util.Round(item, 10)

    local function setDisabled(value)
        disabled = value == true
        item.TextTransparency = disabled and 0.45 or 0
        item.BackgroundTransparency = disabled and 0.45 or 0
    end

    local maid = componentMaid(card)
    local connection = item.MouseButton1Click:Connect(function()
        if not disabled and config.Callback then config.Callback() end
    end)
    if maid then maid:Give(connection) end
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

-- [[ 08. FEEDBACK ]]
function NX:Notify(title, message)
    local maid = Maid.new()
    local gui = Util.Make("ScreenGui", {
        Name = "NEXUS_NC_NOTIFY",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 999998,
        Parent = Util.GuiParent()
    })
    maid:Give(gui)

    local box = Util.Make("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = NX.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 250, 1, -18),
        Size = UDim2.fromOffset(235, 70),
        Parent = gui
    })
    Util.Round(box, 12)
    Util.Stroke(box, NX.Theme.Accent, 0.25)

    local heading = Util.Text(box, title or "NC HUB", 14, Enum.Font.GothamBold)
    heading.Position = UDim2.fromOffset(12, 8)
    heading.Size = UDim2.new(1, -24, 0, 19)

    local body = Util.Text(box, message or "", 12, Enum.Font.Gotham, NX.Theme.Muted)
    body.Position = UDim2.fromOffset(12, 30)
    body.Size = UDim2.new(1, -24, 0, 30)
    body.TextWrapped = true
    body.TextYAlignment = Enum.TextYAlignment.Top

    Util.Tween(box, 0.22, { Position = UDim2.new(1, -18, 1, -18) }):Play()
    task.delay(3, function()
        if not box.Parent then return end
        Util.Tween(box, 0.2, {
            Position = UDim2.new(1, 250, 1, -18),
            BackgroundTransparency = 1
        }):Play()
        task.wait(0.25)
        maid:Destroy()
    end)
end

function NX:Loading(config)
    config = config or {}
    local maid = Maid.new()

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
