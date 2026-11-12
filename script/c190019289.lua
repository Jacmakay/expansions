-- Nozett The Ultimate Soul
-- ID: 190019289
-- Rush Duel - Level 10 / LIGHT / Galaxy / Fusion / Effect
-- ATK 2600 / DEF 2400
-- Fusion Materials: "The Luminescent One" (190019288)
--                   + 1 Level 10 LIGHT monster

local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Fusion materials (a named monster and a generic Level 10 LIGHT monster)
    Fusion.AddProcMix(c,false,true,190019288,s.matfilter)

    -- [REQUIREMENT] Shuffle 1 Spell from your GY into the Deck.
    -- [EFFECT] Special Summon 1 Level 10 LIGHT monster from your GY
    -- in face-up Attack Position, then gain 1000 ATK until the End Phase.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)  -- Rush Duel: once per turn for this copy
    e1:SetCost(s.cost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end

-- Second Fusion material: one Level 10 LIGHT monster.
function s.matfilter(c,fc,sumtype,tp)
    return c:IsLevel(10) and c:IsAttribute(ATTRIBUTE_LIGHT)
end

-- Return one Spell Card from your Graveyard to the Deck as a requirement.
function s.costfilter(c)
    return c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
    end
end

-- Level 10 LIGHT monsters that can be Special Summoned in Attack Position.
function s.spfilter(c,e,tp)
    return c:IsType(TYPE_MONSTER)
        and c:IsLevel(10)
        and c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
                tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
            tp,LOCATION_GRAVE,0,1,nil,e,tp) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc then return end
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)==0 then
        return
    end

    -- Apply the +1000 ATK only after the Special Summon succeeds.
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
    Duel.BreakEffect()
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(1000)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e2)
end
