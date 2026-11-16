-- You need More power
-- Custom EDOPro Rush Duel Normal Spell -- ID 190019182
local s,id=GetID()
local VERGIL=190019180
local YAMATO_ECLIPSE=190019181
local TERMINUS_BLADE=190019214
s.listed_names={VERGIL,YAMATO_ECLIPSE,TERMINUS_BLADE}

function s.initial_effect(c)
    -- [REQUIREMENT] None.
    -- [EFFECT] Fusion Summon Terminus Servitor - Yamato Eclipse
    -- using face-up Vergil + Terminus Blade on your field.
    local params={
        handler=c,
        fusfilter=s.fusfilter,
        matfilter=s.matfilter
    }
    local e1=Fusion.CreateSummonEff(params)
    c:RegisterEffect(e1)
end

function s.fusfilter(c,tp)
    return c:IsCode(YAMATO_ECLIPSE)
end
function s.matfilter(c,e,tp,mg)
    return c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
        and c:IsControler(tp) and c:IsAbleToGrave()
end
