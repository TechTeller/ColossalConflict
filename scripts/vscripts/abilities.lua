function ChopTree( keys )
	local unit = keys.caster
	local caster = unit:GetOwner()
	local data  = nil
	if caster:GetTeam() == DOTA_TEAM_GOODGUYS then
		data = GetRadiantResources()
	elseif caster:GetTeam() == DOTA_TEAM_BADGUYS then
		data = GetDireResources()
	end
	data["lumber"] = LUMBER_PER_TREE
	print ('Casted Ability debug #1')
end

function DestroyTree( keys )
	local caster = keys.caster
	local point = keys.target_points[1]
	caster:AddAbility("ability_destroytree")
	local ab = caster:FindAbilityByName("ability_destroytree")
	ab:SetLevel( 1 ) 

	caster:CastAbilityOnPosition( point, ab, 0)
	print('Casted ability ability_destroytree')
end