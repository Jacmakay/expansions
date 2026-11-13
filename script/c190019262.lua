-- Sineater Heart Iblee the Key Bearer
-- EDOPro Rush Duel - 190019262
local s,id=GetID()

-- Named Fusion Materials:
-- Sineater Fairy + Sevens Road Witch (or Sineater Sevens Witch)
-- + Sineater Dark Knight.
local SINEATER_FAIRY=190019253
local SEVENS_ROAD_WITCH=160401001
local SEVENS_ROAD_WITCH_ALT=160013000
local SINEATER_SEVENS_WITCH=190019255
local SINEATER_DARK_KNIGHT=190019254

-- Do not use RD.AddFusionProcedure / RD.AddCodeList here: RD may be nil.
function s.witchfilter(c,fc,sumtype,tp)
    return c:IsCode(SEVENS_ROAD_WITCH,SEVENS_ROAD_WITCH_ALT,SINEATER_SEVENS_WITCH)
end

function s.initial_effect(c)
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,false,false,SINEATER_FAIRY,s.witchfilter,SINEATER_DARK_KNIGHT)

    -- [REQUIREMENT] Shuffle exactly 1 DARK Fiend, 1 DARK Spellcaster,
    -- and 1 DARK Fairy monster from your GY into the Deck.
    -- [EFFECT] This card gains 5000 ATK until the end of your
    -- opponent's next turn. The opponent cannot activate Set S/T
    -- cards that were already Set when this effect resolved.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK|CATEGORY_ATKCHANGE)
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
        and c:IsRace(RACE_FIEND|RACE_SPELLCASTER|RACE_FAIRY)
end

-- A valid triple uses three DISTINCT cards, with one assigned to
-- each of the Fiend / Spellcaster / Fairy requirements. It also
-- works if a monster counts as more than one Race.
function s.validtriple(a,b,c)
    local cards={a,b,c}
    for i=1,3 do
        if cards[i]:IsRace(RACE_FIEND) then
            for j=1,3 do
                if i~=j and cards[j]:IsRace(RACE_SPELLCASTER) then
                    local k=6-i-j
                    if cards[k]:IsRace(RACE_FAIRY) then return true end
                end
            end
        end
    end
    return false
end

-- Enumerate all legal triples instead of using CheckSubGroup or
-- SelectSubGroup, which are missing from some Rush Duel cores.
function s.getvalidtriples(g)
    local cards={}
    local tc=g:GetFirst()
    while tc do
        cards[#cards+1]=tc
        tc=g:GetNext()
    end

    local triples={}
    for i=1,#cards-2 do
        for j=i+1,#cards-1 do
            for k=j+1,#cards do
                if s.validtriple(cards[i],cards[j],cards[k]) then
                    triples[#triples+1]={cards[i],cards[j],cards[k]}
                end
            end
        end
    end
    return triples
end

-- Each pick is restricted to cards belonging to a legal remaining
-- triple, preventing the player from choosing an impossible cost.
function s.selectcost(triples,tp)
    local selected=Group.CreateGroup()
    local remaining=triples
    for step=1,3 do
        local options=Group.CreateGroup()
        for _,triple in ipairs(remaining) do
            for _,tc in ipairs(triple) do
                if not selected:IsContains(tc) then
                    options:AddCard(tc)
                end
            end
        end
        if #options==0 then return nil end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local pick=options:Select(tp,1,1,nil)
        if not pick or #pick~=1 then return nil end
        local chosen=pick:GetFirst()
        selected:AddCard(chosen)

        local nextremaining={}
        for _,triple in ipairs(remaining) do
            for _,tc in ipairs(triple) do
                if tc==chosen then
                    nextremaining[#nextremaining+1]=triple
                    break
                end
            end
        end
        remaining=nextremaining
    end
    return selected
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_GRAVE,0,nil)
    local triples=s.getvalidtriples(g)
    if chk==0 then return #triples>0 end

    local sg=s.selectcost(triples,tp)
    if sg and #sg==3 then
        Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,0,5000)
end

function s.setfilter(c)
    return c:IsFacedown() and c:IsType(TYPE_SPELL|TYPE_TRAP)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Two End Phases: your turn's End Phase, then the opponent's.
    local reset=RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(5000)
        e1:SetReset(reset,2)
        c:RegisterEffect(e1)
    end

    -- Only the opponent's S/T cards Set at resolution are locked;
    -- cards Set later are unaffected. The lock expires after the
    -- opponent's next End Phase or if a card leaves the field.
    local g=Duel.GetMatchingGroup(s.setfilter,tp,0,LOCATION_SZONE,nil)
    for tc in aux.Next(g) do
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e2:SetCode(EFFECT_CANNOT_TRIGGER)
        e2:SetValue(1)
        e2:SetReset(reset|RESET_CONTROL,2)
        tc:RegisterEffect(e2)
    end
end
