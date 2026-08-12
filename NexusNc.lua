-- NEXUS NC Interface | v0.1
local NX = {}
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer

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

local function make(class, props)
    local obj = Instance.new(class)
    for key, value in pairs(props or {}) do
        obj[key] = value
    end
    return obj
end

local function round(obj, radius)
    return make("UICorner", {
        CornerRadius = UDim.new(0, radius or 10),
        Parent = obj
    })
end

local function line(obj, color, transparency)
    return make("UIStroke", {
        Color = color or NX.Theme.Stroke,
        Thickness = 1,
        Transparency = transparency or 0.3,
        Parent = obj
    })
end

local function text(parent, value, size, font, color)
    return make("TextLabel", {
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

local function guiParent()
    local parent
    pcall(function()
        parent = gethui and gethui() or CoreGui
    end)
    return parent or Player:WaitForChild("PlayerGui")
end

local function tween(obj, time, props)
    return TweenService:Create(
        obj,
        TweenInfo.new(time or 0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        props
    )
end

local function drag(handle, target)
    local active = false
    local input = nil
    local startInput = nil
    local startPos = nil

    local function move(current)
        local delta = current.Position - startInput
        target.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1 then
            active = true
            input = i
            startInput = i.Position
            startPos = target.Position
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if not active then return end

        if input.UserInputType == Enum.UserInputType.Touch then
            if i == input then
                move(i)
            end
        elseif i.UserInputType == Enum.UserInputType.MouseMovement then
            move(i)
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i == input then
            active = false
            input = nil
        end
    end)
end

function NX:Window(config)
    config = config or {}

    local parent = guiParent()
    local old = parent:FindFirstChild("NEXUS_NC")
    if old then
        old:Destroy()
    end

    local app = {Tabs = {}, Active = nil}
    local gui = make("ScreenGui", {
        Name = "NEXUS_NC",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        Parent = parent
    })
    app.Gui = gui

    local main = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = NX.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(config.Width or 580, config.Height or 400),
        Parent = gui
    })
    round(main, 16)
    line(main, NX.Theme.Accent, 0.15)

    local topbar = make("Frame", {
        BackgroundColor3 = NX.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 48),
        Parent = main
    })
    round(topbar, 16)
    make("Frame", {
        BackgroundColor3 = NX.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -16),
        Size = UDim2.new(1, 0, 0, 16),
        Parent = topbar
    })
    drag(topbar, main)

    local title = text(topbar, config.Title or "NC HUB", 18, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(18, 0)
    title.Size = UDim2.new(0.5, 0, 1, 0)

    local subtitle = text(topbar, config.Subtitle or "", 12, Enum.Font.Gotham, NX.Theme.Muted)
    subtitle.AnchorPoint = Vector2.new(0, 0)
subtitle.Position = UDim2.fromOffset(172, 0)
subtitle.Size = UDim2.new(1, -252, 1, 0)
subtitle.TextXAlignment = Enum.TextXAlignment.Left


    local mac = make("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundColor3 = NX.Theme.Surface2,
    BackgroundTransparency = 0.15,
    BorderSizePixel = 0,
    Position = UDim2.new(1, -14, 0.5, 0),
    Size = UDim2.fromOffset(78, 28),
    Parent = topbar
})
round(mac, 9)
line(mac, NX.Theme.Stroke, 0.55)

local restoreBar = make("Frame", {
    BackgroundColor3 = NX.Theme.Surface,
    BorderSizePixel = 0,
    Position = UDim2.new(1, -145, 0, 82),
    Size = UDim2.fromOffset(126, 38),
    Visible = false,
    Parent = gui
})
round(restoreBar, 12)
line(restoreBar, NX.Theme.Accent, 0.25)

local grip = make("TextButton", {
    AutoButtonColor = false,
    BackgroundColor3 = NX.Theme.Surface2,
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(4, 4),
    Size = UDim2.fromOffset(28, 30),
    Text = "⋮",
    TextColor3 = NX.Theme.Muted,
    TextSize = 19,
    Font = Enum.Font.GothamBold,
    Parent = restoreBar
})
round(grip, 9)

local restoreButton = make("TextButton", {
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
    Parent = restoreBar
})

-- Se arrastra desde los tres puntos, así tocar NC HUB no abre por accidente.
drag(grip, restoreBar)

local function macButton(color, x, callback)
    local button = make("TextButton", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        AutoButtonColor = false,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(x, 14),
        Size = UDim2.fromOffset(12, 12),
        Text = "",
        Parent = mac
    })
    round(button, 99)

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            tween(button, 0.08, {Size = UDim2.fromOffset(15, 15)}):Play()
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            tween(button, 0.10, {Size = UDim2.fromOffset(12, 12)}):Play()
        end
    end)

    button.MouseButton1Click:Connect(callback)
end

local normalSize = main.Size
local normalPosition = main.Position
local minimized = false

local function barCenter()
    return UDim2.new(
        restoreBar.Position.X.Scale,
        restoreBar.Position.X.Offset + 63,
        restoreBar.Position.Y.Scale,
        restoreBar.Position.Y.Offset + 19
    )
end

macButton(NX.Theme.MacRed, 15, function()
    gui:Destroy()
end)

macButton(NX.Theme.MacYellow, 39, function()
    if minimized then return end
    minimized = true

    main.ClipsDescendants = true
    tween(main, 0.24, {
        Size = UDim2.fromOffset(126, 38),
        Position = barCenter()
    }):Play()

    task.wait(0.25)
    main.Visible = false
    main.Size = normalSize
    main.Position = normalPosition

    restoreBar.Visible = true
    restoreBar.Size = UDim2.fromOffset(86, 30)
    tween(restoreBar, 0.18, {
        Size = UDim2.fromOffset(126, 38)
    }):Play()
end)

macButton(NX.Theme.MacGreen, 63, function()
    main.Position = UDim2.fromScale(0.5, 0.5)
end)

restoreButton.MouseButton1Click:Connect(function()
    if not minimized then return end
    minimized = false

    restoreBar.Visible = false
    main.Visible = true
    main.Size = UDim2.fromOffset(126, 38)
    main.Position = barCenter()

    tween(main, 0.28, {
        Size = normalSize,
        Position = normalPosition
    }):Play()

    task.delay(0.30, function()
        if main and main.Parent then
            main.ClipsDescendants = false
        end
    end)
end)


    local sidebar = make("ScrollingFrame", {
        Active = true,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = NX.Theme.Surface,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        Position = UDim2.fromOffset(0, 48),
        ScrollBarImageColor3 = NX.Theme.Accent,
        ScrollBarThickness = 3,
        Size = UDim2.new(0, 154, 1, -48),
        Parent = main
    })
    make("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        Parent = sidebar
    })
    make("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sidebar
    })

    local content = make("Frame", {
        BackgroundColor3 = NX.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(154, 48),
        Size = UDim2.new(1, -154, 1, -48),
        Parent = main
    })

    function app:Destroy()
        gui:Destroy()
    end

    function app:Section(name)
        local section = {App = app}
        local header = text(sidebar, name, 11, Enum.Font.GothamBold, NX.Theme.Muted)
        header.Size = UDim2.new(1, 0, 0, 20)

        function section:Tab(name)
            local tab = {App = app}
            local button = make("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = NX.Theme.Surface,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 36),
                Text = name,
                TextColor3 = NX.Theme.Muted,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sidebar
            })
            round(button, 9)
            make("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                Parent = button
            })

            local page = make("ScrollingFrame", {
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
            make("UIPadding", {
                PaddingLeft = UDim.new(0, 14),
                PaddingRight = UDim.new(0, 14),
                PaddingTop = UDim.new(0, 14),
                PaddingBottom = UDim.new(0, 14),
                Parent = page
            })
            make("UIListLayout", {
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
                app.Active = tab
            end

            button.MouseButton1Click:Connect(function()
                tab:Open()
            end)

            function tab:Card(cardTitle)
                local card = {}
                local frame = make("Frame", {
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = NX.Theme.Surface,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 0),
                    Parent = page
                })
                round(frame, 12)
                line(frame, NX.Theme.Stroke, 0.35)
                make("UIPadding", {
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 12),
                    PaddingTop = UDim.new(0, 11),
                    PaddingBottom = UDim.new(0, 11),
                    Parent = frame
                })
                make("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = frame
                })

                if cardTitle then
                    local head = text(frame, cardTitle, 12, Enum.Font.GothamBold, NX.Theme.Cian)
                    head.Size = UDim2.new(1, 0, 0, 18)
                end

                card.Frame = frame
                return card
            end

            table.insert(app.Tabs, tab)
            if #app.Tabs == 1 then
                tab:Open()
            end
            return tab
        end

        return section
    end

    return app
end

function NX:Label(card, value)
    local item = text(card.Frame, value, 13, Enum.Font.Gotham, NX.Theme.Text)
    item.Size = UDim2.new(1, 0, 0, 22)

    return {
        Set = function(_, newValue)
            item.Text = newValue
        end
    }
end

function NX:Button(card, config)
    config = config or {}

    local item = make("TextButton", {
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
    round(item, 10)

    item.MouseButton1Click:Connect(function()
        if config.Callback then
            config.Callback()
        end
    end)

    return item
end

function NX:Toggle(card, config)
    config = config or {}
    local state = config.Default == true

    local row = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        Text = "",
        Parent = card.Frame
    })
    round(row, 10)

    local name = text(row, config.Name or "Toggle", 13, Enum.Font.GothamMedium)
    name.Position = UDim2.fromOffset(11, 0)
    name.Size = UDim2.new(1, -65, 1, 0)

    local track = make("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = NX.Theme.Purple,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -11, 0.5, 0),
        Size = UDim2.fromOffset(36, 20),
        Parent = row
    })
    round(track, 99)

    local knob = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = NX.Theme.Text,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Parent = track
    })
    round(knob, 99)

    local function set(newState, fire)
        state = newState
        tween(track, 0.13, {
            BackgroundColor3 = state and NX.Theme.Cian or NX.Theme.Purple
        }):Play()
        tween(knob, 0.13, {
            Position = UDim2.new(state and 1 or 0, state and -10 or 10, 0.5, 0)
        }):Play()
        if fire and config.Callback then
            config.Callback(state)
        end
    end

    row.MouseButton1Click:Connect(function()
        set(not state, true)
    end)
    set(state, false)

    return {
        Set = function(_, value)
            set(value, true)
        end,
        Get = function()
            return state
        end
    }
end

function NX:Slider(card, config)
    config = config or {}

    local min = config.Min or 0
    local max = config.Max or 100
    local step = config.Step or 1
    local current = config.Default or min

    local holder = make("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 54),
        Parent = card.Frame
    })

    local name = text(holder, config.Name or "Slider", 13, Enum.Font.GothamMedium)
    name.Size = UDim2.new(0.7, 0, 0, 20)

    local value = text(holder, "", 13, Enum.Font.GothamBold, NX.Theme.Cian)
    value.AnchorPoint = Vector2.new(1, 0)
    value.Position = UDim2.new(1, 0, 0, 0)
    value.Size = UDim2.new(0.3, 0, 0, 20)
    value.TextXAlignment = Enum.TextXAlignment.Right

    local bar = make("TextButton", {
        AutoButtonColor = false,
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 32),
        Size = UDim2.new(1, 0, 0, 6),
        Text = "",
        Parent = holder
    })
    round(bar, 99)

    local fill = make("Frame", {
        BackgroundColor3 = NX.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        Parent = bar
    })
    round(fill, 99)

    local knob = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = NX.Theme.Text,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(14, 14),
        Parent = bar
    })
    round(knob, 99)

    local dragging = false
    local activeInput = nil

    local function set(newValue, fire)
        newValue = math.clamp(newValue, min, max)
        newValue = math.floor((newValue - min) / step + 0.5) * step + min
        current = math.clamp(newValue, min, max)

        local pct = (current - min) / (max - min)
        fill.Size = UDim2.fromScale(pct, 1)
        knob.Position = UDim2.fromScale(pct, 0.5)
        value.Text = tostring(current)

        if fire and config.Callback then
            config.Callback(current)
        end
    end

    local function fromX(x)
        local pct = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        set(min + (max - min) * pct, true)
    end

    -- Solo inicia el arrastre al tocar la barra de este slider.
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            activeInput = input
            fromX(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end

        if activeInput.UserInputType == Enum.UserInputType.Touch then
            if input == activeInput then
                fromX(input.Position.X)
            end
        elseif input.UserInputType == Enum.UserInputType.MouseMovement then
            fromX(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input == activeInput then
            dragging = false
            activeInput = nil
        end
    end)

    set(current, false)

    return {
        Set = function(_, newValue)
            set(newValue, true)
        end,
        Get = function()
            return current
        end
    }
end

function NX:Notify(title, message)
    local gui = make("ScreenGui", {
        Name = "NEXUS_NC_NOTIFY",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 999998,
        Parent = guiParent()
    })

    local box = make("Frame", {
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = NX.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 250, 1, -18),
        Size = UDim2.fromOffset(235, 70),
        Parent = gui
    })
    round(box, 12)
    line(box, NX.Theme.Accent, 0.25)

    local head = text(box, title or "NC HUB", 14, Enum.Font.GothamBold)
    head.Position = UDim2.fromOffset(12, 8)
    head.Size = UDim2.new(1, -24, 0, 19)

    local body = text(box, message or "", 12, Enum.Font.Gotham, NX.Theme.Muted)
    body.Position = UDim2.fromOffset(12, 30)
    body.Size = UDim2.new(1, -24, 0, 30)
    body.TextWrapped = true
    body.TextYAlignment = Enum.TextYAlignment.Top

    tween(box, 0.22, {Position = UDim2.new(1, -18, 1, -18)}):Play()
    task.delay(3, function()
        if box.Parent then
            tween(box, 0.2, {
                Position = UDim2.new(1, 250, 1, -18),
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.25)
            gui:Destroy()
        end
    end)
end

function NX:Loading(config)
    config = config or {}

    local gui = make("ScreenGui", {
        Name = "NEXUS_NC_LOADING",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        DisplayOrder = 999999,
        Parent = guiParent()
    })

    local background = make("Frame", {
        BackgroundColor3 = NX.Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Parent = gui
    })

    local card = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = NX.Theme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(320, 125),
        Parent = background
    })
    round(card, 16)
    line(card, NX.Theme.Accent, 0.1)

    local mark = text(card, "N", 22, Enum.Font.GothamBold, NX.Theme.Cian)
    mark.BackgroundColor3 = NX.Theme.Purple
    mark.BackgroundTransparency = 0.1
    mark.Position = UDim2.fromOffset(18, 18)
    mark.Size = UDim2.fromOffset(35, 35)
    mark.TextXAlignment = Enum.TextXAlignment.Center
    round(mark, 10)

    local title = text(card, config.Title or "NC HUB", 21, Enum.Font.GothamBold)
    title.Position = UDim2.fromOffset(63, 19)
    title.Size = UDim2.new(1, -82, 0, 26)

    local status = text(card, config.Text or "Preparando interfaz", 13, Enum.Font.Gotham, NX.Theme.Muted)
    status.Position = UDim2.fromOffset(18, 64)
    status.Size = UDim2.new(1, -36, 0, 18)

    local track = make("Frame", {
        BackgroundColor3 = NX.Theme.Surface2,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(18, 94),
        Size = UDim2.new(1, -36, 0, 7),
        Parent = card
    })
    round(track, 99)

    local fill = make("Frame", {
        BackgroundColor3 = NX.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(0, 1),
        Parent = track
    })
    round(fill, 99)
    make("UIGradient", {
        Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, NX.Theme.Accent),
    ColorSequenceKeypoint.new(0.5, NX.Theme.Cian),
    ColorSequenceKeypoint.new(1, NX.Theme.Rose)
}),

        Parent = fill
    })

    return function(endText)
        status.Text = endText or "Listo"
        tween(fill, 0.6, {Size = UDim2.fromScale(1, 1)}):Play()
        task.wait(0.75)

        tween(background, 0.25, {BackgroundTransparency = 1}):Play()
                tween(card, 0.25, {BackgroundTransparency = 1}):Play()

        for _, obj in ipairs(card:GetDescendants()) do
            if obj:IsA("TextLabel") then
                tween(obj, 0.2, {TextTransparency = 1}):Play()
            elseif obj:IsA("Frame") then
                tween(obj, 0.2, {BackgroundTransparency = 1}):Play()
            elseif obj:IsA("UIStroke") then
                tween(obj, 0.2, {Transparency = 1}):Play()
            end
        end

        task.wait(0.3)
        gui:Destroy()
    end
end

return NX
