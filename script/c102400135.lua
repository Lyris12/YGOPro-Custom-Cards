--created by Lyris
--集いし襲雷
local s,id,o=GetID()
function s.initial_effect(c)
	--During the End Phase of the turn this card was activated, draw a number of cards equal to the number of "Blitzkrieg" monsters with different names that were destroyed this turn (max. 2). You can only activate 1 "Blitzkrieg Convergence" per turn.
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_DRAW)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e0:SetOperation(s.activate)
	c:RegisterEffect(e0)
	if s.counter==nil then
		s.counter=true
		local g=Group.CreateGroup()
		g:KeepAlive()
		s[0]=g
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e2:SetOperation(s.resetcount)
		Duel.RegisterEffect(e2,0)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e3:SetCode(EVENT_DESTROYED)
		e3:SetOperation(s.addcount)
		Duel.RegisterEffect(e3,0)
	end
end
function s.resetcount(e,tp,eg,ep,ev,re,r,rp)
	s[0]:Clear()
end
function s.filter(c)
	return c:IsSetCard(0x7c4) and c:IsType(TYPE_MONSTER)
end
function s.addcount(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg:Filter(s.filter,nil)) do s[0]=s[0]+tc end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.droperation)
	Duel.RegisterEffect(e1,tp)
end
function s.droperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local ct=s[0]:GetClassCount(Card.GetCode)
	if ct>2 then ct=2 end
	Duel.Draw(tp,ct,REASON_EFFECT)
end
