require "bounce_player_behavior_animation"

--弹跳小游戏，玩家控制角色类
---@class BouncePlayer : BehaviorMgr
_class("BouncePlayer", BehaviorMgr)
BouncePlayer = BouncePlayer

function BouncePlayer:Constructor()
end

function BouncePlayer:Init(coreController, palyerPrefabName, parentRt)
    ---@type BounceController
    self._coreController = coreController
    ---@type BounceData
    self._bounceData = coreController:GetData()

    self.playerData = BouncePlayerData:New()
    self.playerData:Init()

    self.viewBehavior = BouncePlayerBeHaviorView:New(palyerPrefabName, parentRt, self.playerData:GetInitPos())
    self:AddBehavior(self.viewBehavior)
    self:AddBehavior(BouncePlayerBeHaviorAnimation:New())

    self.playerStateFsm = StateMachineManager:GetInstance():CreateStateMachine("StateBouncePlayer", StateBouncePlayer)
    self.playerStateFsm:SetData(self) -- 上下文
    self.playerStateFsm:Init(StateBouncePlayer.Init)
    self:Reset()
end

function BouncePlayer:Destroy()
    self:Release()
end

function BouncePlayer:Reset()
    self.playerData:Reset()
    self:SetVisible(false)
    self.state = BounceObjState.Alive
    self.viewBehavior:SetPosition(self.playerData:GetInitPos())
end

function BouncePlayer:AddBehavior(behavior)
    self.super.AddBehavior(self, behavior)
    behavior:SetPlayer(self)
end


---@type BouncePlayerData
function BouncePlayer:GetBouncePlayerData()
    return self.playerData
end

function BouncePlayer:ChgPlayerState(newState, params)
    local lastType = self:GetPlayerStateType()
    if lastType and lastType == StateBouncePlayer.Dead and newState ~= StateBouncePlayer.Init then
        Log.debug("[bounce] BouncePlayer chgPlayerfsmState failed for player is dead , newState =  " .. newState .. "  -- " .. self._bounceData.durationMs)
        return
    end
    Log.debug("[bounce] BouncePlayer chgPlayerfsmState " .. newState .. "  -- " .. self._bounceData.durationMs)
    self.playerStateFsm:ChangeState(newState)
end

---@return BounceData
function BouncePlayer:GetBounceData()
    return self._bounceData
end


--jump cmd
function BouncePlayer:OnJump()
    local curState = self.playerStateFsm:GetCurState()
    curState:OnJump()
end

--attack cmd
function BouncePlayer:OnAttack()
    local curState = self.playerStateFsm:GetCurState()
    curState:OnAttack()
end

--战斗时间轴更新
function BouncePlayer:OnUpdate(deltaMS)
    if self.playerStateFsm then
        self.playerStateFsm:OnUpdate(deltaMS)
    end
    if not self._aniBehavior  then
        self._aniBehavior = self:GetBehavior(BouncePlayerBeHaviorAnimation:Name())
    end
    self._aniBehavior:OnUpdate(deltaMS)
end

--角色下落处理
function BouncePlayer:HandleMove(deltaMS, chgState)
    if self.viewBehavior then
        --change view position
        local pos = self.viewBehavior:GetPosition()
        pos.y = pos.y + self.playerData.curSpeed * deltaMS / 1000;
        
        --change player speed
        self.playerData.curSpeed = self.playerData.curSpeed - self.playerData.gSpeed * deltaMS/1000;
       
        local nextState = nil
        --触地检查 todo
        if pos.y <= 0 then
            pos.y = 0
            self.playerData.curSpeed = 0
            nextState = StateBouncePlayer.Walk
        end
        self.viewBehavior:SetPosition(pos)


        if nextState and chgState then
            self:ChgPlayerState(StateBouncePlayer.Walk)
        end
    end
end

-- function BouncePlayer:UpdateViewPos()
    
-- end

--角色是否触底
function BouncePlayer:IsPlayerOnBoard()
    
end


--设置显示
function BouncePlayer:SetVisible(bVisible)
    self.viewBehavior:SetVisible(bVisible)
end

---@return UnityEngine.Rect
function BouncePlayer:GetRect()
    local curState = self.playerStateFsm:GetCurState()
    local baseRectName, weaponRectName = curState:GetRectNames()
    if not baseRectName then
        return nil
    end

    local baseRect = self.viewBehavior:GetRect(baseRectName)
    local weaponRect = nil
    if weaponRectName then
        weaponRect = self.viewBehavior:GetRect(weaponRectName)
    end
    return baseRect, weaponRect
end

--设置对象状态
---@param state BounceObjState 
function BouncePlayer:SetState(state)
    self.state = state
end

--角色受到伤害
function BouncePlayer:OnHurt(ap)
    if BounceDebug.PlayerLiveForever then
        return
    end
    if self._coreController.bounceData:GetIsGuiding() then
        return
    end
    --self.playerData.hp = self.playerData.hp - ap
    self:ChgPlayerState(StateBouncePlayer.Dead)
    self._coreController:StartOver()
    AudioHelperController.PlayUISoundAutoRelease(CriAudioIDConst.N28BouncePlayerDead)
end

--是否正在下落
function BouncePlayer:IsDown()
    local stateType = self:GetPlayerStateType()
    if not stateType then
        return false
    end
    return stateType == StateBouncePlayer.AccDown or stateType == StateBouncePlayer.Down
end

function BouncePlayer:GetPlayerStateType()
    local curState = self.playerStateFsm:GetCurState()
    local stateType = curState:GetStateType()
    return stateType
end

function BouncePlayer:OnHurtMonsterWhenDown()
    local stateType = self:GetPlayerStateType()
    if not stateType then
        return 
    end
    if stateType == StateBouncePlayer.Down then
        self.playerData.curSpeed = self.playerData.speedWhenAttackAtDown
        self:ChgPlayerState(StateBouncePlayer.Jump)
    elseif stateType == StateBouncePlayer.AccDown then
        self.playerData.curSpeed = self.playerData.speedWhenAttackAtAccDown
        self:ChgPlayerState(StateBouncePlayer.Jump)
    end
end