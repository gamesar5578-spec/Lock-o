local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CONFIG = {
    MaxDistance = 100,
    LockSpeed = 0.2,
    ButtonColor = Color3.fromRGB(220, 50, 50),
    ButtonActiveColor = Color3.fromRGB(50, 200, 50),
    OffsetY = 2,
}

local isLocked = false
local currentTarget = nil
local lockHighlight = nil

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LockOnUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local LockButton = Instance.new("TextButton")
LockButton.Size = UDim2.new(0, 90, 0, 90)
LockButton.Position = UDim2.new(1, -110, 1, -200)
LockButton.BackgroundColor3 = CONFIG.ButtonColor
LockButton.Text = "🎯\nLOCK"
LockButton.TextColor3 = Color3.new(1, 1, 1)
LockButton.TextSize = 16
LockButton.Font = Enum.Font.GothamBold
LockButton.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 16)
Corner.Parent = LockButton

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(0, 200, 0, 40)
TargetLabel.Position = UDim2.new(0.5, -100, 0, 20)
TargetLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TargetLabel.BackgroundTransparency = 0.4
TargetLabel.Text = ""
TargetLabel.TextColor3 = Color3.new(1, 1, 1)
TargetLabel.TextSize = 16
TargetLabel.Font = Enum.Font.GothamBold
TargetLabel.Visible = false
TargetLabel.Parent = ScreenGui

local TargetCorner = Instance.new("UICorner")
TargetCorner.CornerRadius = UDim.new(0, 10)
TargetCorner.Parent = TargetLabel

local function SetHighlight(character)
    if lockHighlight then lockHighlight:Destroy() lockHighlight = nil end
    if character then
        local hl = Instance.new("Highlight")
        hl.Adornee = character
        hl.FillColor = Color3.fromRGB(255, 50, 50)
        hl.FillTransparency = 0.6
        hl.OutlineColor = Color3.fromRGB(255, 50, 50)
        hl.OutlineTransparency = 0
        hl.Parent = character
        lockHighlight = hl
    end
end

local function Unlock()
    isLocked = false
    currentTarget = nil
    Camera.CameraType = Enum.CameraType.Custom
    LockButton.BackgroundColor3 = CONFIG.ButtonColor
    LockButton.Text = "🎯\nLOCK"
    if lockHighlight then lockHighlight:Destroy() lockHighlight = nil end
    TargetLabel.Visible = false
end

local dragging = false
local dragStart = nil
local startPos = nil
local tapTime = 0

LockButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        tapTime = tick()
        dragging = false
        dragStart = input.Position
        startPos = LockButton.Position
    end
end)

LockButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and dragStart then
        local delta = input.Position - dragStart
        if delta.Magnitude > 10 then
            dragging = true
            LockButton.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end
end)

LockButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        if not dragging and tick() - tapTime < 0.2 then
            local character = LocalPlayer.Character
            if not character then return end
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end

            isLocked = not isLocked

            if isLocked then
                local nearest = nil
                local nearestDist = CONFIG.MaxDistance

                for _, model in ipairs(workspace:GetDescendants()) do
                    if model:IsA("Humanoid") and model.Health > 0 then
                        local targetChar = model.Parent
                        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                        if targetRoot and targetChar ~= character then
                            local dist = (rootPart.Position - targetRoot.Position).Magnitude
                            if dist < nearestDist then
                                nearestDist = dist
                                nearest = targetChar
                            end
                        end
                    end
                end

                if nearest then
                    currentTarget = nearest
                    Camera.CameraType = Enum.CameraType.Custom
                    LockButton.BackgroundColor3 = CONFIG.ButtonActiveColor
                    LockButton.Text = "🎯\nON"
                    SetHighlight(currentTarget)
                    TargetLabel.Text = "🎯 " .. currentTarget.Name
                    TargetLabel.Visible = true
                else
                    isLocked = false
                    LockButton.Text = "🎯\nLOCK"
                end
            else
                Unlock()
            end
        end
        dragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if isLocked and currentTarget then
        local humanoid = currentTarget:FindFirstChild("Humanoid")
        local rootPart = currentTarget:FindFirstChild("HumanoidRootPart")

        if not rootPart or not humanoid or humanoid.Health <= 0 then
            Unlock() return
        end

        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        if (myRoot.Position - rootPart.Position).Magnitude > CONFIG.MaxDistance then
            Unlock() return
        end

        local targetPos = rootPart.Position + Vector3.new(0, CONFIG.OffsetY, 0)
        local camPos = Camera.CFrame.Position
        local goalCF = CFrame.lookAt(camPos, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(goalCF, CONFIG.LockSpeed)
    end
end)
