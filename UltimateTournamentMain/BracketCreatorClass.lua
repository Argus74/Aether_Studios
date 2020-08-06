local BracketCreatorClass = {}

BracketCreatorClass.__index = BracketCreatorClass

--Constructor for the bracket class
function BracketCreatorClass:new(participantsTable)
	
	local BracketData = {}
	local metaTable = setmetatable(BracketData,BracketCreatorClass)
	
	BracketData.Size = #participantsTable -- holds the amount of Players participating in the tournament
	BracketData.Entrants = participantsTable -- holds the table of Players participating in the tournament
	
	return BracketData
end

--generates byes in place of players who are absent from the bracket initialization
function changeIntoBye(seed,participating)
	local bye = nil
	if seed <= participating then
		return seed
	else
		return bye
	end
end

--Generates the seeding
function BracketCreatorClass:GenerateNumberSeeding(entr)
	local numParticipants = #entr
	local rounds = math.ceil(math.log(numParticipants)/math.log(2))
	local bracketSize = math.pow(2,rounds)
	local requiredByes = (bracketSize - numParticipants)
		
	local matches = {{1,2}}
	local round = 1
		
	while (round < rounds) do
		local roundMatches = {}
		local sum = math.pow(2,round + 1) + 1
		local k = 0
		while (k< #matches) do
			local i = k+1
			local home = changeIntoBye(matches[i][1],numParticipants)
			local away = changeIntoBye(sum - matches[i][1],numParticipants)
			table.insert(roundMatches,#roundMatches + 1,{home,away})
			home = changeIntoBye(sum - matches[i][2],numParticipants)
			away = changeIntoBye(matches[i][2],numParticipants)
			table.insert(roundMatches,#roundMatches + 1,{home,away})
			k = k + 1
		end
		matches = roundMatches
		round = round + 1
	end
	return matches
end

function BracketCreatorClass:GeneratePlayerSeeding(numberSeeding,entr)
	local playerSeeding = {}
	for i,v in ipairs(numberSeeding) do 
		local pos1,pos2 = unpack(v)
		table.insert(playerSeeding,#playerSeeding + 1,{entr[pos1],entr[pos2]})
	end
	return playerSeeding
end


return BracketCreatorClass

