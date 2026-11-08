-- Rising Harbinger of Finality
-- EDOPro Rush Duel / Card ID: 190019226
-- Revision: permanently locks the ORIGINAL CARD NAME (original card ID)
-- of any card destroyed by this monster. All copies of that card name
-- are prevented from activating cards or activated effects for the Duel.
local s,id=GetID()

function s.initial_effect(c)
    -- [REQUIREMENT] Pay half your LP.
    -- [EFFECT] Set all opponent's monsters, then destroy 2 Set cards.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_POSITION|CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    -- This card can attack up to 3 times per Battle Phase.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EXTRA_ATTACK)
    e2:SetValue(2)
    c:RegisterEffect(e2)

    -- Piercing battle damage.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e3)

    -- Watch actual destruction events, including destruction by battle.
    -- Registered to the Duel so it is not lost on a zone change.
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetLabelObject(c)
    e4:SetOperation(s.destroyed_event)
    Duel.RegisterEffect(e4,c:GetOwner())
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLP(tp)>0 end
    Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,0,1-tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,1-tp,LOCATION_ONFIELD)
end

function s.set_filter(c)
    return c:IsFacedown()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Turn the opponent's monsters to face-down Defense Position.
    local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,0,LOCATION_MZONE,nil)
    if #g>0 then
        Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
    end

    -- Destroy 2 Set cards. Only names of cards ACTUALLY destroyed get locked.
    local dg=Duel.GetMatchingGroup(s.set_filter,tp,0,LOCATION_ONFIELD,nil)
    if #dg>=2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sg=dg:Select(tp,2,2,nil)
        if Duel.Destroy(sg,REASON_EFFECT)>0 then
            -- GetOperatedGroup identifies the cards that were really destroyed,
            -- unlike the selected targets (which may resist destruction).
            local destroyed=Duel.GetOperatedGroup()
            for tc in aux.Next(destroyed) do
                if tc:IsReason(REASON_EFFECT) and tc:GetReasonEffect()==e then
                    s.lock_name(e:GetHandler(),tp,tc:GetOriginalCode())
                end
            end
        end
    end

    -- Protection through the end of the opponent's next turn.
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
    local reset=RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END

    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e5:SetValue(1)
    e5:SetReset(reset,2)
    c:RegisterEffect(e5)

    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_CANNOT_TO_HAND)
    e6:SetValue(1)
    e6:SetReset(reset,2)
    c:RegisterEffect(e6)

    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_SINGLE)
    e7:SetCode(EFFECT_CANNOT_TO_DECK)
    e7:SetValue(1)
    e7:SetReset(reset,2)
    c:RegisterEffect(e7)
end

-- Register a Duel-long ban for a destroyed card's original name/ID.
-- The EFFECT_CANNOT_ACTIVATE check is performed on every activation,
-- wherever the card is located. This covers every copy with that name.
function s.lock_name(source,tp,code)
    if not code or code==0 then return end
    local e1=Effect.CreateEffect(source)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetTargetRange(1,1)
    e1:SetLabel(code)
    e1:SetValue(s.cannot_activate)
    -- No SetReset: this effect lasts for the entire Duel.
    Duel.RegisterEffect(e1,tp)
end

function s.cannot_activate(e,re,tp)
    if not re then return false end
    local handler=re:GetHandler()
    return handler~=nil and handler:GetOriginalCode()==e:GetLabel()
end

-- Event-based backup to catch battle destruction and destruction at other
-- points during the Duel. GetReasonCard is the battle destroyer;
-- GetReasonEffect identifies this monster's destructive activated effect.
function s.destroyed_event(e,tp,eg,ep,ev,re,r,rp)
    local source=e:GetLabelObject()
    if not source then return end
    for tc in aux.Next(eg) do
        local reason_card=tc:GetReasonCard()
        local reason_effect=tc:GetReasonEffect()
        local battle=tc:IsReason(REASON_BATTLE) and
            (reason_card==source or
             (Duel.GetAttacker()==source and Duel.GetAttackTarget()==tc) or
             (Duel.GetAttackTarget()==source and Duel.GetAttacker()==tc))
        local effect=tc:IsReason(REASON_EFFECT) and
            (reason_card==source or
             (reason_effect and reason_effect:GetHandler()==source))
        if tc~=source and (battle or effect) then
            s.lock_name(source,source:GetOwner(),tc:GetOriginalCode())
        end
    end
end
