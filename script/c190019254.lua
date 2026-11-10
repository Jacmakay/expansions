-- Sineater Dark Knight
-- Custom Rush Duel card: 190019254
local s,id=GetID()

function s.initial_effect(c)
    -- If you have a Level 6 monster in your GY, Special Summon this card
    -- from your hand (no Tribute required).
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.hspcon)
    c:RegisterEffect(e1)

    -- [REQUIREMENT] Send 1 eligible monster from hand to GY.
    -- [EFFECT] Change the position of 1 opponent's monster, then
    -- optionally revive a Level 6 or lower Spellcaster/Fiend/Fairy.
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_POSITION|CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

-- Hand Special Summon condition: any Level 6 monster in your GY.
function s.lv6filter(c)
    return c:IsMonster() and c:IsLevel(6)
end
function s.hspcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.lv6filter,tp,LOCATION_GRAVE,0,1,nil)
end

-- The comma-separated alternatives on the card mean DARK attribute OR
-- Fiend OR Spellcaster OR Fairy (and it must be a monster).
function s.handfilter(c)
    return c:IsMonster()
        and (c:IsAttribute(ATTRIBUTE_DARK)
            or c:IsRace(RACE_FIEND|RACE_SPELLCASTER|RACE_FAIRY))
        and c:IsAbleToGraveAsCost()
end

-- Rush Duel convention: check the requirement as a cost,
-- then actually send the card during the operation.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_HAND,0,1,nil)
    end
end

function s.posfilter(c)
    return c:IsMonster() and c:IsCanChangePositionRush()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,LOCATION_MZONE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.gyfilter(c,e,tp)
    return c:IsMonster() and c:IsLevelBelow(6)
        and c:IsRace(RACE_SPELLCASTER|RACE_FIEND|RACE_FAIRY)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Requirement (performed first, as in official Rush Duel scripts).
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local hg=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #hg==0 or Duel.SendtoGrave(hg,REASON_COST)==0 then return end

    -- Change exactly 1 opponent's monster to the opposite battle position.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local pg=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
    local tc=pg:GetFirst()
    if not tc then return end
    -- Attack -> face-up Defense; Defense -> face-up Attack.
    if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,
        POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)==0 then return end

    -- Optional: select 0 or 1 eligible monster to Special Summon.
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.gyfilter),
        tp,LOCATION_GRAVE,0,1,nil,e,tp) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gyfilter),
        tp,LOCATION_GRAVE,0,0,1,nil,e,tp)
    if #sg>0 then
        Duel.BreakEffect()
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
    end
end
