-- U-T-W Weapons Mode: Emir Phoenix Mode
-- Custom EDOPro Rush Duel Ritual / Effect Monster
-- Provisional card ID: 190019272 (change filename if your .cdb uses another ID)
-- Level 9 / EARTH / Beast-Warrior / Ritual / Effect
-- ATK 3000 / DEF 2500
--
-- [REQUIREMENT] Pay 1000 LP and shuffle 2 Beast-Warrior monsters
-- from your Graveyard into the Deck.
-- [EFFECT] Destroy 1 card on your opponent's field. Then all
-- face-up Beast-Warrior monsters on both fields gain 1000 ATK
-- and cannot be destroyed by card effects until the end
-- of your opponent's turn.
--
-- Rush Duel Ritual Summoning is handled by a separate Ritual Spell.

local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Rush Duel: one activation per turn for each face-up copy.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK|CATEGORY_DESTROY|CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- Beast-Warrior Ritual monsters can return to the Extra Deck in Rush Duel.
function s.reqfilter(c)
    return c:IsMonster() and c:IsRace(RACE_BEASTWARRIOR)
        and c:IsAbleToDeckOrExtraAsCost()
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.CheckLPCost(tp,1000)
            and Duel.IsExistingMatchingCard(s.reqfilter,
                tp,LOCATION_GRAVE,0,2,nil)
    end
    Duel.PayLPCost(tp,1000)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.reqfilter,
        tp,LOCATION_GRAVE,0,2,2,nil)
    if #g==2 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
    end
end

-- Any destructible card on the opponent's field, not just monsters.
function s.desfilter(c)
    return c:IsDestructable()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.desfilter,
            tp,0,LOCATION_ONFIELD,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end

-- Field-wide filter: this is evaluated continuously, so new Beast-Warriors
-- that appear AFTER activation also receive both effects while face-up.
function s.bwfilter(e,c)
    return c:IsFaceup() and c:IsMonster()
        and c:IsRace(RACE_BEASTWARRIOR)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Rush Duel effect: choose an opposing card during resolution.
    if not Duel.IsExistingMatchingCard(s.desfilter,
        tp,0,LOCATION_ONFIELD,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,s.desfilter,
        tp,0,LOCATION_ONFIELD,1,1,nil)
    if #dg==0 or Duel.Destroy(dg,REASON_EFFECT)==0 then return end

    -- "Then": only create the field-wide bonuses after a successful destroy.
    -- Because these are DUEL-REGISTERED field effects, they keep applying to
    -- ALL face-up Beast-Warriors on BOTH fields, including those summoned
    -- later, even if Emir Phoenix Mode subsequently leaves the field.
    -- The 2 End Phase reset lasts through the end of the opponent's turn.
    local reset=RESET_PHASE|PHASE_END

    -- +1000 ATK to every face-up Beast-Warrior on either field.
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e1:SetTarget(s.bwfilter)
    e1:SetValue(1000)
    e1:SetReset(reset,2)
    Duel.RegisterEffect(e1,tp)

    -- All face-up Beast-Warriors on either field cannot be destroyed
    -- by card effects, including newly summoned Beast-Warriors.
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(s.bwfilter)
    e2:SetValue(1)
    e2:SetReset(reset,2)
    Duel.RegisterEffect(e2,tp)
end
