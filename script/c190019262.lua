--Sineater Heart Iblee the Key Bearer
--Custom Rush Duel card - 190019262
local s,id=GetID()

--Named Fusion Materials:
--Sineater Fairy: 190019253
--Sevens Road Witch: 160401001 (alternate Rush ID: 160013000)
--Sineater Sevens Witch: 190019255 (custom Sevens Road Witch variant)
--Sineater Dark Knight: 190019254
local mat_fairy=190019253
local mat_witch={160401001,160013000,190019255}
local mat_knight=190019254

function s.initial_effect(c)
    c:EnableReviveLimit()
    --Fusion: Sineater Fairy + Sevens Road Witch + Sineater Dark Knight
    RD.AddCodeList(c,{mat_fairy,160401001,160013000,190019255,mat_knight})
    RD.AddFusionProcedure(c,false,false,mat_fairy,mat_witch,mat_knight)

    --[Requirement] Shuffle 1 DARK Fiend, 1 DARK Spellcaster and
    --1 DARK Fairy monster from your GY into their owners' Decks.
    --[Effect] Gain 5000 ATK through the opponent's next End Phase;
    --the opponent cannot activate their currently Set S/T cards
    --through that same End Phase.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.costfilter(c)
    return c:IsType(TYPE_MONSTER)
        and c:IsAttribute(ATTRIBUTE_DARK)
        and c:IsAbleToDeckAsCost()
        and (c:IsRace(RACE_FIEND)
            or c:IsRace(RACE_SPELLCASTER)
            or c:IsRace(RACE_FAIRY))
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_GRAVE,0,nil)
    if chk==0 then
        return g:CheckSubGroup(aux.gfcheck,3,3,
            Card.IsRace,RACE_FIEND,RACE_SPELLCASTER,RACE_FAIRY)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg=g:SelectSubGroup(tp,aux.gfcheck,false,3,3,
        Card.IsRace,RACE_FIEND,RACE_SPELLCASTER,RACE_FAIRY)
    if sg then
        Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,5000)
end

function s.setfilter(c)
    return c:IsFacedown() and c:IsLocation(LOCATION_SZONE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    --The effect lasts until the end of the opponent's next turn.
    --An Ignition Effect is used on your turn, so this is 2 End Phases.
    local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(5000)
        e1:SetReset(reset,2)
        c:RegisterEffect(e1)
    end

    --Only cards Set at resolution are locked. New Sets aren't affected.
    local g=Duel.GetMatchingGroup(s.setfilter,tp,0,LOCATION_SZONE,nil)
    for tc in aux.Next(g) do
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e2:SetCode(EFFECT_CANNOT_TRIGGER)
        e2:SetValue(1)
        e2:SetReset(reset,2)
        tc:RegisterEffect(e2)
    end
end
