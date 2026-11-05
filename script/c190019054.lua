-- Weapons Mode Two
-- Custom Rush Duel Ritual Spell
-- Card ID: 190019054
-- [REQUIREMENT] None
-- [EFFECT] Ritual Summon 1 "U-T-W Garzett Mode Two" from your Extra Deck
-- by sending face-up monsters from your field to the GY whose combined
-- Levels total 12 or more. You cannot use more monsters than necessary.

local s,id=GetID()
local GARZETT_MODE_TWO=190019053

function s.initial_effect(c)
    -- Ritual Summon the specified Level 12 monster from the Extra Deck.
    -- RITPROC_GREATER enforces the minimum-needed-material rule: the
    -- selected materials must reach the Level, but no selected material
    -- can be removed while still meeting the Level requirement.
    Ritual.AddProcGreater(c,s.ritualfilter,nil,nil,nil,nil,
        s.matfilter,nil,LOCATION_EXTRA,nil,s.ritualop)
end

-- Only the intended monster is a valid Ritual Summon target.
function s.ritualfilter(c)
    return c:IsCode(GARZETT_MODE_TWO)
end

-- Rush Duel Ritual materials: your face-up monsters on the field,
-- not monsters in your hand. They must be able to go to the GY.
function s.matfilter(c,e,tp)
    return c:IsLocation(LOCATION_MZONE)
        and c:IsControler(tp)
        and c:IsFaceup()
        and c:IsAbleToGrave()
end

-- Rush Duel says "send to the GY", not "Tribute".
-- Override the standard ritual helper's Duel.ReleaseRitualMaterial.
function s.ritualop(mat,e,tp,eg,ep,ev,re,r,rp,rc)
    if not mat or #mat==0 or not rc then return end
    rc:SetMaterial(mat)
    local ct=#mat
    if Duel.SendtoGrave(mat,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)~=ct then
        return
    end
    Duel.BreakEffect()
    if Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)>0 then
        rc:CompleteProcedure()
    end
end
