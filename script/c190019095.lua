--Dominus Emperor Wota
--Rush Duel custom card
--Card ID: 190019095

local s,id=GetID()

local RULE_ID=190019097        -- "I Will Rule"
local FLAG_ID=190019099        -- "Dominus Empire Flag"

function s.initial_effect(c)
    -- Special Summon this card from the hand in face-up Defense Position
    -- if you have a DARK Warrior monster in your Graveyard.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SPSUM_PARAM)
    e1:SetRange(LOCATION_HAND)
    e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- [REQUIREMENT] Shuffle 2 monsters from your Graveyard into the Deck.
    -- [EFFECT] Add 1 "I Will Rule" or "Dominus Empire Flag"
    -- from your Graveyard to your hand.
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK|CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

-- DARK Warrior monster in your Graveyard
function s.spfilter(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_WARRIOR)
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end

-- Monsters eligible to be shuffled into the Deck for the requirement.
function s.cfilter(c)
    return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end

-- Cards that may be recovered.
function s.thfilter(c)
    return c:IsCode(RULE_ID,FLAG_ID) and c:IsAbleToHand()
end

-- Check if the Rush Duel requirement can be fulfilled.
-- The actual requirement is performed during the effect operation.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- [REQUIREMENT]
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
    if #g~=2 then return end
    Duel.HintSelection(g)
    if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=2 then return end

    -- [EFFECT]
    if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,sg)
    end
end
