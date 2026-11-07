-- Dominus Empire Flag
-- EDOPro Rush Duel custom Ritual Spell
-- Card ID: 190019099
-- Ritual Summons "U-T-W Gladiness The Emperor's Flagbearer"
-- IMPORTANT: The Flagbearer's card ID has not been confirmed.
-- 190019098 is a PROVISIONAL value: change it if the monster uses another ID.

local s,id=GetID()
local FLAGBEARER_ID=190019098

function s.initial_effect(c)
    -- [REQUIREMENT] None.
    -- [EFFECT] Ritual Summon Flagbearer from the Extra Deck by sending
    -- monsters in your hand/field to the GY whose total Levels are >= 10.
    -- Then you may turn 1 of your opponent's face-up monsters face-down.
    Ritual.AddProcGreater(c,s.ritfilter,10,nil,nil,s.sendmat,s.matfilter,s.afterritual,LOCATION_EXTRA)
end

function s.ritfilter(c)
    return c:IsCode(FLAGBEARER_ID)
end

-- Only monsters from your own hand/field that can be sent to the GY.
function s.matfilter(c,e,tp)
    return c:IsControler(tp)
        and (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_MZONE))
        and c:IsAbleToGrave()
end

-- Rush Ritual materials are sent to the GY, not Tributed/Released.
function s.sendmat(g,e,tp,eg,ep,ev,re,r,rp,rc)
    Duel.SendtoGrave(g,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end

function s.posfilter(c)
    return c:IsFaceup() and c:IsCanTurnSet()
end

-- This is run by the Ritual helper after the Ritual Summon.
function s.afterritual(mat,e,tp,eg,ep,ev,re,r,rp,rc)
    if not (rc and rc:IsLocation(LOCATION_MZONE)
        and rc:IsSummonType(SUMMON_TYPE_RITUAL)) then return end
    if not Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) then return end

    -- This is optional. For a readable prompt, add this card's str1 text
    -- to the custom database, e.g. "Change an opponent's monster face-down?"
    if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
    if #g>0 then
        Duel.HintSelection(g)
        Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
    end
end
