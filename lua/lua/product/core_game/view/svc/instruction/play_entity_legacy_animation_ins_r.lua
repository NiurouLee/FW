require("base_ins_r")

---@class PlayEntityLegacyAnimationInstruction: BaseInstruction
_class("PlayEntityLegacyAnimationInstruction", BaseInstruction)
PlayEntityLegacyAnimationInstruction = PlayEntityLegacyAnimationInstruction

function PlayEntityLegacyAnimationInstruction:Constructor(paramList)
    local str = paramList["animNames"]
    self._animNames = string.split(str, "|")

    self._monsterClassID = tonumber(paramList["monsterClassID"]) or 0
    self._trapID = tonumber(paramList["trapID"]) or 0

    ---挂在玩家身上的特效ID
    self._casterEffectID = tonumber(paramList["casterEffectID"]) or 0
end

---@param casterEntity Entity
function PlayEntityLegacyAnimationInstruction:DoInstruction(TT, casterEntity, phaseContext)
    if self._animNames == nil then
        Log.fatal("Legacy animation params is nil!")
        return
    end

    if casterEntity:HasSuperEntity() then
        casterEntity = casterEntity:GetSuperEntity()
    end

    ---@type MainWorld
    local world = casterEntity:GetOwnerWorld()
    local entityList = {}
    if self._trapID and self._trapID > 0 then
        local trapGroup = world:GetGroup(world.BW_WEMatchers.Trap)
        for _, e in ipairs(trapGroup:GetEntities()) do
            ---@type TrapRenderComponent
            local trapRenderCmpt = e:TrapRender()
            if trapRenderCmpt and not trapRenderCmpt:GetHadPlayDestroy() and self._trapID == trapRenderCmpt:GetTrapID() then
                table.insert(entityList, e)
            end
        end
    end
    if self._monsterClassID and self._monsterClassID > 0 then
        local monsterGroup = world:GetGroup(world.BW_WEMatchers.MonsterID)
        for _, e in ipairs(monsterGroup:GetEntities()) do
            if e:HasView() and not e:HasShowDeath() and self._monsterClassID == e:MonsterID():GetMonsterClassID() then
                table.insert(entityList, e)
            end
        end
    end

    if self._casterEffectID and self._casterEffectID > 0 then 
        ---@type EffectHolderComponent
        local casterEffectHolderCmpt = casterEntity:EffectHolder()
        local effectEntityIDList = casterEffectHolderCmpt:GetEffectEntityIDByEffectID(self._casterEffectID)
        for _, effectEntityID in ipairs(effectEntityIDList) do
            local effectEntity = world:GetEntityByID(effectEntityID)
            table.insert(entityList, effectEntity)
        end
    end

    for _, e in ipairs(entityList) do
        self:_PlayAnimation(e)
    end
end

---@param entity Entity
function PlayEntityLegacyAnimationInstruction:_PlayAnimation(entity)
    if not entity:HasView() then
        return
    end
    local go = entity:View():GetGameObject()
    ---@type UnityEngine.Animation
    local anim = go:GetComponentInChildren(typeof(UnityEngine.Animation))
    if anim == nil then
        Log.fatal("Cant play legacy animation, animation not found in ", go.name)
        return
    end
    if table.count(self._animNames) > 1 then
        anim:Stop()
        for i = 1, #self._animNames do
            anim:PlayQueued(self._animNames[i])
        end
    else
        anim:Play(self._animNames[1])
    end
end
