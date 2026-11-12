-- Nozett Destruction Technique Nova Luminescent
-- ID: 190019297
-- Level 10 / LIGHT / Galaxy / Fusion / Effect
-- ATK 3000 / DEF 3000
-- Fusion Materials: 2 Level 10 LIGHT monsters

local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Fusion Materials: 2 Level 10 LIGHT monsters.
    Fusion.AddProcMix(c,false,true,s.matfilter,s.matfilter)

    -- [REQUIREMENT] None
    -- [EFFECT] Destroy 1 opponent's card; lock activations
    -- of all cards with that name for the rest of the Duel.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
end

function s.matfilter(c)
    return c:IsLevel(10) and c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.desfilter(c)
    return c:IsDestructable()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end

-- Applies to both players, in any zone where the named card/effect could activate.
function s.aclimit(e,re,tp)
    local rc=re:GetHandler()
    return rc and rc:IsCode(e:GetLabel())
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end

    -- Capture the name before the card changes location.
    local code=tc:GetCode()
    if Duel.Destroy(tc,REASON_EFFECT)==0 then return end

    -- An effect with no reset expires only when the Duel ends.
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetTargetRange(1,1)
    e2:SetLabel(code)
    e2:SetValue(s.aclimit)
    Duel.RegisterEffect(e2,tp)
end
