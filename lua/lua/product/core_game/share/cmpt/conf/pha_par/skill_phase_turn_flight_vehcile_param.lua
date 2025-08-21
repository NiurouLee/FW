--[[------------------------------------------------------------------------------------------
    SkillTurnFlightVehcileGridArrayParam : 回旋飞行器攻击
]] --------------------------------------------------------------------------------------------
require "skill_phase_param_base"
---@class SkillTurnFlightVehcileGridArrayParam: Object
_class("SkillTurnFlightVehcileGridArrayParam", SkillPhaseParamBase)
SkillTurnFlightVehcileGridArrayParam = SkillTurnFlightVehcileGridArrayParam

function SkillTurnFlightVehcileGridArrayParam:Constructor(t)
    self._hitAnimName = t.hitAnimName
    self._hitEffectID = t.hitEffectID

    self._flyEffectID = t.flyEffectID --飞出去的特效
    self._flyBackEffectID = t.flyBackEffectID --飞回来的特效
    self._flyTime = t.flyTime --飞出去的时间
    self._flyBackTime = t.flyBackTime -- 飞回来的时间
    self._flyArriveDestory = t.flyArriveDestory --飞到终点后，等待一个时间后销毁自己
    self._flyBackStartWaitTime = t.flyBackStartWaitTime --飞到边缘后，和开始飞回的等待时间
end

function SkillTurnFlightVehcileGridArrayParam:GetCacheTable()
    local t = {}

    if self._hitEffectID and self._hitEffectID > 0 then
        t[#t + 1] = {Cfg.cfg_effect[self._hitEffectID].ResPath, 1}
    end
    if self._flyEffectID and self._flyEffectID > 0 then
        t[#t + 1] = {Cfg.cfg_effect[self._flyEffectID].ResPath, 1}
    end
    if self._flyBackEffectID and self._flyBackEffectID > 0 then
        t[#t + 1] = {Cfg.cfg_effect[self._flyBackEffectID].ResPath, 1}
    end
    return t
end

function SkillTurnFlightVehcileGridArrayParam:GetPhaseType()
    return SkillViewPhaseType.TurnRoundFlightVehicle
end

function SkillTurnFlightVehcileGridArrayParam:GetFlyTime()
    return self._flyTime
end
function SkillTurnFlightVehcileGridArrayParam:GetFlyBackTime()
    return self._flyBackTime
end
function SkillTurnFlightVehcileGridArrayParam:GetFlyArriveDestory()
    return self._flyArriveDestory
end
function SkillTurnFlightVehcileGridArrayParam:GetFlyBackStartWaitTime()
    return self._flyBackStartWaitTime
end

function SkillTurnFlightVehcileGridArrayParam:GetFlyEffectID()
    return self._flyEffectID
end

function SkillTurnFlightVehcileGridArrayParam:GetFlyBackEffectID()
    return self._flyBackEffectID
end

function SkillTurnFlightVehcileGridArrayParam:GetHitAnimName()
    return self._hitAnimName
end

function SkillTurnFlightVehcileGridArrayParam:GetHitEffectID()
    return self._hitEffectID
end
