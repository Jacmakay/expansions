-- Los Stream Gameciel
-- EDOPro Custom Rush Duel card
-- Card ID: 190019234
-- WIND / Sea Serpent / Effect - Level 2 - ATK 500 / DEF 1000
--
-- [REQUIREMENT] During the turn you Normal Summon this card,
-- send the top 2 cards of your Deck to the Graveyard.
-- [EFFECT] Add 1 WIND Sea Serpent monster from your Graveyard to your hand.

local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DECKDES|CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1) -- Rush Duel: once per turn per face-up copy
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- This specific monster must have been Normal Summoned this turn.
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if RD and RD.IsSummonTurn then
        return RD.IsSummonTurn(c)
    end
    return c:IsSummonType(SUMMON_TYPE_NORMAL)
        and c:IsStatus(STATUS_SUMMON_TURN)
end

-- [REQUIREMENT] Send exactly the top 2 cards of your Deck to the GY.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2
    end
    Duel.DisableShuffleCheck()
    local g=Duel.GetDecktopGroup(tp,2)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.thfilter(c)
    return c:IsMonster()
        and c:IsAttribute(ATTRIBUTE_WIND)
        and c:IsRace(RACE_SEASERPENT)
        and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- Don't demand a target before paying the Requirement:
    -- the 2 milled cards may themselves become valid recovery choices.
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
    end
end
