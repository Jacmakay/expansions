-- Faded Memory From Afar - The Dangai Shinigami
-- Rush Duel custom card
-- Card ID: 190019105

local s,id=GetID()

function s.initial_effect(c)
	-- If you have a Level 4 Warrior-Type monster in your Graveyard,
	-- you can Special Summon this card from your hand.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)

	-- [REQUIREMENT]
	-- Send the top 2 cards of your Deck to the Graveyard.
	--
	-- [EFFECT]
	-- Add 1 Level 4 Warrior-Type monster from your Graveyard to your hand,
	-- then this card gains 500 ATK.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

-- Level 4 Warrior in your GY
function s.lv4warrior(c)
	return c:IsMonster()
		and c:IsRace(RACE_WARRIOR)
		and c:IsLevel(4)
end

-- Special Summon procedure from hand
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(
			s.lv4warrior,tp,LOCATION_GRAVE,0,1,nil
		)
end

-- [REQUIREMENT] Send the top 2 cards of your Deck to the Graveyard
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2
	end

	Duel.DisableShuffleCheck()
	local g=Duel.GetDecktopGroup(tp,2)
	Duel.SendtoGrave(g,REASON_COST)
end

function s.thfilter(c)
	return s.lv4warrior(c) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.thfilter,tp,LOCATION_GRAVE,0,1,nil
		)
	end

	Duel.SetOperationInfo(
		0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE
	)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()

	-- Add 1 Level 4 Warrior from your GY to your hand
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(
		tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil
	)

	local tc=g:GetFirst()
	if not tc then return end

	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,tc)

		-- Then, this card gains 500 ATK.
		-- No duration is printed, so the gain remains while this effect
		-- stays applied to this face-up card.
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end
