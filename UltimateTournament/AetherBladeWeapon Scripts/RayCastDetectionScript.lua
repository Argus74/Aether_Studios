local SS = game:GetService('ServerStorage')
local SSS = game:GetService('ServerScriptService')
local RS = game:GetService('ReplicatedStorage')
local UIP = game:GetService('UserInputService')


local players = game:GetService('Players')
local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService('ServerStorage')
local SSS = game:GetService('ServerScriptService')
local sword = script.Parent
local character = sword.Parent
local RequestDebounce = false
local LastAttackTick
local Animations = sword:WaitForChild('Animations'):GetChildren()
local swordProperties = sword:WaitForChild('SwordProperties')
local eventsFolder = sword:WaitForChild('Events')

local ABAttackEvent = eventsFolder.ABAttackEvent
local aetherWindEvent = eventsFolder.AetherWindEvent

local RaycastHitBox = require(RS.HitBoxModules.RaycastHitbox)
local AttachMod = require(script:WaitForChild('AttachmentModule'))
local AnimationsTable = {Animations[1],Animations[2],Animations[3],Animations[4],Animations[5]}
local sword = script.Parent
local hum 
local A1Track 
local A2Track
local A3Track
local A4Track
local movementTrack 
local trackTable = {A1Track,A2Track,A3Track,A4Track,movementTrack}
local hitbox = sword.HitBox



local movementEnums = {
	W = true,
	A = true,
	S = true,
	D = true
}

local movementInputes = {}

local isMoving = false


local ANIMA_TIMES = {swordProperties.AnimFrame2.Value/60,swordProperties.AnimFrame3.Value/60,swordProperties.AnimFrame4.Value/60,}
local DMG = swordProperties.Damage.Value
local STREAK = 0
local LENGTH = math.max(hitbox.Size.X, hitbox.Size.Y, hitbox.Size.Z)
local FIRST_ATTACK_RESET_TIME = ANIMA_TIMES[1] + .5
local SECOND_ATTACK_RESET_TIME = ANIMA_TIMES[2] + .5
local THIRD_ATTACK_RESET_TIME = ANIMA_TIMES[3] + .5
local ATTACK_RESET_TIME = FIRST_ATTACK_RESET_TIME

RaycastHitBox:DebugMode(false)
AttachMod.spawnAttachments(hitbox,LENGTH)
local ignoreList = {sword,character}
local hitBoxLoadedEvent = Instance.new('BindableEvent')
local animationEvent
local Hitbox 

function loadAnimations(animationsTable)
	for i,anim in ipairs(animationsTable) do
		if string.find(anim.Name,'A') then
			trackTable[i] = hum:LoadAnimation(AnimationsTable[i])
			trackTable[i].Priority = Enum.AnimationPriority.Action
		elseif string.find(anim.Name,'I') then
			trackTable[i] = hum:LoadAnimation(AnimationsTable[i])
			trackTable[i].Priority = Enum.AnimationPriority.Idle
		elseif string.find(anim.Name,'W') then
			trackTable[i] = hum:LoadAnimation(AnimationsTable[i])
			trackTable[i].Priority = Enum.AnimationPriority.Movement
		end
	end
end

function animationPlayed(anim)
    local name = anim.Name:lower() -- Get the name of the animation in all lowercase, helps with finding the name.
    if name == "toolnoneanim" or name:find("tool") then		-- "toolnoneanim" is the name of the tool equip animation, if Roblox happens to change the name it'll look for "tool" in the name.
	    anim:Stop()
    end
end

function Attack()
	Hitbox:HitStart()
    -- Let only one attack request be processed at one time
    if RequestDebounce then return end
    RequestDebounce = true
    local CurrentAttackTick = tick()
    local TimeSinceLastAttack = (LastAttackTick and CurrentAttackTick - LastAttackTick) or 0
    if  TimeSinceLastAttack > ATTACK_RESET_TIME then
        -- use first attack
        STREAK = 1
    else  
        -- Increment STREAK
        STREAK = STREAK + 1
    end
	if (STREAK%3 == 1) then
		trackTable[1]:Stop()
		trackTable[2]:Play()
		wait(ANIMA_TIMES[1])
		trackTable[1]:Play()
		ATTACK_RESET_TIME = FIRST_ATTACK_RESET_TIME
	elseif (STREAK%3 == 2) then
		trackTable[1]:Stop()
		trackTable[3]:Play()
		wait(ANIMA_TIMES[2])
		trackTable[1]:Play()
		ATTACK_RESET_TIME = SECOND_ATTACK_RESET_TIME
	elseif (STREAK%3 == 0) then
		trackTable[1]:Stop()
		trackTable[4]:Play()
		wait(ANIMA_TIMES[3])
		trackTable[1]:Play()
		ATTACK_RESET_TIME = THIRD_ATTACK_RESET_TIME
	end
    -- Wait until the attack is ready to be played
	Hitbox:HitStop()
    LastAttackTick = CurrentAttackTick
    RequestDebounce = false
end

script.Parent.Activated:Connect(function()
	Attack()
end)

sword.Equipped:Connect(function()
	character = sword.Parent
	hum = character.Humanoid
	hum.AnimationPlayed:Connect(animationPlayed)
	loadAnimations(AnimationsTable)
	trackTable[1]:Play()
	trackTable[4]:GetMarkerReachedSignal('AetherWindKF'):Connect(function(paramString)
		aetherWindEvent:FireServer()
	end)
	ignoreList = {sword,character}
	 
	animationEvent = hum:GetPropertyChangedSignal("MoveDirection"):Connect(function()
        if hum.MoveDirection.Magnitude == 0 then
            trackTable[5]:Stop()
        elseif hum.MoveDirection.Magnitude > 0 then
            if not trackTable[5].IsPlaying then
                trackTable[5]:Play()
            end
        end
	end)
	
	if not Hitbox then
		 Hitbox = RaycastHitBox:Initialize(hitbox, ignoreList)
		 hitBoxLoadedEvent:Fire()
	end
end)

sword.Unequipped:Connect(function()
	if animationEvent ~= nil then
        animationEvent:Disconnect()
        trackTable[5]:Stop()
	end
	if trackTable[1].IsPlaying then
		trackTable[1]:Stop()
	end
end)
hitBoxLoadedEvent.Event:Wait()


--[[UIP.InputBegan:Connect(function(input, gameProcessEvent)
	if gameProcessEvent then
		return
	end
	
	if hum.MoveDirection.Magnitude > 0 then
		return
	else 
		if movementEnums[input.KeyCode.Name] then
			trackTable[5]:Play()
			isMoving = true
			table.insert(movementInputes,#movementInputes + 1, input.KeyCode.Name )
		end
	end
end)

UIP.InputEnded:Connect(function(input,gameProcessEvent)
	if gameProcessEvent then
		return
	end
	
	if movementEnums[input.KeyCode.Name] then
		if hum.MoveDirection.Magnitude > 0 then
			return
		else
			trackTable[5]:Stop()
		end
	end
end)]]

Hitbox.OnHit:Connect(function(hit,humanoid)
	if hit then
		hum = hit.Parent.Humanoid 
		if hum then
			ABAttackEvent:FireServer(STREAK,hum,DMG)
		end
	end
end)