-- Encounter: Void War Counter
-- Custom EDOPro Rush Duel Normal Trap
-- Card ID: 190019277
--
-- [REQUIREMENT]
-- When your opponent Normal or Special Summons a monster,
-- you control an EARTH monster or a DARK Galaxy monster.
--
-- [EFFECT]
-- Change 1 face-up monster you control to face-down Defense Position,
-- then destroy the Summoned monster.
--
-- If several monsters were Summoned simultaneously, select 1 of them.

local s,id=GetID()

function s.initial_effect(c)
    -- Opponent Normal Summons a monster.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_POSITION|CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Opponent Special Summons a monster.
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end

-- An EARTH monster OR a DARK Galaxy-Type monster on your field.
function s.reqfilter(c)
    return c:IsFaceup()
        and c:IsMonster()
        and (c:IsAttribute(ATTRIBUTE_EARTH)
            or (c:IsAttribute(ATTRIBUTE_DARK)
                and c:IsRace(RACE_GALAXY)))
end

-- A face-up monster you control which can actually be Set.
function s.posfilter(c)
    return c:IsFaceup()
        and c:IsMonster()
        and c:IsCanTurnSet()
end

-- Only the opponent's monsters from this exact Summon event.
function s.sumfilter(c,tp)
    return c:IsControler(1-tp)
        and c:IsLocation(LOCATION_MZONE)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return eg~=nil
        and eg:IsExists(s.sumfilter,1,nil,tp)
        and Duel.IsExistingMatchingCard(
            s.reqfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.posfilter,tp,LOCATION_MZONE,0,1,nil)
            and eg~=nil and eg:IsExists(s.sumfilter,1,nil,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Set one of your monsters first.
    if not Duel.IsExistingMatchingCard(
        s.posfilter,tp,LOCATION_MZONE,0,1,nil) then
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local sg=Duel.SelectMatchingCard(
        tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=sg:GetFirst()
    if not tc then return end
    Duel.HintSelection(sg)

    -- "Then": only destroy the Summoned monster if the
    -- face-down Defense Position change actually succeeds.
    if Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)==0 then
        return
    end

    -- Use the Summon event's group: don't accidentally destroy
    -- a different monster that was already on the field.
    if not eg then return end
    local mg=eg:Filter(s.sumfilter,nil,tp)
    if #mg==0 then return end

    local dg=mg
    if #mg>1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        dg=mg:Select(tp,1,1,nil)
    end
    Duel.BreakEffect()
    Duel.Destroy(dg,REASON_EFFECT)
end
