--Luminescent Soul Auroa
--Custom EDOPro Rush Duel card - ID 190019292
local s,id=GetID()

function s.initial_effect(c)
    -- Card-name activation count is handled by SetCountLimit(1,id).

    --Can be Normal Summoned without Tributing if you control a
    --face-up Level 10 or lower monster. The usual Summon remains possible.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SUMMON_PROC)
    e0:SetCondition(s.ntcon)
    c:RegisterEffect(e0)

    --[REQUIREMENT] You have not activated "Luminescent Soul Auroa" this turn.
    --[EFFECT] Destroy 1 card you control, then turn an opponent's monster
    --face-down. If a Spell/Trap was destroyed, optionally return an
    --opponent's field card to the bottom of its owner's Deck.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_POSITION+CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--Alternative Normal Summon with 0 Tributes.
function s.lvfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(10)
end
function s.ntcon(e,c,minc)
    if c==nil then return true end
    local tp=c:GetControler()
    return minc==0
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return true -- native count limit prevents extra activations
end

function s.desfilter(c)
    return c:IsDestructable()
end
function s.posfilter(c)
    return c:IsFaceup() and c:IsCanTurnSet()
end
function s.deckfilter(c)
    return c:IsAbleToDeck()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
            and Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_ONFIELD)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    --Destroy exactly 1 card on your field (Auroa itself is permitted).
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    local dc=dg:GetFirst()
    if not dc then return end
    local was_spell_trap=dc:IsType(TYPE_SPELL|TYPE_TRAP)
    if Duel.Destroy(dg,REASON_EFFECT)==0 then return end

    --Then, change 1 of your opponent's eligible monsters to face-down DEF.
    local pg=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
    if #pg>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
        local sg=pg:Select(tp,1,1,nil)
        Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
    end

    --Only if the card destroyed by this effect was a Spell or Trap.
    --Cards set or newly placed on the field can be selected, if legal.
    if not was_spell_trap then return end
    local g=Duel.GetMatchingGroup(s.deckfilter,tp,0,LOCATION_ONFIELD,nil)
    if #g==0 then return end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local tg=g:Select(tp,1,1,nil)
    Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
end
