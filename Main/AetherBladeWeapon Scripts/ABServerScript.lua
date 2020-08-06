local SS = game:GetService('ServerStorage')
local SSS = game:GetService('ServerScriptService')
local RS = game:GetService('ReplicatedStorage')

local DmgMod = require(script.DamageModule)
local ABAttackEvent = script.Parent.Events.ABAttackEvent
local sword = script.Parent
local swordProperties = sword:WaitForChild('SwordProperties')




ABAttackEvent.OnServerEvent:Connect(function(player,STREAK,hum,dmg)
	print('Server Event fired')
	print(ABAttackEvent)
	DmgMod.CalcDmg(STREAK,hum,dmg)
end)