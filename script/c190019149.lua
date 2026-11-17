local s,id=GetID()
function s.initial_effect(c)
 Fusion.RegisterSummonEff(c,s.fusfilter,s.matfilter,s.extrafil,s.extraop,nil,s.stage2)
end
function s.fusfilter(c,tp)
 return c:IsCode(190019153,190019154)
end
function s.matfilter(c,e,tp,chk)
 return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsAbleToGrave()
end
function s.gyfilter(c)
 return c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_RITUAL)
  and c:IsCode(190019151,190019152) and c:IsAbleToDeck()
end
function s.extrafil(e,tp,mg)
 local g=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,nil)
 return g,s.checkadditional
end
function s.checkadditional(tp,sg,fc)
 return sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
end
function s.extraop(e,tc,tp,mat)
 local gy=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
 if #gy>0 then
  Duel.SendtoDeck(gy,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
  mat:Sub(gy)
 end
end
function s.stage2(e,tc,tp,mat,step)
 if step~=1 or not tc or not mat or not tc:IsFaceup() then return end
 -- Ritual materials returned from the GY now reside in the Extra Deck.
 if mat:IsExists(Card.IsLocation,1,nil,LOCATION_EXTRA) then
  local atk=Effect.CreateEffect(tc)
  atk:SetType(EFFECT_TYPE_SINGLE)
  atk:SetCode(EFFECT_UPDATE_ATTACK)
  atk:SetValue(500)
  atk:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
  tc:RegisterEffect(atk)
 end
end
