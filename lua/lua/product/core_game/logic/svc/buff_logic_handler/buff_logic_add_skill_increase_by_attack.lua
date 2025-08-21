--[[
    每次攻击叠加层数,每层增加百分比伤害
]]
_class("BuffLogicAddSkillIncreaseByAttack", BuffLogicBase)
---@class BuffLogicAddSkillIncreaseByAttack:BuffLogicBase
BuffLogicAddSkillIncreaseByAttack = BuffLogicAddSkillIncreaseByAttack

function BuffLogicAddSkillIncreaseByAttack:Constructor(buffInstance, logicParam)
	self._buffInstance._layer = 0
	self._buffInstance._effectList = logicParam.effectList
	self._buffComp = buffInstance:Entity():BuffComponent()
end

function BuffLogicAddSkillIncreaseByAttack:DoLogic()
	local e = self._buffInstance:Entity()
	self._buffInstance._layer = self._buffInstance._layer + 1

	---修改伤害
	for _, paramType in ipairs(self._buffInstance._effectList) do
		local addPercent = self._buffInstance._layer * paramType.addPercentPerLayer
		local attackType = paramType.attackType
		self:GetBuffLogicService():ChangeSkillIncrease(e,self:GetBuffSeq(),attackType,addPercent)
	end
	local result = BuffResultAddSkillIncreaseByAttack:New(self._buffInstance._layer)
	return result
end

_class("BuffLogicAddSkillIncreaseByAttackUndo", BuffLogicBase)
---@class BuffLogicAddSkillIncreaseByAttackUndo:BuffLogicBase
BuffLogicAddSkillIncreaseByAttackUndo = BuffLogicAddSkillIncreaseByAttackUndo

function BuffLogicAddSkillIncreaseByAttackUndo:Constructor(buffInstance, logicParam)

end

function BuffLogicAddSkillIncreaseByAttackUndo:DoLogic()
	local e = self._buffInstance:Entity()
	self._buffInstance._layer = 0
	---先移除之前的效果
	for _, paramType in ipairs(self._buffInstance._effectList) do
		local attackType = paramType.attackType
		self:GetBuffLogicService():RemoveSkillIncrease(e,self:GetBuffSeq(),attackType)
    end
	return true
end
