-- AFLD of Equilibrium
-- Custom EDOPro Rush Duel monster - Card ID: 190019230
-- LIGHT / Dragon / Effect - Level 7 - ATK 2500 / DEF 2500
--
-- Special Summon: If you control a face-up LIGHT monster whose ATK equals
-- its DEF, you can Special Summon this card from your hand in face-up Defense.
--
-- [REQUIREMENT] None
-- [CONTINUOUS EFFECT] Your face-up monsters whose ATK equals their DEF
-- gain 500 ATK/DEF and cannot be destroyed by card effects.

local s,id=GetID()

function s.initial_effect(c)
    -- Special Summon this card from the hand in face-up Defense Position.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SPSUM_PARAM)
    e1:SetRange(LOCATION_HAND)
    e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- Continuous: +500 ATK to your qualifying monsters.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.eqtarget)
    e2:SetValue(500)
    c:RegisterEffect(e2)

    -- Continuous: +500 DEF to the same monsters.
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)

    -- Continuous: the same monsters cannot be destroyed by card effects.
    local e4=e2:Clone()
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetValue(1)
    c:RegisterEffect(e4)
end

-- Use the monsters' current ATK/DEF (not printed/base stats).
function s.equalstats(c)
    return c:IsFaceup() and c:IsMonster()
        and c:GetAttack()==c:GetDefense()
end

function s.spfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and s.equalstats(c)
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.eqtarget(e,c)
    return s.equalstats(c)
end
