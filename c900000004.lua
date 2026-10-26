-- Mirror Slime - Purple | MDPro4 / ocgcore development prototype
-- ID 900000004. DARK / Aqua / Effect, Level 3, 1100 ATK / 700 DEF
-- Both effects have independent hard once-per-turn limits.
local s,id=GetID()
-- Effect count identifiers must not contain the core's once-per-Duel flag bits.
local cid=0x0f000000+(id-900000000)*16
local SET_MIRROR=0x1f50
function s.initial_effect(c)
    -- If sent to the GY except as Fusion Material: send another
    -- Mirror Slime from Deck to the GY.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_GRAVE)
    e1:SetCountLimit(1,cid)
    e1:SetCondition(s.gycon)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    -- Restore the Graveyard trigger after the earlier v15 diagnostic.
    -- This and the Fusion-material destruction trigger are separate effects.
    c:RegisterEffect(e1)

    -- If used as Fusion Material for a Slime Fusion Monster: destroy 1 card.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCountLimit(1,cid+1)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    -- Let this activate for discards, destruction, milling, Tributes, etc.,
    -- but do not offer it alongside the Fusion-material destruction effect.
    return (r&REASON_FUSION)==0
end
function s.tgfilter(c)
    return c:IsSetCard(SET_MIRROR) and c:IsType(TYPE_MONSTER)
        and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=c:GetReasonCard()
    -- Material triggers cannot be activated from the hidden Deck, where
    -- Prism Fusion places materials recycled from the GY or Extra Deck.
    return c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
        and (r&REASON_FUSION)~=0 and rc and rc:IsType(TYPE_FUSION)
        and rc:IsSetCard(SET_MIRROR)
end
function s.desfilter(c,e)
    return c:IsOnField() and c:IsDestructable() and c:IsCanBeEffectTarget(e)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return s.desfilter(chkc,e) end
    if chk==0 then
        return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
