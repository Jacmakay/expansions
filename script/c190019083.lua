--U-T-S Majestic Mirage
--Custom Rush Duel Fusion / Effect Monster
--Assumed Card ID: 190019083 (change the filename and database ID if different)
--4 Level 9 monsters
local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMixN(c,true,true,s.matfilter,4)

    --[REQUIREMENT] Shuffle 3 Level 1 and/or Level 9 monsters
    --from your Graveyard into the Deck.
    --[EFFECT] This card can make up to 3 attacks on monsters this turn,
    --and cannot be returned to the Extra Deck from the field by card effects
    --until the end of your opponent's next turn.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--Fusion Material: exactly 4 Level 9 monsters.
function s.matfilter(c,scard,sumtype,tp)
    return c:IsLevel(9)
end

--Only Level 1 or Level 9 monsters that can be returned to the Deck/Extra Deck.
function s.tdfilter(c)
    return c:IsMonster() and (c:IsLevel(1) or c:IsLevel(9))
        and c:IsAbleToDeckOrExtraAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,3,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,3,3,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end

    --Two extra attacks on monsters = three monster attacks total.
    --The attack grant expires at the end of this turn.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
    e1:SetValue(2)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    c:RegisterEffect(e1)

    --Prevent this on-field Fusion Monster from returning to the
    --Extra Deck. The restriction lasts through the opponent's next
    --End Phase (two End Phases from your Main Phase activation).
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_CANNOT_TO_DECK)
    e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,2)
    c:RegisterEffect(e2)
end
