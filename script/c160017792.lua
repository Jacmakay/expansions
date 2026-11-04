-- Majesty of OuTerverSe (Rush Duel)
local s,id=GetID()
function s.initial_effect(c)
    -- Must set Revive Limit for Ritual Monsters
    c:EnableReviveLimit()
    
    -- Name becomes "OuTerverSe" while in the GY
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetValue(160017792) 
    c:RegisterEffect(e1)
    
    -- [CONTINUOUS EFFECT] During your turn, this card becomes Galaxy Type
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CHANGE_RACE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.turncon)
    e2:SetValue(RACE_GALAXY)
    c:RegisterEffect(e2)
    
    -- [CONTINUOUS EFFECT] ATK Boost calculation
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.atkval)
    c:RegisterEffect(e3)
end

-- Condition: Must be the controller's turn
function s.turncon(e)
    return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end

-- Filter for Face-up Galaxy Type Ritual Monsters
function s.atkfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_GALAXY) and c:IsType(TYPE_RITUAL)
end

-- Filter for Level 11 Ritual Monsters
function s.lvl11filter(c)
    return c:IsFaceup() and c:IsLevel(11) and c:IsType(TYPE_RITUAL)
end

-- Multi-layered ATK calculation
function s.atkval(e,c)
    local tp=e:GetHandlerPlayer()
    -- Gains 1000 ATK per face-up Galaxy Ritual monster
    local count_galaxy = Duel.GetMatchingGroupCount(s.atkfilter,tp,LOCATION_MZONE,0,nil)
    local atk = count_galaxy * 1000
    
    -- Gains an additional 4000 ATK if there are 3 or more Level 11 Ritual Monsters
    local count_lvl11 = Duel.GetMatchingGroupCount(s.lvl11filter,tp,LOCATION_MZONE,0,nil)
    if count_lvl11 >= 3 then
        atk = atk + 4000
    end
    return atk
end
