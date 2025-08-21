--[[
    家园宝物木牌对象
]]
_class("HomelandTreasureBoard", Object)
HomelandTreasureBoard = HomelandTreasureBoard

function HomelandTreasureBoard:Constructor(interactPointManager)
    self._interactPointManager = interactPointManager
end

function HomelandTreasureBoard:Show(parent, assPos,parentPos,tipsid)
    local prefab = Cfg.cfg_homeland_global["TreasureBoardPrefab"].StrValue
    self._req = ResourceManager:GetInstance():SyncLoadAsset(prefab, LoadType.GameObject)
    if not self._req then
        Log.error("找不到木牌模型:", prefab)
    end
    ---@type UnityEngine.GameObject
    self._go = self._req.Obj
    ---@type UnityEngine.Transform
    self._transform = self._go.transform
    self._transform:SetParent(parent)
    self._transform.position = assPos
    
    self._go:SetActive(true)
    self._tipsid = tipsid
    
    local vvv = parentPos - assPos
    vvv.y = 0
    local rota = Quaternion.FromToRotation(self._transform.forward,vvv) 
    --rota.y = rota.y + 180
    self._transform.rotation = rota
    --注册交互点
    self._interactPoint = self._interactPointManager:AddBuildInteractPoint(self, tipsid, InteractPointType.TreasureBoard)
end

function HomelandTreasureBoard:Dispose()
    if self._interactPoint then
        self._interactPointManager:RemoveBuildInteractPoint(self._interactPoint)
    end
    
    self._req:Dispose()
    self._req=nil
end

function HomelandTreasureBoard:GetInteractPosition(index)
    return self._transform.position
end

function HomelandTreasureBoard:GetInteractRedStatus()
    return false
end

--木牌弹窗UI
function HomelandTreasureBoard:Interact()
    GameGlobal:GetInstance():EventDispatcher():Dispatch(GameEventType.ShowTreasureBoardUI, self._tipsid)
end