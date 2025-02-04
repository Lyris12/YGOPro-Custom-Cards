--created by Discord \ Walrus
--囁きするカオス
local s,id,o=GetID()
function s.initial_effect(c)
	--Add 1 of your banished cards to your hand. If you added a card that was banished face-down to your hand by this effect, banish both this card and 1 random card from your hand, face-down. If this card is banished: You can activate this effect; during your next Standby Phase, your opponent must banish as many random cards from their hand as possible, face-down, up to the number of Level 8 or higher DARK Fiend monsters you control. You can only activate 1 "Whispering Chaos" per turn.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.filter(c,tc,tp)
	return c:IsAbleToHand() and (c:IsFaceup() or tc:IsAbleToRemove(tp,POS_FACEDOWN)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil,tp,POS_FACEDOWN))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_REMOVED,0,1,nil,e:GetHandler(),tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,tp,LOCATION_REMOVED)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil,e:GetHandler(),tp):GetFirst()
	local b=tc:IsFacedown()
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tc)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND,0,nil,tp,POS_FACEDOWN)
	if b and c:IsRelateToEffect(e) and #g>0 then
		Duel.BreakEffect()
		Duel.Remove(g:RandomSelect(tp,1)+c,POS_FACEDOWN,REASON_EFFECT)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local b=Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY
	local tn=Duel.GetTurnCount()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(function() return Duel.GetTurnPlayer()==tp and (b or Duel.GetTurnCount()~=tn) end)
	e1:SetOperation(function() Duel.Hint(HINT_CARD,0,id) Duel.Remove(Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(1-tp,Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)),POS_FACEDOWN,REASON_EFFECT) end)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,b and 2 or 1)
	Duel.RegisterEffect(e1,tp)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(8) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND)
end
