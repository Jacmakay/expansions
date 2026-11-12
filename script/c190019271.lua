-- U-T-W Weapon's Mode: Yorishiro
-- Custom EDOPro Rush Duel Effect Monster
-- Card ID: 190019271
-- Level 4 / EARTH / Beast-Warrior / Effect / ATK 1000 / DEF 1500
--
-- EDOPro Rush Duel set KP24 card passcodes:
--   Yorishiro of Isyria      160024008 (RD/KP24-JP008)
--   Offering to Isyria       160024047 (RD/KP24-JP047)
--   Sarcophagus of Isyria    160024048 (RD/KP24-JP048)
--   Spirit of Isyria         160024061 (RD/KP24-JP061)
--
-- While face-up on the field, this card's name is "Yorishiro of Isyria".
-- [REQUIREMENT] Send 2 Beast-Warrior monsters from your hand and/or
-- your field to the Graveyard.
-- [EFFECT] Add 1 "Offering to Isyria" OR "Sarcophagus of Isyria",
-- AND 1 "Spirit of Isyria" from your Graveyard to your hand.
-- If you have a Ritual Spell in your Graveyard, you can destroy
-- 1 card in your opponent's Spell/Trap Zones.

local s,id=GetID()

local YORISHIRO=160024008
local OFFERING=160024047
local SARCOPHAGUS=160024048
local SPIRIT=160024061

s.listed_names={YORISHIRO,OFFERING,SARCOPHAGUS,SPIRIT}

function s.initial_effect(c)
    -- Treat this face-up monster as "Yorishiro of Isyria".
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetCondition(s.namecon)
    e0:SetValue(YORISHIRO)
    c:RegisterEffect(e0)

    -- Rush Duel monster effect: once per turn per face-up copy.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_TOHAND|CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

function s.namecon(e)
    return e:GetHandler():IsFaceup()
end

-- The Requirement can use Beast-Warriors in the hand or on the field.
-- It is permitted to send this monster itself if it is one of the two.
function s.costfilter(c)
    return c:IsMonster() and c:IsRace(RACE_BEASTWARRIOR)
        and c:IsAbleToGraveAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,
            LOCATION_HAND|LOCATION_MZONE,0,2,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,
        LOCATION_HAND|LOCATION_MZONE,0,2,2,nil)
    if #g==2 then
        Duel.SendtoGrave(g,REASON_COST)
    end
end

function s.firstfilter(c)
    return c:IsCode(OFFERING,SARCOPHAGUS) and c:IsAbleToHand()
end

function s.spiritfilter(c)
    return c:IsCode(SPIRIT) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.firstfilter),
                tp,LOCATION_GRAVE,0,1,nil)
            and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spiritfilter),
                tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_SZONE)
end

function s.ritualfilter(c)
    return c:IsType(TYPE_SPELL) and c:IsType(TYPE_RITUAL)
end

function s.desfilter(c)
    return c:IsDestructable()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Recover exactly one of the first pair and one Spirit of Isyria.
    local f1=aux.NecroValleyFilter(s.firstfilter)
    local f2=aux.NecroValleyFilter(s.spiritfilter)
    if not Duel.IsExistingMatchingCard(f1,tp,LOCATION_GRAVE,0,1,nil)
        or not Duel.IsExistingMatchingCard(f2,tp,LOCATION_GRAVE,0,1,nil) then
        return
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g1=Duel.SelectMatchingCard(tp,f1,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g1~=1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g2=Duel.SelectMatchingCard(tp,f2,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g2~=1 then return end

    g1:Merge(g2)
    if Duel.SendtoHand(g1,nil,REASON_EFFECT)<2 then return end
    Duel.ConfirmCards(1-tp,g1)

    -- Additional destruction is optional, not a requirement.
    -- Check for a Ritual Spell after the cards are recovered.
    if not Duel.IsExistingMatchingCard(s.ritualfilter,
            tp,LOCATION_GRAVE,0,1,nil) then return end
    if not Duel.IsExistingMatchingCard(s.desfilter,
            tp,0,LOCATION_SZONE,1,nil) then return end
    if not Duel.SelectEffectYesNo(tp,e:GetHandler()) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,
        0,LOCATION_SZONE,1,1,nil)
    if #dg>0 then
        Duel.Destroy(dg,REASON_EFFECT)
    end
end
