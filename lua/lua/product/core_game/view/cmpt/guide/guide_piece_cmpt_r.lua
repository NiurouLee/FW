--[[------------------------------------------------------------------------------------------
    GuidePieceComponent : 新手引导 格子引导
]] --------------------------------------------------------------------------------------------

---@class GuidePieceComponent: Object
_class("GuidePieceComponent", Object)

function GuidePieceComponent:Constructor()
    self.unValidGrids = {}
    self.validGrids = {}
end

function GuidePieceComponent:SetValidGrids(grids)
    self.validGrids = grids
end

function GuidePieceComponent:GetValidGrids()
    return self.validGrids
end
function GuidePieceComponent:SetUnValidGrids(grids)
    self.unValidGrids = grids
end

function GuidePieceComponent:GetUnValidGrids()
    return self.unValidGrids
end
-- As IWorldEntityComponent:
--//////////////////////////////////////////////////////////

---@param owner Entity
function GuidePieceComponent:WEC_PostInitialize(owner)
    --ToDo WEC_PostInitialize
end

function GuidePieceComponent:WEC_PostRemoved()
    --Do WEC_PostRemoved
end ---@return GuidePieceComponent
--------------------------------------------------------------------------------------------

-- This:
--//////////////////////////////////////////////////////////

--[[------------------------------------------------------------------------------------------
    Entity Extensions
]]
function Entity:GuidePiece()
    return self:GetComponent(self.WEComponentsEnum.GuidePiece)
end

function Entity:HasGuidePiece()
    return self:HasComponent(self.WEComponentsEnum.GuidePiece)
end

function Entity:AddGuidePiece()
    local index = self.WEComponentsEnum.GuidePiece
    local component = GuidePieceComponent:New()
    self:AddComponent(index, component)
end

function Entity:ReplaceGuidePiece()
    local index = self.WEComponentsEnum.GuidePiece
    local cmpt = self:GuidePiece()
    self:ReplaceComponent(index, cmpt)
end

function Entity:RemoveGuidePiece()
    if self:HasGuidePiece() then
        self:RemoveComponent(self.WEComponentsEnum.GuidePiece)
    end
end
