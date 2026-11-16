-- Luffy - Gear Second: Jet
-- Custom Rush Duel card; ID 190019122
local s,id=GetID()
function s.initial_effect(c)

    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetValue(190019121)
    c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.deckcost(1))
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)

end

function s.sendfilter(c)
    return c:IsFaceup() and c:IsCode(190019121) and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetMatchingGroup(s.sendfilter,tp,LOCATION_MZONE,0,nil)
    if #g==0 then return false end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local sg=g:Select(tp,1,1,nil)
    if #sg==0 or Duel.GetMZoneCount(tp,sg,tp)<=0 then return false end
    sg:KeepAlive()
    e:SetLabelObject(sg)
    return true
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    if g then
        Duel.SendtoGrave(g,REASON_COST)
        g:DeleteGroup()
        e:SetLabelObject(nil)
    end
end


function s.handfilter(c)
    return c:IsAbleToGraveAsCost()
end
function s.mcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.deckcost(n)
    return function(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=n end
        Duel.DiscardDeck(tp,n,REASON_COST)
    end
end
function s.addatk(c,source,n,turns)
    local e1=Effect.CreateEffect(source)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(n)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,turns or 1)
    c:RegisterEffect(e1)
end
function s.pierce(c,source)
    local e1=Effect.CreateEffect(source)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_PIERCE)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    c:RegisterEffect(e1)
end

function s.operation(e,tp)
    local c=e:GetHandler()
    if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
    s.addatk(c,c,500)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    c:RegisterEffect(e1)
end
