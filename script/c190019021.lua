-- Voidvelg Garlandolf's Requiem
-- EDOPro / Rush Duel script
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Materials:
    -- "Voidvelg Requiem" (160010025)
    -- + "Voidvelg Pale Rider" (160317012)
    -- + exactly 1 DARK monster.
    Fusion.AddProcCode2FunRep(
        c, 160010025, 160317012, s.matfilter, 1, 1, false, false
    )

    -- Contact Fusion: use the required materials from your field,
    -- then shuffle them into the Deck.
    Fusion.AddContactProc(
        c, s.contactmat, s.contactop, nil, nil, SUMMON_TYPE_FUSION
    )

    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1, id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- The third material must be a DARK monster.
function s.matfilter(c, fc, sumtype, tp)
    return c:IsAttribute(ATTRIBUTE_DARK, fc, sumtype, tp)
end

-- Contact Fusion can only use monsters on your own field.
function s.contactmat(tp)
    return Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
end

function s.contactop(g, tp, c)
    c:SetMaterial(g)
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_MATERIAL + REASON_FUSION)
end

-- Face-up monsters other than this card with 2500 DEF or less.
function s.desfilter(c, rc)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER)
        and c ~= rc and c:GetDefense() <= 2500
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(
            s.desfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil, c
        )
    end
    local g = Duel.GetMatchingGroup(
        s.desfilter, tp, LOCATION_MZONE, LOCATION_MZONE, nil, c
    )
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(
        s.desfilter, tp, LOCATION_MZONE, LOCATION_MZONE, nil, c
    )
    if #g == 0 then return end

    local ct = Duel.Destroy(g, REASON_EFFECT)
    if ct > 0 and c:IsRelateToEffect(e) and c:IsFaceup() then
        Duel.BreakEffect()
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(ct * 300)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end
