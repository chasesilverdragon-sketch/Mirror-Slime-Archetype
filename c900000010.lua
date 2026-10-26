-- King Rainbow Slime (three-or-more material development prototype)
-- ID 900000010; LIGHT Aqua Fusion Effect; Level 8; ATK/DEF 3000
-- Fusion Materials: 3 to 6 Mirror Slimes, ALL with distinct Attributes.
-- Attribute benefits are based ONLY on Attributes used as Fusion Materials.
local s,id=GetID()
-- MDPro4 transmits select-option descriptions as 32-bit integers. The main
-- card ID (900000010) multiplied by 16 does not fit. Keep King's card ID
-- untouched but look up its three option labels from an internal, non-playable
-- database entry whose 16x description values fit the protocol.
local CHOICE_TEXT_ID=100099910

function s.initial_effect(c)
    c:EnableReviveLimit()
    -- The material filter also validates uniqueness against the chosen group.
    -- MDPro4 uses the Auxiliary/aux Fusion procedure helpers.
    aux.AddFusionProcMixRep(c,false,false,s.matfilter,3,6)

    -- Cache the Fusion Materials' Attributes at the time of the Summon.
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_MATERIAL_CHECK)
    e0:SetValue(s.matcheck)
    c:RegisterEffect(e0)

    -- FIRE: one extra attack in each Battle Phase.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_EXTRA_ATTACK)
    e1:SetCondition(s.hasfire)
    e1:SetValue(1)
    e1:SetLabelObject(e0)
    c:RegisterEffect(e1)

    -- WATER: destruction immunity against card effects.
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetCondition(s.haswater)
    e2:SetValue(1)
    e2:SetLabelObject(e0)
    c:RegisterEffect(e2)

    -- LIGHT: +500 ATK.
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetCondition(s.haslight)
    e3:SetValue(500)
    e3:SetLabelObject(e0)
    c:RegisterEffect(e3)

    -- MDPro4 v35 stalled when DARK banish and Blue's material-granted ATK
    -- reduction appeared as two simultaneously selectable Quick Effects.
    -- Offer both bonuses through ONE activation, with an option menu only
    -- when both remain available. Each bonus can still be used once/turn;
    -- choosing "Both" resolves them together as one Chain Link.
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.quickcon)
    e4:SetTarget(s.quicktg)
    e4:SetOperation(s.quickop)
    e4:SetLabelObject(e0)
    c:RegisterEffect(e4)

    -- WIND: may attack directly.
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EFFECT_DIRECT_ATTACK)
    e5:SetCondition(s.haswind)
    e5:SetLabelObject(e0)
    c:RegisterEffect(e5)

    -- EARTH: opponent's card effects cannot target King.
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e6:SetCondition(s.hasearth)
    e6:SetValue(aux.tgoval)
    e6:SetLabelObject(e0)
    c:RegisterEffect(e6)

    -- If Fusion Summoned King leaves the field, revive up to 3 distinct-Attribute Mirror Slimes.
    local e7=Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id,1))
    e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e7:SetProperty(EFFECT_FLAG_DELAY)
    e7:SetCode(EVENT_LEAVE_FIELD)
    e7:SetCondition(s.spcon)
    e7:SetTarget(s.sptg)
    e7:SetOperation(s.spop)
    c:RegisterEffect(e7)
end

-- This gets called both to test a possible material and to validate selected materials.
function s.matfilter(c,fc,sub,mg,sg)
    -- The MDPro4 mix-repetition callback receives the selected group as its
    -- fifth argument. Reject another Slime with an already-selected Attribute.
    if not (c:IsFusionSetCard(0x1f50) and c:IsFusionType(TYPE_MONSTER)) then return false end
    if sg then
        for tc in aux.Next(sg) do
            if tc~=c and (tc:GetAttribute()&c:GetAttribute())~=0 then
                return false
            end
        end
    end
    return true
end

-- Called at the Summon to preserve which material Attributes were actually used.
function s.matcheck(e,c)
    local mask=0
    for tc in aux.Next(c:GetMaterial()) do
        mask=mask|tc:GetAttribute()
    end
    e:SetLabel(mask)
end
function s.hasattr(e,attr)
    local src=e:GetLabelObject()
    return src and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and (src:GetLabel()&attr)~=0
end
function s.hasfire(e) return s.hasattr(e,ATTRIBUTE_FIRE) end
function s.haswater(e) return s.hasattr(e,ATTRIBUTE_WATER) end
function s.haslight(e) return s.hasattr(e,ATTRIBUTE_LIGHT) end
function s.hasdark(e) return s.hasattr(e,ATTRIBUTE_DARK) end
function s.haswind(e) return s.hasattr(e,ATTRIBUTE_WIND) end
function s.hasearth(e) return s.hasattr(e,ATTRIBUTE_EARTH) end

function s.rmfilter(c) return c:IsAbleToRemove() end
local BANISH_USED=id+1000
local BLUE_USED=id+1001
local BANISH=1
local BLUE=2
local BOTH=3

function s.canbanish(e,tp)
    return s.hasdark(e) and e:GetHandler():GetFlagEffect(BANISH_USED)==0
        and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.canblue(e,tp)
    return s.haswater(e) and e:GetHandler():GetFlagEffect(BLUE_USED)==0
        and Duel.IsExistingTarget(s.bluefilter,tp,0,LOCATION_MZONE,1,nil)
end
function s.quickcon(e,tp,eg,ep,ev,re,r,rp)
    return s.hasdark(e) or s.haswater(e)
end
function s.quicktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE)
            and s.bluefilter(chkc)
    end
    local b=s.canbanish(e,tp)
    local w=s.canblue(e,tp)
    if chk==0 then return b or w end
    local mode
    if b and w then
        local sel=Duel.SelectOption(tp,
            aux.Stringid(CHOICE_TEXT_ID,0),
            aux.Stringid(CHOICE_TEXT_ID,1),
            aux.Stringid(CHOICE_TEXT_ID,2))
        mode=sel==0 and BANISH or (sel==1 and BLUE or BOTH)
    elseif b then
        mode=BANISH
    else
        mode=BLUE
    end
    e:SetLabel(mode)
    -- Blue's effect targets on activation; King's banish still chooses
    -- its card only at resolution (and therefore does not target).
    if (mode&BLUE)~=0 then
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
        e:SetCategory((mode&BANISH)~=0 and (CATEGORY_REMOVE+CATEGORY_ATKCHANGE) or CATEGORY_ATKCHANGE)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
        Duel.SelectTarget(tp,s.bluefilter,tp,0,LOCATION_MZONE,1,1,nil)
    else
        e:SetProperty(0)
        e:SetCategory(CATEGORY_REMOVE)
    end
    local fc=e:GetHandler()
    local reset=RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END
    if (mode&BANISH)~=0 then fc:RegisterFlagEffect(BANISH_USED,reset,0,1) end
    if (mode&BLUE)~=0 then fc:RegisterFlagEffect(BLUE_USED,reset,0,1) end
end
function s.quickop(e,tp,eg,ep,ev,re,r,rp)
    local mode=e:GetLabel()
    if (mode&BLUE)~=0 then s.blueop(e,tp,eg,ep,ev,re,r,rp) end
    if (mode&BANISH)~=0 then s.rmop(e,tp,eg,ep,ev,re,r,rp) end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then Duel.Remove(g,POS_FACEUP,REASON_EFFECT) end
end

-- Mirror Slime - Blue's unchanged material bonus, now one option on King.
function s.bluefilter(c)
    return c:IsFaceup() and c:IsAttackAbove(0)
end
function s.blueop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local fc=e:GetHandler()
    if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup()
        or not fc:IsFaceup() then return end
    local def=fc:GetDefense()
    if def<=0 then return end
    local e1=Effect.CreateEffect(fc)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(-def)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsPreviousControler(tp)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x1f50) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.newattr(c,sg)
    for tc in aux.Next(sg) do
        if (c:GetAttribute()&tc:GetAttribute())~=0 then return false end
    end
    return true
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local ct=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),3)
    if ct<=0 then return end
    local pool=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
    local sg=Group.CreateGroup()
    for i=1,ct do
        local avail=pool:Filter(s.newattr,nil,sg)
        if #avail==0 then break end
        if i>1 and not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then break end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=avail:Select(tp,1,1,nil)
        if #g==0 then break end
        local tc=g:GetFirst()
        sg:AddCard(tc)
        pool:RemoveCard(tc)
    end
    if #sg>0 then Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP) end
end
