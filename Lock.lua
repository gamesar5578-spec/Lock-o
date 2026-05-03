local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local AIM_RADIUS = 100
local AIM_STRENGTH = 0.1

if not userInputService.TouchEnabled then
	return
end

local function getClosestTarget()
	local closest = nil
	local shortestDistance = AIM_RADIUS

	for _, otherPlayer in pairs(game.Players:GetPlayers()) do
		if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local pos, onScreen = camera:WorldToViewportPoint(otherPlayer.Character.HumanoidRootPart.Position)

			if onScreen then
				local screenCenter = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)
				local distance = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude

				if distance < shortestDistance then
					shortestDistance = distance
					closest = otherPlayer.Character.HumanoidRootPart
				end
			end
		end
	end

	return closest
end

runService.RenderStepped:Connect(function()
	local target = getClosestTarget()

	if target then
		local direction = (target.Position - camera.CFrame.Position).Unit
		local newLook = camera.CFrame.LookVector:Lerp(direction, AIM_STRENGTH)

		camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + newLook)
	end
end)
