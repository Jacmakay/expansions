-- New Memory: Lost in the Maze of Chuhu
-- Rush Duel Normal Spell; card ID 190019116
local s,id=GetID()
local SHINIGAMI_ID=190019100
-- The Black Witch Facing The Temple (user-confirmed card ID).
local BLACK_WITCH_ID=160220048

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
function s.sendfilter(c,e,tp)
    return c:IsMonster() and c:IsAbleToGrave()
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_HAND,0,nil)>=2
            and Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    -- Send 1 monster from your hand, leaving another summonable monster in hand.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local sg=Duel.SelectMatchingCard(tp,s.sendfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    local sc=sg:GetFirst()
    if not sc or Duel.SendtoGrave(sc,REASON_EFFECT)==0 then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local hg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    local tc=hg:GetFirst()
    if not tc or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)==0 then return end
    -- Return exactly the monster sent by this effect, if its name qualifies.
    if sc:IsLocation(LOCATION_GRAVE) and sc:IsAbleToHand()
        and (sc:IsCode(SHINIGAMI_ID) or sc:IsCode(BLACK_WITCH_ID)) then
        Duel.BreakEffect()
        Duel.SendtoHand(sc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,Group.FromCards(sc))
    end
end
