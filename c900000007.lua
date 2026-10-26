-- Prism Scale Slime - Inversion (ID 900000007)
-- DARK / Aqua / Pendulum / Effect, Level 3, Scale 8, ATK 800 / DEF 800.
-- Preliminary script (MDPro4 / ocgcore). Not yet tested in game.
local s,id=GetID()
function s.initial_effect(c)
    aux.EnablePendulumAttribute(c)
    -- Pendulum Zone ignition: summon from hand or GY.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    -- Monster Zone ignition: same effect, once per turn in this zone.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end
-- Shared helper convention: custom Mirror Slime setcode 0x1f50
local SET_MIRROR=0x1f50
function s.mirrorfilter(c,e,tp)
    return c:IsSetCard(SET_MIRROR) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- This applies AFTER the effect resolves, for the remainder of the turn.
function s.extralimit(e,c,sump,sumtype,sumpos,targetp,se)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
           and Duel.IsExistingMatchingCard(s.mirrorfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mirrorfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g==0 then return end
    if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
        local ec=Effect.CreateEffect(e:GetHandler())
        ec:SetType(EFFECT_TYPE_FIELD)
        ec:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ec:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        ec:SetTargetRange(1,0)
        ec:SetTarget(s.extralimit)
        ec:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(ec,tp)
    end
end
