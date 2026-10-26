-- Prism Reformation | card ID 900000017
-- Normal Spell (development prototype; requires MDPro4 playtesting).
-- Special Summons 1 to 3 colored Mirror Slimes from your GY and/or face-up banishment,
-- with their effects negated for as long as they remain face-up on the field.
local s,id=GetID()
-- Effect count identifiers must not contain the core's once-per-Duel flag bits.
local cid=0x0f000000+(id-900000000)*16
local MIRRORS={900000001,900000002,900000003,900000004,900000005,900000006}

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,cid+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end

function s.spfilter(c,e,tp)
    return c:IsCode(900000001,900000002,900000003,900000004,900000005,900000006)
        and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and c:IsCanBeEffectTarget(e)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsControler(tp)
            and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
            and aux.NecroValleyFilter(s.spfilter)(chkc,e,tp)
    end
    local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if chk==0 then
        return ct>0 and Duel.IsExistingTarget(aux.NecroValleyFilter(s.spfilter),tp,
            LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(s.spfilter),tp,
        LOCATION_GRAVE+LOCATION_REMOVED,0,1,math.min(3,ct),nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,tp,
        LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    -- MDPro4 does not provide Duel.GetTargetCards. Retrieve the Chain's
    -- recorded targets and keep only cards still related to this effect.
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if not g then return end
    g=g:Filter(Card.IsRelateToEffect,nil,e)
    if #g==0 then return end
    local summoned=0
    for tc in aux.Next(g) do
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then break end
        if tc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
            and tc:IsCode(900000001,900000002,900000003,900000004,900000005,900000006)
            and (not tc:IsLocation(LOCATION_REMOVED) or tc:IsFaceup())
            and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
            and aux.NecroValleyFilter(s.spfilter)(tc,e,tp)
            and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
            -- Register negation BEFORE SpecialSummonComplete, so effects
            -- that would trigger on Summon are also disabled.
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            tc:RegisterEffect(e2)
            summoned=summoned+1
        end
    end
    if summoned>0 then Duel.SpecialSummonComplete() end
end
