--[[
    白水仙镜子破碎、露易丝加防头像左移
]]
_class("BuffViewIncreaseAddDefense", BuffViewBase)
BuffViewIncreaseAddDefense = BuffViewIncreaseAddDefense

function BuffViewIncreaseAddDefense:PlayView(TT)
    GameGlobal.EventDispatcher():Dispatch(GameEventType.InOutQueue, self._entity:PetPstID():GetPstID(), true)
    YIELD(TT, 1500)
    GameGlobal.EventDispatcher():Dispatch(GameEventType.InOutQueue, self._entity:PetPstID():GetPstID(), false)
end

_class("BuffViewResetIncreaseAddDefense", BuffViewBase)
BuffViewResetIncreaseAddDefense = BuffViewResetIncreaseAddDefense

function BuffViewResetIncreaseAddDefense:PlayView(TT)
    GameGlobal.EventDispatcher():Dispatch(GameEventType.ActivatePassive, self._entity:PetPstID():GetPstID(), false)
end
