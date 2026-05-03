local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CONFIG = {
    MaxDistance = 100,
    LockSpeed = 0.08,
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

local function GetNearestEnemy()
    local character = LocalPlayer.Character
    if not character then return nil end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local nearest = nil
    local nearestDist = CONFIG.MaxDistance

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local enemyChar = player.Character
            if enemyChar then
                local enemyRoot = enemyChar:FindFirstChild("HumanoidRootPart")
                local enemyHuman = enemyChar:FindFirstChild("Humanoid")
                if enemyRoot and enemyHuman and enemyHuman.Health > 0 then
                    local dist = (rootPart.Position - enemyRoot.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = enemyChar
                    end
                end
            end
        end
    end
    return nearest
end

local function SetHighlight(character)
    if lockHighlight then lockHighlight:Destroy() lockHighlight = nil end
    if character then
        local hl = Instance.new("SelectionBox")
        hl.Adornee = character
        hl.Color3 = Color3.fromRGB(255, 0, 0)
        hl.LineThickness = 0.05
        hl.SurfaceTransparency = 0.8
        hl.SurfaceColor3 = Color3.fromRGB(255, 100, 100)
        hl.Parent = workspace
        lockHighlight = hl
    end
end

local function ToggleLock()
    isLocked = not isLocked
    if isLocked then
        currentTarget = GetNearestEnemy()
        if currentTarget then
            LockButton.BackgroundColor3 = CONFIG.ButtonActiveColor
            LockButton.Text = "🎯\nON"
            SetHighlight(currentTarget)
            TargetLabel.Text = "🎯 " .. currentTarget.Name
            TargetLabel.Visible = true
        else
            isLocked = false
            LockButton.Text = "🎯\nLOCK"
            TargetLabel.Visible = false
        end
    else
        currentTarget = nil
        LockButton.BackgroundColor3 = CONFIG.ButtonColor
        LockButton.Text = "🎯\nLOCK"
        SetHighlight(nil)
        TargetLabel.Visible = false
    end
end

RunService.RenderStepped:Connect(function()
    if isLocked and currentTarget then
        local humanoid = currentTarget:FindFirstChild("Humanoid")
        local rootPart = currentTarget:FindFirstChild("HumanoidRootPart")
        if not rootPart or not humanoid or humanoid.Health <= 0 then
            ToggleLock() return
        end
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        if (myRoot.Position - rootPart.Position).Magnitude > CONFIG.MaxDistance then
            ToggleLock() return
        end
        local targetPos = rootPart.Position + Vector3.new(0, CONFIG.OffsetY, 0)
        local currentCF = Camera.CFrame
        local goalCF = CFrame.lookAt(currentCF.Position, targetPos)
        Camera.CFrame = currentCF:Lerp(goalCF, CONFIG.LockSpeed)
    end
end)

LockButton.MouseButton1Click:Connect(ToggleLock)
