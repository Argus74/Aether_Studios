local GameModSupClass = script.Parent
local SS = game:GetService('ServerStorage')
local RS = game:GetService('RunService')
local TS = SS.TempStorage
local gameAssets = SS.GameAssets:GetChildren()
local Teams = game:GetService('Teams')
local CapTheFlag = require(GameModSupClass):new()

local activeFlags = {}

local flagObjects = {
	redFlag = {
		flag = gameAssets.Flags.RedFlag,
		stand = gameAssets.FlagStands.RedFlagStand,
		location = function(self)
			local standCf = self.stand.CFrame
			return standCf * CFrame.new(0,self.stand.Size/2,0)
		end,
		touchedFunction = function(self,rightArm)
			local flag = self.flag
			local weld = Instance.new('Weld')
		end
	},
	blueFlag = {
		flag = gameAssets.Flags.BlueFlag,
		stand = gameAssets.FlagStands.BlueFlagStand,
		location = function(self)
			local standCf = self.stand.CFrame
			return standCf * CFrame.new(0,self.stand.Size/2,0)
		end
	}
}

CapTheFlag.Name = 'CapTheFlag'


function CapTheFlag.FlagTouched(touchedPart,flagPole)
	local hum = touchedPart.Parent:FindFirstChild('Humanoid')
	local flag = flagPole.Parent 
	if hum and flag.beingHeld == false then
		local weld = Instance.new('Weld')
		weld.Part0 = hum.Parent.RightHand
		weld.Part1 = flagPole
		weld.C0 = CFrame.new(0,0,0)
		weld.C1 = CFrame.new(0,0,0)
		weld.Parent = hum.Parent.RightHand
		flag.ownerCharacter = hum.Parent
		flag.beingHeld = true
		if hum.Parent:FindFirstChild('ClassicPaintBallGun')
	end
end

function CapTheFlag.PrepareMap(flagObjects)
	for	i,flagObject in pairs(flagObjects) do
		local newFlag = flagObject.flag:Clone()
		local newFlagStand = flagObject.Stand:Clone()
		newFlagStand.Parent = game.Workspace
		newFlag.Parent = game.Workspace
		newFlag.CFrame = newFlag:location()
		table.insert(activeFlags,#activeFlags + 1,newFlag)
	end
end

function CapTheFlag.ActivateFlags(activeFlags)
	for i,flag in ipairs(activeFlags) do
		flag.Touched:Connect(function(touched)
			CapTheFlag.FlagTouched(touched,flag.Handle)
		end)
	end
end

function CapTheFlag.RespawnWithWeapons(playingTable,connectionTable,player)
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
	
function CapTheFlag.DecideWinner(playingTable)
	local redTeam = Teams.RedTeam
	local blueTeam = Teams.BlueTeam
	
	Teams.RedTeam:Destroy()
	Teams.BlueTeam:Destroy()
end

function CapTheFlag.DisconnectConnection(connectionTable)
	for i,connection in ipairs(connectionTable) do
		connectionTable[i]:Disconnect()
	end
end

function CapTheFlag.OnNewPlayerAddedToMatch(player,playingTable,connectionTable)
	table.insert(playingTable,#playingTable + 1,player)
	CapTheFlag.AddToATeam(player)
	CapTheFlag.OnPlayerAddedConnections(playingTable,connectionTable,player)
	CapTheFlag.FirstPersonConnection(nil,connectionTable,player)
	CapTheFlag.SpawnPlayers(nil,player)
	CapTheFlag.ActivateWeapons(playingTable,player)
	CapTheFlag.RespawnWithWeapons(nil,connectionTable,player)
	CapTheFlag.PlaceClockInPlayers(nil,player)
	CapTheFlag.PlaceGunModeGuiInPlayers(nil,player)
end	
return CapTheFlag

