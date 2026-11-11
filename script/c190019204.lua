-- Blue-Eyes Phantom Dragon
-- Custom EDOPro Rush Duel card - ID 190019204
-- Level 8 / LIGHT / Dragon / Effect / ATK 3000 / DEF 2500
--
-- Hand Special Summon: if you have a Level 8 LIGHT Dragon in your GY,
-- Special Summon this card from your hand in face-up Defense Position.
--
-- [REQUIREMENT] Send the top card of your Deck to the GY.
-- [EFFECT] This card's name becomes "Blue-Eyes White Dragon" this turn.
-- You may add from your GY either "Maximum Chaos Ritual" (190019209),
-- a Level 8 LIGHT Dragon, or "The Ultimate Blue-Eyed Legend" (160319027).
-- For the rest of this turn, you cannot activate the effects of
-- "Blue-Eyes Phantom Dragon" (including other copies).
--

local s,id=GetID()
local BLUE_EYES_WHITE_DRAGON=89631139
local MAXIMUM_CHAOS_RITUAL=190019209
local ULTIMATE_BLUE_EYED_LEGEND=160319027

s.listed_names={BLUE_EYES_WHITE_DRAGON,MAXIMUM_CHAOS_RITUAL,ULTIMATE_BLUE_EYED_LEGEND}

function s.initial_effect(c)
    -- Special Summon from hand in face-up Defense Position.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SPSUM_PARAM)
    e1:SetRange(LOCATION_HAND)
    e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- Rush Duel monster effect: once per turn per face-up copy.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DECKDES|CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.cost)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

-- Must already have a Level 8 LIGHT Dragon in the GY for the hand Summon.
function s.spfilter(c)
    return c:IsMonster() and c:IsLevel(8)
        and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_DRAGON)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end

-- [REQUIREMENT] Mill the top card as the cost to activate.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
    Duel.DiscardDeck(tp,1,REASON_COST)
end

-- The named cards OR any Level 8 LIGHT Dragon can be recovered.
function s.thfilter(c)
    if not c:IsAbleToHand() then return false end
    if c:IsCode(MAXIMUM_CHAOS_RITUAL) then return true end
    if c:IsCode(ULTIMATE_BLUE_EYED_LEGEND) then return true end
    return s.spfilter(c)
end

-- Block other copies even though this copy temporarily changes its name.
function s.aclimit(e,re,tp)
    local rc=re:GetHandler()
    return rc~=nil and rc:GetOriginalCode()==id
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsFaceup() then return end

    -- "Blue-Eyes White Dragon" name lasts until this turn's End Phase.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetValue(BLUE_EYES_WHITE_DRAGON)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
    c:RegisterEffect(e1)

    -- The activation lock applies for the rest of the current turn,
    -- even if this monster leaves the field.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetTargetRange(1,0)
    e2:SetValue(s.aclimit)
    e2:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e2,tp)

    -- Optional GY recovery after milling. Can recover the card milled.
    if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),
            tp,LOCATION_GRAVE,0,1,nil) then return end
    -- Custom database texts.str1: "Add an eligible card from your GY?"
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),
        tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
    end
end
