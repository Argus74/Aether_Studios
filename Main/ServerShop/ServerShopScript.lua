local DS2 = require(1936396537)
local rs = game:GetService('ReplicatedStorage')
local SS  = game:GetService('ServerStorage')
local shopGui = rs.Shop.ShopGui
local swordPage = shopGui.OuterBorder.Pages.SwordPage
local swordImages = {5032412074,5032413591}
local swordNames = {"AetherBlade","RayCastKatana"}
local ItemsMod = require(SS.ItemsModule:WaitForChild("ItemsModule"))
local Items = ItemsMod.ReturnTable()
local CS = game:GetService('CollectionService')
local priceTags = CS:GetTagged('Price')

for i,PriceTag in ipairs(priceTags) do
	PriceTag.Changed:Connect(function(newValue)
		PriceTag.Parent.Text = newValue
	end)
end

for i,swordDesc in ipairs(swordPage:GetChildren()) do
	if swordDesc.Name ~= "Display" then
		if swordImages[i] and Items[swordNames[i]] then
			swordDesc.SwordImage.Image = ("rbxthumb://type=Asset&id="..swordImages[i]).."&w=150&h=150"
			swordDesc.PriceLabel.Price.Value = Items[swordNames[i]].Price
			swordDesc.ReferenceTool.Value = Items[swordNames[i]].Path
			print(swordDesc.ReferenceTool.Value)
			swordDesc.ReferenceTool.Name = swordNames[i]
		end
	end
end




