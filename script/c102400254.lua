--created by Lyris
--アーマリン・メムワー・ナース
local s,id,o=GetID()
function s.initial_effect(c)
	--Once per turn, during damage calculation, if this card battles (Quick Effect): You can Special Summon 1 "Armarine" monster from your Deck with a different name from the monster you control and/or in your GY, then destroy this card. If this card is destroyed by a card effect: Return 1 "Armarine" card from your GY to the hand, except "Armarine Nurse of Memory". You can only use this effect of "Armarine Nurse of Memory" once per turn.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCountLimit(1,id)
	e5:SetCondition(function(e,tp,eg,ep,ev,re,r) return r&REASON_EFFECT>0 end)
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetTarget(s.tg)
	e5:SetOperation(s.op)
	c:RegisterEffect(e5)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if a:IsControler(1-tp) then a=Duel.GetAttackTarget() end
	return a==e:GetHandler() and a:IsRelateToBattle()
end
function s.filter(c,e,tp)
	return c:IsSetCard(0xa6c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if Duel.SpecialSummon(Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.BreakEffect()
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.rfilter(c)
	return c:IsSetCard(0xa6c) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g)
end
