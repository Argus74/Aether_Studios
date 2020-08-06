--[[
____________________________________________________________________________________________________________________________________________________________________________

	Created by Swordphin123 - 2020. If you have any questions, feel free to message me on DevForum. Credits not neccessary but is appreciated.
	
	[ How To Use - Quick Start Guide ]
	
		1. Insert Attachments to places where you want your "hitbox" to be. For swords, I like to have attachments 1 stud apart and strung along the blade.
		2. Name those Attachments "DmgPoint" (so the script knows). You can configure what name the script will look for in the variables below.
		3. Open up a script. As an example, maybe we have a sword welded to the character or as a tool. Require this, and initialize:
				
				* Example Code
					
					local Damage = 10
					local Hitbox = RaycastHitbox:Initialize(Character, {Character})
					
					Hitbox.OnHit:Connect(function(hit, humanoid)
						print(hit.Name)
						humanoid:TakeDamage(Damage)
					end)
					
					Hitbox:HitStart()
					wait(2)
					Hitbox:HitStop()
		
		4. Profit. Refer to the API below for more information.
				
	
____________________________________________________________________________________________________________________________________________________________________________

	[ RaycastHitBox API ]
	
		* local RaycastHitbox = require(RaycastHitbox) ---Duh
				--- To use, insert this at the top of your scripts or wherever.
				
				
		
		* RaycastHitbox:Initialize(Instance model, table ignoreList)
				Description
					--- Preps the model and recursively finds attachments in it so it knows where to shoot rays out of later.
				Arguments
					--- Instance model: Model instance (Like your character, a sword model, etc). May support Parts later.
					--- table ignoreList: Raycast takes in ignorelists. Heavily recommended to add in a character so it doesn't hurt itself in its confusion.
				Returns
					Instance HitboxObject 
					
		* RaycastHitbox:Deinitialize(Instance model)
				Description
					--- Removes references to the attachments and garbage collects values from the original init instance. Great if you are deleting the hitbox soon.
					--- The script will attempt to run this function automatically if the model ancestry was changed.
				Arguments
					--- Instance model: Same model that you initialized with earlier. Will do nothing if model was not initialized.
						
		* RaycastHitModule:GetHitbox(Instance model)
				Description
					--- Gets the HitboxObject if it exists.
				Returns
					--- HitboxObject if found, else nil
					
		* RaycastHitModule:DebugMode(boolean true/false)
				Description
					--- Turn the RaycastHitboxModule DebugRays on or off during runtime. All hitboxes will be shown at runtime if true.
				Arguments
					--- boolean: true for on, false for off. Defaults to off if given a nil value.
					
					
					
					
					
					
					
					
		
		* HitboxObject:PartMode(boolean true/false)
				Description
					--- If true, OnHit will return every hit part (in respect to the hitbox's ignore list), regardless if it's ascendant has a humanoid or not. Defaults false.
					--- OnHit will no longer return a humanoid so you will have to check it. Performance may suffer if there are a lot of parts, use only if necessary.
				Arguments
					--- boolean: true for parts return, false for off.
		
		* HitboxObject:SetPoints(Instance part, table vectorPoints)
				Description
					--- Merges existing Hitbox points with new Vector3 values relative to a part position. This part can be a descendent of your original Hitbox model or can be
						an entirely different instance that is not related to the hitbox (example: Have a weapon with attachments and you can then add in more vector3 
						points without instancing new attachments, great for dynamic hitboxes)
				Arguments
					--- Instance part: Sets the part that these vectorPoints will move in relation to the part's origin using Vector3ToWorldSpace
					--- table vectorPoints: Table of vector3 values.
					
		* HitboxObject:RemovePoints(Instance part, table vectorPoints)
				Description
					--- Remove given Vector3 values provided the part was the same as the ones you set in SetPoints
				Arguments
					--- Instance part: Sets the part that these vectorPoints will be removed from in relation to the part's origin using Vector3ToWorldSpace
					--- table vectorPoints: Table of vector3 values.
		
		* HitboxObject:LinkAttachments(Instance attachment1, Instance attachment2)
				Description
					--- Set two attachments to be in a link. The Raycast module will raycast between these two points.
				Arguments
					--- Instance attachment1/attachment2: Attachment objects
					
		* HitboxObject:UnlinkAttachments(Instance attachment1)
				Description
					--- Removes the link of an attachment. Only needs the primary attachment (argument 1 of LinkAttachments) to work. Will automatically sever the connection
						to the second attachment.
				Arguments
					--- Instance attachment1: Attachment object
				
		* HitboxObject:HitStart([Optional Number damage])
				Description
					--- Starts drawing the rays. Will only damage the target once. Call HitStop to reset the target pool so you can damage the same targets again.
						If HitStart hits a target(s), OnHit event will be called.
				Arguments
					--- Number damage [Optional]: Immediately damage the humanoid after scoring a hit, you can also leave it blank
					
		* HitboxObject:HitStop()
				Description
					--- Stops drawing the rays and resets the target pool. Will do nothing if no rays are being drawn from the initialized model.

		* HitboxObject.OnHit:Connect(returns: Instance part, returns: Instance humanoid)
				Description
					--- If HitStart hits a fresh new target, OnHit returns information about the hit target
				Arguments
					--- Instance part: Returns the part that the rays hit first
					--- Instance humanoid: Returns the Humanoid object 
		
		
____________________________________________________________________________________________________________________________________________________________________________

	[ Troubleshooting ]
	
	Q1 - Rays are not coming out / DebugRays not showing any rays
			--- Make sure you initialized an instance and that it contains parts. These parts should contain attachments
				named after the AttachmentName variable below.
			--- Pay attention to what the output says.
				
	Q2 - Sometimes my rays "lag" or they do not come out soon enough
			--- This is a known issue and I've been actively trying to investigate the cause of it. Though it doesn't really happen often enough to be a concern.
			
	Q3 - Why do I deal more and more damage the more times I hit my humanoid enemy?
			--- You should always disconnect your OnHit events every time you are done using them (preferably alongside HitStop). Here is a barebones example, 
				it's using a loop but you should also take care when doing it in functions or server/client events since it's the same.
			
			BAD:
				while true do
					Hitbox:HitStart()
					Hitbox.OnHit:Connect(function(hit, humanoid)	--- This connection line will not be garbage collected, and will continue to up the damage by 10 per 3 seconds
						humanoid:TakeDamage(10)
					end)
					wait(3)
					Hitbox:HitStop()
				end
			
			GOOD:
				while true do
					Hitbox:HitStart()
					
					local MyHitboxConnection
					MyHitboxConnection = Hitbox.OnHit:Connect(function(hit, humanoid)	--- Save it to a variable
						humanoid:TakeDamage(10)
					end)
					
					wait(3)
					Hitbox:HitStop()
					
					MyHitboxConnection:Disconnect()		--- Disconnects it when we are done with it
				end
____________________________________________________________________________________________________________________________________________________________________________

	I do not recommend editing the mayhem below unless you know what you're doing.
____________________________________________________________________________________________________________________________________________________________________________

--]]

local AttachmentName = "DmgPoint"			--- The attachment names the script will look for. This is where the rays will shoot out of.
local DontCheckForTransparency = true		--- Normally the script won't fire rays if the parent part the attachment is in is transparent (== 1). You can set this to true to override it.
local DebugRays = true						--- Highly recommended to test your rays so turn this to true to see where your rays are shooting from. Turn it off in production.

-------------------------------------------------

local RaycastHitModule = {
	Version = "1.53 Beta"
}

-------------------------------------------------

local Debris = game:GetService("Debris")
local Insta = Instance.new

local function assert(condition, m)
	if not condition == true then
		warn(m)
	end
end

local function CheckForTransparency(Point)
	if DontCheckForTransparency or (Point.RelativePart and Point.RelativePart.Transparency < 1) or (typeof(Point.Attachment) == "Instance" and Point.Attachment.Parent and Point.Attachment.Parent.Transparency < 1) then
		return true
	end
	return false
end

local function DrawRays(Distance, NewCFrame)
	local beam = Insta("Part")
	beam.BrickColor = BrickColor.new("Bright red")
	beam.Material = Enum.Material.Neon
	beam.Anchored = true
	beam.CanCollide = false
	beam.Name = "RaycastHitboxDebugPart"
	
	local Dist = (Distance).magnitude
	beam.Size = Vector3.new(0.1, 0.1, Dist)
	beam.CFrame = NewCFrame * CFrame.new(0, 0, -Dist / 2)
	
	beam.Parent = workspace.Terrain
	Debris:AddItem(beam, 1)
end

-------------------------------------------------

local RunService = game:GetService("RunService")

local CFrameN = CFrame.new
local RayN = Ray.new

local Instances = {}
local Hitboxing = {}
Hitboxing.__index = Hitboxing

function Hitboxing.__tostring(self)
	return self.Object.Name
end

function Hitboxing:FindAttachments(model)
	local Count = 0
	local TransparencyDetected = false
	local Model = model:GetDescendants()
	
	for _, Attachments in ipairs(Model) do
		if Attachments:IsA("Attachment") and Attachments.Name == AttachmentName then
			Count = Count + 1
			self.Points[Attachments] = {
				RelativePart = nil,
				Attachment = Attachments,
				LastPosition = nil
			}
			if not CheckForTransparency(self.Points[Attachments]) then
				TransparencyDetected = true
			end
		end
	end
	
	if Count == 0 then
		warn("\n[[RAYCAST WARNING]]\nNo attachments with the name '" ..AttachmentName.. "' were found in " ..model.Name..". No raycasts will be drawn. Can be ignored if you are using SetPoints.")
	else
		if TransparencyDetected then
			warn("\n[[RAYCAST WARNING]]\nAttachments were found in a transparent part. Raycasts will not draw from transparent parts. If this was unintentional, consider changing the variable DontCheckForTransparency to true.")
		end
		print("\n[[RAYCAST MESSAGE]]\n\nCreated Hitbox for Object " ..model.Name..". Attachments found: " .. tostring(Count) .. "\n")
	end
	
	table.insert(self.Ignore, workspace.Terrain)
end

function Hitboxing:SetPoints(partInstance, vectorPoints)
	if partInstance and partInstance:IsA("BasePart") then
		for _, vectors in ipairs(vectorPoints) do
			if typeof(vectors) == "Vector3" then
				self.Points[vectors] = {
					RelativePart = partInstance,
					Attachment = vectors,
					LastPosition = nil
				}
			end
		end
	end
end

function Hitboxing:RemovePoints(partInstance, vectorPoints)
	if partInstance then
		if partInstance:IsA("BasePart") or partInstance:IsA("MeshPart") then
			for _,Points in pairs(self.Points) do
				for _, vectors in ipairs(vectorPoints) do
					if typeof(Points.Attachment) == "Vector3" and Points.Attachment == vectors and Points.RelativePart == partInstance then
						self.Points[Points.Attachment] = nil
					end
				end
			end
		end
	end
end

function Hitboxing:LinkAttachments(primaryAttachment, secondaryAttachment)
	if primaryAttachment:IsA("Attachment") and secondaryAttachment:IsA("Attachment") then
		self.Points[primaryAttachment] = {
			RelativePart = nil,
			Attachment = primaryAttachment,
			Attachment0 = secondaryAttachment,
			LastPosition = nil
		}
	end
end

function Hitboxing:UnlinkAttachments(primaryAttachment)
	if self.Points[primaryAttachment] ~= nil then
		self.Points[primaryAttachment] = nil
	end
end

function Hitboxing:PartMode(bool)
	assert(typeof(bool) == "boolean")
	self.SearchPart = bool
end

function Hitboxing:HitStart(Damage)
	if self.Points == nil then
		print("Hitbox does not exist")
	else
		if self.Connection then
			self.Connection:Disconnect()
			self.Connection = nil
		end
		self.Connection = RunService.Heartbeat:Connect(function()
			local Target = nil
			for _,Point in pairs(self.Points) do
				if Point ~= nil and CheckForTransparency(Point) then
					local MissingRelative = false
					if self.Connection then
						local WorldPositionOfRelative = Point.RelativePart and Point.RelativePart.Position + Point.RelativePart.CFrame:VectorToWorldSpace(Point.Attachment)
						
						if not Point.LastPosition and Point.Attachment0 == nil then
							if WorldPositionOfRelative then
								Point.LastPosition = WorldPositionOfRelative
							else
								if typeof(Point.Attachment) == "Instance" then
									Point.LastPosition = Point.Attachment.WorldPosition
								else
									MissingRelative = true		--- If Setpoints was used and it's relative part was removed, then skip
									self.Points[Point.Attachment] = nil
								end
							end
						end
						
						if not MissingRelative then
							local ray = RayN(
								Point.Attachment0 ~= nil and Point.Attachment.WorldPosition or Point.LastPosition, 
								Point.Attachment0 ~= nil and Point.Attachment0.WorldPosition - Point.Attachment.WorldPosition or
								(WorldPositionOfRelative and WorldPositionOfRelative - (Point.LastPosition and Point.LastPosition or Vector3.new()) 
								or Point.Attachment.WorldPosition - Point.LastPosition)
							)
							local obj, pos = workspace:FindPartOnRayWithIgnoreList(ray, self.Ignore)
							
							if DebugRays then
								DrawRays(
									Point.Attachment0 ~= nil and Point.Attachment.WorldPosition - Point.Attachment0.WorldPosition or
									(WorldPositionOfRelative and WorldPositionOfRelative - Point.LastPosition or Point.Attachment.WorldPosition - Point.LastPosition),
									Point.Attachment0 ~= nil and CFrameN(Point.Attachment.WorldPosition, Point.Attachment0.WorldPosition) or
									CFrameN(WorldPositionOfRelative and WorldPositionOfRelative or Point.Attachment.WorldPosition, Point.LastPosition)
								)
							end
		
							Point.LastPosition = WorldPositionOfRelative and WorldPositionOfRelative or Point.Attachment.WorldPosition --- Save the last position in frame
							
							if obj then
								if not self.SearchPart then
									if obj.Parent and (not self.HitTargets[obj.Parent]) then
										local TargetHumanoid = obj.Parent:FindFirstChildOfClass("Humanoid")
										if TargetHumanoid then
											self.HitTargets[obj.Parent] = true
											self.OnHitEvent:Fire(obj, TargetHumanoid)
											local Dmg = Damage and Damage or 0
											if Dmg > 0 then
												TargetHumanoid:TakeDamage(Dmg)
											end
										end
									end
								else
									if not self.HitTargets[obj] then
										self.HitTargets[obj] = true
										self.OnHitEvent:Fire(obj, nil)
									end
								end
							end
						end
					else
						break
					end
				end
			end
		end)
	end
end

function Hitboxing:HitStop()
	if self.Points == nil then
		print("Hitbox does not exist")
	else
		for _,Point in pairs(self.Points) do
			Point.LastPosition = nil
		end
		self.HitTargets = {}
		if self.Connection then
			self.Connection:Disconnect()
		end
		self.Connection = nil
	end
end

function Hitboxing:Deactivate()
	if self.OnHitEvent then
		self.OnHitEvent:Destroy()
		self.OnHitEvent = nil
	end
	
	if self.Connection then
		self.Connection:Disconnect()
	end

	self.Connection = nil
	self.Object = nil
	self.Points = nil
	self.HitTargets = nil
	self.Ignore = nil
end

-------------------------------------------------

local Players = game:GetService("Players")

function RaycastHitModule:Initialize(instanceObject, ignoreList)
	assert(typeof(instanceObject) == "Instance", "RaycastHitModule requires an Instance")
	
	local Hitbox = Instances[instanceObject]
	if Hitbox then
		print("Hitbox for this Instance exists")
		return Instances[instanceObject]
	else
		local Event = Instance.new("BindableEvent")
		local NewHitbox = setmetatable({
			OnHitEvent = Event,
			OnHit = Event.Event,
			Object = instanceObject,
			SearchPart = false,
			Connection = nil,
			Points = {},
			HitTargets = {},
			Ignore = ignoreList and ignoreList or {}
		}, Hitboxing)
		
		Instances[instanceObject] = NewHitbox		
		Instances[instanceObject]:FindAttachments(instanceObject)
		
		instanceObject.AncestryChanged:Connect(function()
			if Instances[instanceObject] and (not workspace:IsAncestorOf(instanceObject) and not Players:IsAncestorOf(instanceObject)) then
				RaycastHitModule:Deinitialize(instanceObject)
				print("Hitbox Object was deleted")
			end
		end)
		
		return Instances[instanceObject]
	end
end

function RaycastHitModule:Deinitialize(instanceObject)
	assert(typeof(instanceObject) == "Instance", "RaycastHitModule requires an Instance")
	
	local Hitbox = Instances[instanceObject]
	if Hitbox then
		Instances[instanceObject]:HitStop()
		Instances[instanceObject]:Deactivate()
		Instances[instanceObject] = nil
	else
		print("Hitbox does not exist")
	end
end

function RaycastHitModule:GetHitbox(instanceObject)
	return Instances[instanceObject]
end

function RaycastHitModule:DebugMode(boolean)
	DebugRays = boolean == true and true or false
end

return RaycastHitModule
