local s,id=GetID()
function s.initial_effect(c)
 c:EnableReviveLimit()
 Fusion.AddProcMix(c,false,true,190019151,190019142)
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
 if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
 local cg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
 if #cg==0 or Duel.SendtoDeck(cg,nil,SEQ_DECKSHUFFLE,REASON_COST)==0 then return end
 local c=e:GetHandler()
 if not c:IsFaceup() or not c:IsRelateToEffect(e) then return end
 local count=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_RITUAL)
 if count>0 then
  local a=Effect.CreateEffect(c)
  a:SetType(EFFECT_TYPE_SINGLE)
  a:SetCode(EFFECT_UPDATE_ATTACK)
  a:SetValue(count*500)
  a:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
  c:RegisterEffect(a)
 end
 local e2=Effect.CreateEffect(c)
 e2:SetType(EFFECT_TYPE_SINGLE)
 e2:SetCode(EFFECT_ATTACK_ALL)
 e2:SetValue(1)
 e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
 c:RegisterEffect(e2)
end
