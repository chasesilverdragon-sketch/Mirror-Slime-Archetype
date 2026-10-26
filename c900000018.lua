-- Prism Scale Shift (custom ID 900000018)
-- Normal Spell. MDPro4 / ocgcore development prototype: in-game test required.
-- Works with Prism Scale Slime - Inversion (900000007) and - Pure (900000008).
local s,id=GetID()
-- Effect count identifiers must not contain the core's once-per-Duel flag bits.
local cid=0x0f000000+(id-900000000)*16
local SCALE_INVERSION=900000007
local SCALE_PURE=900000008

function s.initial_effect(c)
    -- Activate: target a Prism Scale Slime in your Pendulum Zone; Special Summon it.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,cid)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- In the GY: banish this card as cost to reclaim a face-up Scale Slime
    -- Pendulum Monster from the face-up Extra Deck.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,cid+1)
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

function s.psfilter(c,e,tp)
    return c:IsCode(SCALE_INVERSION,SCALE_PURE)
        and c:IsFaceup() and c:IsType(TYPE_PENDULUM)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp)
            and s.psfilter(chkc,e,tp)
    end
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingTarget(s.psfilter,tp,LOCATION_PZONE,0,1,nil,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.psfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_PZONE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not tc:IsLocation(LOCATION_PZONE)
        or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
        or not s.psfilter(tc,e,tp) then return end
    Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToRemoveAsCost() end
    Duel.Remove(c,POS_FACEUP,REASON_COST)
end
function s.thfilter(c)
    return c:IsCode(SCALE_INVERSION,SCALE_PURE) and c:IsFaceup()
        and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA,0,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
    end
end
