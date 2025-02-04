--created by Lyris
--勇気の波動拳
local s,id,o=GetID()
function s.initial_effect(c)
	--If you control no monsters: You can Special Summon this card from your hand. During your Main Phase: You can have your opponent shuffle their Deck, then each player excavates the bottom 3 cards of their Deck, and if they do, they Special Summon 1 excavated Level 4 or lower monster to either field, (you must Special Summon a LIGHT "uken" monster), also, you place the rest on top of the Decks in any order. You can only use each effect of "Brave Hadouken" once per turn.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE+LOCATION_HAND)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetCountLimit(2,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
function s.filter(c)
	return c:IsSetCard(0x1d10) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=3
	if Duel.IsPlayerAffectedByEffect(tp,102400030) then ct=ct*2 end
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ct
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local ct=3
	if Duel.IsPlayerAffectedByEffect(tp,102400030) then ct=ct*2 end
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct then return end
	local g=Group.CreateGroup()
	for i=0,ct-1 do
		local tc=Duel.GetFieldCard(tp,LOCATION_DECK,i)
		if ct<6 then for p=0,1 do Duel.ConfirmCards(p,tc,true) end end
		g:AddCard(tc)
	end
	if ct>5 then for p=0,1 do Duel.ConfirmCards(p,g,true) end end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=g:FilterSelect(tp,Card.IsSetCard,1,1,nil,0x1d10):GetFirst()
	if tc then
		Duel.DisableShuffleCheck()
		if tc:IsAbleToHand() then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
			Duel.ShuffleHand(tp)
		else Duel.SendtoGrave(tc,REASON_RULE) end
		g:RemoveCard(tc)
	end
	for i=1,#g do Duel.MoveSequence(Duel.GetFieldCard(tp,LOCATION_DECK,0),SEQ_DECKTOP) end
end
