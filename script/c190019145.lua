local s,id=GetID()
function s.initial_effect(c)
 local e1=Effect.CreateEffect(c)
 e1:SetCategory(CATEGORY_DESTROY)
 e1:SetType(EFFECT_TYPE_ACTIVATE)
 e1:SetCode(EVENT_FREE_CHAIN)
 e1:SetTarget(s.target)
 e1:SetOperation(s.operation)
 c:RegisterEffect(e1)
end
function s.warfilter(c)
 return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
function s.desfilter(c,atk)
 return c:IsFaceup() and c:IsAttackBelow(atk) and c:IsDestructable()
end
function s.available(tp)
 local wg=Duel.GetMatchingGroup(s.warfilter,tp,LOCATION_MZONE,0,nil)
 for tc in aux.Next(wg) do
  if Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,tc:GetAttack()) then return true end
 end
 return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
 if chk==0 then return s.available(tp) end
 Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
 local wg=Duel.GetMatchingGroup(s.warfilter,tp,LOCATION_MZONE,0,nil)
 wg:Match(function(c) return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()) end,nil)
 if #wg==0 then return end
 Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
 local own=wg:Select(tp,1,1,nil):GetFirst()
 local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,own:GetAttack())
 if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
end
