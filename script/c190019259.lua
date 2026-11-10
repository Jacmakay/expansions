-- Knightmare Overlimit Sineater Witch
-- Custom EDOPro / Rush Duel
-- Card ID: 190019259
-- Level 10 DARK / Fiend / Fusion / Effect / ATK 2900 / DEF 2500
--
-- Sineater Fairy custom card ID verified from its original script: 190019253.
-- "Sevens Road Witch" uses Rush ID 160013000 (alias of 160401001).

local s,id=GetID()
local SINEATER_FAIRY=190019253
local SEVENS_ROAD_WITCH=160401001
s.listed_names={SINEATER_FAIRY,SEVENS_ROAD_WITCH}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Fusion Materials: "Sineater Fairy" + "Sevens Road Witch"
    Fusion.AddProcMix(c,false,false,SINEATER_FAIRY,SEVENS_ROAD_WITCH)

    -- [Requirement] Shuffle 2 Spells from your opponent's GY into their Deck.
    -- [Effect] Shuffle 1 monster from EACH field into the Decks, then
    -- add 1 Spell from your GY to your hand.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK|CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Cost: 2 Spell Cards from the opponent's GY.
function s.costfilter(c)
    return c:IsSpell() and c:IsAbleToDeckAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,0,LOCATION_GRAVE,2,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg=Duel.SelectMatchingCard(tp,s.costfilter,tp,0,LOCATION_GRAVE,2,2,nil)
    Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end

function s.monfilter(c)
    return c:IsMonster() and c:IsAbleToDeck()
end
function s.spellfilter(c)
    return c:IsSpell() and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_MZONE,0,1,nil)
           and Duel.IsExistingMatchingCard(s.monfilter,tp,0,LOCATION_MZONE,1,nil)
           and Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,PLAYER_ALL,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Choose 1 monster from each player's field at resolution.
    if not Duel.IsExistingMatchingCard(s.monfilter,tp,LOCATION_MZONE,0,1,nil)
        or not Duel.IsExistingMatchingCard(s.monfilter,tp,0,LOCATION_MZONE,1,nil) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g1=Duel.SelectMatchingCard(tp,s.monfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g2=Duel.SelectMatchingCard(tp,s.monfilter,tp,0,LOCATION_MZONE,1,1,nil)
    if #g1~=1 or #g2~=1 then return end

    g1:Merge(g2)
    -- Send to owners' Decks (Fusion Monsters return to the Extra Deck).
    if Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=2 then return end

    -- Then add 1 Spell from your Graveyard to your hand, if possible.
    Duel.BreakEffect()
    if not Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_GRAVE,0,1,nil) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,sg)
    end

    -- "You can activate 1 Spell Card after this effect":
    -- In Rush Duel, the player may activate a legal Spell during the Main
    -- Phase after this chain finishes. There is no extra activation limit
    -- to lift, so no separate effect is needed for that sentence.
end
