-- Wisela of Transcendence
-- Card ID: 190019004
local s, id = GetID()
function s.initial_effect(c)
    -- Rush Duel Ignition Effect
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(190019004, 0))
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- REQUIREMENT: Send the top 2 cards of your Deck to the Graveyard
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp, 2) end
    Duel.DiscardDeck(tp, 2, REASON_COST)
end

-- Filter targeting Level 4 or lower DARK Galaxy monsters in the GY
function s.filter(c)
    return c:IsType(TYPE_MONSTER) and c:GetLevel() <= 4 and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY) and c:IsAbleToHand()
end

-- Target Block: Ensures activation is permitted independently of current GY status
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then 
        return e:GetHandler():IsFaceup() and Duel.IsPlayerCanDiscardDeckAsCost(tp, 2)
    end
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end

-- EFFECT: Name becomes Contact Dark Matter Wyvern & optional recovery
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        -- This card's name becomes "Contact Dark Matter Wyvern"
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(160018003) -- Contact Dark Matter Wyvern ID
        -- Until the end of your opponent's next turn
        if Duel.GetTurnPlayer() == tp then
            e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END + RESET_OPPO_TURN, 1)
        else
            e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END + RESET_OPPO_TURN, 2)
        end
        c:RegisterEffect(e1)
        
        -- Then you can add one level 4 or lower Dark Galaxy monster from your Graveyard to your hand
        local g = Duel.GetMatchingGroup(s.filter, tp, LOCATION_GRAVE, 0, nil)
        if #g > 0 and Duel.SelectYesNo(e:GetHandlerPlayer(), aux.Stringid(190019004, 1)) then
            Duel.BreakEffect()
            -- FIXED: Replaced standard macro names with raw numeric tokens to stabilize engine
            Duel.Hint(1, tp, 506)
            local sg = g:Select(tp, 1, 1, nil)
            if #sg > 0 then
                local tc = sg:GetFirst()
                if tc then
                    Duel.SendtoHand(tc, tp, REASON_EFFECT)
                end
            end
        end
    end
end