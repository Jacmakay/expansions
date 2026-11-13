-- U-T-W Squeeze The Black Dragon Turtle.
-- Custom EDOPro Rush Duel Monster
-- Card ID: 190019268
-- DARK / Dragon / Effect / Level 7 / ATK 700 / DEF 2400

local s,id=GetID()

function s.initial_effect(c)
    -- Special Summon this card from your hand in face-up Defense Position
    -- while you have a FIRE or DARK Dragon monster in your GY.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SPSUM_PARAM)
    e1:SetRange(LOCATION_HAND)
    e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- [REQUIREMENT] Opponent controls an Attack Position monster.
    -- [EFFECT] Draw 1 card. If it is a monster, Ritual Summon a
    -- DARK or FIRE Dragon Ritual Monster from your Extra Deck,
    -- using this card as part of the hand/field materials.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DRAW|CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.drcon)
    e2:SetTarget(s.drtg)
    e2:SetOperation(s.drop)
    c:RegisterEffect(e2)
end

-- FIRE or DARK Dragon in your Graveyard.
function s.gyfilter(c)
    return c:IsMonster() and c:IsRace(RACE_DRAGON)
        and c:IsAttribute(ATTRIBUTE_FIRE|ATTRIBUTE_DARK)
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil)
end

function s.atkfilter(c)
    return c:IsAttackPos()
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil)
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- DARK or FIRE Dragon Ritual Monster from the Extra Deck.
function s.ritfilter(c)
    return c:IsType(TYPE_RITUAL) and c:IsRace(RACE_DRAGON)
        and c:IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_FIRE)
end

-- The Ritual material pool is restricted to your hand and field.
function s.matfilter(c,e,tp)
    return c:IsMonster() and c:IsControler(tp)
        and c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
        and c:GetLevel()>0 and c:IsAbleToGrave()
end

-- Every valid selected material group must contain this monster.
function s.mustuse(e,tp,sg,rc)
    local c=e:GetHandler()
    return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
        and sg:IsContains(c)
end

function s.matlevel(c,rc)
    return c:GetLevel()
end

-- Send materials to the GY rather than Tributing them.
function s.sendmat(mat,e,tp,eg,ep,ev,re,r,rp,rc)
    Duel.SendtoGrave(mat,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end

-- Disallow activating effects/cards with this original name
-- for the remainder of the turn after this effect resolves.
function s.namefilter(e,re,tp)
    return re:GetHandler():IsOriginalCode(id)
end

function s.lockname(e,tp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetTargetRange(1,0)
    e1:SetValue(s.namefilter)
    e1:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
    local dg=Duel.GetOperatedGroup()
    local dc=dg:GetFirst()
    if not dc then return end

    -- Reveal the draw so the monster check is verifiable.
    Duel.ConfirmCards(1-tp,dc)
    local ismon=dc:IsMonster()
    Duel.ShuffleHand(tp)

    if ismon then
        -- The normal Ritual helper handles the level requirement,
        -- the minimum-needed-material rule and the actual summon.
        -- It only offers legal Rituals if THIS card can be used.
        local ritualop=Ritual.Operation({
            filter=s.ritfilter,
            lvtype=RITPROC_GREATER,
            matfilter=s.matfilter,
            forcedselection=s.mustuse,
            requirementfunc=s.matlevel,
            extraop=s.sendmat,
            location=LOCATION_EXTRA,
            sumpos=POS_FACEUP
        })
        ritualop(e,tp,eg,ep,ev,re,r,rp)
    end

    s.lockname(e,tp)
end
