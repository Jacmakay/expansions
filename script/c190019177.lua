-- Sophia Goddess of Rebirth
-- Level 11 DARK Fairy/Effect; card ID 190019177
local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_FUSION)>=2
        and Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_RITUAL)>=1
end
function s.getbottom(p)
    local ct=Duel.GetFieldGroupCount(p,LOCATION_DECK,0)
    if ct==0 then return nil end
    local dg=Duel.GetDecktopGroup(p,ct)
    return dg:Filter(function(c,n) return c:GetSequence()==n-1 end,nil,ct):GetFirst()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local all=Duel.GetFieldGroup(tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE,
                                     LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE)
    all:RemoveCard(c)
    -- Shuffle all other cards on the field, in both hands and both GYs into
    -- their owners' Decks (Extra Deck monsters return to the Extra Deck).
    if #all>0 then Duel.SendtoDeck(all,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end
    Duel.BreakEffect()
    local choices=Group.CreateGroup()
    for p=0,1 do
        local tc=s.getbottom(p)
        if tc then
            -- Show that player their bottom card; reveal to both for verification.
            Duel.ConfirmCards(0,Group.FromCards(tc))
            Duel.ConfirmCards(1,Group.FromCards(tc))
            if tc:IsMonster() then
                if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) then
                    choices:AddCard(tc)
                end
            elseif tc:IsAbleToGrave() then
                Duel.SendtoGrave(tc,REASON_EFFECT)
            end
        end
    end
    -- Summon at most one qualifying bottom-deck monster, from either Deck.
    if #choices>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=choices:Select(tp,1,1,nil)
        if #g>0 then Duel.SpecialSummon(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP_ATTACK) end
    end
end
