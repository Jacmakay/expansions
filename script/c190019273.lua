-- Phoenix Flames Over Isyria
-- Custom EDOPro Rush Duel Ritual Spell
-- Provisional card ID: 190019273
--
-- In the GY, this card's name becomes
-- "Monumenthes Festival -The Isyria Seance-".
--
-- [REQUIREMENT] None.
-- [EFFECT] Ritual Summon 1 "U-T-W Weapons Mode: Emir Phoenix Mode"
-- from your Extra Deck by sending face-up Beast-Warrior monsters
-- you control to the GY as materials whose combined Levels are 9 or more.
-- Uses a greater-than-or-equal Ritual procedure, which prevents
-- selecting unnecessary extra materials.

local s,id=GetID()
local EMIR_PHOENIX_MODE=190019272
-- EDOPro Rush-style passcode inferred from RD/KP24-JP046.
local MONUMENTHES_FESTIVAL=160024046

s.listed_names={EMIR_PHOENIX_MODE,MONUMENTHES_FESTIVAL}

function s.initial_effect(c)
    -- This card's name becomes "Monumenthes Festival -The Isyria Seance-"
    -- only while it is in the Graveyard.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetRange(LOCATION_GRAVE)
    e0:SetValue(MONUMENTHES_FESTIVAL)
    c:RegisterEffect(e0)

    -- Ritual Summon Emir Phoenix Mode from the Extra Deck.
    -- No additional activation requirement.
    local e1=Ritual.CreateProc({
        handler=c,
        lvtype=RITPROC_GREATER,
        filter=s.ritfilter,
        lv=9,
        matfilter=s.matfilter,
        requirementfunc=s.matlevel,
        extraop=s.sendmat,
        location=LOCATION_EXTRA,
        sumpos=POS_FACEUP
    })
    c:RegisterEffect(e1)
end

-- Only the named custom Ritual Monster is eligible.
function s.ritfilter(c)
    return c:IsCode(EMIR_PHOENIX_MODE) and c:IsType(TYPE_RITUAL)
end

-- Materials must be face-up Beast-Warrior monsters on your field.
-- Monsters in your hand, GY, and on the opponent's field are excluded.
function s.matfilter(c,e,tp)
    return c:IsMonster()
        and c:IsLocation(LOCATION_MZONE)
        and c:IsControler(tp)
        and c:IsFaceup()
        and c:IsRace(RACE_BEASTWARRIOR)
        and c:GetLevel()>0
        and c:IsAbleToGrave()
end

-- Count each chosen material's actual current Level.
function s.matlevel(c,rc)
    return c:GetLevel()
end

-- Rush Duel Ritual materials are SENT to the GY, not Tributed.
-- The Ritual helper handles the material selection, Ritual Summon,
-- and proper-summon procedure completion.
function s.sendmat(g,e,tp,eg,ep,ev,re,r,rp,rc)
    Duel.SendtoGrave(g,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end
