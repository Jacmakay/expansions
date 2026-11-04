-- The Ultimate Endbringer (Rush Duel)
-- Card ID: 190019055
local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- EDOPro-native Fusion procedure:
    -- "Buster Blader" + 2 Level 8 or lower Dragon monsters.
    -- Use the original Buster Blader passcode as a NAMED material.
    -- Fusion.AddProcMix uses Card.IsSummonCode, so Rush aliases/name changes
    -- can satisfy the named material while Rush Prisma can read c.material.
    Fusion.AddProcMix(c,true,true,78193831,s.dragonfilter,s.dragonfilter)

    -- Continuous Effect: ATK Gain
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)

    -- Indestructible by card effects
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetValue(1)
    c:RegisterEffect(e3)
end

function s.dragonfilter(c,fc,sumtype,tp)
    return c:IsRace(RACE_DRAGON)
        and c:HasLevel()
        and c:GetLevel()<=8
end

function s.atkfilter(c)
    return c:IsRace(RACE_DRAGON)
        and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end

function s.atkval(e,c)
    return Duel.GetMatchingGroupCount(s.atkfilter,0,
        LOCATION_MZONE|LOCATION_GRAVE,
        LOCATION_MZONE|LOCATION_GRAVE,nil)*500
end
