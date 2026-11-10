-- Salamandus Heat Leo
-- Custom EDOPro Rush Duel monster: 190019248
-- Level 9 / FIRE / Pyro / Effect / ATK 2500 / DEF 2000
local s,id=GetID()
local CHEMICALIZED_SALAMANDER=160010020
local MAXIMUM_FLARE_FUSION=160019049 -- RD/KP19-JP049
s.listed_names={CHEMICALIZED_SALAMANDER,MAXIMUM_FLARE_FUSION}

function s.initial_effect(c)
    -- This card's name is "Chemicalized Salamander" while face-up.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetCondition(s.namecon)
    e1:SetValue(CHEMICALIZED_SALAMANDER)
    c:RegisterEffect(e1)

    -- You can Special Summon this card from the hand in face-up Defense Position
    -- if your GY contains a FIRE Maximum monster or "Chemicalized Salamander".
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SPSUM_PARAM)
    e2:SetRange(LOCATION_HAND)
    e2:SetTargetRange(POS_FACEUP_DEFENSE,0)
    e2:SetCondition(s.spcon)
    c:RegisterEffect(e2)

    -- [Requirement] Send the top 2 cards of your Deck to the GY.
    -- [Effect] Add up to 2 of the FIRE Maximum monsters among those cards
    -- to your hand. If exactly 2 were added, add "Maximum Flare Fusion"
    -- from your GY to your hand, if possible.
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DECKDES|CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(s.thcost)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

function s.namecon(e)
    return e:GetHandler():IsFaceup()
end

function s.gyfilter(c)
    return c:IsMonster() and
        ((c:IsType(TYPE_MAXIMUM) and c:IsAttribute(ATTRIBUTE_FIRE))
            or c:IsCode(CHEMICALIZED_SALAMANDER))
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil)
end

function s.millfilter(c)
    return c:IsMonster() and c:IsType(TYPE_MAXIMUM)
        and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
        and c:IsLocation(LOCATION_GRAVE)
end

function s.flarefilter(c)
    return c:IsCode(MAXIMUM_FLARE_FUSION) and c:IsAbleToHand()
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2
            and Duel.IsPlayerCanDiscardDeckAsCost(tp,2)
    end
    -- Save the EXACT two cards sent as the requirement, even if more
    -- cards are sent to the GY later in the chain.
    Duel.DiscardDeck(tp,2,REASON_COST)
    local g=Duel.GetOperatedGroup():Clone()
    g:KeepAlive()
    e:SetLabelObject(g)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local milled=e:GetLabelObject()
    if not milled then return end
    -- Only the FIRE Maximum monsters from the two cards just milled count.
    local g=milled:Filter(s.millfilter,nil)
    local ct=0
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:Select(tp,0,math.min(2,#g),nil)
        if #sg>0 then
            ct=Duel.SendtoHand(sg,nil,REASON_EFFECT)
            if ct>0 then Duel.ConfirmCards(1-tp,sg) end
        end
    end
    milled:DeleteGroup()
    e:SetLabelObject(nil)

    if ct==2 and Duel.IsExistingMatchingCard(s.flarefilter,tp,LOCATION_GRAVE,0,1,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local fg=Duel.SelectMatchingCard(tp,s.flarefilter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #fg>0 and Duel.SendtoHand(fg,nil,REASON_EFFECT)>0 then
            Duel.ConfirmCards(1-tp,fg)
        end
    end
end
