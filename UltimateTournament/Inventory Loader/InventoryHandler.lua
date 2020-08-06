local SS = game:GetService('ServerStorage')
local inventoryTemplate = SS:WaitForChild('InventoryTemplate')
local ItemsMod =  require(SS.ItemsModule:WaitForChild('ItemsModule'))
local Items = ItemsMod.ReturnTable()
local RS = game:GetService('ReplicatedStorage')
local DataStore2 = require(1936396537)

local uiEvent = RS.DataStoreEvents.UpdateUIInvEvent
local dataLoadedEvent = RS.DataStoreEvents.DataStoreLoaded
local sucPurchaseEvent = RS.ShopEvents.SuccesfulPurchaseEvent

function SetupInventory(player)
	local inventory = player:WaitForChild('Inventory')
	local invItems = inventory:GetChildren()
	local playerGui = player:WaitForChild('PlayerGui')
	local inventoryGui = playerGui:WaitForChild('Inventory')
	local inventoryFrame = inventoryGui.InventoryFrame
	for i,item in ipairs(invItems) do
		if inventoryFrame.ItemList:FindFirstChild(item.Name) then
				
		else
			local newItemFrame = inventoryTemplate.ItemFrame:Clone()
			newItemFrame.ItemImage.Image = ("rbxthumb://type=Asset&id="..(Items[item.Name].ImageID)).."&w=150&h=150"
			newItemFrame.Name = item.Name
			newItemFrame.ItemName.Text = item.Name
			newItemFrame.Parent = inventoryFrame.ItemList
		end
	end
end

function UpdateInventory(player)
	local inventory = player:FindFirstChild('Inventory')
	local invItems = inventory:GetChildren()
	local playerGui = player:FindFirstChild('PlayerGui')
	local inventoryGui = playerGui:WaitForChild('Inventory')
	local inventoryFrame = inventoryGui:WaitForChild('InventoryFrame')
	for i,item in ipairs(invItems) do
		if inventoryFrame.ItemList:FindFirstChild(item.Name) then
			
		else
			print(item.Name)
			local newItemFrame = inventoryTemplate.ItemFrame:Clone()
			newItemFrame.ItemImage.Image = ("rbxthumb://type=Asset&id="..(Items[item.Name].ImageID)).."&w=150&h=150"
			newItemFrame.Name = item.Name
			newItemFrame.ItemName.Text = item.Name
			newItemFrame.Parent = inventoryFrame.ItemList
		end
	end
end


game.Players.PlayerAdded:Connect(function(player)
	dataLoadedEvent.Event:Wait()
	SetupInventory(player)
	local inventoryStore = DataStore2("inventory",player)
end)

uiEvent.Event:Connect(function(player)
	UpdateInventory(player)
end)