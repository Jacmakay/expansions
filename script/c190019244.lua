-- Dragonridge the Father That Never Was
-- Custom EDOPro Rush Duel Fusion Monster (190019244)
local s,id=GetID()
local DRACORIDGE=190019242

function s.initial_effect(c)
    -- "Dracoridge" + 1 Level 7 or higher DARK Dragon
    c:EnableReviveLimit()
    Fusion.AddProcMix(c,false,false,DRACORIDGE,s.matfilter)

    -- [REQUIREMENT] Send the top 2 cards of your Deck to the GY.
    -- [EFFECT] Set the ATK of up to 3 opposing monsters to 0;
    -- Special Summon 1 monster from your GY, then destroy 1 opposing
    -- Spell/Trap if the Summoned monster is a Dragon.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DECKDES|CATEGORY_ATKCHANGE|CATEGORY_SPECIAL_SUMMON|CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.matfilter(c)
    return c:IsLevelAbove(7) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DRAGON)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
    Duel.DiscardDeck(tp,2,REASON_COST)
end

function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

function s.atkfilter(c)
    return c:IsFaceup() and c:IsMonster()
end

function s.desfilter(c)
    return c:IsDestructable()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- The 2 milled cards may become eligible revival targets.
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local sg=g:Select(tp,0,math.min(3,#g),nil)
        for tc in aux.Next(sg) do
            local ae=Effect.CreateEffect(e:GetHandler())
            ae:SetType(EFFECT_TYPE_SINGLE)
            ae:SetCode(EFFECT_SET_ATTACK_FINAL)
            ae:SetValue(0)
            ae:SetReset(RESET_EVENT|RESETS_STANDARD)
            tc:RegisterEffect(ae)
        end
    end

    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local rg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,
        LOCATION_GRAVE,0,nil,e,tp)
    if #rg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=rg:Select(tp,1,1,nil):GetFirst()
    if not tc then return end
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    if not tc:IsRace(RACE_DRAGON) then return end
    local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_SZONE,nil)
    if #dg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local sg=dg:Select(tp,1,1,nil)
    Duel.Destroy(sg,REASON_EFFECT)
end
