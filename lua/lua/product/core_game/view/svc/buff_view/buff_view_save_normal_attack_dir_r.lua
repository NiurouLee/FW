--[[

]]
_class("BuffViewSaveNormalAttackDir", BuffViewBase)
---@class BuffViewSaveNormalAttackDir : BuffViewBase
BuffViewSaveNormalAttackDir = BuffViewSaveNormalAttackDir

function BuffViewSaveNormalAttackDir:PlayView(TT)
    ---@type BuffResultSavePetNormalAttackDir
    local result = self._buffResult

    local dirNum = result:GetDirNum()

    local effectHolder = self._entity:EffectHolder()
    if not effectHolder then
        self._entity:AddEffectHolder()
        effectHolder = self._entity:EffectHolder()
    end

    local effectKey = "SetNormalAttackDirEff" .. dirNum
    local effectIDList = effectHolder:GetEffectList(effectKey) or {}

    if effectIDList and table.count(effectIDList) > 0 then
        local viewParams = self._viewInstance:BuffConfigData():GetViewParams()
        local removeAnim = nil
        local removeAnimTime = nil
        if viewParams then
            removeAnim = viewParams.removeAnim
            removeAnimTime = viewParams.removeAnimTime
        end

        for _, effID in ipairs(effectIDList) do
            local effEntity = self._world:GetEntityByID(effID)
            if effEntity then
                GameGlobal.TaskManager():CoreGameStartTask(
                    function(TT)
                        local go = effEntity:View():GetGameObject()

                        ---@type UnityEngine.Animation
                        local anim = go:GetComponentInChildren(typeof(UnityEngine.Animation))
                        if go and anim and anim.clip and removeAnim then
                            anim:Play(removeAnim)
                            if removeAnimTime then
                                YIELD(TT, removeAnimTime)
                            end

                            go:SetActive(false)
                        end
                    end
                )
            end
        end
    end
end

--是否匹配参数
function BuffViewSaveNormalAttackDir:IsNotifyMatch(notify)
    ---@type BuffResultSavePetNormalAttackDir
    local result = self._buffResult

    if result.__notify_attackPos == notify:GetAttackPos() and result.__notify_beAttackPos == notify:GetTargetPos() then
        return true
    end

    return false
end
