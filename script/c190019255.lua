-- Sineater Sevens Witch
-- Custom Rush Duel monster
-- Card ID: 190019255
local s,id=GetID()

-- Rush Duel "Sevens Road Witch" card code.
local SEVENS_ROAD_WITCH=160401001

function s.initial_effect(c)
    -- Special Summon this card from your hand if you have a Level 2 or 6
    -- monster in your Graveyard.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.handspcon)
    c:RegisterEffect(e1)

    -- This card's name becomes "Sevens Road Witch" while face-up.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CHANGE_CODE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.faceupcon)
    e2:SetValue(SEVENS_ROAD_WITCH)
    c:RegisterEffect(e2)

    -- [REQUIREMENT] You have not activated this card's effect this turn.
    -- [EFFECT] Revive a Level 2 or 6 monster, then Fusion Summon a
    -- Level 6+ Spellcaster, Fiend, or Fairy using hand/field materials.
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_FUSION_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.target)
    e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
end
s.listed_names={SEVENS_ROAD_WITCH}

function s.faceupcon(e)
    return e:GetHandler():IsFaceup()
end

function s.lvfilter(c)
    return c:IsMonster() and (c:IsLevel(2) or c:IsLevel(6))
end

function s.handspcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_GRAVE,0,1,nil)
end

function s.revivefilter(c,e,tp)
    return s.lvfilter(c)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end

-- Restrict the Fusion Monster, not the monsters that may be used as material.
function s.fusfilter(c,tp)
    return c:IsLevelAbove(6)
        and c:IsRace(RACE_SPELLCASTER|RACE_FIEND|RACE_FAIRY)
end

-- The Fusion library checks each Fusion Monster's listed material requirements.
function s.matfilter(c,e,tp,chk)
    return c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
        and c:IsMonster() and c:IsAbleToGrave()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.revivefilter),
                tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.revivefilter),
        tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc then return end

    -- The revival has to succeed before proceeding to the Fusion Summon.
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    -- Check again after the revival: its new name, available materials and
    -- open monster zones can now affect which Fusion Summons are legal.
    local params={fusfilter=s.fusfilter,matfilter=s.matfilter}
    local fusion_target=Fusion.SummonEffTG(params)
    if not fusion_target(e,tp,eg,ep,ev,re,r,rp,0) then return end
    local fusion_operation=Fusion.SummonEffOP(params)
    fusion_operation(e,tp,eg,ep,ev,re,r,rp)
end
