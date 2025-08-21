---@class StateBouncePlayerJumpAttack : StateBouncePlayerBase
_class("StateBouncePlayerJumpAttack", StateBouncePlayerBase)
StateBouncePlayerJumpAttack = StateBouncePlayerJumpAttack

function StateBouncePlayerJumpAttack:OnEnter(TT, ...)
    self:Init()
    self.AniDuration = self:PlayAnim()
    self:LoadJumpEffect()
    if BounceDebug.ShowObjRect then
        self:ShowDebugRect()
    end
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.N28BounceJump)
end

function StateBouncePlayerJumpAttack:OnExit(TT)
end


function StateBouncePlayerJumpAttack:GetStateType()
    return StateBouncePlayer.JumpAttack
end

function StateBouncePlayerJumpAttack:OnUpdate(deltaTimeMS)
    if not self.AniDuration then
        return
    end
    self.AniDuration = self.AniDuration - deltaTimeMS
    
    --change view position
    self.player:HandleMove(deltaTimeMS)
    
    if self.AniDuration <= 0 then
        if self.playerData.curSpeed > 0 then
            self.player:ChgPlayerState(StateBouncePlayer.Jump)
        else
            self.player:ChgPlayerState(StateBouncePlayer.Down)
        end
    end
end

--attack cmd
function StateBouncePlayerJumpAttack:OnAttack()
    --chgspeed and chg to jump state
    if  self.playerData.curSpeed > self.playerData.accDownSpeed then
       self.playerData.curSpeed = self.playerData.accDownSpeed
   end
   self.player:ChgPlayerState(StateBouncePlayer.AccDown)
end

function StateBouncePlayerJumpAttack:LoadJumpEffect()
    ---@type BouncePlayerBeHaviorView
    local viewBehavior = self:GetBehavior(BouncePlayerBeHaviorView:Name())
    if not viewBehavior then
        return
    end
    local playerGo = viewBehavior:GetGameObject()
    if not playerGo then
        return
    end
    local playerTran = playerGo:GetComponent("RectTransform")
    local eff = EffectManager.Acquire("eff_jump.prefab", playerTran.parent, playerTran.anchoredPosition, 350)
    return eff
end
