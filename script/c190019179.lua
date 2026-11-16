-- The Cosmo Harbingers Schemes
-- Card ID: 190019179 | EDOPro Rush Duel Ritual Spell (TYPE_RITUAL|TYPE_SPELL = 130)
-- Ritual Summons Sophia Ex Cosmo Harbinger of Rebirth (190019178)
-- from the Extra Deck using face-up field monsters with Levels totaling 12+.
-- If you control a face-up Level 10+ Fairy, monsters in your hand may also be used.
--
-- Compatibility fix: do not use Group.CheckSubGroup / Group.SelectSubGroup;
-- those methods are not present in every EDOPro engine build.
-- Uses engine-native Group.CheckWithSumGreater / SelectWithSumGreater instead.

local s,id=GetID()
local SOPHIA_ID=190019178
local REQUIRED_LEVEL=12

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.fairyfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsLevelAbove(10)
end

function s.fieldmat(c)
    return c:IsFaceup() and c:IsMonster() and c:IsLevelAbove(1)
        and c:IsAbleToGrave() and c:IsLocation(LOCATION_MZONE)
end

function s.handmat(c)
    return c:IsMonster() and c:IsLevelAbove(1) and c:IsAbleToGrave()
        and c:IsLocation(LOCATION_HAND)
end

function s.materials(tp)
    local mg=Duel.GetMatchingGroup(s.fieldmat,tp,LOCATION_MZONE,0,nil)
    -- Hand monsters become eligible only while a Level 10+ Fairy is face-up.
    if Duel.IsExistingMatchingCard(s.fairyfilter,tp,LOCATION_MZONE,0,1,nil) then
        mg:Merge(Duel.GetMatchingGroup(s.handmat,tp,LOCATION_HAND,0,nil))
    end
    return mg
end

function s.canritual(c,e,tp,mg)
    if not c:IsCode(SOPHIA_ID) or not c:IsType(TYPE_RITUAL) then return false end
    if not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,false,
                                    POS_FACEUP_ATTACK) then return false end
    if not mg:CheckWithSumGreater(Card.GetLevel,REQUIRED_LEVEL-1) then
        return false
    end
    -- If all monster zones are occupied, using a field monster as a
    -- material is necessary to make space for the Extra Deck Ritual.
    return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
        or mg:IsExists(s.fieldmat,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg=s.materials(tp)
        return #mg>0 and Duel.IsExistingMatchingCard(s.canritual,tp,
                                LOCATION_EXTRA,0,1,nil,e,tp,mg)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE|LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local mg=s.materials(tp)
    if #mg==0 then return end
    local rg=Duel.GetMatchingGroup(s.canritual,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
    if #rg==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local rc=rg:Select(tp,1,1,nil):GetFirst()
    if not rc then return end

    -- If the field is full, force at least one face-up field material so
    -- the Ritual Summon will have an available Monster Zone.
    if Duel.GetLocationCountFromEx(tp,tp,nil,rc)<=0 then
        local fieldgroup=mg:Filter(s.fieldmat,nil)
        if #fieldgroup==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local mandatory=fieldgroup:Select(tp,1,1,nil)
        if not mandatory or #mandatory==0 then return end
        Duel.SetSelectedCard(mandatory)
    end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    -- The sum must be strictly greater than 11, i.e. Level 12 or higher.
    -- This engine-native selector includes any mandatory card above.
    local sg=mg:SelectWithSumGreater(tp,Card.GetLevel,REQUIRED_LEVEL-1)
    if not sg or #sg==0 then return end
    if sg:GetSum(Card.GetLevel)<REQUIRED_LEVEL then return end
    if Duel.GetLocationCountFromEx(tp,tp,sg,rc)<=0 then return end

    -- Rush Ritual material is SENT to the GY rather than Tributed.
    rc:SetMaterial(sg)
    local moved=Duel.SendtoGrave(sg,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
    if moved~=#sg then return end
    if Duel.GetLocationCountFromEx(tp,tp,nil,rc)<=0 then return end

    Duel.BreakEffect()
    if Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,false,
                          POS_FACEUP_ATTACK)>0 then
        rc:CompleteProcedure()
    end
end
