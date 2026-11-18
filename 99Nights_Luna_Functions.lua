-- 99 Nights in the Forest
-- Functions module only.
-- No Luna, no UI, no tabs and no controls are created here.

local Functions = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Connections = {}
local ESPObjects = {}

Functions.Players = Players
Functions.ReplicatedStorage = ReplicatedStorage
Functions.RunService = RunService
Functions.Workspace = Workspace
Functions.Lighting = Lighting
Functions.UserInputService = UserInputService
Functions.TeleportService = TeleportService
Functions.LocalPlayer = LocalPlayer

local function getCharacter()
    return LocalPlayer and LocalPlayer.Character
end

function Functions.GetRoot(character)
    character = character or getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

function Functions.GetHumanoid(character)
    character = character or getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

function Functions.GetRemoteEvents()
    return ReplicatedStorage:FindFirstChild("RemoteEvents")
end

function Functions.GetRemote(name)
    local events = Functions.GetRemoteEvents()
    return events and events:FindFirstChild(name)
end

function Functions.FireRemote(name, ...)
    local remote = Functions.GetRemote(name)
    if not remote then
        return false, "Remote not found: " .. tostring(name)
    end

    local args = table.pack(...)
    local ok, result = pcall(function()
        if remote:IsA("RemoteFunction") then
            return remote:InvokeServer(table.unpack(args, 1, args.n))
        end

        remote:FireServer(table.unpack(args, 1, args.n))
        return true
    end)

    return ok and result ~= false, result
end

function Functions.TeleportCFrame(cframe)
    local root = Functions.GetRoot()
    if not root or typeof(cframe) ~= "CFrame" then
        return false
    end

    root.CFrame = cframe
    return true
end

function Functions.TeleportPart(part)
    if not part or not part:IsA("BasePart") then
        return false
    end

    return Functions.TeleportCFrame(part.CFrame + Vector3.new(0, 3, 0))
end

function Functions.TeleportModel(model)
    if not model or not model:IsA("Model") then
        return false
    end

    local pivot = model:GetPivot()
    return Functions.TeleportCFrame(pivot + Vector3.new(0, 3, 0))
end

function Functions.GetMap()
    return Workspace:FindFirstChild("Map")
end

function Functions.GetItems()
    return Workspace:FindFirstChild("Items")
        or Workspace:FindFirstChild("DroppedItems")
        or Workspace:FindFirstChild("WorldItems")
end

function Functions.FindByName(name, root)
    root = root or Workspace
    local matches = {}
    local wanted = tostring(name):lower()

    for _, object in ipairs(root:GetDescendants()) do
        if object.Name:lower():find(wanted, 1, true) then
            table.insert(matches, object)
        end
    end

    return matches
end

function Functions.FindFirstByName(name, root)
    local matches = Functions.FindByName(name, root)
    return matches[1]
end

function Functions.GetPlayers()
    return Players:GetPlayers()
end

function Functions.GetMobs()
    local mobs = {}

    for _, object in ipairs(Workspace:GetDescendants()) do
        if object:IsA("Model") and object ~= getCharacter() then
            local humanoid = object:FindFirstChildOfClass("Humanoid")
            if humanoid then
                table.insert(mobs, object)
            end
        end
    end

    return mobs
end

function Functions.BringItem(item, position)
    if not item or not item.Parent then
        return false
    end

    position = position or (Functions.GetRoot() and Functions.GetRoot().Position)
    if not position then
        return false
    end

    local startDrag = Functions.GetRemote("RequestStartDraggingItem")
    local stopDrag = Functions.GetRemote("StopDraggingItem")
    if not startDrag or not stopDrag then
        return false
    end

    local ok = pcall(function()
        startDrag:FireServer(item)
        task.wait(0.05)

        if item:IsA("Model") then
            item:PivotTo(CFrame.new(position))
        else
            local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
            if part then
                part.CFrame = CFrame.new(position)
            end
        end

        task.wait(0.05)
        stopDrag:FireServer(item)
    end)

    return ok
end

function Functions.BringItems(items, position, delay)
    delay = delay or 0.05
    local moved = 0

    for _, item in ipairs(items or {}) do
        if Functions.BringItem(item, position) then
            moved += 1
        end
        task.wait(delay)
    end

    return moved
end

function Functions.GetLandmark(name)
    local map = Functions.GetMap()
    return map and Functions.FindFirstByName(name, map)
end

function Functions.RemoveFog()
    local map = Functions.GetMap()
    local boundaries = map and map:FindFirstChild("Boundaries")
    if not boundaries then
        return false
    end

    for _, object in ipairs(boundaries:GetChildren()) do
        if object.Name ~= "Fog" then
            object:Destroy()
        end
    end

    return true
end

function Functions.SetWalkSpeed(value)
    local humanoid = Functions.GetHumanoid()
    if not humanoid then
        return false
    end

    humanoid.WalkSpeed = tonumber(value) or 16
    return true
end

function Functions.SetJumpPower(value)
    local humanoid = Functions.GetHumanoid()
    if not humanoid then
        return false
    end

    humanoid.UseJumpPower = true
    humanoid.JumpPower = tonumber(value) or 50
    return true
end

function Functions.GetStats()
    local character = getCharacter()
    local humanoid = Functions.GetHumanoid(character)
    local root = Functions.GetRoot(character)

    return {
        Health = humanoid and humanoid.Health or 0,
        MaxHealth = humanoid and humanoid.MaxHealth or 0,
        Position = root and root.Position or nil,
        PlayerCount = #Players:GetPlayers(),
        UserId = LocalPlayer and LocalPlayer.UserId or 0,
    }
end

function Functions.CreateESP(object, text, color)
    if not object or ESPObjects[object] then
        return ESPObjects[object]
    end

    local adornee = object:IsA("BasePart") and object or object:FindFirstChildWhichIsA("BasePart", true)
    if not adornee then
        return nil
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "NCHUB_ESP"
    highlight.Adornee = object
    highlight.FillColor = color or Color3.fromRGB(170, 110, 255)
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = object

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NCHUB_ESP_Label"
    billboard.Adornee = adornee
    billboard.Size = UDim2.fromOffset(160, 28)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = object

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Text = text or object.Name
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Parent = billboard

    ESPObjects[object] = {Highlight = highlight, Billboard = billboard}
    return ESPObjects[object]
end

function Functions.ClearESP(object)
    local entry = ESPObjects[object]
    if not entry then
        return
    end

    for _, instance in pairs(entry) do
        if instance and instance.Parent then
            instance:Destroy()
        end
    end

    ESPObjects[object] = nil
end

function Functions.ClearAllESP()
    for object in pairs(ESPObjects) do
        Functions.ClearESP(object)
    end
end

function Functions.StartLoop(name, callback, interval)
    Functions.StopLoop(name)
    Connections[name] = task.spawn(function()
        while Connections[name] do
            pcall(callback)
            task.wait(interval or 0.25)
        end
    end)
end

function Functions.StopLoop(name)
    local thread = Connections[name]
    if thread then
        task.cancel(thread)
        Connections[name] = nil
    end
end

function Functions.StopAllLoops()
    for name in pairs(Connections) do
        Functions.StopLoop(name)
    end
end

return Functions
