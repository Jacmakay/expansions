-- I'll Surpass Your Pathetic Bankai | 190019468
-- Rush Duel Ritual Spell
-- Ritual Summons "Harbinger of Frost Yuki-Onna - Eternal Winter Release"
-- (190019270, Level 12) from the Extra Deck.
-- Materials: monsters in your hand / field, total Levels >= 12,
-- without unnecessary extra materials. SEND to GY (not Tribute).
local s,id=GetID()
local ETERNAL_WINTER_RELEASE=190019270
s.listed_names={ETERNAL_WINTER_RELEASE}
function s.initial_effect(c)
    -- Matches the existing "Will of Terminus" Rush Ritual Spell convention.
    Ritual.AddProcGreater(c,s.ritualfilter,nil,nil,nil,
        s.sendmaterials,s.materialfilter,nil,LOCATION_EXTRA)
end
function s.ritualfilter(c)
    return c:IsCode(ETERNAL_WINTER_RELEASE) and c:IsType(TYPE_RITUAL)
end
function s.materialfilter(c,e,tp)
    return c:IsMonster() and c:IsControler(tp)
        and c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
        and c:GetLevel()>0 and c:IsAbleToGrave()
end
function s.sendmaterials(g,e,tp,eg,ep,ev,re,r,rp,rc)
    Duel.SendtoGrave(g,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end
