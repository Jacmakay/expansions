-- Void War Ritual (Rush Duel Edition)
-- Card ID: 190019023
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_names={190019022} -- War Voidvelg Garlandolf

-- Material Filter
function s.matfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsLevelAbove(1) and c:IsAbleToGrave()
end

-- Target Ritual Monster Filter
function s.ritfilter(c,e,tp)
	return c:IsCode(190019022) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true,POS_FACEUP)
end

-- Custom Select Recursive function
function s.check_recursive(g,tp,current_sum,target_sum,available_mats)
	if current_sum >= target_sum then return true end
	for i = 1, #available_mats do
		local c = available_mats[i]
		if not g:IsContains(c) then
			g:AddCard(c)
			if s.check_recursive(g,tp,current_sum+c:GetLevel(),target_sum,available_mats) then
				return true
			end
			g:RemoveCard(c)
		end
	end
	return false
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		local ritg=Duel.GetMatchingGroup(s.ritfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		if #ritg==0 or #mg==0 then return false end
		
		-- Look for any valid subset that sums to >= 9
		local check_g=Group.CreateGroup()
		local available_mats={}
		for tc in aux.Next(mg) do table.insert(available_mats,tc) end
		return s.check_recursive(check_g,tp,0,9,available_mats)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	local ritg=Duel.GetMatchingGroup(s.ritfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #ritg==0 or #mg==0 then return end
	
	-- Select the materials manually
	local available_mats={}
	for tc in aux.Next(mg) do table.insert(available_mats,tc) end
	
	local select_g=Group.CreateGroup()
	local current_sum=0
	
	while current_sum<9 do
		local valid_choices=Group.CreateGroup()
		for _,c in ipairs(available_mats) do
			if not select_g:IsContains(c) then
				-- Check if choosing this can lead to a valid combination
				local test_g=select_g:Clone()
				test_g:AddCard(c)
				if s.check_recursive(test_g,tp,current_sum+c:GetLevel(),9,available_mats) then
					valid_choices:AddCard(c)
				end
			end
		end
		
		if #valid_choices==0 then return end -- Fallback safetynet
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sc=valid_choices:Select(tp,1,1,nil):GetFirst()
		select_g:AddCard(sc)
		current_sum = current_sum + sc:GetLevel()
	end
	
	if #select_g>0 and Duel.SendtoGrave(select_g,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if tc then
			tc:SetMaterial(select_g)
			if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)>0 then
				tc:CompleteProcedure()
			end
		end
	end
end
