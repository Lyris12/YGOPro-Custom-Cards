--EE・ウィノーナー
function c101010489.initial_effect(c)
	--You can target 1 "Earth Enforcer" Xyz Monster you control; discard this card from your hand, then attach 1 "Earth Enforcer" monster from your Deck to that Xyz Monster as an Xyz Material.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c101010489.mattg)
	e1:SetOperation(c101010489.matop)
	c:RegisterEffect(e1)
	--If this card is detached from an "Earth Enforcer" Xyz Monster and sent to the Graveyard to activate that monster's effect: You can pay 1000 LP; add this card from your Graveyard to your hand.
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c101010489.dtcon)
	e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)if chk==0 then return Duel.CheckLPCost(tp,1000) end Duel.PayLPCost(tp,1000) end)
	e3:SetTarget(c101010489.thtg)
	e3:SetOperation(c101010489.thop)
	c:RegisterEffect(e3)
end
function c101010489.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0xeeb)
end
function c101010489.matfilter(c)
	return c:IsSetCard(0xeeb) and c:IsType(TYPE_MONSTER)
end
function c101010489.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c101010489.xyzfilter(chkc) end
	if chk==0 then return e:GetHandler():IsDiscardable(REASON_EFFECT) and Duel.IsExistingTarget(c101010489.xyzfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c101010489.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c101010489.matop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_DISCARD)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,c101010489.matfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.BreakEffect()
			Duel.Overlay(tc,g)
		end
	end
end
function c101010489.dtcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsHasType(0x7e0) and re:IsActiveType(TYPE_MONSTER)
		and c:IsPreviousLocation(LOCATION_OVERLAY) and re:GetHandler():IsSetCard(0xeeb)
end
function c101010489.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	e:GetHandler():CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function c101010489.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
