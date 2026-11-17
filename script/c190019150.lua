local s,id=GetID()
function s.initial_effect(c)
 c:EnableReviveLimit()
 local e1=Effect.CreateEffect(c)
 e1:SetDescription(aux.Stringid(id,0))
 e1:SetCategory(CATEGORY_DESTROY|CATEGORY_TOHAND|CATEGORY_TODECK)
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
function s.desfilter(c)
 return c:IsFaceup() and c:IsAttackBelow(2800) and c:IsDestructable()
end
function s.thfilter(c)
 return c:IsCode(190019145) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,2,nil)
  and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
 Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
 local cg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
 if #cg~=2 or Duel.SendtoDeck(cg,nil,SEQ_DECKSHUFFLE,REASON_COST)~=2 then return end
 local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
 if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0
  and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
  and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
  local h=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
  if #h>0 then Duel.SendtoHand(h,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,h) end
 end
end
