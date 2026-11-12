--Dragonic Requiem Technique Tri-Force Fusion
--Custom Rush Duel Spell - 190019263
local s,id=GetID()

function s.initial_effect(c)
    --[REQUIREMENT] Your opponent controls at least 2 monsters.
    --[EFFECT] Reveal a Fusion Monster listing 3+ materials;
    --you may Fusion Summon it using field/GY materials shuffled into the Deck.
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

--Opponent must have at least 2 monsters (face-up or face-down).
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=2
end

--RushDuel.AddFusionProcedure records the printed minimum/maximum
--number of Fusion Materials as material_count on the card metatable.
--This excludes Fusion Monsters that only list 1 or 2 materials.
function s.revealfilter(c)
    if not c:IsType(TYPE_FUSION) then return false end
    local mt=getmetatable(c)
    local count=mt and mt.material_count
    return type(count)=="table" and type(count[1])=="number"
        and count[1]>=3
end

--The field may supply face-up monsters only; the hand is excluded.
function s.matfilter(c)
    return c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
        and c:IsType(TYPE_MONSTER)
        and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end

--Monsters in your Graveyard may also be Fusion Materials.
function s.gyfilter(c)
    return c:IsType(TYPE_MONSTER)
        and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        --The Fusion Summon is optional, so a reveal alone is legal.
        return Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_EXTRA,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.revealfilter,tp,LOCATION_EXTRA,0,nil)
    if #g==0 then return end

    --Reveal the selected 3+-material Fusion Monster first.
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local fc=g:Select(tp,1,1,nil):GetFirst()
    if not fc then return end
    Duel.ConfirmCards(1-tp,Group.FromCards(fc))

    --Only the revealed monster may be Fusion Summoned.
    local function selected(c)
        return c==fc
    end

    --The "then you can" part is optional.
    if not RD.IsCanFusionSummon(e,tp,POS_FACEUP,
        s.matfilter,selected,s.gyfilter,LOCATION_GRAVE,0) then
        return
    end
    if not Duel.SelectYesNo(tp,1169) then return end

    --Fusion Summon using your face-up field monsters and/or GY.
    --Return all chosen materials to their owners' Decks/Extra Decks.
    RD.FusionSummon(s.matfilter,selected,s.gyfilter,
        LOCATION_GRAVE,0,nil,RD.FusionToDeck,
        e,tp,POS_FACEUP,false)
end
