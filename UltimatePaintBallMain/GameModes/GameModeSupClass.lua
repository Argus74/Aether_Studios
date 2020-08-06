local Teams = game:GetService('Teams')
local IS = game:GetService('InsertService')
local RS = game:GetService('ReplicatedStorage')
local SS = game:GetService('ServerStorage')
local RunService = game:GetService('RunService')
local playerGunEvent = RS:WaitForChild('PlayersGotGun')
local CS = game:GetService('CollectionService')
local AudioHandler = require(script.Parent.AudioHandler)
--("rbxthumb://type=Asset&id="..swordImages[i]).."&w=150&h=150"
local shirtIDS = {
	red = 'http://www.roblox.com/asset/?id=5078426647',
	blue = 'http://www.roblox.com/asset/?id=5078610607'
}

local pantsIDS = {
	red = 'http://www.roblox.com/asset/?id=5078598745',
	blue = 'http://www.roblox.com/asset/?id=5078631582'
}

local GameModeSuperClass = {}

	function GameModeSuperClass.CreateTeams()
		local redTeam = Instance.new('Team',Teams)
		redTeam.TeamColor = BrickColor.new('Bright red')
		redTeam.AutoAssignable = false
		redTeam.Name = 'RedTeam'
		
		local blueTeam = Instance.new('Team',Teams)
		blueTeam.TeamColor = BrickColor.new('Bright blue')
		blueTeam.AutoAssignable = false
		blueTeam.Name = 'BlueTeam'
		return redTeam,blueTeam
	end
	
	function GameModeSuperClass.DestroyClothes(player)
			for i, object in ipairs(player.Character:GetChildren()) do
				if object:IsA('Accessory') then
					object:Destroy()
				end
			end
			if player.Character:FindFirstChild('Shirt Graphic') then
				player.Character.FindFirstChild('Shirt Graphic'):Destroy()
			end	
	end
	
	function GameModeSuperClass.SortTeams(playingTable)
		local team1,team2 = GameModeSuperClass.CreateTeams()
		for i,player in ipairs(playingTable) do
			if i%2 == 0 then
				player.Team = team1
			elseif i%2 == 1 then
				player.Team = team2
			end
		end
	end
	
	function GameModeSuperClass.AddToATeam(player)
		local redTeamNum = #(Teams.RedTeam:GetPlayers())
		local blueTeamNum = #(Teams.BlueTeam:GetPlayers())
		if redTeamNum > blueTeamNum then
			player.Team = Teams.BlueTeam
		elseif blueTeamNum > redTeamNum then
			player.Team = Teams.RedTeam
		end
	end
	
	function GameModeSuperClass.ClothPlayer(player,team)
			local hats = {
				red = IS:LoadAsset('10130964'):FindFirstChildOfClass('Accessory'),
				blue = IS:LoadAsset('10130979'):FindFirstChildOfClass('Accessory')
			}
			if team.Name == 'RedTeam' then
				if player.Character:FindFirstChild('Shirt') then
					player.Character.Shirt.ShirtTemplate = shirtIDS['red']
				else
					local shirt = Instance.new('Shirt')
					shirt.Parent = player.Character
					shirt.Name = 'Shirt'
					player.Character.Shirt.ShirtTemplate = shirtIDS['red']
				end
				
				if player.Character:FindFirstChild('Pants') then
					player.Character.Pants.PantsTemplate = pantsIDS['red']
				else
					local pants = Instance.new('Pants')
					pants.Parent = player.Character
					pants.Name = 'Pants'
					player.Character.Pants.PantsTemplate = pantsIDS['red']
				end
				local hat = hats['red']
				hat.Name = 'redHat'
				CS:AddTag(hat,'hat')
				hat.Parent = player.Character
				
			elseif team.Name == 'BlueTeam' then
				if player.Character:FindFirstChild('Shirt') then
					player.Character.Shirt.ShirtTemplate = shirtIDS['blue']
				else
					local shirt = Instance.new('Shirt')
					shirt.Parent = player.Character
					player.Character.Shirt.ShirtTemplate = shirtIDS['blue']
				end
				
				if player.Character:FindFirstChild('Pants') then
					player.Character.Pants.PantsTemplate = pantsIDS['blue']
				else
					local pants = Instance.new('Pants')
					pants.Parent = player.Character
					player.Character.Pants.PantsTemplate = pantsIDS['blue']
				end
				
				local hat = hats['blue']
				hat.Name = 'blueHat'
				CS:AddTag(hat,'hat')
				hat.Parent = player.Character
			end
	end
	
	function GameModeSuperClass.SpawnPlayers(playingTable,player)
		if player then
			player:LoadCharacter()
		else
			for i,player in ipairs(playingTable) do
				if player then
					player:LoadCharacter()
				end
			end
		end
	end
	
	function GameModeSuperClass.ActivateWeapons(playingTable,player)
		if player then
			local paintGun = SS.ClassicPaintballGun:Clone()
			paintGun.Parent = player.Backpack
		else
			for i,player in ipairs(playingTable) do
				local paintGun = SS.ClassicPaintballGun:Clone()
				paintGun.Parent = player.Backpack
			end
		end
	end
	
	function GameModeSuperClass.DeactivateWeapons(playingTable)
	for i,player in ipairs(playingTable) do
		if player.Character then
				if player.Character:FindFirstChild('ClassicPaintBallGun') then
					player.Character.ClassicPaintBallGun:Destroy()
					player.CameraMaxZoomDistance = 15
				end
				for i,tool in ipairs(player.Backpack:GetChildren()) do
					tool:Destroy()
				end
			end
		end
	end
	
	function GameModeSuperClass.StartClock(gameTime,playingTable)
		GameModeSuperClass.PlaceClockInPlayers(playingTable)
	
		for i = gameTime,0,-1 do
			local gameTimer = SS.GameOpsGui.Clock.GameTimer
			gameTimer.Value = i
			wait(1)
		end
	end
	
	function GameModeSuperClass.PlaceClockInPlayers(playingTable,player)
		if player then
			local clock = SS.GameOpsGui.Clock:Clone()
			clock.Parent = player.PlayerGui
		else
			for i, player in ipairs(playingTable) do
				local clock = SS.GameOpsGui.Clock:Clone()
				clock.Parent = player.PlayerGui
			end
		end
	end
	
	function GameModeSuperClass.PlaceGunModeGuiInPlayers(playingTable,player)
		if player then
			local gunModeGui = SS.GameOpsGui.GunMode:Clone()
			gunModeGui.Parent = player.PlayerGui
		else
			for i, player in ipairs(playingTable) do
				local gunModeGui = SS.GameOpsGui.GunMode:Clone()
				gunModeGui.Parent = player.PlayerGui
			end
		end
	end
	
	function GameModeSuperClass.DestroyGui(playingTable)
		for i,player in ipairs(playingTable) do
			for i, gui in ipairs(player.PlayerGui:GetChildren()) do
				gui:Destroy()
			end
		end
	end
	
	
	function GameModeSuperClass.ReturnToLobby(playingTable)
		for i,player in ipairs(playingTable) do
			local lobbyTeam = Teams:WaitForChild('LobbyTeam')
			player.Team = lobbyTeam
			
			player:LoadCharacter()
		end
	end
	
	function GameModeSuperClass:new()
    	local superClass = {}
    	local mt = {__index = self}
    	setmetatable(superClass, mt)
    	return superClass
	end
	
	function GameModeSuperClass.OnPlayerAddedConnections(playingTable,connectionTable,player)
		if player then
			local connection = player.CharacterAdded:Connect(function(character)
				character.ChildAdded:wait()
				GameModeSuperClass.DestroyClothes(player)
				character.ChildAdded:Connect(function(child)
					if  child:IsA("Accessory") and child.Name ~= 'redHat' and child.Name ~= 'blueHat' then
						child:Destroy()
					end
				end)
				GameModeSuperClass.ClothPlayer(player,player.Team)
			end)
			table.insert(connectionTable,#connectionTable + 1,connection)
		else
			for i,player in ipairs(playingTable) do
				local connection = player.CharacterAdded:Connect(function(character)
					character.ChildAdded:wait()
					GameModeSuperClass.DestroyClothes(player)
					local clothesConnection = character.ChildAdded:Connect(function(child)
						if  child:IsA("Accessory") and child.Name ~= 'redHat' and child.Name ~= 'blueHat' then
							RunService.Stepped:wait()
							child:Destroy()
						end
					end)
					GameModeSuperClass.ClothPlayer(player,player.Team)
				end)
				table.insert(connectionTable,#connectionTable + 1,connection)
			end
		end
	end
	
	function GameModeSuperClass.CreatePlayingPlrsTable(players)
		local playingTable = players:GetChildren()
		return playingTable
	end
	
	function GameModeSuperClass.PlayGuiConnection(players,connectionTable)
		local connection = players.PlayerAdded:Connect(function(player)
			local playGui = SS.GameOpsGui:Clone()
			playGui.Parent = player.PlayerGui
		end)
		table.insert(connectionTable,#connectionTable + 1,connection)
	end
	
	function GameModeSuperClass.FirstPersonConnection(playingTable,connectionTable,player)
		if player then
			local connection  = player.CharacterAdded:Connect(function(character)
				player.CameraMaxZoomDistance = 0
			end)
			table.insert(connectionTable,#connectionTable + 1,connection)
		else
			for i,player in ipairs(playingTable) do 
				if player then
					local connection  = player.CharacterAdded:Connect(function(character)
						player.CameraMaxZoomDistance = 0
					end)
					table.insert(connectionTable,#connectionTable + 1,connection)
				end
			end
		end
	end

	function GameModeSuperClass.PlaySound(gameModeSoundString)
		AudioHandler.preloadAudio(gameModeSoundString)
		local audio = AudioHandler.playAudio(gameModeSoundString)
		return audio
	end

	function GameModeSuperClass.StopSound(audio)
		audio:Destroy()	
	end

return GameModeSuperClass
