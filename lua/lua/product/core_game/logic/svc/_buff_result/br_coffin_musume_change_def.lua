_class("BuffResultCoffinMusumeChangeDefenceByCandle", BuffResultBase)
---@class BuffResultCoffinMusumeChangeDefenceByCandle:BuffResultBase
BuffResultCoffinMusumeChangeDefenceByCandle = BuffResultCoffinMusumeChangeDefenceByCandle

function BuffResultCoffinMusumeChangeDefenceByCandle:Constructor(tLightCandleID, uiText, val)
    self._tLightCandleID = tLightCandleID
    self._uiText = uiText or "str_battle_harm_reduction" --不写默认使用“信标减伤”
    self._val = val
end

function BuffResultCoffinMusumeChangeDefenceByCandle:GetLightCandleIDs()
    return self._tLightCandleID
end

function BuffResultCoffinMusumeChangeDefenceByCandle:GetLightCandleCount()
    return #(self._tLightCandleID)
end

function BuffResultCoffinMusumeChangeDefenceByCandle:GetHarmReduction()
    return self._val
end

function BuffResultCoffinMusumeChangeDefenceByCandle:GetUIText()
    return self._uiText
end
