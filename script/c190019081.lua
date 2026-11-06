--War To Zen! Trouble Solve Dawn Job!
--Custom Rush Duel Trap
--Card ID: 190019081
local s,id=GetID()

function s.initial_effect(c)
    --Activate when an opponent's monster declares an attack.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

--[REQUIREMENT] When an opponent's monster declares an attack.
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local ac=Duel.GetAttacker()
    return ac and ac:IsControler(1-tp)
end

--Level 9+ Galaxy or Magical Knight Fusion Monster in your GY.
function s.spfilter(c,e,tp)
    return c:IsType(TYPE_FUSION)
        and c:IsLevelAbove(9)
        and (c:IsRace(RACE_GALAXY) or c:IsRace(RACE_MAGICALKNIGHT))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,0,1-tp,-7500)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp) then
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    --[EFFECT] All face-up monsters the opponent controls lose 7500 ATK
    --until the end of this turn.
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    local reduced=false
    for tc in aux.Next(g) do
        if tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
            local old_atk=tc:GetAttack()
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(-7500)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
            tc:RegisterEffect(e1)
            if tc:GetAttack()<old_atk then
                reduced=true
            end
        end
    end

    --Then optionally Special Summon 1 qualifying Fusion Monster from your GY.
    if not reduced or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp) then return end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
    end
end
