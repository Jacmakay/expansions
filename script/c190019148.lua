local s,id=GetID()
local RITUAL_ID=190019152
local EXTRA_ID=0
function s.initial_effect(c)
 Ritual.AddProcGreater(c,s.rfilter,nil,nil,s.extrafil,s.extraop,s.matfilter,s.stage2,LOCATION_EXTRA)
end
function s.rfilter(c)
 return c:IsCode(RITUAL_ID)
end
function s.extrafilter(c)
 return c:IsType(TYPE_RITUAL) and c:IsRace(RACE_WARRIOR) and c:IsAbleToDeck()
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
 if not mat:IsExists(Card.IsType,1,nil,TYPE_RITUAL) then return end
 local ind=Effect.CreateEffect(tc)
 ind:SetType(EFFECT_TYPE_SINGLE)
 ind:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
 ind:SetValue(function(e,re,rp) return rp~=e:GetHandler():GetControler() and re:IsActiveType(TYPE_MONSTER) end)
 ind:SetReset(RESET_EVENT|RESETS_STANDARD)
 tc:RegisterEffect(ind)
end
