--Dragonridge the Father That Never Was
--Custom Rush Duel Fusion Monster
--Card ID: 190019244
local s,id=GetID()
local DRACORIDGE=190019242

function s.initial_effect(c)
    --Fusion Materials: "Dracoridge" + 1 Level 7 or higher DARK Dragon
    c:EnableReviveLimit()
    RD.AddCodeList(c,{DRACORIDGE})
    RD.AddFusionProcedure(c,false,false,DRACORIDGE,s.matfilter)

    --[REQUIREMENT] Send the top 2 cards of your Deck to the Graveyard.
    --[EFFECT] Make up to 3 opponent's monsters have 0 ATK;
    --Special Summon 1 monster from your GY. If it is a Dragon,
    --destroy 1 card in your opponent's Spell & Trap Zones.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DECKDES+CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCost(RD.CostSendDeckTopToGrave(2))
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--The unnamed Fusion Material
function s.matfilter(c)
    return c:IsLevelAbove(7)
        and c:IsAttribute(ATTRIBUTE_DARK)
        and c:IsRace(RACE_DRAGON)
end

function s.spfilter(c,e,tp)
    return c:IsType(TYPE_MONSTER)
        and RD.IsCanBeSpecialSummoned(c,e,tp,POS_FACEUP)
end

function s.atkfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end

function s.desfilter(c)
    return c:IsDestructable()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        --A legal revival might become available after milling 2 cards.
        return Duel.GetMZoneCount(tp)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    --Step 1: Set the ATK of up to 3 face-up opposing monsters to 0.
    --No end-of-turn duration is stated on this custom card.
    local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local sg=g:Select(tp,0,math.min(3,#g),nil)
        for tc in aux.Next(sg) do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_ATTACK_FINAL)
            e1:SetValue(0)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end

    --Step 2: Revive exactly 1 eligible monster from your Graveyard.
    if Duel.GetMZoneCount(tp)<=0 then return end
    local rg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,
        LOCATION_GRAVE,0,nil,e,tp)
    if #rg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=rg:Select(tp,1,1,nil):GetFirst()
    if not tc then return end
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    --Step 3: Only if the summoned monster is a Dragon,
    --destroy 1 of the opponent's Spell/Trap Zone cards.
    if not tc:IsRace(RACE_DRAGON) then return end
    local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_SZONE,nil)
    if #dg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local sg=dg:Select(tp,1,1,nil)
    Duel.Destroy(sg,REASON_EFFECT)
end
