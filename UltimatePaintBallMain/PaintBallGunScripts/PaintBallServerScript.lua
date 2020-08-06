local RS = game:GetService('ReplicatedStorage')
local CS = game:GetService("CollectionService")
local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local MouseFunction = Tool:WaitForChild("MouseFunction")
local FirePointObject = Handle:WaitForChild("GunFirePoint")
local FastCast = require(Tool:WaitForChild("FastCastRedux"))
local FireSound = Handle:WaitForChild("Fire")
local Debris = game:GetService("Debris")
local ImpactParticle = Handle:WaitForChild("ImpactParticle")
local changeGunModeEvent = Tool.ChangeGunModeEvent

local RNG = Random.new()
local BULLET_SPEED = 150							
local BULLET_MAXDIST = 300
local BULLET_GRAVITY = Vector3.new(0, -30, 0)
local MIN_BULLET_SPREAD_ANGLE = 0					
local MAX_BULLET_SPREAD_ANGLE = 10	
local FIRE_DELAY = 0.2
local TAU = math.pi * 2
local PIERCE_DEMO = false	

local players = game:GetService('Players')
local blackList = CS:GetTagged('hat')
local gunModes = {'Rifle','Shotgun'}

local gunModeNum = 1
local gunMode = gunModes[gunModeNum]

CS:GetInstanceAddedSignal('hat'):Connect(function(hat)
	table.insert(blackList,#blackList + 1,hat)
end)

CS:GetInstanceRemovedSignal('hat'):Connect(function(hat)
	table.remove(blackList,table.find(blackList,hat))
end)

function changeGameMode()
	if gunModeNum >= #gunModes then
		gunModeNum = 1
	else
		gunModeNum = gunModeNum + 1
	end
	print(gunModeNum)
	gunMode = gunModes[gunModeNum]
end


local paintBullet = Instance.new("Part")
paintBullet.Material = Enum.Material.Plastic
paintBullet.Color = Color3.fromRGB(245, 0, 0)
paintBullet.CanCollide = false
paintBullet.Anchored = true
paintBullet.Shape = Enum.PartType.Ball
paintBullet.Size = Vector3.new(0.9, 0.9, 2)

function Equipped()
	local character = Tool.Parent
	local player = players:GetPlayerFromCharacter(character)
	
	if player.Team.Name == 'BlueTeam' then
		paintBullet.Color = Color3.fromRGB(0, 0, 245)
		print('Changing particle color')
		ImpactParticle.Color = ColorSequence.new(Color3.new(0,0,245))
	end
end

Tool.Equipped:Connect(function()
	Equipped()
end)



changeGunModeEvent.OnServerEvent:Connect(function()
	changeGameMode()
end)

	

local CanFire = true	
local Caster = FastCast.new() 

function PlayFireSound()
	print(FireSound)
	FireSound:Play()
end

function MakeParticleFX(position, normal)
	-- This is a trick I do with attachments all the time.
	-- Parent attachments to the Terrain - It counts as a part, and setting position/rotation/etc. of it will be in world space.
	-- UPD 11 JUNE 2019 - Attachments now have a "WorldPosition" value, but despite this, I still see it fit to parent attachments to terrain since its position never changes.
	local attachment = Instance.new("Attachment")
	attachment.CFrame = CFrame.new(position, position + normal)
	attachment.Parent = workspace.Terrain
	local particle = ImpactParticle:Clone()
	particle.Parent = attachment
	Debris:AddItem(attachment, particle.Lifetime.Max) -- Automatically delete the particle effect after its maximum lifetime.
	
	-- A potentially better option in favor of this would be to use the Emit method (Particle:Emit(numParticles)) though I prefer this since it adds some natural spacing between the particles.
	particle.Enabled = true
	wait(0.05)
	particle.Enabled = false
end

function Fire(direction)
	local character = Tool.Parent
	local player = players:GetPlayerFromCharacter(character)
	-- Called when we want to fire the gun.
	if Tool.Parent:IsA("Backpack") then return end -- Can't fire if it's not equipped.
	-- Note: Above isn't in the event as it will prevent the CanFire value from being set as needed.
	
	-- UPD. 11 JUNE 2019 - Add support for random angles.
	local directionalCF = CFrame.new(Vector3.new(), direction)
	-- Now, we can use CFrame orientation to our advantage.
	-- Overwrite the existing Direction value.
	local direction = (directionalCF * CFrame.fromOrientation(0, 0, RNG:NextNumber(0, TAU)) * CFrame.fromOrientation(math.rad(RNG:NextNumber(MIN_BULLET_SPREAD_ANGLE, MAX_BULLET_SPREAD_ANGLE)), 0, 0)).LookVector
	
	-- UPDATE V6: Proper bullet velocity!
	-- IF YOU DON'T WANT YOUR BULLETS MOVING WITH YOUR CHARACTER, REMOVE THE THREE LINES OF CODE BELOW THIS COMMENT.
	-- Requested by https://www.roblox.com/users/898618/profile/
	-- We need to make sure the bullet inherits the velocity of the gun as it fires, just like in real life.
	local humanoidRootPart = Tool.Parent:WaitForChild("HumanoidRootPart", 1)	-- Add a timeout to this.
	local myMovementSpeed = humanoidRootPart.Velocity							-- To do: It may be better to get this value on the clientside since the server will see this value differently due to ping and such.
	local modifiedBulletSpeed = (direction * BULLET_SPEED) + myMovementSpeed	-- We multiply our direction unit by the bullet speed. This creates a Vector3 version of the bullet's velocity at the given speed. We then add MyMovementSpeed to add our body's motion to the velocity.
	
	-- Prepare a new cosmetic bullet
	local bullet = paintBullet:Clone()
	bullet.CFrame = CFrame.new(FirePointObject.WorldPosition, FirePointObject.WorldPosition + direction)
	bullet.Parent = workspace
	table.insert(blackList,bullet)
	
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = player
	creator_tag.Name = "creator"
	creator_tag.Parent = bullet
	
	-- NOTE: It may be a good idea to make a Folder in your workspace named "CosmeticBullets" (or something of that nature) and use FireWithBlacklist on the descendants of this folder!
	-- Quickly firing bullets in rapid succession can cause the caster to hit other casts' bullets from the same gun (The caster only ignores the bullet of that specific shot, not other bullets).
	-- Do note that if you do this, you will need to remove the Equipped connection that sets IgnoreDescendantsInstance, as this property is not used with FireWithBlacklist
	
	Caster:FireWithBlacklist(FirePointObject.WorldPosition, direction * BULLET_MAXDIST, modifiedBulletSpeed, blackList, bullet, false, BULLET_GRAVITY)
	
	
	-- Play the sound
	PlayFireSound()
end

function TagHumanoid(tag,humanoid)
	tag.Parent = humanoid
end

function untagHumanoid(humanoid)
	if humanoid then
		local tag = humanoid:FindFirstChild('creator')
		if tag then
			tag:Destroy()
		end
	end	
end

function OnRayHit(hitPart, hitPoint, normal, material, cosmeticBulletObject)
	-- This function will be connected to the Caster's "RayHit" event.
	local newCreatorTag = cosmeticBulletObject.creator:Clone()
	cosmeticBulletObject:Destroy() -- Destroy the cosmetic bullet.
	if hitPart and hitPart.Parent then -- Test if we hit something
		local humanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid") -- Is there a humanoid?
		if humanoid then
			newCreatorTag.Parent = humanoid
			humanoid:TakeDamage(40) -- Damage.
			delay(1,function()
				untagHumanoid(humanoid)
			end)
		else
			newCreatorTag:Destroy()
		end
		MakeParticleFX(hitPoint, normal) -- Particle FX
	end
end

function OnRayUpdated(castOrigin, segmentOrigin, segmentDirection, length, cosmeticBulletObject)
	local bulletLength = cosmeticBulletObject.Size.Z / 2 
	local baseCFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection)
	cosmeticBulletObject.CFrame = baseCFrame * CFrame.new(0, 0, -(length - bulletLength))
end

assert(MAX_BULLET_SPREAD_ANGLE >= MIN_BULLET_SPREAD_ANGLE, "Error: MAX_BULLET_SPREAD_ANGLE cannot be less than MIN_BULLET_SPREAD_ANGLE!")
if (MAX_BULLET_SPREAD_ANGLE > 180) then
	warn("Warning: MAX_BULLET_SPREAD_ANGLE is over 180! This will not pose any extra angular randomization. The value has been changed to 180 as a result of this.")
	MAX_BULLET_SPREAD_ANGLE = 180
end

MouseFunction.OnServerInvoke = function(clientThatFired, mouseDirection)
	if not CanFire then
		print('Return true cause canfire is false')
		return true
	end
	CanFire = false
	
	if gunMode == 'Rifle' then
		print('Firing Rifle')
		MAX_BULLET_SPREAD_ANGLE = 0.5	
		Fire(mouseDirection)
		CanFire = true
		wait(FIRE_DELAY)
		return true
	elseif gunMode == 'Shotgun' then
		print('Shotgun')
		MAX_BULLET_SPREAD_ANGLE = 10	
		for i = 1,4,1 do
			Fire(mouseDirection)
		end
		CanFire = true
		wait(FIRE_DELAY)
		return false
	end
end

Caster.LengthChanged:Connect(OnRayUpdated)
Caster.RayHit:Connect(OnRayHit)