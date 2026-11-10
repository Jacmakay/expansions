-- Encounter: You are a stain on the Harbinger Name!
-- Custom Rush Duel Normal Spell
-- Card ID: 190019280
local s,id=GetID()

function s.initial_effect(c)
    -- [REQUIREMENT] Send your entire hand to the Graveyard.
    -- [EFFECT] Change the battle positions of 2 opponent's monsters,
    -- then you can Special Summon a Level 11 or lower monster with
    -- exactly 3500 ATK from your Graveyard in Attack Position.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_POSITION|CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- The hand must contain at least 1 card, and every card must be able
-- to be sent to the GY as a cost. All of them are sent, not selected.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    if chk==0 then
        return #g>0 and g:FilterCount(Card.IsAbleToGraveAsCost,nil)==#g
    end
    Duel.SendtoGrave(g,REASON_COST)
end

-- Exclude Maximum Mode monsters, which cannot change battle position.
function s.posfilter(c)
    return c:IsCanChangePositionRush()
end

function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsLevelBelow(11) and c:IsAttack(3500)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,2,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,2,1-tp,LOCATION_MZONE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
    if #g<2 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local sg=g:Select(tp,2,2,nil)
    if #sg~=2 then return end
    Duel.HintSelection(sg)

    -- Attack -> face-up Defense; Defense -> face-up Attack.
    -- Facedown Defense -> face-up Attack.
    if Duel.ChangePosition(sg,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,
        POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=2 then return end

    -- The Special Summon is optional and happens only after both changes.
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,nil,e,tp) then return end
    if not Duel.SelectEffectYesNo(tp,e:GetHandler()) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
    if tc then
        Duel.BreakEffect()
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
    end
end
