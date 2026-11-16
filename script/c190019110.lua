-- The Forging of True Zangetsu (190019110) -- Normal Spell
local s,id=GetID()
local TRUE_SHIKAI=190019102
local BANKAI_RITUAL=190019111
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
function s.costfilter(c)
    return c:IsMonster() and c:IsRace(RACE_WARRIOR) and c:IsAbleToDeckAsCost()
end
function s.thfilter(c)
    return c:IsCode(TRUE_SHIKAI,BANKAI_RITUAL) and c:IsAbleToHand()
end
function s.spellfilter(c)
    return c:IsCode(BANKAI_RITUAL) and c:IsAbleToHand()
end
function s.shikaifilter(c)
    return c:IsCode(TRUE_SHIKAI) and c:IsAbleToHand()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local wg=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_GRAVE,0,nil)
    local cankeep=Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_GRAVE,0,1,nil)
        or (#wg>=3 and Duel.IsExistingMatchingCard(s.shikaifilter,tp,LOCATION_GRAVE,0,1,nil))
    if chk==0 then return #wg>=2 and cankeep end
    -- When the only retrievable card is True Shikai, reserve one copy so
    -- that the requirement cannot accidentally shuffle all targets away.
    if not Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_GRAVE,0,1,nil) then
        local keep=Duel.SelectMatchingCard(tp,s.shikaifilter,tp,LOCATION_GRAVE,0,1,1,nil)
        wg:Sub(keep)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=wg:Select(tp,2,2,nil)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
