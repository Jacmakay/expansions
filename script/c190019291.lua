--Luminescent Soul Soltus
--Custom EDOPro Rush Duel card: 190019291
local s,id=GetID()

--Some Rush Duel installs call the High Dragon race RACE_HYDRAGON.
local HIGH_DRAGON=RACE_HYDRAGON or RACE_HIGHDRAGON

function s.initial_effect(c)
    -- Native count limit handles previous activations this turn.

    --Normal Summon without Tributing if you control a Level 7 or lower monster.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SUMMON_PROC)
    e0:SetCondition(s.ntcon)
    c:RegisterEffect(e0)

    --[REQUIREMENT] You have not activated "Luminescent Soul Soltus" this turn.
    --[EFFECT] Destroy 1 card you control, then Fusion Summon from your
    --hand/field. If you destroyed a monster, you may destroy 1 opposing S/T.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--Alternate Normal Summon procedure (standard Tribute Summon stays available).
function s.lvfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(7)
end
function s.ntcon(e,c,minc)
    if c==nil then return true end
    local tp=c:GetControler()
    return minc==0
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return true
end

function s.destroyfilter(c)
    return c:IsDestructable()
end

--Fusion Materials are monsters in your hand or face-up on your field.
function s.matfilter(c)
    return (c:IsLocation(LOCATION_HAND)
            or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()))
        and c:IsType(TYPE_MONSTER)
        and c:IsCanBeFusionMaterial()
        and c:IsAbleToGrave()
end

--Dragon, High Dragon, Spellcaster, Magical Knight or Galaxy Fusion Monsters.
function s.fusfilter(c)
    return c:IsType(TYPE_FUSION)
        and (c:IsRace(RACE_DRAGON)
            or (HIGH_DRAGON and c:IsRace(HIGH_DRAGON))
            or c:IsRace(RACE_SPELLCASTER)
            or c:IsRace(RACE_MAGICALKNIGHT)
            or c:IsRace(RACE_GALAXY))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.destroyfilter,
                tp,LOCATION_ONFIELD,0,1,nil)
            and s.fusion_tg(e,tp,eg,ep,ev,re,r,rp,0)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    --First, destroy exactly one of your cards.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.destroyfilter,
        tp,LOCATION_ONFIELD,0,1,1,nil)
    local tc=g:GetFirst()
    if not tc then return end
    local destroyed_monster=tc:IsType(TYPE_MONSTER)
    if Duel.Destroy(g,REASON_EFFECT)==0 then return end

    --Then Fusion Summon using valid materials from your hand or field.
    -- EDOPro's native Fusion library checks every listed material recipe.
    if s.fusion_tg(e,tp,eg,ep,ev,re,r,rp,0) then
        s.fusion_op(e,tp,eg,ep,ev,re,r,rp)
    end

    --Only if the card destroyed above was a monster:
    --optionally destroy an opponent's Spell/Trap card.
    if not destroyed_monster then return end
    if not Duel.IsExistingMatchingCard(s.destroyfilter,
            tp,0,LOCATION_SZONE,1,nil) then return end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local sg=Duel.SelectMatchingCard(tp,s.destroyfilter,
        tp,0,LOCATION_SZONE,1,1,nil)
    if #sg>0 then Duel.Destroy(sg,REASON_EFFECT) end
end

-- Native Fusion helpers (not the unavailable MDPro4 RD library).
s.fusion_tg=Fusion.SummonEffTG(s.fusfilter,s.matfilter)
s.fusion_op=Fusion.SummonEffOP(s.fusfilter,s.matfilter)
