local GameModSupClass = script.Parent
local SS = game:GetService('ServerStorage')
local RS = game:GetService('RunService')
local TS = SS.TempStorage
local Teams = game:GetService('Teams')
local DeathMatchGameMode = require(GameModSupClass):new()
	
	DeathMatchGameMode.Name = 'DeathMatch'
	
	--[[function DeathMatchGameMode.CloneGui(playingTable,player)
		if player then
			print('finishing the clone connection set up')
			local dmGui = SS.GameModeGui.DeathMatch.DeathMatchGui:Clone()
			dmGui.Parent = player.PlayerGui
			dmGui.Name = 'DeathMatchGui'
		else
			for i,plr in ipairs(playingTable) do
				local dmGui = SS.GameModeGui.DeathMatch.DeathMatchGui:Clone()
				dmGui.Parent = plr.PlayerGui
				dmGui.Name = 'DeathMatchGui'
			end
		end
	end]]
	
	function DeathMatchGameMode.RespawnWithWeapons(playingTable,connectionTable,player)
		if player then
			local connection = player.CharacterAppearanceLoaded:Connect(function(character)
				if player.Backpack:FindFirstChild('ClassicPaintballGun') then
					player.Backpack.ClassicPaintballGun:Destroy()
				end
				local paintGun = SS.ClassicPaintballGun:Clone()
				paintGun.Parent = player.Backpack
			end)
			table.insert(connectionTable,#connectionTable + 1,connection)
		else
			for i,player in ipairs(playingTable) do
				local connection = player.CharacterAppearanceLoaded:Connect(function(character)
					if player.Backpack:FindFirstChild('ClassicPaintballGun') then
						player.Backpack.ClassicPaintballGun:Destroy()
					end
					local paintGun = SS.ClassicPaintballGun:Clone()
					paintGun.Parent = player.Backpack
				end)
				table.insert(connectionTable,#connectionTable + 1,connection)
			end
		end
	end
	
	function DeathMatchGameMode.DecideWinner(playingTable)
		local redTeam = Teams.RedTeam
		local blueTeam = Teams.BlueTeam
		local redTeamPoints = 0
		local blueTeamPoints = 0
		for i,player in ipairs(redTeam:GetPlayers()) do
			local playerKills = player.leaderstats.Kills.Value
			redTeamPoints = redTeamPoints + playerKills
		end
		for i,player in ipairs(blueTeam:GetPlayers()) do
			local playerKills = player.leaderstats.Kills.Value
			blueTeamPoints= blueTeamPoints + playerKills
		end
		
		if redTeamPoints > blueTeamPoints then
			for i, player in ipairs(playingTable) do
				if player then
					local clockGuiFrame = player.PlayerGui.Clock.Frame
					clockGuiFrame.ImageColor3 = Color3.fromRGB(255,0,0)
					clockGuiFrame.TextLabel.Text = 'Red Team Won!'
					wait(5)
				end
			end
		elseif redTeamPoints < blueTeamPoints then
			for i, player in ipairs(playingTable) do
				if player then
					local clockGuiFrame = player.PlayerGui.Clock.Frame
					clockGuiFrame.ImageColor3 = Color3.fromRGB(0,0,255)
					clockGuiFrame.TextLabel.Text = 'Blue Team Won!'
					wait(5)
				end
			end
		else
			for i, player in ipairs(playingTable) do
				if player then
					local clockGuiFrame = player.PlayerGui.Clock.Frame
					clockGuiFrame.ImageColor3 = Color3.fromRGB(255,0,255)
					clockGuiFrame.TextLabel.Text = 'Draw!'
					wait(5)
				end
			end

		end
		for i,player in ipairs(playingTable) do
			local kills = player.leaderstats.Kills
			kills.Value = 0
		end
		Teams.RedTeam:Destroy()
		Teams.BlueTeam:Destroy()
	end
	
	function DeathMatchGameMode.DisconnectConnection(connectionTable)
		for i,connection in ipairs(connectionTable) do
			connectionTable[i]:Disconnect()
		end
	end
	
	--[[function DeathMatchGameMode.DestroyGui(playingTable)
		for i,player in ipairs(playingTable) do
			for i, gui in ipairs(player.PlayerGui:GetChildren()) do
				gui:Destroy()
			end
		end
	end]]
	
	--[[function DeathMatchGameMode.UpdateGameBoard(playingTable,connectionTable,player)
		if player then
			local kills = player.leaderstats.Kills
			local teamName = player.Team.Name
			local redKills = dmGui.OuterFrame.InnerFrame.RedFrame.KillsCounter.Kills.Value
			local redkillsCounter = dmGui.OuterFrame.InnerFrame.RedFrame.KillsCounter
			local blueKills = dmGui.OuterFrame.InnerFrame.BlueFrame.KillsCounter.Kills.Value
			local bluekillsCounter = dmGui.OuterFrame.InnerFrame.BlueFrame.KillsCounter
			local connection = kills.Changed:Connect(function()
				updateBracket:FireAllClients(teamName)
				if teamName == 'RedTeam' then
					redKills = redKills + 1
					redkillsCounter.Text = tostring(redKills)
				elseif teamName == 'BlueTeam' then
					blueKills = blueKills + 1
					bluekillsCounter.Text = tostring(blueKills)
				end
			end)
			table.insert(connectionTable,#connectionTable + 1,connection)
		else
			for i,player in ipairs(playingTable) do
				local kills = player.leaderstats.Kills
				local teamName = player.Team.Name
				local dmGui = player.PlayerGui.DeathMatchGui
				local redKills = dmGui.OuterFrame.InnerFrame.RedFrame.KillsCounter.Kills.Value
				local redkillsCounter = dmGui.OuterFrame.InnerFrame.RedFrame.KillsCounter
				local blueKills = dmGui.OuterFrame.InnerFrame.BlueFrame.KillsCounter.Kills.Value
				local bluekillsCounter = dmGui.OuterFrame.InnerFrame.BlueFrame.KillsCounter
				local connection = kills.Changed:Connect(function()
					if teamName == 'RedTeam' then
						redKills = redKills + 1
						redkillsCounter.Text = tostring(redKills)
					elseif teamName == 'BlueTeam' then
						blueKills = blueKills + 1
						bluekillsCounter.Text = tostring(blueKills)
					end
				end)
				table.insert(connectionTable,#connectionTable + 1,connection)
			end
		end
	end]]
	
	function DeathMatchGameMode.OnNewPlayerAddedToMatch(player,playingTable,connectionTable)
		table.insert(playingTable,#playingTable + 1,player)
		DeathMatchGameMode.AddToATeam(player)
		DeathMatchGameMode.OnPlayerAddedConnections(playingTable,connectionTable,player)
		DeathMatchGameMode.FirstPersonConnection(nil,connectionTable,player)
		DeathMatchGameMode.SpawnPlayers(nil,player)
		DeathMatchGameMode.ActivateWeapons(playingTable,player)
		DeathMatchGameMode.RespawnWithWeapons(nil,connectionTable,player)
		DeathMatchGameMode.PlaceClockInPlayers(nil,player)
		DeathMatchGameMode.PlaceGunModeGuiInPlayers(nil,player)
	end	
return DeathMatchGameMode



