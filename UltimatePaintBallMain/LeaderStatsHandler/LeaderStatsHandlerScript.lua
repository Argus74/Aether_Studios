local players = game:GetService('Players')
local RS = game:GetService('ReplicatedStorage')
local removeBoard = RS:WaitForChild('RemoveBoard')
local loadBoard = RS:WaitForChild('LoadBoard')

players.PlayerAdded:Connect(function(player)
	local stats = Instance.new('Folder')
	stats.Name = "leaderstats"
	stats.Parent = player
	local kills = Instance.new('IntValue')
	kills.Name = 'Kills'
	kills.Parent = stats
	player.CharacterAdded:Connect(function(char)
		local hum = char.Humanoid
		hum.Died:Connect(function()
			local tag = hum:FindFirstChild('creator')
			if tag then
				local killer = tag.Value
				if killer then
					killer.leaderstats.Kills.Value = killer.leaderstats.Kills.Value + 1 
				end
			end
		end)
	end)
end)
