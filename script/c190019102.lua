-- The Shinigami From Afar - True Shikai (190019102)
-- DARK / Warrior / Level 8 / 2500 ATK / 2000 DEF
local s,id=GetID()
local BORN=190019100
local MUGETSU_RITUAL=190019108
local BANKAI_RITUAL=190019111

function s.initial_effect(c)
    -- Special Summon itself from the HAND if Born in the Dark is in GY
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_HAND)
    e0:SetCondition(s.spcon)
    c:RegisterEffect(e0)
    -- [REQUIREMENT] Mill 2. [EFFECT] Recover either Ritual Spell from GY;
    -- optionally copy the name of "Born in the Dark" until end of turn.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.cost)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.bornfilter(c)
    return c:IsCode(BORN)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.bornfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=2 end
    Duel.DisableShuffleCheck()
    Duel.SendtoGrave(Duel.GetDecktopGroup(tp,2),REASON_COST)
end
function s.spellfilter(c)
    return c:IsCode(MUGETSU_RITUAL,BANKAI_RITUAL) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Checking only after the mill allows freshly milled Spells to be recovered.
    if Duel.IsExistingMatchingCard(s.spellfilter,tp,LOCATION_GRAVE,0,1,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,s.spellfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    end
    if c:IsFaceup() and c:IsRelateToEffect(e)
        and Duel.IsExistingMatchingCard(s.bornfilter,tp,LOCATION_GRAVE,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_CHANGE_CODE)
        e2:SetValue(BORN)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e2)
    end
end
