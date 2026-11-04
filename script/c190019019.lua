-- Card ID: 190019019
-- Void Chaos Ritual (Rush Duel Normal Spell)
local s,id=GetID()
function s.initial_effect(c)
	-- Effect: Ritual Summon Void Chaos Soldier from Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

-- Only include monsters that actually have levels (> 0)
function s.matfilter(c)
	return c:IsAbleToGrave() and c:IsMonster() and c:GetLevel()>0
end

-- Filter checking for Void Chaos Soldier in the EXTRA DECK
function s.tgfilter(c,e,tp,mg)
	if c:GetCode()~=190019018 or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,false,false) then return false end
	return mg:CheckWithSumEqual(Card.GetLevel,10,1,99) or mg:CheckWithSumGreater(Card.GetLevel,10)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	local tc=tg:GetFirst()
	
	if tc then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		
		-- Use the correct standard engine loop for selecting >= 10 levels without locking to exact 10
		local mat=Group.CreateGroup()
		while #mat==0 or mat:GetSum(Card.GetLevel)<10 do
			-- Filter options that can still help reach or exceed 10
			local cg=mg:Filter(function(c)
				local g=mat:Clone()
				g:AddCard(c)
				return g:GetSum(Card.GetLevel)>=10 or mg:IsExists(function(mc)
					local g2=g:Clone()
					g2:AddCard(mc)
					return g2:GetSum(Card.GetLevel)>=10 or (mg-g2):CheckWithSumGreater(Card.GetLevel,10-g2:GetSum(Card.GetLevel))
				end,1,c)
			end,nil)
			
			if #cg==0 then break end
			
			-- Allow completing the selection if the current sum is already 10 or greater
			local select_cancel = mat:GetSum(Card.GetLevel)>=10
			local sg=cg:Select(tp,1,1,select_cancel,nil)
			if not sg or #sg==0 then break end
			
			mat:AddCard(sg:GetFirst())
			mg:RemoveCard(sg:GetFirst())
		end
		
		if #mat>0 and mat:GetSum(Card.GetLevel)>=10 then
			tc:SetMaterial(mat)
			Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)
		end
	end
end
