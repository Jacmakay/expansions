-- Maximum Purple Chaos Blue-Eyes Dragon
-- Custom EDOPro Rush Duel Ritual / Effect Monster
-- Card ID: 1900192210 (as supplied by the card creator)
-- Level 11 / DARK / Dragon / Ritual / Effect / ATK 4000 / DEF 3500
--
-- [REQUIREMENT] None
-- [CONTINUOUS EFFECT]
-- Cannot be destroyed by card effects.
-- Can make up to 3 attacks on monsters; inflicts piercing battle damage.
-- If Ritual Summoned using a Galaxy monster as material, this card
-- gains 1500 ATK and cannot be returned to the Extra Deck by card effects.
--
-- Ritual Summoning is handled by a separate Ritual Spell/effect.
-- In the custom Rush Duel environment, Ritual Monsters use the Extra Deck.

local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Remember whether at least one Galaxy monster was used as Ritual Material.
    -- EFFECT_MATERIAL_CHECK runs while the Ritual Material group is available.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_MATERIAL_CHECK)
    e0:SetValue(s.matcheck)
    c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetLabelObject(e0)
    e1:SetOperation(s.recordmaterial)
    c:RegisterEffect(e1)

    -- Continuous: cannot be destroyed by card effects.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Continuous: a normal monster attack plus two more on monsters.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e3:SetValue(2)
    c:RegisterEffect(e3)

    -- Continuous: inflict piercing damage when attacking a Defense monster.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e4)

    -- Galaxy-material Ritual bonus: +1500 ATK while face-up on the field.
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EFFECT_UPDATE_ATTACK)
    e5:SetCondition(s.galaxycon)
    e5:SetValue(1500)
    c:RegisterEffect(e5)

    -- Galaxy-material Ritual bonus: prevent effect-based returns from the
    -- field to the Extra Deck. A send replacement lets normal costs and
    -- game-rule moves work, unlike an unconditional CANNOT_TO_DECK effect.
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EFFECT_SEND_REPLACE)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCondition(s.galaxycon)
    e6:SetTarget(s.reptg)
    e6:SetValue(s.repval)
    c:RegisterEffect(e6)
end

-- Check the actual Ritual Materials, not the monsters that happen to
-- remain in the Graveyard after the Ritual Summon resolves.
function s.galaxymat(c)
    return c:IsMonster() and c:IsRace(RACE_GALAXY)
end

function s.matcheck(e,c)
    local mg=c:GetMaterial()
    e:SetLabel(mg and mg:IsExists(s.galaxymat,1,nil) and 1 or 0)
end

function s.recordmaterial(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsSummonType(SUMMON_TYPE_RITUAL) then return end

    -- Also check the material group directly, in case the Ritual helper
    -- exposes it at Summon success rather than through MATERIAL_CHECK.
    local check=e:GetLabelObject()
    local mg=c:GetMaterial()
    local used_galaxy=(check and check:GetLabel()==1)
        or (mg and mg:IsExists(s.galaxymat,1,nil))
    if used_galaxy then
        c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
    end
end

function s.galaxycon(e)
    local c=e:GetHandler()
    return c:IsFaceup() and c:GetFlagEffect(id)>0
end

-- Only prevent this particular monster from being moved to the Deck /
-- Extra Deck by an effect (rather than by a cost, material procedure,
-- or game rule). Rush Ritual Monsters normally return to the Extra Deck.
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        if not eg:IsContains(c) or c:GetFlagEffect(id)==0 then
            return false
        end
        local dest=c:GetDestination()
        return (r&REASON_EFFECT)~=0
            and (r&REASON_REPLACE)==0
            and (dest==LOCATION_DECK or dest==LOCATION_EXTRA)
    end
    return true
end

function s.repval(e,c)
    return c==e:GetHandler()
end
