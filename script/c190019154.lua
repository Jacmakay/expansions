local s,id=GetID()
function s.initial_effect(c)
 c:EnableReviveLimit()
 Fusion.AddProcMix(c,false,true,190019151,190019152)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_TODECK)
 e1:SetType(EFFECT_TYPE_IGNITION)
 e1:SetRange(LOCATION_MZONE)
 e1:SetCountLimit(1)
 e1:SetTarget(s.target)
 e1:SetOperation(s.operation)
 c:RegisterEffect(e1)
end
function s.costfilter(c)
 return c:IsRace(RACE_WARRIOR) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,3,nil) end
end
function s.desfilter(c)
 return c:IsFaceup()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
 local cg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,3,3,nil)
 if #cg~=3 or Duel.SendtoDeck(cg,nil,SEQ_DECKSHUFFLE,REASON_COST)~=3 then return end
 local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
 if #g>0 then
  local sg=g:Select(tp,1,math.min(2,#g),nil)
  for tc in aux.Next(sg) do
   if tc:IsFaceup() then
    local a=Effect.CreateEffect(e:GetHandler())
    a:SetType(EFFECT_TYPE_SINGLE)
    a:SetCode(EFFECT_UPDATE_ATTACK)
    a:SetValue(-1500)
    a:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    tc:RegisterEffect(a)
   end
  end
 end
 local c=e:GetHandler()
 if c:IsRelateToEffect(e) and c:IsFaceup() then
  local a=Effect.CreateEffect(c)
  a:SetType(EFFECT_TYPE_SINGLE)
  a:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
  a:SetValue(2)
  a:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
  c:RegisterEffect(a)
  local endphase=Effect.CreateEffect(c)
  endphase:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
  endphase:SetCode(EVENT_PHASE|PHASE_END)
  endphase:SetRange(LOCATION_MZONE)
  endphase:SetCountLimit(1)
  endphase:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
  endphase:SetOperation(function(e) local handler=e:GetHandler()
   if handler:IsFaceup() and handler:IsLocation(LOCATION_MZONE) then
    Duel.SendtoDeck(handler,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
   end
  end)
  c:RegisterEffect(endphase)
 end
end
