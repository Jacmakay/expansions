-- Los Stream Coredae
-- Custom EDOPro Rush Duel card
-- Card ID: 190019236
-- Level 4 / WIND / Sea Serpent / Effect / ATK 500 / DEF 1000
--
-- [REQUIREMENT] During the turn you Normal or Special Summon this card,
-- send the top 2 cards of your Deck to the Graveyard.
-- [EFFECT] Special Summon 1 Level 5 or higher WIND Sea Serpent monster
-- from your Graveyard. Then, if it is Level 8 or higher, you can add
-- 1 "Los Stream Extreme" (190019239) from your Graveyard to your hand.

local s,id=GetID()
local LOS_STREAM_EXTREME=190019239
s.listed_names={LOS_STREAM_EXTREME}

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DECKDES|CATEGORY_SPECIAL_SUMMON|CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1) -- Rush Duel: once per turn, per face-up copy
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Only on the turn THIS copy was Normal or Special Summoned.
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return (c:IsSummonType(SUMMON_TYPE_NORMAL) and c:IsStatus(STATUS_SUMMON_TURN))
        or c:IsStatus(STATUS_SPSUMMON_TURN)
end

-- Send the top 2 cards as the Requirement, before determining which
-- monster can be revived. The sent cards can become valid choices.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2
    end
    Duel.DisableShuffleCheck()
    local g=Duel.GetDecktopGroup(tp,2)
    Duel.SendtoGrave(g,REASON_COST)
end

-- A properly summoned Fusion/Ritual monster in the GY is allowed if
-- EDOPro confirms that this effect may Special Summon it.
function s.spfilter(c,e,tp)
    return c:IsMonster()
        and c:IsLevelAbove(5)
        and c:IsAttribute(ATTRIBUTE_WIND)
        and c:IsRace(RACE_SEASERPENT)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end

function s.thfilter(c)
    return c:IsCode(LOS_STREAM_EXTREME) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- No GY candidate is required before the Requirement: the cards
    -- milled from the Deck may provide one during resolution.
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local filter=aux.NecroValleyFilter(s.spfilter)
    if not Duel.IsExistingMatchingCard(filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) then
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local sc=sg:GetFirst()
    if not sc then return end
    if Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP_ATTACK)==0 then
        return
    end

    -- The recovery is optional and happens only if the monster was
    -- successfully Special Summoned and is Level 8 or higher.
    if not sc:IsLevelAbove(8)
        or not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
        or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        return
    end

    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
    end
end
