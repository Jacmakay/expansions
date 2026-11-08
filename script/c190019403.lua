-- Tides Servant Ulpis
-- Custom Rush Duel card ID: 190019403
-- "Cosmic Tag Team" card ID: 190019224

local s,id=GetID()
local COSMIC_TAG_TEAM=190019224

function s.initial_effect(c)
    -- Special Summon this card from the hand by sending 1 OTHER
    -- card from your hand to the GY.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- [REQUIREMENT] Shuffle 3 Cyberse monsters from your GY into the Deck.
    -- [EFFECT] Destroy 1 card in your opponent's Spell & Trap Zones,
    -- then add 1 "Cosmic Tag Team" from your GY to your hand.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DESTROY|CATEGORY_TOHAND|CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

-- Self-Special Summon: the sent card must be different from Ulpis itself.
function s.spfilter(c)
    return c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,c)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_COST)
    end
end

-- Rush Duel requirement: check here; perform it at resolution.
function s.tdfilter(c)
    return c:IsMonster() and c:IsRace(RACE_CYBERSE)
        and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,3,nil)
    end
end

-- The Field Zone is excluded; only Spell & Trap Zones can be destroyed.
function s.desfilter(c)
    return c:GetSequence()~=5 and c:IsDestructable()
end
function s.thfilter(c)
    return c:IsCode(COSMIC_TAG_TEAM) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_SZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_SZONE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Requirement: return exactly 3 Cyberse monsters to the Deck.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local rg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
    if #rg~=3 then return end
    Duel.HintSelection(rg)
    if Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_COST)~=3 then return end

    -- Effect: destroy 1 card in an opponent's Spell & Trap Zone.
    if not Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_SZONE,1,nil) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_SZONE,1,1,nil)
    if #dg==0 or Duel.Destroy(dg,REASON_EFFECT)==0 then return end

    -- Then recover "Cosmic Tag Team" if one is still in your GY.
    local thfilter=aux.NecroValleyFilter(s.thfilter)
    if not Duel.IsExistingMatchingCard(thfilter,tp,LOCATION_GRAVE,0,1,nil) then
        return
    end
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local hg=Duel.SelectMatchingCard(tp,thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #hg>0 and Duel.SendtoHand(hg,tp,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,hg)
    end
end
