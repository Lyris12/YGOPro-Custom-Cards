--created by Lyris
--サイバー・ドラゴン・ティマイオス
local s,id,o=GetID()
function s.initial_effect(c)
	--Declare 1 number from 2 to 6, then target 1 "Cyber Dragon" you control; Fusion Summon 1 Fusion Monster from your Extra Deck that lists "Cyber Dragon" as a Fusion Material, using it as the Fusion Material, treating it as up to the declared number of monsters, then you can have the Summoned monster gain 3400 ATK, but you cannot Special Summon other monsters for the rest of this turn, except Machine monsters. At the end of the turn this card is activated, take damage equal to the Summoned monster's current surplus of ATK. You can only activate 1 "Cyber Dragon Timaeus" per turn. If you Fusion Summon a Fusion Monster, this card can be treated as a monster with the same name as "Cyber Dragon".
	local f1,f2,f3=Card.IsCanBeFusionMaterial,Duel.GetMatchingGroup,Duel.GetFusionMaterial
	Card.IsCanBeFusionMaterial=function(tc,fc)
		return f1(tc,fc) or (not tc:IsHasEffect(EFFECT_CANNOT_BE_FUSION_MATERIAL) and tc:GetOriginalCode()==c:GetOriginalCode())
	end
	Duel.GetMatchingGroup=function(f,p,sloc,oloc,exc,...)
		local g=f2(f,p,sloc,oloc,exc,table.unpack{...})
		if not f or f(c,table.unpack{...}) then g:AddCard(c) end
		return g:Filter(function(c) return (c:IsControler(p) and c:IsLocation(sloc)) or (c:IsControler(1-p) and c:IsLocation(oloc)) end,nil)
	end
	Duel.GetFusionMaterial=function(p)
		local mg,loc=f3(p),c:GetLocation()
		if loc&(LOCATION_HAND+LOCATION_ONFIELD)==loc and f1(c) then mg:AddCard(c) end
		return mg
	end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ADD_FUSION_CODE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetValue(CARD_CYBER_DRAGON)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tgfilter(c,e,tp,n)
	return c:IsFaceup() and c:IsCode(CARD_CYBER_DRAGON) and c:IsCanBeFusionMaterial()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,n)
		and Duel.GetLocationCountFromEx(tp,tp,c)>0
end
function s.spfilter(c,e,tp,tc,n)
	if not (aux.IsMaterialListCode(c,CARD_CYBER_DRAGON) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	local g=Group.FromCards(tc)
	for i=2,n do
		Duel.DisableActionCheck(true)
		local tk=Duel.CreateToken(tp,CARD_CYBER_DRAGON)
		Duel.DisableActionCheck(false)
		g:AddCard(tk)
	end
	aux.FCheckAdditional=function(tp,sg,fc)
		return #sg==n or fc:IsCode(CARD_CYBER_DRAGON)
	end
	local res=c:CheckFusionMaterial(g,nil,tp)
	aux.FCheckAdditional=nil
	return res
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local t={}
	for i=2,6 do
		if Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,i) then table.insert(t,i) end
	end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,e,tp,e:GetLabel()) end
	if chk==0 then return #t>0 end
	local ct=Duel.AnnounceNumber(tp,table.unpack(t))
	e:SetLabel(ct)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,ct)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCountFromEx(tp,tp,tc)<=0 then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeFusionMaterial() and not tc:IsImmuneToEffect(e) then
		local ct=e:GetLabel()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,ct)
		local sc=sg:GetFirst()
		if sc then
			local mg=Group.FromCards(tc)
			for i=2,ct do
				local ck=Duel.CreateToken(tp,CARD_CYBER_DRAGON)
				mg:AddCard(ck)
			end
			sc:SetMaterial(mg)
			Duel.SendtoGrave(tc,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			if Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)~=0 then
				sc:CompleteProcedure()
				if not Duel.SelectYesNo(tp,1113) then return end
				Duel.BreakEffect()
				if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
					local e2=Effect.CreateEffect(e:GetHandler())
					e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					e2:SetCode(EVENT_PHASE+PHASE_END)
					e2:SetCountLimit(1)
					e2:SetLabelObject(sc)
					e2:SetReset(RESET_PHASE+PHASE_END)
					e2:SetOperation(s.damop)
					Duel.RegisterEffect(e2,tp)
				end
				local e0=Effect.CreateEffect(e:GetHandler())
				e0:SetType(EFFECT_TYPE_FIELD)
				e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e0:SetReset(RESET_PHASE+PHASE_END)
				e0:SetTargetRange(1,0)
				e0:SetTarget(s.splimit)
				Duel.RegisterEffect(e0,tp)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(3400)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
			end
		end
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetRace()~=RACE_MACHINE
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	local base,curr=ec:GetBaseAttack(),ec:GetAttack()
	if curr>base then Duel.Damage(tp,curr-base,REASON_EFFECT) end
end
