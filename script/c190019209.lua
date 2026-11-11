-- Maximum Chaos Ritual
-- Custom EDOPro Rush Duel Ritual Spell
-- Card ID: 190019209
--
-- [REQUIREMENT] None.
-- [EFFECT] Ritual Summon 1 Ritual Monster from your Extra Deck by
-- sending monsters from your hand and/or field to the Graveyard as
-- material, whose combined Levels equal or exceed the Ritual
-- Monster's Level.
--
-- This version follows the latest card image: ANY Ritual Monster in
-- your Extra Deck is eligible, not just Maximum Purple Chaos
-- Blue-Eyes Dragon (1900192210).

local s,id=GetID()

function s.initial_effect(c)
    -- Rush Duel Rituals are summoned from the Extra Deck.
    -- RITPROC_GREATER accepts material Levels equal to or above the
    -- Ritual Monster's Level and uses only the required materials.
    local e1=Ritual.CreateProc({
        handler=c,
        lvtype=RITPROC_GREATER,
        filter=s.ritfilter,
        matfilter=s.matfilter,
        requirementfunc=s.matlevel,
        extraop=s.sendmat,
        location=LOCATION_EXTRA,
        sumpos=POS_FACEUP
    })
    c:RegisterEffect(e1)
end

-- The Ritual Monster must be in the Extra Deck. No particular name,
-- Attribute or monster Type is required by this card's latest text.
function s.ritfilter(c)
    return c:IsType(TYPE_RITUAL)
end

-- Only monsters in your own hand or on your own field can be used.
-- They must have a Level and be able to go to the Graveyard by effect.
function s.matfilter(c,e,tp)
    return c:IsMonster()
        and c:IsControler(tp)
        and c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
        and c:GetLevel()>0
        and c:IsAbleToGrave()
end

-- Check current Levels, totaling at least the Ritual Monster's Level.
function s.matlevel(c,rc)
    return c:GetLevel()
end

-- Rush Ritual material is SENT to the GY, not Tributed.
-- Ritual.CreateProc sets the material group before calling this.
function s.sendmat(g,e,tp,eg,ep,ev,re,r,rp,rc)
    Duel.SendtoGrave(g,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end
