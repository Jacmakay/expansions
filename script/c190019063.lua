--Astro Gear Fusion
--Card ID: 190019063
local s,id=GetID()

function s.initial_effect(c)
    --[REQUIREMENT] None.
    --[EFFECT] Fusion Summon 1 EARTH Machine monster using materials
    --from your hand or field. If your opponent controls 2 or more
    --monsters, monsters in your GY can also be used as material;
    --GY materials are shuffled into the Deck instead.
    local e1=Fusion.CreateSummonEff(c,s.fusfilter,s.matfilter,s.fextra,s.extraop)
    c:RegisterEffect(e1)
end

--Fusion Monster must be EARTH Machine
function s.fusfilter(c,tp)
    return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)
end

--Normal materials: hand or Monster Zone, sent to the GY by the Fusion helper
function s.matfilter(c,e,tp,chk)
    return c:IsLocation(LOCATION_HAND|LOCATION_MZONE) and c:IsAbleToGrave()
end

--GY materials must be able to return to the Deck/Extra Deck
function s.gyfilter(c)
    return c:IsMonster() and c:IsAbleToDeck()
end

--If the opponent controls 2 or more monsters, allow GY materials
function s.fextra(e,tp,mg)
    if Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)<2 then
        return nil
    end
    return Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,nil)
end

--Shuffle only selected GY materials into the Deck.
--Any selected hand/field materials remain in sg and are sent to the GY
--normally by Fusion.SummonEffOP.
function s.extraop(e,tc,tp,sg)
    local gg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
    if #gg==0 then return end
    sg:Sub(gg)
    Fusion.ShuffleMaterial(e,tc,tp,gg)
end
