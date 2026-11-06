--Always and Forever With You
--Rush Duel Normal Spell
--Card ID: 190019084
local s,id=GetID()

--The card's name becomes "U-T-W Combined Manuever" in the Graveyard.
local COMBINED_MANUEVER=190019079
s.listed_names={COMBINED_MANUEVER}

function s.initial_effect(c)
    --Name change in the Graveyard (applies even without activating this Spell).
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetRange(LOCATION_GRAVE)
    e0:SetValue(COMBINED_MANUEVER)
    c:RegisterEffect(e0)

    --Choose 1 monster you control: it can attack monsters up to 3 times
    --this turn, and inflicts piercing battle damage.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.monfilter(c)
    return c:IsMonster()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_MZONE,0,1,nil)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_MZONE,0,1,nil) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    local g=Duel.SelectMatchingCard(tp,s.monfilter,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end
    Duel.HintSelection(g)

    --Up to 3 monster attacks total (2 additional attacks on monsters).
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e1:SetValue(2)
    e1:SetReset(RESETS_STANDARD_PHASE_END)
    tc:RegisterEffect(e1)

    --Piercing battle damage against Defense Position monsters.
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_PIERCE)
    e2:SetReset(RESETS_STANDARD_PHASE_END)
    tc:RegisterEffect(e2)
end
