--created by Lyris
--銀河眼の固体光子竜
local s,id,o=GetID()
function s.initial_effect(c)
	--Cannot be Normal Summoned/Set. Must be Special Summoned (from your hand or Deck) by Tributing 2 monsters with 2000 or more ATK, including a "Galaxy-Eyes Photon Dragon" equipped with "Metalmorph". (Quick Effect): You can activate this effect; until the end of this turn, this card gains 500 ATK for each material that was used to Special Summon 1 monster on the field from the Extra Deck, also it is unaffected by your opponent's Spell effects. You can only use this effect of "Galaxy-Eyes Solid Photon Dragon" once per turn. If this card in the Monster Zone leaves the field: You can Special Summon 1 "Galaxy-Eyes" Dragon monster from your GY.
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) end)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
end
function s.rfilter(c,tp)
	return c:IsAttackAbove(2000) and (c:IsControler(tp) or c:IsFaceup())
end
function s.spcfilter(c)
	return c:IsFaceup() and c:IsCode(93717133) and c:GetEquipGroup():IsExists(aux.AND(Card.IsFaceup,Card.IsCode),1,nil,id)
end
function s.spgoal(g)
	return g:IsExists(s.spcfilter,1,nil) and Duel.GetMZoneCount(tp,g)>0
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and Duel.GetReleaseGroup(tp):Filter(s.rfilter,nil,tp):CheckSubGroup(s.spgoal,2,2)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.GetReleaseGroup(tp):Filter(s.rfilter,nil,tp):SelectSubGroup(tp,s.spgoal,Duel.IsSummonCancelable(),2,2)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else return false end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Release(g,REASON_COST)
	c:RegisterFlagEffect(0,RESET_EVENT+0x4fc0000,EFFECT_FLAG_CLIENT_HINT,1,0,5)
	g:DeleteGroup()
end
function s.filter(c)
	return c:GetMaterialCount()>0 and c:GetSummonLocation()==LOCATION_EXTRA
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	e2:SetValue(aux.TargetBoolFunction(Effect.IsActiveType,TYPE_SPELL))
	c:RegisterEffect(e2)
	local e1=e2:Clone()
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	e1:SetValue(Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst():GetMaterialCount()*500)
	c:RegisterEffect(e1)
end
function s.eqfilter(c,tp)
	return c:IsCode(68540058) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x107b) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp),0,tp,tp,false,false,POS_FACEUP)
end
