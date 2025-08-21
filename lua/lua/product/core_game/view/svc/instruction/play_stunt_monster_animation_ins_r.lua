require("base_ins_r")

---@class PlayStuntMonsterAnimationInstruction: BaseInstruction
_class("PlayStuntMonsterAnimationInstruction", BaseInstruction)
PlayStuntMonsterAnimationInstruction = PlayStuntMonsterAnimationInstruction

function PlayStuntMonsterAnimationInstruction:Constructor(paramList)
    self._stuntTag = paramList.tag or "default"

    self._animName = paramList["animName"]
end

---@param casterEntity Entity
function PlayStuntMonsterAnimationInstruction:DoInstruction(TT,casterEntity,phaseContext)
    if not casterEntity:HasStuntOwnerComponent() then
        return
    end
    
    local e = casterEntity:StuntOwnerComponent():GetStuntByTag(self._stuntTag)
    if not e then
        return
    end

    e:SetAnimatorControllerTriggers({self._animName})
end
