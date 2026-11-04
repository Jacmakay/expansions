--Astro Gear Statue
--Card ID: 190019060
local s,id=GetID()

function s.initial_effect(c)
    --[REQUIREMENT] Send this card to the Graveyard.
    --[EFFECT] This turn, you can Normal Summon 1 Level 5 or higher
    --EARTH Machine monster without Tributing.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return c:IsAbleToGraveAsCost()
    end
    Duel.SendtoGrave(c,REASON_COST)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    --Grant one no-Tribute Normal Summon for the rest of this turn.
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetTargetRange(LOCATION_HAND,0)
    e1:SetCountLimit(1)
    e1:SetCondition(s.ntcon)
    e1:SetTarget(aux.FieldSummonProcTg(s.nttg))
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.ntcon(e,c,minc)
    if c==nil then return true end
    return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end

function s.nttg(e,c)
    return c:IsLevelAbove(5)
        and c:IsAttribute(ATTRIBUTE_EARTH)
        and c:IsRace(RACE_MACHINE)
end
