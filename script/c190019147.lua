local s,id=GetID()
local RITUAL_ID=190019151
local EXTRA_ID=190019143
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
 if not mat:IsExists(Card.IsCode,1,nil,EXTRA_ID) then return end
 if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
 local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.clonefilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
 if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE) end
end
function s.clonefilter(c,e,tp)
 return c:IsCode(190019142) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
