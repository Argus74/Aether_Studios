local replicatedStorage = game:GetService('ReplicatedStorage')
local attackEvent1 = replicatedStorage:WaitForChild('AttackEvent1')
local attackEvent2 = replicatedStorage:WaitForChild('AttackEvent2')
local attackEvent3 = replicatedStorage:WaitForChild('AttackEvent3')
local specialEvent = replicatedStorage:WaitForChild('SpecialEvent')
local debounce = true
attackEvent1.OnServerEvent:Connect(function(player,humanoid)
	humanoid:TakeDamage(20)	
end)

attackEvent2.OnServerEvent:Connect(function(player,humanoid)
	humanoid:TakeDamage(20)
end)

attackEvent3.OnServerEvent:Connect(function(player,humanoid)
	humanoid:TakeDamage(20)
end)
	
specialEvent.OnServerEvent:Connect(function(player,mouse)
	local char = player.Character or player.CharacterAdded:Wait()
	local part = Instance.new('Part')
	local offsetCFrame = CFrame.new(0,0,-2.5)
	
	part.Shape = Enum.PartType.Block
	part.Anchored = false
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Transparency = 0.5
	part.BrickColor = BrickColor.new('Cyan')
	part.Size = Vector3.new(10,1,1) 
	part.Name = 'AetherWind'
	part.CFrame = char.UpperTorso.CFrame:ToWorldSpace(offsetCFrame)
	part.Parent = workspace
	
	local BodyVelocity = Instance.new('BodyVelocity',part)
	BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	BodyVelocity.Velocity = mouse.lookVector * 40
	
	part.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid and debounce and hit.Parent.Name ~= player.Name then
			debounce = false
			humanoid:TakeDamage(20)
			wait(1.5)
			debounce = true
		end
	end)
end)





