require("cutscene_base_ins_r")
---@class CutsceneMonsterTurnToPlayerInstruction: CutsceneBaseInstruction
_class("CutsceneMonsterTurnToPlayerInstruction", CutsceneBaseInstruction)
CutsceneMonsterTurnToPlayerInstruction = CutsceneMonsterTurnToPlayerInstruction

function CutsceneMonsterTurnToPlayerInstruction:Constructor(paramList)
    self._name = paramList["name"]
end

---@param phaseContext CutscenePhaseContext
function CutsceneMonsterTurnToPlayerInstruction:DoInstruction(TT, phaseContext)
    local world = phaseContext:GetCutsceneWorld()
    ---@type CutsceneServiceRender
    local cutsceneServiceRender = world:GetService("Cutscene")
    local playerEntity = world:Player():GetLocalTeamEntity()
    local playerPos = cutsceneServiceRender:GetCutsceneRenderGridPosition(playerEntity)

    for i, entity in ipairs(cutsceneServiceRender:GetCutsceneMonsterGroupEntity()) do
        ---@type CutsceneMonsterComponent
        local cutsceneMonsterComponent = entity:CutsceneMonster()
        if cutsceneMonsterComponent:GetCutsceneMonsterName() == self._name then
            local curPos = cutsceneServiceRender:GetCutsceneRenderGridPosition(entity)
            local dir = playerPos - curPos
            entity:SetDirection(dir)
        end
    end
end
