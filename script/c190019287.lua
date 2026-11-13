-- Encounter a Fathers Sacrifice: The Least I Can Do!
-- Custom EDOPro Rush Duel Normal Trap
-- Card ID: 190019287
--
-- [REQUIREMENT]
-- When an opponent's monster declares an attack on your monster.
-- [EFFECT]
-- Negate that attack, then destroy the attacked monster you control.
-- If it was destroyed, Special Summon 1 monster with the same Attribute
-- from your Graveyard in face-up Defense Position.
--
-- Database: configure this card as a Normal Trap (TYPE_TRAP).

local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE|CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- The attack must be declared by your opponent and target a monster
-- you control; direct attacks do not satisfy the Requirement.
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    return a~=nil and d~=nil
        and a:IsControler(1-tp)
        and d:IsControler(tp)
        and d:IsLocation(LOCATION_MZONE)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return s.condition(e,tp,eg,ep,ev,re,r,rp)
    end
    local d=Duel.GetAttackTarget()
    if d then
        -- Remember the monster that was attacked at activation.
        e:SetLabelObject(d)
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,tp,LOCATION_MZONE)
    end
    -- The attacked monster itself may enter the GY upon destruction,
    -- so the eligible revival pool cannot be fixed at activation.
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.spfilter(c,e,tp,att)
    return c:IsMonster() and c:IsAttribute(att)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Resolve against the ORIGINAL attacked monster, even if an
    -- intervening chain changes the current attack target.
    local d=e:GetLabelObject()
    if not d or not d:IsControler(tp) or not d:IsLocation(LOCATION_MZONE) then
        return
    end
    local att=d:GetAttribute()

    -- No further steps happen if the attack is not successfully negated.
    if not Duel.NegateAttack() then return end

    -- Destroy specifically the monster which was being attacked.
    -- Only a successful destruction allows the next step.
    if not d:IsLocation(LOCATION_MZONE) or not d:IsControler(tp) then
        return
    end
    if Duel.Destroy(d,REASON_EFFECT)==0 then return end

    -- 'Same Attribute' refers to the attacked monster's Attribute
    -- as it was on the field immediately before destruction.
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local f=aux.NecroValleyFilter(s.spfilter)
    if not Duel.IsExistingMatchingCard(f,tp,LOCATION_GRAVE,0,1,nil,e,tp,att) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,f,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,att)
    local tc=g:GetFirst()
    if tc then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
    end
end
