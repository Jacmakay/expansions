-- The Guardian's Ultimate Shield Exxod
-- Custom EDOPro Rush Duel Fusion Monster, 190019233
local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Exactly 3 monsters, all with different Races (Monster Types).
    -- Use EDOPro's Fusion library; RD is not available in this build.
    Fusion.AddProcMix(c,false,false,s.matfilter,s.matfilter,s.matfilter)

    -- Cannot be destroyed by card effects.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- Opponent's monsters may attack this card, but cannot choose
    -- any of your other monsters as an attack target.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetValue(s.atlimit)
    c:RegisterEffect(e2)
end

function s.samerace(tc,race)
    return tc:IsRace(race)
end

-- Fusion recipe filter signature:
-- (candidate, fusion monster, summon type, player, substitute, pool,
--  already-chosen materials, contact fusion)
function s.matfilter(c,fc,sumtype,tp,sub,mg,sg,contact)
    if not c:IsType(TYPE_MONSTER) then return false end
    if not sg then return true end
    -- 'sg' can include the candidate itself: exclude it from this check.
    return not sg:IsExists(s.samerace,1,c,c:GetRace())
end

function s.atlimit(e,c)
    return c~=e:GetHandler()
end
