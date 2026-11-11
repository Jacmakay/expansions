-- @Singularity Sineater Firewall Dragon
-- Custom EDOPro Rush Duel Ritual/Effect Monster
-- Card ID: 190019260
local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- This card is treated as a Fiend monster while in the Graveyard.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CHANGE_RACE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetValue(RACE_FIEND)
    c:RegisterEffect(e1)

    -- [REQUIREMENT] Shuffle 1 Fiend, 1 Spellcaster and 1 Fairy
    -- monster from your Graveyard into the Deck.
    -- [EFFECT] Bounce 2 opposing cards, recover 1 monster,
    -- then gain 1500 ATK and effect-destruction protection
    -- through the end of the opponent's next turn.
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND|CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

-- A monster that can actually be returned to the Deck as a cost.
function s.costfilter(c)
    return c:IsMonster() and c:IsAbleToDeckAsCost()
        and c:IsRace(RACE_FIEND|RACE_SPELLCASTER|RACE_FAIRY)
end

function s.thfilter(c)
    return c:IsMonster() and c:IsAbleToHand()
end

-- Exactly three DIFFERENT cards must fulfill the three Type roles.
-- This also handles monsters that possess multiple Types.
function s.costcheck(g,tp)
    local cards={}
    local tc=g:GetFirst()
    while tc do
        cards[#cards+1]=tc
        tc=g:GetNext()
    end
    if #cards~=3 then return false end

    local assigned=false
    for i=1,3 do
        if cards[i]:IsRace(RACE_FIEND) then
            for j=1,3 do
                if i~=j and cards[j]:IsRace(RACE_SPELLCASTER) then
                    local k=6-i-j -- remaining index among 1, 2, 3
                    if cards[k]:IsRace(RACE_FAIRY) then
                        assigned=true
                        break
                    end
                end
            end
        end
        if assigned then break end
    end
    if not assigned then return false end

    -- There must be a monster left to recover after paying the cost.
    local rg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),
        tp,LOCATION_GRAVE,0,nil)
    rg:Sub(g)
    return #rg>0
end

-- Compatibility: enumerate legal groups of exactly three cards without
-- Group.CheckSubGroup / Group.SelectSubGroup, which are not present in
-- some older Rush Duel simulator cores.
function s.getvalidtriples(g,tp)
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
                local test=Group.CreateGroup()
                test:AddCard(cards[i])
                test:AddCard(cards[j])
                test:AddCard(cards[k])
                if s.costcheck(test,tp) then
                    triples[#triples+1]={cards[i],cards[j],cards[k]}
                end
            end
        end
    end
    return triples
end

-- Let the player pick each card, showing only selections that can still
-- complete a legal Fiend / Spellcaster / Fairy group of three.
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
        if not pick or #pick==0 then return nil end
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
    local triples=s.getvalidtriples(g,tp)
    if chk==0 then
        return #triples>0
    end
    local sg=s.selectcost(triples,tp)
    if sg and #sg==3 then
        Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
    end
end

function s.bouncefilter(c)
    return c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.bouncefilter,
            tp,0,LOCATION_ONFIELD,2,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,1-tp,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(s.bouncefilter,
        tp,0,LOCATION_ONFIELD,2,nil) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local bg=Duel.SelectMatchingCard(tp,s.bouncefilter,
        tp,0,LOCATION_ONFIELD,2,2,nil)
    if #bg~=2 or Duel.SendtoHand(bg,nil,REASON_EFFECT)~=2 then return end

    local filter=aux.NecroValleyFilter(s.thfilter)
    if not Duel.IsExistingMatchingCard(filter,
        tp,LOCATION_GRAVE,0,1,nil) then return end

    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=Duel.SelectMatchingCard(tp,filter,
        tp,LOCATION_GRAVE,0,1,1,nil)
    if #sg==0 or Duel.SendtoHand(sg,nil,REASON_EFFECT)==0 then return end

    -- 2 End Phases: this turn's End Phase + your opponent's End Phase.
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end
    local reset=RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(1500)
    e1:SetReset(reset,2)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(1)
    e2:SetReset(reset,2)
    c:RegisterEffect(e2)
end
