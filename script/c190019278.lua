-- Encounter: Void War Impact
-- Custom EDOPro Rush Duel Normal Spell
-- Card ID: 190019278
--
-- [REQUIREMENT] Send 1 EARTH monster or 1 DARK Galaxy monster
-- from your field to the Graveyard.
--
-- [EFFECT] Destroy 1 opponent's monster whose ATK is lower than
-- the ATK of the monster sent for this card's requirement.
-- Then, if the sent monster was an EARTH Ritual monster or a
-- Galaxy Ritual monster, draw 2 cards.

local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY|CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Opposing monsters have to be face-up so their current ATK
-- can be compared with the sent monster's ATK.
function s.desfilter(c,atk)
    return c:IsFaceup()
        and c:IsMonster()
        and c:GetAttack()<atk
        and c:IsDestructable()
end

-- The monster used for the requirement must be a face-up
-- EARTH monster, or a face-up DARK Galaxy monster, and must
-- be able to be sent to the GY as a cost.
function s.reqfilter(c)
    return c:IsFaceup()
        and c:IsMonster()
        and (c:IsAttribute(ATTRIBUTE_EARTH)
            or (c:IsAttribute(ATTRIBUTE_DARK)
                and c:IsRace(RACE_GALAXY)))
        and c:IsAbleToGraveAsCost()
end

-- To activate, at least one eligible requirement monster must
-- have higher ATK than a destroyable opposing monster.
function s.costfilter(c,tp)
    return s.reqfilter(c)
        and Duel.IsExistingMatchingCard(
            s.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end

-- Qualifies for the optional draw:
-- EARTH Ritual, or Galaxy-Type Ritual (any Attribute).
function s.drawfilter(c)
    return c:IsType(TYPE_RITUAL)
        and (c:IsAttribute(ATTRIBUTE_EARTH)
            or c:IsRace(RACE_GALAXY))
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.costfilter,tp,LOCATION_MZONE,0,1,nil,tp)
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(
        tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
    local tc=g:GetFirst()
    if not tc then return end

    -- Remember the ATK and Ritual status before the card leaves the field.
    local atk=tc:GetAttack()
    local drawflag=s.drawfilter(tc) and 1 or 0

    local sent=Duel.SendtoGrave(tc,REASON_COST)
    -- Only qualify for the draw if it actually reached the Graveyard.
    if sent==0 or not tc:IsLocation(LOCATION_GRAVE) then
        drawflag=0
    end
    e:SetLabel(atk,drawflag)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    -- The cost check already verifies a valid monster pair;
    -- checking again here would fail after the monster is sent.
    if chk==0 then return true end
    Duel.SetOperationInfo(
        0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
    Duel.SetPossibleOperationInfo(
        0,CATEGORY_DRAW,nil,0,tp,2)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local atk,drawflag=e:GetLabel()

    -- Choose an opposing monster at resolution (non-targeting).
    if not Duel.IsExistingMatchingCard(
        s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(
        tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,atk)
    if #g==0 then return end
    Duel.HintSelection(g)

    -- "Then": proceed to the draw only if the destruction succeeds.
    if Duel.Destroy(g,REASON_EFFECT)==0 then return end

    if drawflag==1 then
        Duel.BreakEffect()
        Duel.Draw(tp,2,REASON_EFFECT)
    end
end
