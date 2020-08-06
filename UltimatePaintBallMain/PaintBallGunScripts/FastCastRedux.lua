--[[
	FastCast Ver. 9.0.0
	Written by Eti the Spirit (18406183)
	
		The latest patch notes can be located here: https://github.com/XanTheDragon/FastCastAPIDocs/wiki/Changelist
		
		*** If anything is broken, please don't hesitate to message me! ***
		
		YOU CAN FIND IMPORTANT USAGE INFORMATION HERE: https://github.com/XanTheDragon/FastCastAPIDocs/wiki
		YOU CAN FIND IMPORTANT USAGE INFORMATION HERE: https://github.com/XanTheDragon/FastCastAPIDocs/wiki
		YOU CAN FIND IMPORTANT USAGE INFORMATION HERE: https://github.com/XanTheDragon/FastCastAPIDocs/wiki
		
		YOU SHOULD ONLY CREATE ONE CASTER PER GUN.
		YOU SHOULD >>>NEVER<<< CREATE A NEW CASTER EVERY TIME THE GUN NEEDS TO BE FIRED.
		
		A caster (created with FastCast.new()) represents a "gun".
		When you consider a gun, you think of stats like accuracy, bullet speed, etc. This is the info a caster stores. 
	
	--
	
	This is a library used to create hitscan-based guns that simulate projectile physics.
	
	This means:
		- You don't have to worry about bullet lag / jittering
		- You don't have to worry about keeping bullets at a low speed due to physics being finnicky between clients
		- You don't have to worry about misfires in bullet's Touched event (e.g. where it may going so fast that it doesn't register)
		
	Hitscan-based guns are commonly seen in the form of laser beams, among other things. Hitscan simply raycasts out to a target
	and says whether it hit or not.
	
	Unfortunately, while reliable in terms of saying if something got hit or not, this method alone cannot be used if you wish
	to implement bullet travel time into a weapon. As a result of that, I made this library - an excellent remedy to this dilemma.
	
	FastCast is intended to be require()'d once in a script, as you can create as many casters as you need with FastCast.new()
	This is generally handy since you can store settings and information in these casters, and even send them out to other scripts via events
	for use.
	
	Remember -- A "Caster" represents an entire gun (or whatever is launching your projectiles), *NOT* the individual bullets.
	Make the caster once, then use the caster to fire your bullets. Do not make a caster for each bullet.
--]]

local FastCast = {}
FastCast.DebugLogging = false
FastCast.__index = FastCast

-----------------------------------------------------------
----------------------- STATIC DATA -----------------------
-----------------------------------------------------------
local RunService = game:GetService("RunService")
local Signal = require(script:WaitForChild("Signal"))
local table = require(script:WaitForChild("Table"))

-- Format params: methodName, ctorName
local ERR_NOT_INSTANCE = "Cannot statically invoke method '%s' - It is an instance method. Call it on an instance of this class created via %s"

-- Format params: paramName, expectedType, actualType
local ERR_INVALID_TYPE = "Invalid type for parameter '%s' (Expected %s, got %s)"


-----------------------------------------------------------
------------------------ UTILITIES ------------------------
-----------------------------------------------------------

-- Alias function to automatically error out for invalid types.
local function MandateType(value, type, paramName, nullable)
	if nullable and value == nil then return end
	assert(typeof(value) == type, ERR_INVALID_TYPE:format(paramName or "ERR_NO_PARAM_NAME", type, typeof(value)))
end

-- Print that runs only if debug mode is active.
local function PrintDebug(message)
	if FastCast.DebugLogging == true then
		print(message)
	end
end

-----------------------------------------------------------
------------------------ CORE CODE ------------------------
-----------------------------------------------------------

-- Simple raycast alias
local function Cast(origin, direction, ignoreDescendantsInstance, ignoreWater)
	local castRay = Ray.new(origin, direction)
	return workspace:FindPartOnRay(castRay, ignoreDescendantsInstance, false, ignoreWater)
end

-- This function casts a ray with a whitelist.
local function CastWithWhitelist(origin, direction, whitelist, ignoreWater)
	if not whitelist or typeof(whitelist) ~= "table" then
		-- This array is faulty.
		error("Call in CastWhitelist failed! Whitelist table is either nil, or is not actually a table.", 0)
	end
	local castRay = Ray.new(origin, direction)
	-- Now here's something bizarre: FindPartOnRay and FindPartOnRayWithIgnoreList have a "terrainCellsAreCubes" boolean before ignoreWater. FindPartOnRayWithWhitelist, on the other hand, does not!
	return workspace:FindPartOnRayWithWhitelist(castRay, whitelist, ignoreWater)
end

-- This function casts a ray with a blacklist.
local function CastWithBlacklist(origin, direction, blacklist, ignoreWater)
	if not blacklist or typeof(blacklist) ~= "table" then
		-- This array is faulty
		error("Call in CastBlacklist failed! Blacklist table is either nil, or is not actually a table.", 0)
	end
	local castRay = Ray.new(origin, direction)
	return workspace:FindPartOnRayWithIgnoreList(castRay, blacklist, false, ignoreWater)
end

-- Thanks to zoebasil for supplying the velocity and position functions below. (I've modified these functions)
-- I was having a huge issue trying to get it to work and I had overcomplicated a bunch of stuff.
-- GetPositionAtTime is used in physically simulated rays (Where Caster.HasPhysics == true or the specific Fire has a specified acceleration).
-- This returns the location that the bullet will be at when you specify the amount of time the bullet has existed, the original location of the bullet, and the velocity it was launched with.
local function GetPositionAtTime(time, origin, initialVelocity, acceleration)
	local force = Vector3.new((acceleration.X * time^2) / 2,(acceleration.Y * time^2) / 2, (acceleration.Z * time^2) / 2)
	return origin + (initialVelocity * time) + force
end

-- Simulate a raycast.
local function SimulateCast(origin, direction, velocity, castFunction, lengthChangedEvent, rayHitEvent, cosmeticBulletObject, listOrIgnoreDescendantsInstance, ignoreWater, bulletAcceleration, canPierceFunction)
	PrintDebug("Cast simulation requested.")
	if type(velocity) == "number" then
		velocity = direction.Unit * velocity
	end
	
	local bulletAcceleration = bulletAcceleration or Vector3.new() -- Fix bug reported by Spooce: Failing to pass in the bulletAcceleration parameter throws an error, so add a fallback of Vector3.new()
	local distance = direction.Magnitude -- This will be a unit vector multiplied by the maximum distance.
	local normalizedDir = direction / distance
	local upgradedDir = (normalizedDir + velocity).Unit
	local initialVelocity = (upgradedDir * velocity.Magnitude)
	
	local totalDelta = 0
	local distanceTravelled = 0
	local lastPoint = origin
	
	local targetEvent
	local connection
	local isRunningPierce = false
	local originalList = listOrIgnoreDescendantsInstance
	local originalCastFunction = castFunction
	
	if RunService:IsClient() then
		targetEvent = RunService.RenderStepped
	else
		targetEvent = RunService.Heartbeat
	end
	
	local function Fire(delta, customAt)
		PrintDebug("Casting for frame.")
		totalDelta = totalDelta + delta
		local at = customAt or GetPositionAtTime(totalDelta, origin, initialVelocity, bulletAcceleration)
		local displacement = (at - lastPoint)
		local rayDir = displacement.Unit * velocity.Magnitude * delta
		local hit, point, normal, material = castFunction(lastPoint, rayDir, listOrIgnoreDescendantsInstance, ignoreWater)
		
		local rayDisplacement = displacement.Magnitude - (at - point).Magnitude
		lengthChangedEvent:Fire(origin, lastPoint, rayDir.Unit, displacement.Magnitude, cosmeticBulletObject)
		lastPoint = at
		if hit and hit ~= cosmeticBulletObject then
			local start = tick()
			
			-- SANITY CHECK: Don't allow the user to yield or run otherwise extensive code that takes longer than one frame/heartbeat to execute.
			if (canPierceFunction ~= nil) then
				if (isRunningPierce) then
					error("ERROR: The latest call to canPierceFunction took too long! This cast is going to suffer desyncs and may have undesired behavior.")
				end
				isRunningPierce = true
			end
			
			if canPierceFunction == nil or (canPierceFunction ~= nil and canPierceFunction(hit, point, normal, material) == false) then
				PrintDebug("Piercing function is nil or it returned FALSE to not pierce this hit. Ending cast and firing RayHit.")
				isRunningPierce = false
				-- Pierce function is nil, or it's not nil and it returned false (we cannot pierce this object).
				-- Hit.
				
				connection:Disconnect()
				rayHitEvent:Fire(hit, point, normal, material, cosmeticBulletObject)
				return
			else
				PrintDebug("Piercing returned TRUE to pierce this hit. Processing...")
				isRunningPierce = false
				-- Nope! We want to pierce this part.				
				-- Now this is gonna be DISGUSTING. 
				-- We need to run this until we fufill that lost distance, so if some guy decides to layer up like 10 parts right next to eachother, we need to handle all of those in a single frame
				-- The only way to do this isn't particularly pretty but it needs to be quick.
				if (castFunction == CastWithWhitelist) then
					-- User is using whitelist. We need to temporarily pull this from their list.
					-- n.b. this function is offered by the sandboxed table system. It's not stock.
					table.removeObject(listOrIgnoreDescendantsInstance, hit)
					PrintDebug("Whitelist cast detected, removed " .. tostring(hit) .. " from whitelist temporarily.")
				elseif (castFunction == CastWithBlacklist) then
					table.insert(listOrIgnoreDescendantsInstance, hit)
					PrintDebug("Blacklist cast detected, added " .. tostring(hit) .. " to blacklist temporarily.")
				else
					-- This is where things get finnicky.
					-- We can't reparent the object. If we do this, we risk altering behavior of the developer's game which has undesirable effects.
					-- We need to swap cast functions on the fly here. This is gonna get NASTY.
					castFunction = CastWithBlacklist
					listOrIgnoreDescendantsInstance = listOrIgnoreDescendantsInstance:GetDescendants()
					table.insert(listOrIgnoreDescendantsInstance, hit)
					PrintDebug("Stock cast detected, transformed cast into blacklist cast and added " .. tostring(hit) .. " to blacklist temporarily.")
				end
				
				-- So now just cast again!
				-- Cast with 0 deltaTime and from the prespecified point (this saves a smidge of performance since we don't need to try to recalculate a position value that will come out to be the same thing.)
				PrintDebug("Recasting for pierce...")
				Fire(0, at)
				
				-- And exit the function here too.
				return
			end
		end
		
		-- Now if we get here we need to reset the state. If we didn't have a custom state this does nothing (which is okay)
		if (listOrIgnoreDescendantsInstance ~= originalList or castFunction ~= originalCastFunction) then
			PrintDebug("Restored list/ignoredescendantsinstance and/or castFunction to the user-defined state as the latest pierce was completed.")
		end
		listOrIgnoreDescendantsInstance = originalList
		castFunction = originalCastFunction
					
		distanceTravelled = distanceTravelled + displacement.Magnitude
		
		if distanceTravelled > distance then
			connection:Disconnect()
			rayHitEvent:Fire(nil, lastPoint, nil, nil, cosmeticBulletObject)
		end
	end
	
	connection = targetEvent:Connect(Fire)
end

local function BaseFireMethod(self, origin, directionWithMagnitude, velocity, cosmeticBulletObject, ignoreDescendantsInstance, ignoreWater, bulletAcceleration, list, isWhitelist, canPierceFunction)
	MandateType(origin, "Vector3", "origin")
	MandateType(directionWithMagnitude, "Vector3", "directionWithMagnitude")
	assert(typeof(velocity) == "Vector3" or typeof(velocity) == "number", ERR_INVALID_TYPE:format("velocity", "Variant<Vector3, number>", typeof(velocity))) -- This one's an odd one out.
	MandateType(cosmeticBulletObject, "Instance", "cosmeticBulletObject", true)
	MandateType(ignoreDescendantsInstance, "Instance", "ignoreDescendantsInstance", true)
	MandateType(ignoreWater, "boolean", "ignoreWater", true)
	MandateType(bulletAcceleration, "Vector3", "bulletAcceleration", true)
	MandateType(list, "table", "list", true)
	-- isWhitelist is strictly internal so it doesn't need to get sanity checked, because last I checked, I'm not insane c:
	-- ... I hope
	-- However, as of Version 9.0.0, a pierce function can be specified
	MandateType(canPierceFunction, "function", "canPierceFunction", true)

	-- Now get into the guts of this.
	local castFunction = Cast
	local ignoreOrList = ignoreDescendantsInstance
	if list ~= nil then
		ignoreOrList = list
		if isWhitelist then
			castFunction = CastWithWhitelist
		else
			castFunction = CastWithBlacklist
		end
	end
	
	SimulateCast(origin, directionWithMagnitude, velocity, castFunction, self.LengthChanged, self.RayHit, cosmeticBulletObject, ignoreOrList, ignoreWater, bulletAcceleration, canPierceFunction)
end

-----------------------------------------------------------
------------------------- EXPORTS -------------------------
-----------------------------------------------------------

-- Constructor.
function FastCast.new()
	return setmetatable({
		LengthChanged = Signal:CreateNewSignal(),
		RayHit = Signal:CreateNewSignal()
	}, FastCast)
end

-- Fire with stock ray
function FastCast:Fire(origin, directionWithMagnitude, velocity, cosmeticBulletObject, ignoreDescendantsInstance, ignoreWater, bulletAcceleration, canPierceFunction)
	assert(getmetatable(self) == FastCast, ERR_NOT_INSTANCE:format("Fire", "FastCast.new()"))
	BaseFireMethod(self, origin, directionWithMagnitude, velocity, cosmeticBulletObject, ignoreDescendantsInstance, ignoreWater, bulletAcceleration, nil, nil, canPierceFunction)
end

-- Fire with whitelist
function FastCast:FireWithWhitelist(origin, directionWithMagnitude, velocity, whitelist, cosmeticBulletObject, ignoreWater, bulletAcceleration, canPierceFunction)
	assert(getmetatable(self) == FastCast, ERR_NOT_INSTANCE:format("FireWithWhitelist", "FastCast.new()"))
	BaseFireMethod(self, origin, directionWithMagnitude, velocity, cosmeticBulletObject, nil, ignoreWater, bulletAcceleration, whitelist, true)
end

-- Fire with blacklist
function FastCast:FireWithBlacklist(origin, directionWithMagnitude, velocity, blacklist, cosmeticBulletObject, ignoreWater, bulletAcceleration, canPierceFunction)
	assert(getmetatable(self) == FastCast, ERR_NOT_INSTANCE:format("FireWithBlacklist", "FastCast.new()"))
	BaseFireMethod(self, origin, directionWithMagnitude, velocity, cosmeticBulletObject, nil, ignoreWater, bulletAcceleration, blacklist, false)
end

-- Export
return FastCast