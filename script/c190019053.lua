-- U-T-W Garzett Mode Two
-- Custom Rush Duel Ritual/Effect Monster
-- Card ID: 190019053
-- Level 12 | DARK | Fiend | Ritual/Effect | ATK 0 / DEF 0

local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- [REQUIREMENT] Shuffle 3 monsters from your GY into the Deck.
    -- [EFFECT] Gain ATK and DEF equal to the combined ATK and DEF
    -- of those 3 monsters, respectively.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_DEFCHANGE|CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    -- This card's attacks pierce while a Fiend Ritual Monster
    -- is in your GY.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(3208)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e2:SetCode(EFFECT_PIERCE)
    e2:SetCondition(s.piercecon)
    c:RegisterEffect(e2)
end

function s.deckfilter(c)
    -- Rush Duel Ritual/Fusion Monsters in the GY can return to
    -- the Extra Deck when a requirement says to shuffle into the Deck.
    return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.deckfilter,tp,LOCATION_GRAVE,0,3,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Resolve the Rush Duel requirement first.
    if not Duel.IsExistingMatchingCard(s.deckfilter,tp,LOCATION_GRAVE,0,3,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.deckfilter,tp,LOCATION_GRAVE,0,3,3,nil)
    if #g~=3 then return end

    -- Record both totals before the monsters leave the GY.
    local atk,def=0,0
    for tc in g:Iter() do
        atk=atk+math.max(0,tc:GetAttack())
        def=def+math.max(0,tc:GetDefense())
    end
    if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)~=3 then return end

    -- The stat increases persist while this copy remains on the field.
    local c=e:GetHandler()
    if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(atk)
    e1:SetReset(RESET_EVENT|RESETS_STANDARD)
    c:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    e2:SetValue(def)
    c:RegisterEffect(e2)
end

function s.piercefilter(c)
    return c:IsRace(RACE_FIEND) and c:IsType(TYPE_RITUAL)
end

function s.piercecon(e)
    local c=e:GetHandler()
    return Duel.IsExistingMatchingCard(s.piercefilter,c:GetControler(),LOCATION_GRAVE,0,1,nil)
end
