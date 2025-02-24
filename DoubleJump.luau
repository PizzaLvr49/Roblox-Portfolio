local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
game.Players.LocalPlayer.CharacterAdded:Wait()
local character = game.Players.LocalPlayer.Character
local DoubleJumping = false


local doubleJumpAnimation = Instance.new("Animation")
doubleJumpAnimation.AnimationId = "rbxassetid://"..script:GetAttribute("AnimationID")

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
	if input.KeyCode == Enum.KeyCode.Space and not(DoubleJumping) then
		if character:FindFirstChildOfClass("Humanoid").FloorMaterial == Enum.Material.Air then
			if character:GetAttribute("Dashing") then
				character:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("BodyVelocity"):Destroy()
			end
			character:FindFirstChild("HumanoidRootPart").AssemblyLinearVelocity = Vector3.new(0,75,0)
			DoubleJumping = true
			local playAnim = character.Humanoid:LoadAnimation(doubleJumpAnimation)
			playAnim:Play()
		end
	end	
end)

character:FindFirstChildOfClass("Humanoid").StateChanged:Connect(function(old: Enum.HumanoidStateType, new: Enum.HumanoidStateType) 
	if new == Enum.HumanoidStateType.Landed then
		DoubleJumping = false
	end
end)
