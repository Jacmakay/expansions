local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_DESTROY|CATEGORY_DECKDES)
 e1:SetType(EFFECT_TYPE_IGNITION)
 e1:SetRange(LOCATION_MZONE)
 e1:SetCountLimit(1)
 e1:SetCost(s.cost)
 e1:SetOperation(s.operation)
 c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
end
function s.desfilter(c)
 return c:IsFaceup() and c:IsAttackBelow(1500) and c:IsDestructable()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
 if Duel.DiscardDeck(tp,2,REASON_COST)<2 then return end
 local c=e:GetHandler()
 if c:IsFaceup() and c:IsRelateToEffect(e) then
  local a=Effect.CreateEffect(c)
  a:SetType(EFFECT_TYPE_SINGLE)
  a:SetCode(EFFECT_UPDATE_ATTACK)
  a:SetValue(500)
  a:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
  c:RegisterEffect(a)
 end
 if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,190019141,190019142)
  and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil)
  and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
  local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
  if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
 end
end
