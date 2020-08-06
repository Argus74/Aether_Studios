local gunHoldingAnim = script.Parent.GunHoldAnimation

local AnimationHandler = {}
	
	function AnimationHandler.PlayAnimation(anim,humanoid,priority,animationTrack)
		animationTrack = humanoid:LoadAnimation(anim)
		animationTrack.Priority = priority
		animationTrack:Play()
		
	end
	
	function AnimationHandler.StopAnimation(animationTrack)
		animationTrack:Stop()
	end
	
return AnimationHandler 
