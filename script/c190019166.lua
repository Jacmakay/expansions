-- Winda F.C.W Fonix
-- Level 5 WIND Spellcaster/Fusion/Effect; card ID 190019166
local s,id=GetID()
local WINDA_ID=190019165

function s.initial_effect(c)
    -- "Winda the Masked Man's Apprentice" + 1 Spellcaster with 1500 DEF
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,true,true,WINDA_ID,s.matfilter)
    -- Rush Duel Contact Fusion: shuffle face-up field materials into Deck.
    Fusion.AddContactProc(c,s.contactfilter,s.contactop,nil,nil,SUMMON_TYPE_FUSION,nil,false)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.matfilter(c,fc,sumtype,tp,sub,mg,sg,contact)
    return c:IsRace(RACE_SPELLCASTER) and c:GetDefense()==1500
end
function s.contactfilter(tp)
    return Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAbleToDeckOrExtraAsCost),tp,LOCATION_MZONE,0,nil)
end
function s.contactop(g,tp)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:GetTurnID()==Duel.GetTurnCount() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.thfilter(c)
    return c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
    if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
    local c=e:GetHandler()
    if c:IsFaceup() and c:IsLocation(LOCATION_MZONE) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(1500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end
end
