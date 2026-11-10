-- Sineater Witch
-- Custom Rush Duel Fusion Monster
-- Card ID: 190019258
local s,id=GetID()

local SINEATER_FAIRY=190019253
local SEVENS_ROAD_WITCH=160013000
local SEVENS_ROAD_WITCH_VS=160401001
local SINEATER_ULTIMA_FUSION=190019257

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Fusion Materials: "Sineater Fairy" + "Sevens Road Witch".
    -- Also accepts the code used by Sineater Sevens Witch's name change.
    Fusion.AddProcMix(c,false,true,SINEATER_FAIRY,s.witchmat)

    -- Contact Fusion: shuffle the face-up listed materials you control
    -- into their owners' Decks instead of using a Fusion Spell.
    Fusion.AddContactProc({
        handler=c,
        materialFilter=s.contactmat,
        materialOperation=s.contactop,
        sumtype=SUMMON_TYPE_FUSION
    })

    -- [REQUIREMENT] None.
    -- [EFFECT] Special Summon 1 Level 6 or lower Spellcaster/Fiend/Fairy
    -- from your GY in face-up Defense Position. If it is Level 6,
    -- add "Sineater Ultima Fusion" from your GY to your hand.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

s.listed_names={SINEATER_FAIRY,SEVENS_ROAD_WITCH,SEVENS_ROAD_WITCH_VS,SINEATER_ULTIMA_FUSION}

-- Matches both official Rush Duel print IDs for Sevens Road Witch,
-- including the name assigned by c190019255.lua to Sineater Sevens Witch.
function s.witchmat(c,fc,sub,sub2,mg,sg,tp,contact,sumtype)
    return c:IsCode(SEVENS_ROAD_WITCH,SEVENS_ROAD_WITCH_VS)
end

function s.contactmat(tp)
    return Duel.GetMatchingGroup(s.contactfilter,tp,LOCATION_MZONE,0,nil)
end
function s.contactfilter(c)
    return c:IsFaceup() and c:IsMonster() and c:IsAbleToDeck()
end
function s.contactop(g,tp,c)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL|REASON_FUSION)
end

function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsLevelBelow(6)
        and c:IsRace(RACE_SPELLCASTER|RACE_FIEND|RACE_FAIRY)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
                tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.addfilter(c)
    return c:IsCode(SINEATER_ULTIMA_FUSION) and c:IsAbleToHand()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc then return end
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)==0 then return end

    -- The add-to-hand step only applies if the revived monster is Level 6.
    if not tc:IsLevel(6) then return end
    if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.addfilter),
        tp,LOCATION_GRAVE,0,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.addfilter),
        tp,LOCATION_GRAVE,0,1,1,nil)
    if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,sg)
    end
end
