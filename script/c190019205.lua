-- Jupiter the Arisen Heart
-- Custom EDOPro Rush Duel Fusion / Effect Monster
-- Card ID: 190019205
-- Level 10 / DARK / Galaxy / Fusion / Effect / ATK 3800 / DEF 2500
-- Materials: "Ultimecia the Titan of Endless Darkness" (190019201)
--          + "Jupiter the God From Another World" (190019200)
-- Can also be Contact Fusion Summoned using those face-up monsters
-- from your field, shuffling them into their owners' Decks.
-- [REQUIREMENT] During the Main Phase this card was Special Summoned.
-- [EFFECT] Change 1 opponent's monster to face-down Defense Position;
-- then you can return 1 card on their field to the bottom of its owner's Deck.

local s,id=GetID()
local ULTIMECIA=190019201
local JUPITER=190019200
s.listed_names={ULTIMECIA,JUPITER}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Normal Fusion Summon: exactly these two named monsters.
    Fusion.AddProcMix(c,true,true,ULTIMECIA,JUPITER)

    -- Alternative Contact Fusion from your own face-up Monster Zone.
    -- The Fusion helper checks that the two correct materials are used.
    Fusion.AddContactProc(c,s.contactfilter,s.contactop,
        nil,nil,SUMMON_TYPE_FUSION,nil,false)

    -- Remember a Special Summon performed during your Main Phase.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetOperation(s.summonop)
    c:RegisterEffect(e0)

    -- Rush Duel effect: once per turn for this face-up copy.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_POSITION|CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- A Contact Fusion may only use face-up monsters you control that can
-- be returned to their owners' Decks/Extra Decks.
function s.contactmat(c)
    return c:IsFaceup() and c:IsMonster()
        and c:IsAbleToDeckOrExtraAsCost()
end
function s.contactfilter(tp)
    return Duel.GetMatchingGroup(s.contactmat,tp,LOCATION_MZONE,0,nil)
end
function s.contactop(g,tp,fc)
    fc:SetMaterial(g)
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,
        REASON_COST|REASON_MATERIAL|REASON_FUSION)
end

-- Flag applies only in the Main Phase in which THIS copy was summoned.
function s.summonop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_MAIN1 then
        e:GetHandler():RegisterFlagEffect(id,
            RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,0,1)
    end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
        and Duel.GetCurrentPhase()==PHASE_MAIN1
        and e:GetHandler():GetFlagEffect(id)>0
end

function s.posfilter(c)
    return c:IsMonster() and c:IsFaceup() and c:IsCanTurnSet()
end
function s.deckfilter(c)
    return c:IsAbleToDeck()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,POS_FACEDOWN_DEFENSE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Choose at resolution (Rush Duel effects do not target here).
    if not Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil) then
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,0,LOCATION_MZONE,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end
    Duel.HintSelection(g)

    -- The optional Deck return happens only if the position change succeeds.
    if Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)==0 then return end

    local dg=Duel.GetMatchingGroup(s.deckfilter,tp,0,LOCATION_ONFIELD,nil)
    if #dg==0 then return end

    -- texts.str2 in the custom .cdb:
    -- "Return 1 card your opponent controls to the bottom of the Deck?"
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end

    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg=Duel.SelectMatchingCard(tp,s.deckfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
    if #sg==0 then return end
    Duel.HintSelection(sg)
    -- nil preserves original ownership; Fusion monsters return to Extra Deck.
    Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
end
