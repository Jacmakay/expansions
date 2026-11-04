--Astro Gear Fenrir
--Card ID: 190019064
local s,id=GetID()

function s.initial_effect(c)
    --This card cannot attack directly.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
    c:RegisterEffect(e0)

    --[REQUIREMENT] The turn you Normal Summon this card,
    --shuffle 5 EARTH Machine monsters from your GY into the Deck.
    --[EFFECT] Destroy 2 cards in your opponent's Spell & Trap Zones,
    --then this turn your opponent cannot activate Trap Cards when
    --your EARTH Machine monsters declare an attack.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK|CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_NORMAL)
        and c:IsStatus(STATUS_SUMMON_TURN)
end

function s.costfilter(c)
    return c:IsMonster()
        and c:IsAttribute(ATTRIBUTE_EARTH)
        and c:IsRace(RACE_MACHINE)
        and c:IsAbleToDeckAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(
            s.costfilter,tp,LOCATION_GRAVE,0,5,nil
        )
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(
        tp,s.costfilter,tp,LOCATION_GRAVE,0,5,5,nil
    )
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)>=2
    end
    Duel.SetOperationInfo(
        0,CATEGORY_DESTROY,nil,2,1-tp,LOCATION_SZONE
    )
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_SZONE)
    if #g<2 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local sg=g:Select(tp,2,2,nil)

    --"then": apply the Trap activation restriction only if both
    --selected Spell/Trap cards were successfully destroyed.
    if Duel.Destroy(sg,REASON_EFFECT)~=2 then return end

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetTargetRange(0,1)
    e1:SetCondition(s.actcon)
    e1:SetValue(s.aclimit)
    e1:SetLabel(tp)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

--The restriction is active only while one of your EARTH Machine
--monsters is the current attacking monster.
function s.actcon(e)
    local a=Duel.GetAttacker()
    local tp=e:GetLabel()
    return a
        and a:IsControler(tp)
        and a:IsAttribute(ATTRIBUTE_EARTH)
        and a:IsRace(RACE_MACHINE)
end

--Prevent activation of Trap Cards (not merely effects of already
--face-up Trap Cards).
function s.aclimit(e,re,tp)
    return re:IsActiveType(TYPE_TRAP)
        and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
