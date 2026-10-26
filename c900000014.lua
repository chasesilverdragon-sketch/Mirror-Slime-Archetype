-- Prism Fusion | MDPro4-compatible Fusion Summon script.
-- Mirror Slime and Prism Scale Slime materials from GY / face-up Extra Deck return to the Deck;
-- ordinary hand / Monster Zone materials go to the GY.
local s,id=GetID()
-- Effect count identifiers must not contain the core's once-per-Duel flag bits.
local cid=0x0f000000+(id-900000000)*16
local SET_MIRROR=0x1f50
local SCALE_INVERSION=900000007
local SCALE_PURE=900000008
local KING=900000010
local KNIGHT=900000019

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,cid+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.fustg)
    e1:SetOperation(s.fusop)
    c:RegisterEffect(e1)
end

function s.mainmat(c,e)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
        and not c:IsImmuneToEffect(e)
end

function s.extramat(c,e)
    return c:IsType(TYPE_MONSTER)
        and (c:IsFusionSetCard(SET_MIRROR)
            or c:IsFusionCode(SCALE_INVERSION,SCALE_PURE))
        and (c:IsLocation(LOCATION_GRAVE)
            or (c:IsLocation(LOCATION_EXTRA) and c:IsFaceupEx()))
        and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end

function s.materials(e,tp)
    local ordinary=Duel.GetFusionMaterial(tp):Filter(s.mainmat,nil,e)
    local extra=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.extramat),tp,
        LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e)
    ordinary:Merge(extra)
    return ordinary
end

function s.fusfilter(c,e,tp,mg)
    return c:IsCode(KING,KNIGHT)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
        and c:CheckFusionMaterial(mg,nil,tp)
end

function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg=s.materials(e,tp)
        return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,
            1,nil,e,tp,mg)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local mg=s.materials(e,tp)
    local fusions=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,
        nil,e,tp,mg)
    if #fusions==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local fc=fusions:Select(tp,1,1,nil):GetFirst()
    if not fc then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
    local sg=Duel.SelectFusionMaterial(tp,fc,mg,nil,tp)
    if not sg or #sg==0 then return end
    fc:SetMaterial(sg)

    local recycle=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE+LOCATION_EXTRA)
    local normal=sg:Clone()
    normal:Sub(recycle)
    local reasons=REASON_EFFECT+REASON_MATERIAL+REASON_FUSION

    if #recycle>0 then
        Duel.SendtoDeck(recycle,nil,SEQ_DECKSHUFFLE,reasons)
    end
    if #normal>0 then
        Duel.SendtoGrave(normal,reasons)
    end

    Duel.BreakEffect()
    if Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
        fc:CompleteProcedure()
    end
end
