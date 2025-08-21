require "bounce_player_behavior_base"
--玩家行为组件-动作
---@class BouncePlayerBeHaviorAnimation : BouncePlayerBeHaviorBase
_class("BouncePlayerBeHaviorAnimation", BouncePlayerBeHaviorBase)
BouncePlayerBeHaviorAnimation = BouncePlayerBeHaviorAnimation

function BouncePlayerBeHaviorAnimation:Constructor()
    self._animator = nil
end

function BouncePlayerBeHaviorAnimation:Name()
    return "BouncePlayerBeHaviorAnimation"
end

function BouncePlayerBeHaviorAnimation:GetAnimation()
    if self._animator then
        return self._animator
    end

    ---@type BouncePlayerBeHaviorView
    local view = self.player:GetBehavior("BouncePlayerBeHaviorView")
    if view == nil then
        return nil
    end

    local go = view:GetGameObject()
    if not go then
        return nil
    end
    self._animator = go:GetComponent("Animator")
    return self._animator
end

function BouncePlayerBeHaviorAnimation:PlayAnimation(animName)
    self._animName = animName
    local animator = self:GetAnimation()
   -- Log.debug("[bounce] BouncePlayer PlayAnim before " .. animName .. "  -- " .. self.player:GetBounceData().durationMs)
    animator:Play(animName)
    --Log.debug("[bounce] BouncePlayer PlayAnim after " .. animName .. "  -- " .. self.player:GetBounceData().durationMs)
end

function BouncePlayerBeHaviorAnimation:OnUpdate(deltaTimeMS)
    if not self._animName or not self._animator then
        return
    end
    if self._animator:IsInTransition(0) then
        Log.error("[bounce] IsInTransition")
        return
    end
    local curAniState = self._animator:GetCurrentAnimatorStateInfo(0)
    if curAniState and not curAniState:IsName(self._animName) then
        self:PlayAnimation(self._animName)
    end
end


function BouncePlayerBeHaviorAnimation:OnRelease()
    self._animator = nil
    self._animName = nil
end
