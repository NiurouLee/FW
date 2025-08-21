require "homelandpet_behavior_base"

---@class HomelandPetBehaviorFree:HomelandPetBehaviorBase
_class("HomelandPetBehaviorFree", HomelandPetBehaviorBase)
HomelandPetBehaviorFree = HomelandPetBehaviorFree

function HomelandPetBehaviorFree:Constructor(behaviorType, pet)
    ---@type HomelandPetComponentPlayAnimation
    self._animationComponent = self:GetComponent(HomelandPetComponentType.Animation)
    ---@type HomelandPetComponentBubble
    self._bubbleComponent = self:GetComponent(HomelandPetComponentType.Bubble)
end

function HomelandPetBehaviorFree:Enter()
    HomelandPetBehaviorFree.super.Enter(self)
    self._animationComponent:PlayStand()
    self._bubbleComponent:Show()
end
function HomelandPetBehaviorFree:Exit()
    HomelandPetBehaviorFree.super.Exit(self)
end
function HomelandPetBehaviorFree:CanInterrupt()
    return true
end
