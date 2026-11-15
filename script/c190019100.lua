-- The Shinigami From Afar - Born in the Dark
-- Rush Duel custom card
-- Card ID: 190019100

local s,id=GetID()

local FINAL_GETSUGA_TENSHO=190019113
local PIERCING_GETSUGA=190019114

function s.initial_effect(c)
	-- Register that this card was Normal Summoned this turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SUMMON_SUCCESS)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)

	-- [REQUIREMENT]
	-- During the turn this card was Normal Summoned,
	-- send the top card of your Deck to the Graveyard.
	--
	-- [EFFECT]
	-- This card gains 400 ATK until the end of this turn.
	-- Then, if you have a Level 7 or higher Warrior in your GY,
	-- you can add 1 "The Final Getsuga Tensho" or
	-- 1 "Piercing Getsuga" from your GY to your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(
		id,
		RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,
		0,
		1
	)
end

-- Effect can only be used during the turn this card was Normal Summoned
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end

-- [REQUIREMENT] Send the top card of your Deck to the Graveyard
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=1
	end
	Duel.DisableShuffleCheck()
	Duel.SendtoGrave(Duel.GetDecktopGroup(tp,1),REASON_COST)
end

-- Level 7 or higher Warrior-Type monster in your Graveyard
function s.highwarriorfilter(c)
	return c:IsMonster()
		and c:IsRace(RACE_WARRIOR)
		and c:IsLevelAbove(7)
end

-- "The Final Getsuga Tensho" or "Piercing Getsuga"
function s.thfilter(c)
	return c:IsCode(FINAL_GETSUGA_TENSHO,PIERCING_GETSUGA)
		and c:IsAbleToHand()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end

	-- This card gains 400 ATK until the end of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(400)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)

	-- Then, if you have a Level 7 or higher Warrior in your GY,
	-- you can add 1 of the listed Getsuga cards from your GY to your hand
	if Duel.IsExistingMatchingCard(
			s.highwarriorfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(
			s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then

		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(
			tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil
		)

		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
