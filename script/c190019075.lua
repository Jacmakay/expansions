--U-T-W Chainverse
--ID: 190019075
local s,id=GetID()

function s.initial_effect(c)
	--[REQUIREMENT]
	--Send 1 Level 1 or 9 monster from your hand to the GY.
	--[EFFECT]
	--Draw 1 card, then you can add 1 Level 9 monster
	--with a different Attribute than the sent monster from your GY to your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.cfilter(c)
	return c:IsMonster()
		and (c:IsLevel(1) or c:IsLevel(9))
		and c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	e:SetLabel(tc:GetAttribute())
	Duel.SendtoGrave(tc,REASON_COST)
end

function s.thfilter(c,att)
	return c:IsMonster()
		and c:IsLevel(9)
		and not c:IsAttribute(att)
		and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsPlayerCanDraw(tp,1)
	end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end

	local att=e:GetLabel()

	--Optional: add 1 Level 9 monster with a different Attribute
	--from your GY to your hand.
	if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil,att)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(
			tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,att
		)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
