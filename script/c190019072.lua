--U-T-W Abad
--ID: 190019072
local s,id=GetID()

function s.initial_effect(c)
	--[REQUIREMENT] Send the top 2 cards of your Deck to the Graveyard.
	--[EFFECT] Increase this card's Level by 8, then Fusion Summon
	--a Level 8 or higher Galaxy or Magical Knight Fusion Monster,
	--using monsters from your hand or field as material.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LVCHANGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2
	end
	Duel.DiscardDeck(tp,2,REASON_COST)
end

--Fusion Monster must be Level 8+ and Galaxy or Magical Knight
function s.fusfilter(c)
	return c:IsType(TYPE_FUSION)
		and c:IsLevelAbove(8)
		and (c:IsRace(RACE_GALAXY) or c:IsRace(RACE_MAGICALKNIGHT))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end

	--Increase this card's Level by 8
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(8)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)

	--Then Fusion Summon using monsters from the hand or field
	if not Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil) then return end
	Fusion.SummonEffOP({
		fusfilter=s.fusfilter,
		matfilter=function(mc) return mc:IsLocation(LOCATION_HAND|LOCATION_MZONE) end,
		extrafil=function(e,tp,mg)
			return Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
		end,
		extraop=function(e,tc,tp,sg)
			Duel.SendtoGrave(sg,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
		end
	})(e,tp,eg,ep,ev,re,r,rp)
end
