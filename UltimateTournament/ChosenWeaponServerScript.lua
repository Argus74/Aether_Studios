local RS = game:GetService('ReplicatedStorage')
local chosenWepEvent = RS.InvEvents.ChosenWepEvent


chosenWepEvent.OnServerEvent:Connect(function(player,itemName)
	local newChosenWep = Instance.new('ObjectValue')
	local chosenInv = player.ChosenWeapon
	newChosenWep.Name = itemName
	newChosenWep.Parent = chosenInv
end)