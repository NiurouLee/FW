--[[

]]
_class("BuffViewSetNormalAttackDirEff", BuffViewBase)
---@class BuffViewSetNormalAttackDirEff : BuffViewBase
BuffViewSetNormalAttackDirEff = BuffViewSetNormalAttackDirEff

function BuffViewSetNormalAttackDirEff:PlayView(TT)
    ---@type SetNormalAttackDirEff
    local result = self._buffResult

    local effectDirList = result:GetEffectDirList()
    local animName = result:GetAnimName()
    local waitTime = result:GetWaitTime()
    local remove = result:GetRemove()
    local effectID = result:GetEffectID()
    local curRoundHadSave = result:GetCurRoundHadSave()

    local effectHolder = self._entity:EffectHolder()
    if not effectHolder then
        self._entity:AddEffectHolder()
        effectHolder = self._entity:EffectHolder()
    end

    ---@type EffectService
    local effectService = self._world:GetService("Effect")

    local startAnim = animName .. "start"
    local loopAnim = animName .. "loop"
    local removeAnim = animName .. "end"

    for _, dirNum in ipairs(effectDirList) do
        if not table.icontains(curRoundHadSave, dirNum) then
            local effectKey = "SetNormalAttackDirEff" .. dirNum

            local effectIDList = effectHolder:GetEffectList(effectKey)
            -- effectHolder:ClearEffectList(effectKey)

            if effectIDList and table.count(effectIDList) > 0 then
                for _, effID in ipairs(effectIDList) do
                    local effEntity = self._world:GetEntityByID(effID)
                    if effEntity then
                        if remove == 1 then
                            -- effectHolder:ClearEffectList(effectKey)
                            GameGlobal.TaskManager():CoreGameStartTask(
                                function(TT)
                                    local go = effEntity:View():GetGameObject()

                                    ---@type UnityEngine.Animation
                                    local anim = go:GetComponentInChildren(typeof(UnityEngine.Animation))
                                    if go and anim and anim.clip and removeAnim then
                                        anim:Play(removeAnim)
                                        if waitTime then
                                            YIELD(TT, waitTime)
                                        end
                                        -- self._world:DestroyEntity(effEntity)

                                        go:SetActive(false)
                                    end
                                end
                            )
                        else
                            -- self._world:DestroyEntity(effEntity)

                            -- local newEffectEntity = effectService:CreateEffect(effectID, self._entity)
                            -- effectHolder:AttachEffect(effectKey, newEffectEntity:GetID())

                            -- local dir = self:_CalcDir(dirNum)
                            -- newEffectEntity:SetDirection(dir)

                            local go = effEntity:View():GetGameObject()
                            go:SetActive(true)

                            GameGlobal.TaskManager():CoreGameStartTask(
                                function(TT)
                                    ---@type UnityEngine.Animation
                                    local anim = go:GetComponentInChildren(typeof(UnityEngine.Animation))
                                    if go and anim and anim.clip then
                                        anim:Play(startAnim)
                                        if waitTime then
                                            YIELD(TT, waitTime)
                                        end
                                        anim:Play(loopAnim)
                                    end
                                end
                            )
                        end
                    end
                end
            else
                if effectID then
                    local newEffectEntity = effectService:CreateEffect(effectID, self._entity)
                    effectHolder:AttachEffect(effectKey, newEffectEntity:GetID())

                    local dir = self:_CalcDir(dirNum)

                    GameGlobal.TaskManager():CoreGameStartTask(
                        function(TT)
                            YIELD(TT)

                            newEffectEntity:SetDirection(dir)

                            local go = newEffectEntity:View():GetGameObject()

                            ---@type UnityEngine.Animation
                            local anim = go:GetComponentInChildren(typeof(UnityEngine.Animation))
                            if go and anim and anim.clip then
                                anim:Play(startAnim)
                                if waitTime then
                                    YIELD(TT, waitTime)
                                end
                                anim:Play(loopAnim)
                            end
                        end
                    )
                end
            end
        end
    end
end

--是否匹配参数
function BuffViewSetNormalAttackDirEff:IsNotifyMatch(notify)
    ---@type BuffResultSetNormalAttackDirEff
    local result = self._buffResult

    return true
end

function BuffViewSetNormalAttackDirEff:_CalcDir(dirNum)
    local dir = Vector2(0, 0)

    if dirNum == BuffLogicSaveNormalAttackDirEnum.Up then
        dir = Vector2(0, 1)
    elseif dirNum == BuffLogicSaveNormalAttackDirEnum.RightTop then
        dir = Vector2(1, 1)
    elseif dirNum == BuffLogicSaveNormalAttackDirEnum.Right then
        dir = Vector2(1, 0)
    elseif dirNum == BuffLogicSaveNormalAttackDirEnum.RightBottom then
        dir = Vector2(1, -1)
    elseif dirNum == BuffLogicSaveNormalAttackDirEnum.Down then
        dir = Vector2(0, -1)
    elseif dirNum == BuffLogicSaveNormalAttackDirEnum.LeftBottom then
        dir = Vector2(-1, -1)
    elseif dirNum == BuffLogicSaveNormalAttackDirEnum.Left then
        dir = Vector2(-1, 0)
    elseif dirNum == BuffLogicSaveNormalAttackDirEnum.LeftTop then
        dir = Vector2(-1, 1)
    end

    return dir
end
