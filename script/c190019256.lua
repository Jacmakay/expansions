-- Sineater Number 99
-- Custom EDOPro Rush Duel card
-- Card ID: 190019256
local s,id=GetID()

function s.initial_effect(c)
    -- You can Tribute Summon this card in Attack Position by Tributing
    -- exactly 1 Level 2 or Level 6 monster instead of the usual 2 Tributes.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetCondition(s.otcon)
    e1:SetOperation(s.otop)
    e1:SetValue(SUMMON_TYPE_ADVANCE or 0x11000000) -- fallback for EDOPro builds where the named constant is nil
    c:RegisterEffect(e1)

    -- [REQUIREMENT] During the turn you Normal Summoned this card.
    -- [EFFECT] Destroy 1 opposing Spell/Trap, then Special Summon
    -- 1 Spellcaster, Fairy or Fiend from your GY in face-up Attack Position.
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1) -- Rush Duel: once per turn, per face-up copy
    e2:SetCondition(s.effcon)
    e2:SetTarget(s.efftg)
    e2:SetOperation(s.effop)
    c:RegisterEffect(e2)
end

-- Alternative, one-Tribute Normal Summon (does not replace the ordinary
-- two-Tribute Summon; does not apply to Tribute Sets).
function s.tributefilter(c)
    return c:IsLevel(2) or c:IsLevel(6)
end

function s.otcon(e,c,minc)
    if c==nil then return true end
    local mg=Duel.GetTributeGroup(c):Filter(s.tributefilter,nil)
    return (minc or 0)<=1 and Duel.CheckTribute(c,1,1,mg)
end

function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
    local mg=Duel.GetTributeGroup(c):Filter(s.tributefilter,nil)
    local sg=Duel.SelectTribute(tp,c,1,1,mg)
    c:SetMaterial(sg)
    Duel.Release(sg,REASON_SUMMON|REASON_MATERIAL)
end

-- The condition is tied to THIS monster being Normal Summoned this turn.
-- Prefer the Rush helper when the Rush rule library is loaded.
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if RD and RD.IsSummonTurn then
        return RD.IsSummonTurn(c)
    end
    return c:IsSummonType(SUMMON_TYPE_NORMAL)
        and c:IsStatus(STATUS_SUMMON_TURN)
end

function s.stfilter(c)
    return c:IsSpellTrap() and c:IsDestructable()
end

function s.spfilter(c,e,tp)
    return c:IsMonster()
        and c:IsRace(RACE_SPELLCASTER|RACE_FAIRY|RACE_FIEND)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.stfilter,tp,0,LOCATION_SZONE,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
                tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_SZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,s.stfilter,tp,0,LOCATION_SZONE,1,1,nil)
    local dc=dg:GetFirst()
    if not dc or Duel.Destroy(dc,REASON_EFFECT)==0 then return end

    -- "Then": continue with the revival only if destruction succeeded.
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,nil,e,tp) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),
        tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #sg>0 then
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_ATTACK)
    end
end
