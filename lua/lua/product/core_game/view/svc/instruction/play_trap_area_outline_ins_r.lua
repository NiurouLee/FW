---@class PlayTrapAreaOutlineInstruction:BaseInstruction
_class("PlayTrapAreaOutlineInstruction", BaseInstruction)
PlayTrapAreaOutlineInstruction = PlayTrapAreaOutlineInstruction

function PlayTrapAreaOutlineInstruction:Constructor(paramList)
    self._effectID = tonumber(paramList.effectID)
    --self._trapID = tonumber(paramList.trapID)
    self._trapType = tonumber(paramList.trapType)
end

function PlayTrapAreaOutlineInstruction:GetCacheResource()
    local t = {}
    if self._effectID and self._effectID > 0 then
        table.insert(t, {Cfg.cfg_effect[self._effectID].ResPath, 10})
    end
    return t
end

function PlayTrapAreaOutlineInstruction:DoInstruction(TT, casterEntity, phaseContext)
    ---@type MainWorld
    local world = casterEntity:GetOwnerWorld()

    local utilScope = world:GetService("UtilScopeCalc")
    local tGridRange = utilScope:GetGridPossessedByTrapType(self._trapType)

    ---@type RenderEntityService
    local rsvcEntity = world:GetService("RenderEntity")
    rsvcEntity:ClearTrapAreaOutlineEntity()
    rsvcEntity:CreateTrapAreaOutlineEntity(tGridRange, Cfg.cfg_effect[self._effectID].ResPath)
end
