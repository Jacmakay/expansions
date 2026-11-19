-- With This Treasure I Summon
-- 190019174 | Ritual Spell for Mahoraga (190019173)
-- Ritual Summon from the Extra Deck in face-up Attack Position using
-- monsters in your own hand/Monster Zone whose total Levels are >= 12.
-- If 3 or more monsters are used, give Mahoraga 1 Adaptation Counter.
local s,id=GetID()
local MAHORAGA=190019173
local COUNTER_ADAPTATION=0x0B73

function s.initial_effect(c)
    -- EDOPro's modern Ritual helper honors Extra Deck Rush Ritual summoning.
    -- The stage2 callback receives the actual materials and the summoned card.
    Ritual.AddProcGreater(c,s.ritfilter,12,nil,nil,nil,s.matfilter,
        s.stage2,LOCATION_EXTRA,nil,nil,nil,nil,POS_FACEUP_ATTACK)
end

function s.ritfilter(c)
    return c:IsCode(MAHORAGA)
end

function s.matfilter(c,e,tp)
    return c:IsControler(tp)
        and (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_MZONE))
end

function s.stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
    if tc and tc:IsFaceup() and tc:IsCode(MAHORAGA) and #mat>=3 then
        tc:AddCounter(COUNTER_ADAPTATION,1)
    end
end
