---@class UIN14FishingGameOrderItem : UICustomWidget
_class("UIN14FishingGameOrderItem", UICustomWidget)
UIN14FishingGameOrderItem = UIN14FishingGameOrderItem

function UIN14FishingGameOrderItem:Constructor() 
    self.hadFinished = false 
end 
function UIN14FishingGameOrderItem:OnShow(uiParams)
    self:InitWidget()
    self:CalBgPos()
end

function UIN14FishingGameOrderItem:CalBgPos()
    self._offsetY = 20
    local tmp = self._bg.gameObject.transform.localPosition 
    tmp.y = tmp.y + self._offsetY
    self._tmpPos = 
    {
        [0] = Vector3(tmp.x , 22 , tmp.z),
        [1] = Vector3(tmp.x , 5 , tmp.z)
    }
end
function UIN14FishingGameOrderItem:InitWidget()
    --generated--
    self._bg = self:GetUIComponent("Image", "bg")
    self._fishImg = self:GetUIComponent("Image", "fishImg")
    self._finishImg = self:GetGameObject("finishImg")
    self._atlas = self:GetAsset("UIN14FishingGame.spriteatlas", LoadType.SpriteAtlas)
    self._animation = self.view.gameObject:GetComponent("Animation")
    self._effectGo = self:GetGameObject("effect")
    self._bgError = self:GetGameObject("bgError")
    self._effectOriPos = self._effectGo.transform.localPosition
    self._bgError:SetActive(false)
    --generated end--
end
function UIN14FishingGameOrderItem:SetData(index , fishId , isCurrent , isFinish , islast)
    self:ResetWeight() 
    self._index = index --  位置顺序
    self._fishId = fishId  -- 鱼表索引
    self._isCurrent = isCurrent
    self._isFinish = isFinish
    self._islastOrder = islast
    self._fishCfg = Cfg.cfg_fishing_fish{ID = fishId}[1]
    self:InitWidget()
    self:_OnValue()
    self._bg.transform.localRotation = self._isFinish  and  Quaternion.Euler(0 , 180 , 0) or  Quaternion.identity
    self._finishImg.transform.localRotation = self._isFinish  and  Quaternion.Euler(0 , 180 , 0) or  Quaternion.identity
    
end

function UIN14FishingGameOrderItem:_OnValue()
    local fishId =  self._fishId
    self._fishImg.gameObject:SetActive(self._isFinish == false)
    self._finishImg:SetActive(self._isFinish == true)
    self._bgError:SetActive(true)
    self._bg.gameObject.transform.localPosition = self._tmpPos[self._index % 2]
    if self._isCurrent then
        self._bg.sprite = self._atlas:GetSprite("n14_fish_huima2")
    else
        self._bg.sprite = self._atlas:GetSprite("n14_fish_huima1")
    end

    self._fishImg.sprite =  self._atlas:GetSprite(self._fishCfg.Sprite)
    -- if self._isCurrent then
    --     self._fishImg.transform.localScale = Vector3.one * 1.2
    -- else
    --     self._fishImg.transform.localScale = Vector3.one 
    -- end

    if (not self.hadFinished) and  self._isFinish then 
        self.hadFinished = true 
    end 
end
function UIN14FishingGameOrderItem:PlayAnimation(index,needlast ) 
    local aniNames = 
    {
        "uieff_orderFinish",
        "uieff_orderRefresh",
        "uieff_errorfish",
        "uieff_orderRefresh_time"
    }
    local last = 500
    if index == 4  then  
        last = 1200 
    end
    self:StartTask(
        function(TT)
            self:Lock("UIN14FishingGameOrderItem:PlayAnimation")
            self:ResetWeight() 
            YIELD(TT, 100)
            self._animation:Play(aniNames[index])
            YIELD(TT, last)
            if index == 4 then 
                self:ResetWeight() 
            end
            self:UnLock("UIN14FishingGameOrderItem:PlayAnimation")
        end,
        self
    )
end 

function UIN14FishingGameOrderItem:EffectDoTween(path ,duration,ease,callback) 
    local usePath  = {}
    local next =  math.random(1,2)
    table.insert(usePath,path[next])
    table.insert(usePath,path[3])
    self._effectGo:SetActive(true)
    self._effectGo.transform:DOPath(usePath, duration):SetEase(ease):OnComplete(
        function()
            if callback then 
                callback(self._effectGo.transform.position)
                self._effectGo:SetActive(false)
                self._effectGo.transform.localPosition = self._effectOriPos
            end 
        end
    )
end 

function UIN14FishingGameOrderItem:ResetWeight() 
    self:GetUIComponent("Image", "bg").color = Color(255 / 255, 255 / 255, 255 / 255,1)
    self:GetUIComponent("Image", "bgError").color = Color(255 / 255, 255 / 255, 255 / 255,0)
    self:GetUIComponent("Image", "finishImg").color = Color(255 / 255, 255 / 255, 255 / 255,1)  
    self._finishImg.transform.localRotation =  Quaternion.identity
    self._finishImg.transform.localScale = Vector3(1,1,1)
    self._finishImg:SetActive(false)
    self._fishImg.transform.localRotation = Quaternion.identity
    self._fishImg.transform.localScale = Vector3(1,1,1)
    --self._bg.sprite = self._atlas:GetSprite("n14_fish_huima1")
end
