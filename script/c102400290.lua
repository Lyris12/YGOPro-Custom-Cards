--created by Lyris
--半物質のオーヴァロード(アナザー宙)
local s,id,o=GetID()
function s.initial_effect(c)
	--2 monsters with different Attributes, except Tokens If this card you control is banished, if all of the monsters that were used for its Spatial Summon are banished: You can Special Summon all of them, but change their ATK to the lowest ATK among those Summoned monsters (your choice, if tied).
	c:EnableReviveLimit()
	aux.AddOrigSpatialType(c)
	aux.AddSpatialProc(c,aux.dabcheck,aux.FilterBoolFunction(aux.NOT(Card.IsType),TYPE_TOKEN),2,2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(function() return c:GetPreviousControler()==c:GetOwner() and c:IsPreviousLocation(LOCATION_ONFIELD) end)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.spt_other_space=102400286
function s.filter(c,e,tp,sync)
	local REASON_SPTMAT=REASON_MATERIAL+REASON_SPATIAL
	return c:IsLocation(LOCATION_REMOVED) and c:GetReason()&REASON_SPTMAT==REASON_SPTMAT
		and c:GetReasonCard()==sync and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	local ct=#mg
	if chk==0 then return c:IsSummonType(SUMMON_TYPE_SPATIAL)
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and ct>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct and mg:FilterCount(s.filter,nil,e,tp,c)==ct end
	Duel.SetTargetCard(mg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mg,ct,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local mg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=mg:Filter(Card.IsRelateToChain,nil,0)
	if #g<#mg then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<#g then return end
	local _,atk=g:GetMinGroup(Card.GetAttack)
	for tc in aux.Next(g) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end
