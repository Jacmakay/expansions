--Timaeus X the Legendary Knight
--Custom EDOPro Rush Duel card
--Card ID: 190019265
local s,id=GetID()
local TIMAEUS_X=190019264

function s.initial_effect(c)
    -- Its named Fusion recipes provide the material code list.

    --May be Tribute Summoned in Attack Position with 1
    --Dragon, Spellcaster, or Warrior monster.
    --The standard 2-Tribute Summon is still available.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetCondition(s.tribute_condition)
    e1:SetOperation(s.tribute_operation)
    e1:SetValue(SUMMON_TYPE_TRIBUTE)
    c:RegisterEffect(e1)

    --[REQUIREMENT] During the turn this card was Normal or
    --Special Summoned, pay 800 LP.
    --[EFFECT] Draw 1 card. Then, if "Timaeus X" is in the GY,
    --you may Fusion Summon using only this card and Timaeus X,
    --shuffling both into their owners' Decks.
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1) -- Rush Duel once-per-turn activation
    e2:SetCondition(s.condition)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)

    -- Track which turn this monster was successfully Summoned.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetOperation(s.mark)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
end

--An alternate 1-Tribute Summon: the selected Tribute must
--have one of the three specified Monster Types.
function s.tribute_filter(c)
    return c:IsRace(RACE_DRAGON|RACE_SPELLCASTER|RACE_WARRIOR)
end

function s.tribute_condition(e,c,minc)
    if c==nil then return true end
    if minc>1 then return false end
    local mg=Duel.GetTributeGroup(c):Filter(s.tribute_filter,nil)
    return Duel.CheckTribute(c,1,1,mg)
end

function s.tribute_operation(e,tp,eg,ep,ev,re,r,rp,c)
    local mg=Duel.GetTributeGroup(c):Filter(s.tribute_filter,nil)
    local sg=Duel.SelectTribute(tp,c,1,1,mg)
    c:SetMaterial(sg)
    Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end

--Rush Duel distinguishes a Normal Summon this turn from a
--Special Summon this turn; either one fulfills the requirement.
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.GetTurnPlayer()==tp and c:GetFlagEffect(id)>0
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,800) end
    Duel.PayLPCost(tp,800)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

--Only the specified Graveyard monster can be used.
function s.gy_material(c)
    return c:IsCode(TIMAEUS_X)
        and c:IsType(TYPE_MONSTER)
        and c:IsCanBeFusionMaterial()
        and c:IsAbleToDeck()
end

function s.fusion_monster(c)
    return c:IsType(TYPE_FUSION)
end

function s.mark(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end

function s.fieldmat(c,e,tp,chk)
    local hc=e:GetHandler()
    return c==hc and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
        and c:IsAbleToDeck()
end

function s.gymat(e,tp,mg)
    return Duel.GetMatchingGroup(s.gy_material,tp,LOCATION_GRAVE,0,nil)
end

function s.mandatory(e,tp,eg,ep,ev,re,r,rp,chk)
    return e:GetHandler()
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- Draw even if the optional Fusion Summon is not available.
    if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
    local hc=e:GetHandler()
    if not hc:IsFaceup() or not hc:IsLocation(LOCATION_MZONE)
        or not hc:IsRelateToEffect(e) then return end
    if not s.fusion_tg(e,tp,eg,ep,ev,re,r,rp,0) then return end
    if not Duel.SelectYesNo(tp,1169) then return end
    s.fusion_op(e,tp,eg,ep,ev,re,r,rp)
end

s.fusion_tg=Fusion.SummonEffTG(s.fusion_monster,s.fieldmat,s.gymat,
    Fusion.ShuffleMaterial,s.mandatory,nil,2)
s.fusion_op=Fusion.SummonEffOP(s.fusion_monster,s.fieldmat,s.gymat,
    Fusion.ShuffleMaterial,s.mandatory,nil,2)
