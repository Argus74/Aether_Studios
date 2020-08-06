local DamageMod= {}

function DamageMod.CalcDmg(Streak,humanoid,dmg)
	if (Streak%1== 0) and (Streak%2 ~= 0) then
		humanoid:TakeDamage(dmg)
	elseif (Streak%2 == 0) then
		humanoid:TakeDamage(dmg)
	end
end


return DamageMod