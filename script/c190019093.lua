--Proclaimed One True Ruler
--Card ID: 190019093
local s,id=GetID()

function s.initial_effect(c)
	--Fusion Materials:
	--"Emperor of Dominus" + "Emperor's Finality Blade"
	Fusion.AddProcMix(c,true,true,190019091,190019092)

	--[REQUIREMENT]
	--Send the top 3 cards of your Deck to the Graveyard.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.lightfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
	end
	local g=Duel.GetDecktopGroup(tp,3)
	local light=g:IsExists(s.lightfilter,1,nil)
	e:SetLabel(light and 1 or 0)
	Duel.DisableShuffleCheck()
	Duel.SendtoGrave(g,REASON_COST)
end

function s.desfilter(c)
	return c:IsDestructable()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	--This card can make up to 3 attacks on monsters this turn.
	--EFFECT_EXTRA_ATTACK_MONSTER value 2 = 2 additional monster attacks.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetValue(2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)

	--If at least 1 LIGHT monster was sent by the Requirement,
	--destroy 1 card on the field.
	if e:GetLabel()==1
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,
			LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
