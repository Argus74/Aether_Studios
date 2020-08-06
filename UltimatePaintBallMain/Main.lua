local playingPlayers = {}
local SSS = game:GetService('ServerScriptService')
local SS = game:GetService('ServerStorage')
local RS = game:GetService('ReplicatedStorage')
local gameModes = SSS.GameModes.GameModeSupClass:GetChildren()
local startEvent = Instance.new('BindableEvent')
local GameOps = require(script.GameOps)
local GameRunner = require(SSS.GameModeRunner.Runner)
local endEvent = RS.EndEvent
local connection
local INTERMISSION_TIME = 20
local MINIMUM_NUM_PLAYERS = 2
local GAME_TIME = 100



while true do
	local players = game:GetService('Players')
	GameOps.CreateIntermissionGui(players)
	local rand = Random.new(tick())
	local chosenGameMode = require(gameModes[1])
	players.PlayerAdded:Connect(function(player)
		GameOps.CheckIfReady(players:GetChildren(),MINIMUM_NUM_PLAYERS,startEvent)
		player.CharacterAdded:Connect(function()
			GameOps.CreateIntermissionGui(nil,player)
		end)
	end)
	if #(players:GetChildren())< MINIMUM_NUM_PLAYERS then
		startEvent.Event:Wait()
	end
	GameOps.CountDownClock(INTERMISSION_TIME)
	GameOps.DestroyGui(players)
	GameRunner.RunChosenMode(chosenGameMode,players,GAME_TIME,connection)
	endEvent:Fire()							
end

game:GetService('Players').PlayerAdded:Connect(function(player)
	GameOps.OnPlayerAdded(player)
end)
