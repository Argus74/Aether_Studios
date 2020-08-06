local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local MouseFunction = Tool:WaitForChild("MouseFunction")
local player = game.Players.LocalPlayer
local RS = game:GetService('ReplicatedStorage')
local character = player.Character or player.CharacterAdded:Wait()
local RunS = game:GetService('RunService')

local Mouse = nil
local ExpectingInput = false
local Camera = workspace.CurrentCamera
local FirePointObject = Handle:WaitForChild('GunFirePoint')
local changeGunModeEvent = Tool:WaitForChild('ChangeGunModeEvent')
local FiringGun = false
local autoShooting = true

local viewModelConnection
local characterRespawnConnection

function UpdateMouseIcon()
	if Mouse and not Tool.Parent:IsA("Backpack") then
		Mouse.Icon = "rbxasset://textures/GunCursor.png"
	end
end

function onDied(viewModel)
	viewModel.Parent = nil
end

function onRespawn(viewModel)
	viewModel.Parent = nil
end

function updateArm(key,viewModel,weapon)
	local shoulder = viewModel[key..'UpperArm'][key..'Shoulder']
	local cf = weapon[key].CFrame * CFrame.Angles(math.pi/2,0,math.pi/4) * CFrame.new(0,1.5,0)
	shoulder.C1 = cf:ToObjectSpace(shoulder.Part0.CFrame):ToWorldSpace(shoulder.C0)
end

function onUpdate(viewModel,camera,weapon)
	viewModel.Head.CFrame = camera.CFrame
	updateArm('Right',viewModel,weapon)
	updateArm('Left',viewModel,weapon)
end

function PlaceFPSArms()
	local camera = game.Workspace.CurrentCamera
	local humanoid = player.Character.Humanoid
	local viewModel = game.ReplicatedStorage:WaitForChild('viewModel'):Clone()
	humanoid.Died:Connect(onDied)
	player.CharacterAdded:Connect(function()
		onRespawn(viewModel)
	end)
	
	local weapon = RS:WaitForChild('PaintGun'):Clone()
	weapon.Parent = viewModel
	viewModel.Parent = camera

	local joint = Instance.new('Motor6D')
	joint.C0 = CFrame.new(2,-.9,-2) * CFrame.Angles(math.rad(90),0,0)
	joint.Part0 = viewModel.Head
	joint.Part1 = weapon.Handle
	joint.Parent = viewModel.Head
	viewModelConnection = game:GetService('RunService').RenderStepped:Connect(function()
		onUpdate(viewModel,camera,weapon)
	end)
end

function MakeHandleInvisible()
	local handle = script.Parent.Handle
	handle.LocalTransparencyModifier = 1
end


function OnEquipped(PlayerMouse)
	Mouse = PlayerMouse
	ExpectingInput = true
	UpdateMouseIcon()
	MakeHandleInvisible()
	PlaceFPSArms()
end

function OnUnequipped()
	ExpectingInput = false
	UpdateMouseIcon()
	local camera = game.Workspace.CurrentCamera
	camera.viewModel:Destroy()
	viewModelConnection:Disconnect()
end


local inputs = {
	MouseButton1 = {
		Method = function(boolean)
			FiringGun = boolean
		end
	},
	Q = {
		Method = function()
			changeGunModeEvent:FireServer()
		end
	}
}

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnequipped)

UserInputService.InputBegan:Connect(function (input, gameHandledEvent)
	if gameHandledEvent or not ExpectingInput then
		--The ExpectingInput value is used to prevent the gun from firing when it shouldn't on the clientside.
		--This will still be checked on the server.
		return
	end
	local data = inputs[input.UserInputType.Name]
	local data2 = inputs[input.KeyCode.Name]
	
	if data and Mouse ~= nil then
		data.Method(true)
	elseif data2 then
		data2.Method()
	end
end)

UserInputService.InputEnded:Connect(function(input,gameHandledEvent)
	if gameHandledEvent or not ExpectingInput then
		--The ExpectingInput value is used to prevent the gun from firing when it shouldn't on the clientside.
		--This will still be checked on the server.
		return
	end
	local data = inputs[input.UserInputType.Name]
	if data and Mouse ~= nil then
		data.Method(false)
	end
end)

coroutine.wrap(function()
	while true do
		if FiringGun then
			print('Firing Gun')
			local FireDirection = (Mouse.Hit.p - FirePointObject.WorldPosition).Unit
			if not MouseFunction:InvokeServer(FireDirection) then
				print('Invoked Server')
				FiringGun = false 
			end
		end
		RunS.RenderStepped:Wait()
    end
end)()
