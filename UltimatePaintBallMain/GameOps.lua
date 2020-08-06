local SS = game:GetService('ServerStorage')
local SSS = game:GetService('ServerScriptService')
local GameOperations = {}

function GameOperations.CheckIfReady(players,num,event)
	if #players>= num then
		event:Fire()
	else
	
	end
end
	
function GameOperations.OnPlayerAdded(player)
	local playGui = SS.GameOpsGui.PlayGui:Clone()
	playGui.Parent = player.PlayerGui
end

function GameOperations.CreateIntermissionGui(players,player)
	
	if player then
		if SSS.GameModeRunner.GameState.Value == 'Intermission' then
			local intGui = SS.GameOpsGui.Intermission:Clone()
			intGui.Parent = player.PlayerGui
		end
	else
		for i,player in ipairs(players:GetChildren()) do
			local intGui = SS.GameOpsGui.Intermission:Clone()
			intGui.Parent = player.PlayerGui
		end
	end
end

function GameOperations.CountDownClock(intermissionTime)
	local intGui = SS.GameOpsGui.Intermission
	for i = intermissionTime,0,-1 do
		intGui.IntermissionTimer.Value = i
		wait(1)
	end
end

function GameOperations.DestroyGui(players)
	for i,player in ipairs(players:GetChildren()) do
		local intGui = player.PlayerGui:FindFirstChild('Intermission')
		if intGui then
			intGui:Destroy()
		end
	end
end
	
	

return GameOperations
