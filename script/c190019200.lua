-- Jupiter the God From Another World
-- Custom EDOPro Rush Duel card: 190019200
-- DARK / Machine / Level 10 / Effect / ATK 3500 / DEF 2500
-- Alternative Special Summon from hand when a Dragon, Spellcaster,
-- or Galaxy monster is in your GY.
-- [REQUIREMENT] Destroy 0-2 cards on your own field.
-- [MULTI-CHOICE EFFECT] Choose Fusion or Ritual Summon (shared 1/turn):
--   Fusion: Level 10+ Dragon or High Dragon Fusion Monster.
--   Ritual: "Maximum Purple Chaos Blue-Eyes Dragon" (1900192210).
-- Normal materials: monsters from hand/field, sent to the GY.
-- If exactly 2 cards were destroyed for the Requirement, monsters
-- from your GY can also be used; those GY materials are shuffled
-- into the Deck instead of being sent to the GY.

local s,id=GetID()
local PURPLE_CHAOS_BLUE_EYES=1900192210
s.listed_names={PURPLE_CHAOS_BLUE_EYES}

function s.initial_effect(c)
    -- Special Summon from hand (doesn't require Tributes).
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_HAND)
    e0:SetCondition(s.spcon)
    c:RegisterEffect(e0)

    -- MULTI-CHOICE: Fusion Summon (option 1).
    -- Fusion.CreateSummonEff provides material legality checks and the
    -- standard EDOPro Fusion selection interface.
    local e1=Fusion.CreateSummonEff({
        handler=c,
        fusfilter=s.fusfilter,
        matfilter=s.fusmatfilter,
        extrafil=s.extrafil,
        extraop=s.fusmatop
    })
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetLabel(-1) -- pre-Requirement state
    e1:SetCost(s.cost)
    c:RegisterEffect(e1)

    -- MULTI-CHOICE: Ritual Summon (option 2).
    -- Rush Ritual Monsters are summoned from the Extra Deck.
    -- Both choices share the same once-per-turn card-name count.
    local e2=Ritual.CreateProc({
        handler=c,
        lvtype=RITPROC_GREATER,
        filter=s.ritfilter,
        matfilter=s.ritmatfilter,
        extrafil=s.extrafil,
        extraop=s.ritmatop,
        location=LOCATION_EXTRA,
        sumpos=POS_FACEUP_ATTACK
    })
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetLabel(-1) -- pre-Requirement state
    e2:SetCost(s.cost)
    c:RegisterEffect(e2)
end

-- HAND SPECIAL SUMMON ------------------------------------------------------
function s.spfilter(c)
    return c:IsMonster()
        and c:IsRace(RACE_DRAGON|RACE_SPELLCASTER|RACE_GALAXY)
end

function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil)
end

-- SHARED REQUIREMENT -------------------------------------------------------
function s.desfilter(c)
    return c:IsDestructable()
end

-- Destroy UP TO two cards you control (including 0, if you choose).
-- SetLabel remembers how many cards were actually destroyed, since
-- Graveyard materials are allowed only when that number is exactly 2.
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        e:SetLabel(-1) -- engine legality check, not a paid Requirement
        return true
    end
    local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,0,nil)
    if #g==0 then
        e:SetLabel(0)
        return
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local sg=Duel.SelectMatchingCard(tp,s.desfilter,tp,
        LOCATION_ONFIELD,0,0,math.min(2,#g),nil)
    local ct=0
    if #sg>0 then
        ct=Duel.Destroy(sg,REASON_COST)
    end
    e:SetLabel(ct)
end

-- During the engine's pre-activation legality check, the Requirement
-- hasn't been paid yet. If 2 destructible cards are currently present,
-- allow the helper to consider a potential Graveyard-material route.
-- After cost payment, ONLY the actual destruction count is used.
function s.allowgrave(e,tp)
    if e:GetLabel()==2 then return true end
    if e:GetLabel()==-1 then
        return Duel.IsExistingMatchingCard(s.desfilter,tp,
            LOCATION_ONFIELD,0,2,nil)
    end
    return false
end

-- Common extra material pool: only your own GY, only if eligible.
function s.gyfilter(c)
    return c:IsMonster() and c:IsAbleToDeck()
end

function s.extrafil(e,tp,mg)
    if not s.allowgrave(e,tp) then return Group.CreateGroup() end
    return Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_GRAVE,0,nil)
end

-- FUSION CHOICE ------------------------------------------------------------
function s.fusfilter(c,tp)
    return c:IsType(TYPE_FUSION)
        and c:IsLevelAbove(10)
        and c:IsRace(RACE_DRAGON|RACE_HIGHDRAGON)
end

-- The normal Fusion pool is hand + field. Only sendable monsters qualify.
function s.fusmatfilter(c,e,tp,chk)
    return c:IsMonster() and c:IsControler(tp)
        and c:IsLocation(LOCATION_HAND|LOCATION_MZONE)
        and c:IsAbleToGrave()
end

-- Shuffle selected GY Fusion Materials. The Fusion helper sends the
-- remaining (hand/field) materials to the GY by its normal procedure.
function s.fusmatop(e,fc,tp,sg)
    local gg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
    if #gg==0 then return end
    sg:Sub(gg)
    Fusion.ShuffleMaterial(e,fc,tp,gg)
end

-- RITUAL CHOICE ------------------------------------------------------------
function s.ritfilter(c)
    return c:IsCode(PURPLE_CHAOS_BLUE_EYES)
end

function s.ritmatfilter(c,e,tp)
    if not c:IsMonster() or not c:IsControler(tp) then return false end
    if c:IsLocation(LOCATION_GRAVE) then
        return s.allowgrave(e,tp) and c:IsAbleToDeck()
    end
    return c:IsLocation(LOCATION_HAND|LOCATION_MZONE) and c:IsAbleToGrave()
end

-- The Ritual procedure has already associated materials with the summoned
-- monster. Send selected hand/field materials to the GY, and shuffle only
-- selected GY materials into the Deck/Extra Deck.
function s.ritmatop(mat,e,tp,eg,ep,ev,re,r,rp,rc)
    local gy=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
    local normal=mat:Clone()
    normal:Sub(gy)
    if #normal>0 then
        Duel.SendtoGrave(normal,REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
    end
    if #gy>0 then
        Duel.SendtoDeck(gy,nil,SEQ_DECKSHUFFLE,
            REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
    end
end
