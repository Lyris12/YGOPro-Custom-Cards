--created by Lyris
--半物質の融合
local s,id,o=GetID()
function s.initial_effect(c)
	--Immediately after this effect resolves, Spatial Summon 1 Spatial Monster, using only "Antemattr" monsters in your hand and/or Deck. You can only apply the effect of "Antemattr Fusion" once per turn.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	Duel.RegisterEffect(e1,0)
end
function s.spfilter(c,e,tp)
	local res=false
	if not (c:IsType(TYPE_SPATIAL)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPATIAL,tp,false,false)) then return res end
	local et=global_card_effect_table[c]
	for _,e in ipairs(et) do
		if e:GetCode()==EFFECT_SPSUMMON_PROC then
			local ev=e:GetValue()
			local ec=e:GetCondition()
			if ev and (aux.GetValueType(ev)=="function" and ev(ef,c) or ev==SUMMON_TYPE_SPATIAL) and (not ec or ec(e,c)) then res=true end
		end
	end
	return res
end
function s.xfilter(e,c)
	return not c:IsLocation(LOCATION_DECK+LOCATION_HAND)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetFlagEffect(tp,id)>0 then return false end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BE_SPACE_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
		e1:SetTargetRange(0xfc,0)
		e1:SetValue(1)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_EXTRA_SPACE_MATERIAL)
		e2:SetTargetRange(LOCATION_DECK+LOCATION_HAND,0)
		e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf87))
		Duel.RegisterEffect(e2,tp)
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		e1:Reset() e2:Reset()
		return #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_SPACE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
	e1:SetTargetRange(0xfc,0)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_SPACE_MATERIAL)
	e2:SetTargetRange(LOCATION_DECK+LOCATION_HAND,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf87))
	Duel.RegisterEffect(e2,tp)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	e1:Reset() e2:Reset()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=g:Select(tp,1,1,nil):GetFirst()
	if sc then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_BE_SPACE_MATERIAL)
		e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE)
		e1:SetTargetRange(0xfc,0)
		e1:SetValue(1)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_EXTRA_SPACE_MATERIAL)
		e2:SetTargetRange(LOCATION_DECK+LOCATION_HAND,0)
		e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf87))
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_SPSUMMON)
		e3:SetOperation(function(ef,p,tg) if tg:GetFirst()~=sc then return end e1:Reset() e2:Reset() ef:Reset() end)
		Duel.RegisterEffect(e3,tp)
		Duel.SpecialSummonRule(tp,sc)
		if Duel.SetSummonCancelable then Duel.SetSummonCancelable(false) end
	end
end
