local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local RADIUS = 150
local STRENGTH = 0.08

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

if not isMobile then return end

local function getNearestEnemy()
	local closest = nil
	local closestDist = RADIUS
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player and other.Character then
			local hrp = other.Character:FindFirstChild("HumanoidRootPart")
			local hum = other.Character:FindFirstChild("Humanoid")
			if hrp and hum and hum.Health > 0 then
				local screen, visible = camera:WorldToScreenPoint(hrp.Position)
				if visible then
					local dist = (Vector2.new(screen.X, screen.Y) - center).Magnitude
					if dist < closestDist then
						closestDist = dist
						closest = hrp
					end
				end
			end
		end
	end

	return closest
end

RunService.RenderStepped:Connect(function()
	local target = getNearestEnemy()
	if target then
		local lookCFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
		camera.CFrame = camera.CFrame:Lerp(lookCFrame, STRENGTH)
	end
end)
