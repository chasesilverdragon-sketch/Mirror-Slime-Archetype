-- Queen Rainbow Slime
-- Custom card ID: 900000020
-- LINK-2 / LIGHT / Aqua / 1600 ATK
-- Links: bottom-left, bottom-right
-- Materials: 2 Aqua monsters, including a "Mirror Slime" monster.
-- Mirror Slime archetype code: 0x1f50 (8016 decimal).
local s,id=GetID()
-- Effect count identifiers must not contain the core's once-per-Duel flag bits.
local cid=0x0f000000+(id-900000000)*16

function s.initial_effect(c)
    -- Link Summon using exactly 2 Aqua monsters, including a Mirror Slime.
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_AQUA),2,2,s.lcheck)

    -- Each Fusion Monster Queen points to survives destruction once each turn.
    -- With EFFECT_TYPE_FIELD + EFFECT_INDESTRUCTABLE_COUNT, the limit applies
    -- to the affected monsters; it is not an activated effect.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.indtg)
    e1:SetCountLimit(1)
    e1:SetValue(s.indval)
    c:RegisterEffect(e1)

    -- If Queen is sent from anywhere on the field to the GY, search a Mirror Slime.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1,cid)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- The extra condition is checked on the entire material group.
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(s.mirrorfilter,1,nil)
end

function s.mirrorfilter(c)
    return c:IsSetCard(0x1f50) and c:IsType(TYPE_MONSTER)
end

function s.indtg(e,c)
    return c:IsType(TYPE_FUSION)
        and e:GetHandler():GetLinkedGroup():IsContains(c)
end

function s.indval(e,re,r,rp)
    return (r&REASON_BATTLE)~=0 or (r&REASON_EFFECT)~=0
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end

function s.thfilter(c)
    return s.mirrorfilter(c) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
    end
end
