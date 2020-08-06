local InputHandler = {}

InputHandler.Actions = {
	ACTION_RUN = {
		Method = function(player)
			player.Humanoid.WalkSpeed = 28
		end
	}	
}
return InputHandler
