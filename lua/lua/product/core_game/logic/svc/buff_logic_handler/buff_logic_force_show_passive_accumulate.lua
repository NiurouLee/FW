--[[
    用来修改UI上的被动计能计数显隐
]]

---@class BuffLogicForceShowPassiveAccumulate:BuffLogicBase
_class("BuffLogicForceShowPassiveAccumulate", BuffLogicBase)
BuffLogicForceShowPassiveAccumulate = BuffLogicForceShowPassiveAccumulate

function BuffLogicForceShowPassiveAccumulate:Constructor(buffInstance, logicParam)
	self._buffLayerList = logicParam.buffLayerList
	self._forceInitType = logicParam.forceInitType
	self._maxLayerCount = logicParam.maxLayerCount
end

function BuffLogicForceShowPassiveAccumulate:DoLogic(notify)
	local buffResult = BuffResultForceShowPassiveAccumulate:New(self._buffLayerList, self._forceInitType, self._maxLayerCount)
	return buffResult
end