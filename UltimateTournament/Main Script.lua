--Define Variables
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Status = ReplicatedStorage:WaitForChild("Status")
local RoundLength = 120
local Lobby = game.Workspace.Lobby
local Player = game:GetService("Players")
local updateBracket = ReplicatedStorage.UpdateBracket
local bracketSizes = ServerStorage.bracketSizes
local BracketCreatorClass = require(script.Parent.BracketCreatorClass)
local serverBracket 
local playableSwords = ServerStorage.PlayableSwords:GetChildren()
local ItemsModule = require(ServerStorage.ItemsModule:WaitForChild('ItemsModule'))
local Items = ItemsModule.ReturnTable()
math.randomseed(tick())

local GameOps = require(script.GameOperations)

while true do
	Status.Value = 'Waiting for enough players'
	repeat wait(1) until game.Players.NumPlayers >= 2
	-- Initial Game Setup Timer
	for i = 20, 0, -1 do 
		Status.Value = 'Intermission: ' .. i .. ' seconds'
		wait(1)
		if i == 0 then 
			Status.Value = 'Generating Bracket'
		else
		
		end
	end
	local listPlrs = game.Players:GetChildren()
	local shuffledListPlrs = GameOps.shuffleList(listPlrs)
	local BracketCreator = BracketCreatorClass:new(shuffledListPlrs)
	local entrants = BracketCreator.Entrants
	local numberSeeding = BracketCreator:GenerateNumberSeeding(entrants)
	local playerSeedingQ1 = BracketCreator:GeneratePlayerSeeding(numberSeeding,entrants)
	print('Got this far')
	local chosenBracket = GameOps.cloneGUIToRepStorage(#numberSeeding,bracketSizes,serverBracket)
	local bracketPositions = chosenBracket.Frame:GetChildren()
	GameOps.fillOutTourneyGui(playerSeedingQ1,bracketPositions)
	
	-- Choose a map and set it up
	local AvailableMaps = ServerStorage:WaitForChild("Maps"):GetChildren()
	local ClonedMap = AvailableMaps[math.random(1,#AvailableMaps)]:Clone()
	Status.Value = ClonedMap.Name..' Was Chosen'
	ClonedMap.Parent = game.Workspace
	wait(3)
	local AvailableSpawnPoints = ClonedMap:FindFirstChild('SpawnPoints'):GetChildren()
	local round = 1
	local rounds = math.ceil(math.log(#listPlrs)/math.log(2))
	local matches = ((math.pow(2,rounds))-1)
	while round <= matches do
		local plrString1 = bracketPositions[(2*round)-1].TextLabel.Text
		local plrString2 = bracketPositions[(2*round)].TextLabel.Text
		local player1 = GameOps.getPlayer(plrString1,playerSeedingQ1)
		local player2 = GameOps.getPlayer(plrString2,playerSeedingQ1)
		
		local currentRoundParticipants
		if player1 then
			currentRoundParticipants = {player1,player2}
		else
			currentRoundParticipants = {player2,player1} 
		end
		
		for i,player in ipairs(currentRoundParticipants) do
			if player then
				character = player.Character
				if character then
					character:FindFirstChild('HumanoidRootPart').CFrame = AvailableSpawnPoints[1].CFrame
					table.remove(AvailableSpawnPoints,1)
					local plrWeapon = GameOps.getWeapon(player,Items)
					plrWeapon.Parent = player.Backpack
					local GameTag = Instance.new('BoolValue')
					GameTag.Name = 'GameTag'
					GameTag.Parent = player.Character
				else
					if not player then
						table.remove(currentRoundParticipants,i)
					end
				end
			end
		end
		local plrOneName 
		local plrTwoName
		if currentRoundParticipants[1] and currentRoundParticipants[2] then
			plrOneName = currentRoundParticipants[1].Name
			plrTwoName = currentRoundParticipants[2].Name
			Status.Value = 'Round '..round..' '..plrOneName..' vs '..plrTwoName
		else
			local unkPlr = currentRoundParticipants[1] or currentRoundParticipants[2]
			local unkPlrName = unkPlr.Name
			Status.Value = unkPlrName.." gets a bye!"
		end
		
		wait(5)
		print(currentRoundParticipants[1],currentRoundParticipants[2])
		for i = RoundLength,0,-1 do
			for x, player in pairs(currentRoundParticipants) do
				if player then
					character = player.Character
					if character then -- If player is loaded into the game
						if not character:FindFirstChild('GameTag') then -- Player is dead
							table.remove(currentRoundParticipants,x)	
						end
					end
				else
					table.remove(currentRoundParticipants,x)	
				end
			end
			Status.Value = 'There are '..i..' seconds remaining in the round '
			if #currentRoundParticipants == 1 then -- one guy remaining. must be winner
				if currentRoundParticipants[1] then
					Status.Value = 'The winner of the round is '..currentRoundParticipants[1].Name
					local image,text = GameOps.movePlayerThroughBracket(round,rounds,currentRoundParticipants[1],bracketPositions)
					local serverBracketChildren = ReplicatedStorage.ServerBracket:GetChildren()
					local currentBracketName = serverBracketChildren[1].Name
					updateBracket:FireAllClients(currentBracketName,round,rounds,currentRoundParticipants[1])
					currentRoundParticipants[1]:LoadCharacter()
					break
				elseif currentRoundParticipants[2] then
					Status.Value = 'The winner of the round is '..currentRoundParticipants[2].Name
					local image,text =  GameOps.movePlayerThroughBracket(round,rounds,currentRoundParticipants[2],bracketPositions)
					local serverBracketChildren = ReplicatedStorage.ServerBracket:GetChildren()
					local currentBracketName = serverBracketChildren[2].Name
					updateBracket:FireAllClients(currentBracketName,round,rounds,currentRoundParticipants[2])
					currentRoundParticipants[2]:LoadCharacter()
					break
				end
			elseif #currentRoundParticipants == 0 then
				Status.Value = 'Nobody won!'
				break
			elseif i == 0 then
				Status.Value = 'Time up!'
				break	
			end
			wait(5)	
		end
		AvailableSpawnPoints = ClonedMap:FindFirstChild('SpawnPoints'):GetChildren()
		round = round + 1	
	end
	Status.Value = bracketPositions[#bracketPositions].TextLabel.Text..' Is the ULTIMATE'
	wait(3)
	--End of Game Cleanup		
	for i, player in pairs(game.Players:GetPlayers())do
		character = player.Character
		if character then
			GameOps.cleanUp(player,character)
		end
		player:LoadCharacter()
	end
	ClonedMap:Destroy()
	Status.Value = 'Game ended'
end



