--
---@class UIN32MultiLineMapDialoglNode : UICustomWidget
_class("UIN32MultiLineMapDialoglNode", UICustomWidget)
UIN32MultiLineMapDialoglNode = UIN32MultiLineMapDialoglNode
--初始化
function UIN32MultiLineMapDialoglNode:OnShow(uiParams)
    self:InitWidget()
end
--获取ui组件
function UIN32MultiLineMapDialoglNode:InitWidget()
    --generated--
    ---@type UnityEngine.GameObject
    self.hasRead = self:GetGameObject("hasRead")
    ---@type UnityEngine.GameObject
    self.unRead = self:GetGameObject("unRead")
    ---@type UnityEngine.GameObject
    --generated end--
    self.animation = self:GetUIComponent("Animation", "animation")
    self.unReadAni = self:GetUIComponent("Animation", "unReadAni")
    self._btnGo  = self:GetGameObject("btn")
end

--设置数据
function UIN32MultiLineMapDialoglNode:SetData(levelId, missionId, isPass, cb)
    self._callback = cb
    self._levelId = levelId
    self._missionId = missionId

    self.hasRead:SetActive(isPass)
    self.unRead:SetActive(not isPass)
end

--按钮点击
function UIN32MultiLineMapDialoglNode:BtnOnClick(go)
    if self._callback then
        self._callback(self._levelId, self._missionId)
    end
end

function UIN32MultiLineMapDialoglNode:PlayEnterAni()
    self:ResetAni(self.animation,"uieff_UIN32MultiLineDialogueNode_in")
    self.animation:Play("uieff_UIN32MultiLineDialogueNode_in")

    if self.unRead then
        self:PlayUnReadAni()
    end
end

function UIN32MultiLineMapDialoglNode:PlayUnReadAni()
    self:ResetAni(self.unReadAni,"uieff_UIN32MultiLineDialogueNode_unRead_loop")
    self.unReadAni:Play("uieff_UIN32MultiLineDialogueNode_unRead_loop")
end


function UIN32MultiLineMapDialoglNode:ResetAni(animation, clipName)
    local state = animation:get_Item(clipName)
    state.normalizedTime = 0
    animation:Stop()
end

function UIN32MultiLineMapDialoglNode:GetLevelId()
    return self._levelId
end

function UIN32MultiLineMapDialoglNode:SetVisible(bVisible)
    if not bVisible then
        self.unReadAni:Stop()
        self.animation:Stop()
    end
    self:GetGameObject():SetActive(bVisible)
end

function UIN32MultiLineMapDialoglNode:GetBtn()
    return self._btnGo 
end