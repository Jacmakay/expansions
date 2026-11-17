local s,id=GetID()
local RITUAL_ID=190019150
local EXTRA_ID=190019142
function s.initial_effect(c)
 Ritual.AddProcGreater(c,s.rfilter,nil,nil,s.extrafil,s.extraop,s.matfilter,s.stage2,LOCATION_EXTRA)
end
function s.rfilter(c)
 return c:IsCode(RITUAL_ID)
end
function s.extrafilter(c)
 return c:IsCode(EXTRA_ID) and c:IsAbleToDeck()
end
function s.extrafil(e,tp)
 return Duel.GetMatchingGroup(s.extrafilter,tp,LOCATION_GRAVE,0,nil)
end
function s.matfilter(c)
 return (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())
  or (c:IsLocation(LOCATION_GRAVE) and s.extrafilter(c))
end
function s.extraop(mat,e,tp,eg,ep,ev,re,r,rp,tc)
 local gy=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
 local field=mat:Filter(Card.IsLocation,nil,LOCATION_MZONE)
 if #gy>0 then Duel.SendtoDeck(gy,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL) end
 if #field>0 then Duel.ReleaseRitualMaterial(field) end
end
function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
 if mat:IsExists(Card.IsCode,1,nil,EXTRA_ID) then
  local atk=Effect.CreateEffect(tc)
  atk:SetType(EFFECT_TYPE_SINGLE)
  atk:SetCode(EFFECT_UPDATE_ATTACK)
  atk:SetValue(500)
  atk:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
  tc:RegisterEffect(atk)
 end
end
