-- Maiden of Equilibrium
-- Rush Duel custom card: 190019227
-- [REQUIREMENT] Shuffle 2 LIGHT and/or DARK monsters from your GY into the Deck.
-- [EFFECT] Choose 1 face-up monster your opponent controls; it loses ATK and
--          DEF equal to half its current ATK (rounded down).

local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK|CATEGORY_ATKCHANGE|CATEGORY_DEFCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- LIGHT and DARK may be mixed. Both selected monsters must be able to return.
function s.reqfilter(c)
    return c:IsMonster()
        and c:IsAttribute(ATTRIBUTE_LIGHT|ATTRIBUTE_DARK)
        and c:IsAbleToDeck()
end

function s.targetfilter(c)
    return c:IsFaceup() and c:IsMonster()
end

-- Rush Duel requirements are checked when activation is offered, and are
-- actually performed at the start of the operation (as in official Rush scripts).
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.reqfilter),tp,LOCATION_GRAVE,0,2,nil)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.targetfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- REQUIREMENT: Return exactly two LIGHT/DARK monsters to the Deck.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local rg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.reqfilter),tp,LOCATION_GRAVE,0,2,2,nil)
    if #rg~=2 then return end
    Duel.HintSelection(rg)
    if Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,REASON_COST)~=2 then return end

    -- EFFECT: Choose one face-up opposing monster (does not target in Rush).
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectMatchingCard(tp,s.targetfilter,tp,0,LOCATION_MZONE,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end
    Duel.HintSelection(g)

    -- The same value is subtracted from both ATK and DEF.
    -- No "until the end of this turn" duration was specified, so the
    -- reduction remains while that monster stays face-up on the field.
    local reduction=math.floor(math.max(0,tc:GetAttack())/2)
    if reduction==0 then return end

    local c=e:GetHandler()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(-reduction)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    tc:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    e2:SetValue(-reduction)
    e2:SetReset(RESET_EVENT|RESETS_STANDARD)
    tc:RegisterEffect(e2)
end
