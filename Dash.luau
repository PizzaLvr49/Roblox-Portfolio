local UserInputService = game:GetService("UserInputService")
game.Players.LocalPlayer.CharacterAdded:Wait()
local character = game.Players.LocalPlayer.Character

local keybind = Enum.KeyCode.Q
local canslide = true

local slideAnimation = Instance.new("Animation")

UserInputService.InputBegan:Connect(function(input,gameprocessed)
	if gameprocessed then return end
	if not canslide then return end
	
	if input.KeyCode == keybind then
		canslide = false
		
		local slide = Instance.new("BodyVelocity")
		slide.MaxForce = Vector3.one * 30000
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			slideAnimation.AnimationId = "rbxassetid://"..script:GetAttribute("Left")
			slide.Velocity = CFrame.Angles(0,math.pi/2,0):VectorToWorldSpace(character.HumanoidRootPart.CFrame.lookVector) * 100
		elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then
			slideAnimation.AnimationId = "rbxassetid://"..script:GetAttribute("Right")
			slide.Velocity = CFrame.Angles(0,-math.pi/2,0):VectorToWorldSpace(character.HumanoidRootPart.CFrame.lookVector) * 100
		elseif UserInputService:IsKeyDown("S") then
			slideAnimation.AnimationId = "rbxassetid://"..script:GetAttribute("Back")
			slide.Velocity = character.HumanoidRootPart.CFrame.lookVector * -100
		else
			slideAnimation.AnimationId = "rbxassetid://"..script:GetAttribute("Front")
			slide.Velocity = character.HumanoidRootPart.CFrame.lookVector * 100
		end
		slide.Parent = character.HumanoidRootPart

		local playAnim = character.Humanoid:LoadAnimation(slideAnimation)
		playAnim:Play()
		character:SetAttribute("Dashing", true)
		
		wait(0.25)
		
		playAnim:Stop()
		slide:Destroy()
		character:SetAttribute("Dashing", false)
		
		wait(1)

		canslide = true
	end
end)
