local ContentProvider = game:GetService("ContentProvider")

local gameModeAudioAssets = {
	DeathMatchAudio = 1843324336,
}

local AudioHandler = {}

AudioHandler.preloadAudio = function(audioString)
	local audioAssets = {}
 
	-- Add new "Sound" assets to "audioAssets" array
	local audioID = gameModeAudioAssets[audioString]
	local audioInstance = Instance.new("Sound")
	audioInstance.SoundId = "rbxassetid://" .. audioID
	audioInstance.Name = audioString
	audioInstance.Looped = true
	audioInstance.Parent = game.Workspace
	table.insert(audioAssets, audioInstance)
	local success, assets = pcall(function()
		ContentProvider:PreloadAsync(audioAssets)
	end)
end

AudioHandler.playAudio = function(assetName)
	local audio = game.Workspace:FindFirstChild(assetName)
	if not audio then
		warn("Could not find audio asset: " .. assetName)
		return
	end
	if not audio.IsLoaded then
		audio.Loaded:wait()
	end
	audio:Play()
	return audio
end

return AudioHandler
