-- Harbinger of Tides Truth Heart Aoi
-- Custom EDOPro / Rush Duel card
-- ID: 190019218
local s,id=GetID()

function s.initial_effect(c)
    -- [REQUIREMENT] Shuffle 2 WATER monsters from your GY into the Deck.
    -- [EFFECT] Destroy 1 card on the field (optionally 2 if a 0 ATK
    -- monster was shuffled). Protect this card through the opponent's turn.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Only WATER monsters that can actually be shuffled back may be selected.
function s.costfilter(c)
    return c:IsMonster() and c:IsAttribute(ATTRIBUTE_WATER)
        and c:IsAbleToDeckAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,2,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
    -- Remember if one of the TWO selected WATER monsters had 0 ATK.
    local zero=g:IsExists(function(c) return c:GetAttack()==0 end,1,nil)
    e:SetLabel(zero and 1 or 0)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.desfilter(c)
    return c:IsDestructable()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
    end
    -- No targets are chosen until resolution.
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if #g>0 then
        local maxct=1
        if e:GetLabel()==1 and #g>=2 then
            maxct=2
        end
        -- 2 cards is optional when a shuffled monster had 0 ATK.
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,
            LOCATION_ONFIELD,LOCATION_ONFIELD,1,maxct,nil)
        if #dg>0 then
            Duel.Destroy(dg,REASON_EFFECT)
        end
    end

    -- The protection lasts until the END of the opponent's next turn:
    -- two End Phases, including this turn's End Phase.
    if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
    local reset=RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END

    -- Cannot be destroyed by effects.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetValue(1)
    e1:SetReset(reset,2)
    c:RegisterEffect(e1)

    -- Cannot be returned to the hand.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_TO_HAND)
    e2:SetValue(1)
    e2:SetReset(reset,2)
    c:RegisterEffect(e2)

    -- Cannot be returned to the Deck.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_CANNOT_TO_DECK)
    e3:SetValue(1)
    e3:SetReset(reset,2)
    c:RegisterEffect(e3)
end
