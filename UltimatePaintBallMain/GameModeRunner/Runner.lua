local RS = game:GetService('RunService')
local RepS = game:GetService('ReplicatedStorage')
local playerGunEvent = RepS:WaitForChild('PlayersGotGun')
local newPlayerEvent = RepS.NewPlayerEvent
local gameState = script.Parent.GameState
local Runner = {}
	
	function Runner.RunChosenMode(GameModeTable,players,gameTime)
		gameState.Value = 'GameInProgress'
		if GameModeTable.Name == 'DeathMatch' then
			local DeathMatchGameMode = GameModeTable
			local playerConnections = {}
			local playingTable = DeathMatchGameMode.CreatePlayingPlrsTable(players)
			DeathMatchGameMode.PlayGuiConnection(players,playerConnections)
			newPlayerEvent.OnServerEvent:Connect(function(player)
				DeathMatchGameMode.OnNewPlayerAddedToMatch(player,playingTable,playerConnections)
			end)
			DeathMatchGameMode.SortTeams(playingTable)
			DeathMatchGameMode.OnPlayerAddedConnections(playingTable,playerConnections)
			DeathMatchGameMode.FirstPersonConnection(playingTable,playerConnections)
			local sound = DeathMatchGameMode.PlaySound('DeathMatchAudio')
			DeathMatchGameMode.SpawnPlayers(playingTable)
			DeathMatchGameMode.ActivateWeapons(playingTable)
			DeathMatchGameMode.RespawnWithWeapons(playingTable,playerConnections)
			DeathMatchGameMode.PlaceGunModeGuiInPlayers(playingTable)
			DeathMatchGameMode.StartClock(gameTime,playingTable)
			DeathMatchGameMode.DisconnectConnection(playerConnections)
			DeathMatchGameMode.DeactivateWeapons(playingTable)
			DeathMatchGameMode.DecideWinner(playingTable)
			DeathMatchGameMode.StopSound(sound)
			DeathMatchGameMode.DestroyGui(playingTable)
			DeathMatchGameMode.ReturnToLobby(playingTable)
			gameState.Value = 'Intermission'
		end
	end

return Runner
