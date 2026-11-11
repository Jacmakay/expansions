-- Los Stream Extreme
-- Custom EDOPro Rush Duel Ritual Spell
-- Card ID: 190019239
-- Ritual Summons "U-T-W Los Daedalus" (190019240) from the Extra Deck.
--
-- [REQUIREMENT] None.
-- [EFFECT] Ritual Summon "U-T-W Los Daedalus" by sending monsters
-- from your hand and/or field to the Graveyard whose combined Levels
-- are 11 or higher. You cannot use more monsters than necessary.

local s,id=GetID()
local LOS_DAEDALUS=190019240
s.listed_names={LOS_DAEDALUS}

function s.initial_effect(c)
    -- Create the Ritual Spell activation.
    -- RITPROC_GREATER checks the Level total and prevents using
    -- more Ritual Materials than necessary.
    local e1=Ritual.CreateProc({
        handler=c,
        lvtype=RITPROC_GREATER,
        filter=s.ritfilter,
        lv=11,
        matfilter=s.matfilter,
        requirementfunc=s.matlevel,
        extraop=s.sendmat,
        location=LOCATION_EXTRA,
        sumpos=POS_FACEUP
    })
    c:RegisterEffect(e1)
end

-- Only summon U-T-W Los Daedalus.
function s.ritfilter(c)
    return c:IsCode(LOS_DAEDALUS)
end

-- Materials must be monsters in YOUR hand or Monster Zone.
function s.matfilter(c,e,tp)
    return c:IsMonster()
        and c:IsControler(tp)
        and c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
        and c:GetLevel()>0
        and c:IsAbleToGrave()
end

-- Use the actual current Levels to reach at least Level 11.
function s.matlevel(c,rc)
    return c:GetLevel()
end

-- Rush Ritual materials are SENT to the Graveyard, not Tributed.
-- The Ritual helper sets the material group and performs the Ritual Summon.
function s.sendmat(g,e,tp,eg,ep,ev,re,r,rp,rc)
    Duel.SendtoGrave(g,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end
