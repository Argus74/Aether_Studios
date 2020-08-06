local GameOpsMod = {}
local ReplicatedStorage = game:GetService('ReplicatedStorage')

function GameOpsMod.cleanUp(player,character)
	local brackets = ReplicatedStorage.ServerBracket:GetChildren()
	if character:FindFirstChild('GameTag') then
		character.GameTag:Destroy()
	end
	for i,tool in ipairs(player.Backpack:GetChildren()) do
		tool:Destroy()
	end
	if brackets[1] then
		brackets[1]:Destroy()
	end
	if player.PlayerGui:FindFirstChild('TwoPerson')  then
		player.PlayerGui.TwoPerson:Destroy()
	end
	if player.PlayerGui:FindFirstChild('FourPerson') then
		player.PlayerGui.FourPerson:Destroy()
	end
	if player.PlayerGui:FindFirstChild('EightPerson') then
		player.PlayerGui.EightPerson:Destroy()
	end
end

function GameOpsMod.movePlayerThroughBracket(round,rounds,winningPlayer,positions)
	local bracketSize = ((math.pow(2,rounds)))
	positions[round + bracketSize].ImageLabel.Image = "http://www.roblox.com/thumbs/avatar.ashx?x=352&y=352&format=png&username="..winningPlayer.Name
	positions[round + bracketSize].TextLabel.Text = winningPlayer.Name
	return positions[round + bracketSize].ImageLabel.Image,positions[round + bracketSize].TextLabel.Text 
end

function GameOpsMod.fillOutTourneyGui(playerSeeding,positions)
	local posDictionary = {}
	for i,v in ipairs(playerSeeding)do
		posDictionary[playerSeeding[i]] = {positions[2*i-1],positions[2*i]}
	end
	for players,positions in pairs(posDictionary) do
		if players[1] then
			positions[1].ImageLabel.Image = "http://www.roblox.com/thumbs/avatar.ashx?x=352&y=352&format=png&username="..players[1].Name
			positions[1].TextLabel.Text = players[1].Name
		end
		if players[2] then
			positions[2].ImageLabel.Image = "http://www.roblox.com/thumbs/avatar.ashx?x=352&y=352&format=png&username="..players[2].Name
			positions[2].TextLabel.Text = players[2].Name
		end
	end
end

function GameOpsMod.cloneGUIToRepStorage(numGroups,bracketSizes,serverBracket)
	serverBracket = ReplicatedStorage.ServerBracket
	if numGroups == 1 then
		local twoPersonBracket = bracketSizes.TwoPerson:Clone()
		twoPersonBracket.Parent = serverBracket
		return twoPersonBracket
	elseif numGroups == 2 then
		local fourPersonBracket = bracketSizes.FourPerson:Clone()
		fourPersonBracket.Parent = serverBracket
		return fourPersonBracket
	elseif numGroups == 4 then
		local eightPersonBracket = bracketSizes.EightPerson:Clone()
		eightPersonBracket.Parent = serverBracket
		return eightPersonBracket
	end
end	

function GameOpsMod.shuffleList(list)
	local shuffled = {}
	for i, v in ipairs(list) do
		local pos = math.random(1, #shuffled+1)
		table.insert(shuffled, pos, v)
	end
	return shuffled
end

function GameOpsMod.getPlayer(plrString,playerSeeding)
	for i,players in ipairs(playerSeeding) do
		local player1,player2 = unpack(players)
		if player1 then
			if plrString == player1.Name then
			return player1
			end
		end
		if player2 then
			if plrString == player2.Name then
			return player2
			end
		end
	end
end

function GameOpsMod.getWeapon(player,Items)
	local playerChosenWep = player.ChosenWeapon:FindFirstChildOfClass('ObjectValue')
	local Weapon
	if playerChosenWep then
		print('fetching chosen wep')
		Weapon = Items[playerChosenWep.Name].Path:Clone()
	else
		print('giving the player the default weapon')
		Weapon = Items['RayCastKatana'].Path:Clone()
	end
	return Weapon
end

function GameOpsMod.FetchWeapons(player)
	local weapon = player.ChosenWeapon:FindFirstChildOfClass('ObjectValue')
	return weapon
end
return GameOpsMod
