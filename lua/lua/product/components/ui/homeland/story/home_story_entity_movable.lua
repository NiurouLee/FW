---可以控制运动的剧情元素
_class("HomeStoryEntityMovable", HomeStoryEntity)
---@class HomeStoryEntityMovable:HomeStoryEntity
HomeStoryEntityMovable = HomeStoryEntityMovable

---@class HomeStoryEntityAnimationType
local HomeStoryEntityAnimationType = {
    AlphaChange = 1,
    BrightnessChange = 2,
    Translate = 3,
    Rotate = 4,
    Scale = 5,
    Shake = 6,
    Animation = 7,
    Bubble = 8
}
_enum("HomeStoryEntityAnimationType", HomeStoryEntityAnimationType)

function HomeStoryEntityMovable:Constructor(ID, gameObject, resRequest, storyManager)
    HomeStoryEntityMovable.super.Constructor(self, ID, gameObject, resRequest, storyManager)
    ---@type table<table,number> 运行时动画数据
    self._animationData = {}

    storyManager:InitLayerInfo(gameObject.transform)

    self.recvoerClips = {
        ["surprise"]=true,
        ["sad"]=true,
        ["happy"]=true,
        ["angry"]=true,
    }
    self.standClip = "stand"
end
function HomeStoryEntityMovable:Destroy()
    HomeStoryEntityMovable.super.Destroy(self)
end

---关键帧处理---
---@param keyframeData table
function HomeStoryEntityMovable:_TriggerKeyframe(keyframeData)
    ---关键帧直接设置表现的数据
    if keyframeData.Active ~= nil then
        self._gameObject:SetActive(keyframeData.Active)
    end

    if keyframeData.Alpha ~= nil then
        self:_SetAlpha(keyframeData.Alpha)
    end

    if keyframeData.Brightness ~= nil then
        self:_SetBrightness(keyframeData.Brightness)
    end

    if keyframeData.Position3D ~= nil then
        self:_SetPosition(Vector3(keyframeData.Position3D[1],keyframeData.Position3D[2],keyframeData.Position3D[3]))
    end

    if keyframeData.Rotation3D ~= nil then
        self:_SetRotation(Quaternion.Euler(keyframeData.Rotation3D[1], keyframeData.Rotation3D[2],keyframeData.Rotation3D[3]))
    end

    if keyframeData.Scaling3D ~= nil then
        self:_SetScaling(Vector3(keyframeData.Scaling3D[1], keyframeData.Scaling3D[2], keyframeData.Scaling3D[3]))
    end

    if keyframeData.Layer ~= nil then
        self:_SetLayer(keyframeData.Layer)
    end

    if keyframeData.PlayAnimation ~= nil then
        ---@type UnityEngine.Animation
        local animCmp = self._gameObject:GetComponentInChildren(typeof(UnityEngine.Animation))
        if not animCmp then
            Log.fatal("story entity without animation component triggered animation:"..keyframeData.PlayAnimation)
        else
            animCmp:CrossFade(keyframeData.PlayAnimation,0.2)
            

            self:StartAnimPlay(keyframeData.PlayAnimation)
        end
    end

    if keyframeData.PlayAnimator ~= nil then
        ---@type UnityEngine.Animator
        local animCmp = self._gameObject:GetComponentInChildren(typeof(UnityEngine.Animator))
        local layerIdx = animCmp:GetLayerIndex("HomeStoryLayer")
        local lw = animCmp:GetLayerWeight(layerIdx)
        if lw < 1 then
            animCmp:SetLayerWeight(layerIdx,1)
        end
        if not animCmp then
            Log.fatal("story entity without animation component triggered animation:"..keyframeData.PlayAnimator)
        else
            animCmp:CrossFade(keyframeData.PlayAnimator, 0.2,1)
        end
    end

    ---关键帧开始的动画数据
    if keyframeData.AlphaChange then
        local aniInfo = {
            HomeStoryEntityAnimationType.AlphaChange,
            keyframeData.Time,
            keyframeData.AlphaChange.StartValue,
            keyframeData.AlphaChange.EndValue
        }
        self._animationData[keyframeData.AlphaChange] = aniInfo
    end

    if keyframeData.BrightnessChange then
        local aniInfo = {
            HomeStoryEntityAnimationType.BrightnessChange,
            keyframeData.Time,
            keyframeData.BrightnessChange.StartValue,
            keyframeData.BrightnessChange.EndValue
        }
        self._animationData[keyframeData.BrightnessChange] = aniInfo
    end

    if keyframeData.Translate3D then
        local aniInfo = {
            HomeStoryEntityAnimationType.Translate,
            keyframeData.Time,
            Vector3(keyframeData.Translate3D.StartValue[1], keyframeData.Translate3D.StartValue[2], keyframeData.Translate3D.StartValue[3]),
            Vector3(keyframeData.Translate3D.EndValue[1], keyframeData.Translate3D.EndValue[2], keyframeData.Translate3D.EndValue[3])
        }
        self._animationData[keyframeData.Translate3D] = aniInfo
    end

    if keyframeData.Rotate3D then
        local aniInfo = {
            HomeStoryEntityAnimationType.Rotate,
            keyframeData.Time,
            Quaternion.Euler(keyframeData.Rotate3D.StartValue[1], keyframeData.Rotate3D.StartValue[2], keyframeData.Rotate3D.StartValue[3]),
            Quaternion.Euler(keyframeData.Rotate3D.EndValue[1], keyframeData.Rotate3D.EndValue[2], keyframeData.Rotate3D.EndValue[3])
        }
        self._animationData[keyframeData.Rotate3D] = aniInfo
    end

    if keyframeData.Scale3D then
        local aniInfo = {
            HomeStoryEntityAnimationType.Scale,
            keyframeData.Time,
            Vector3(keyframeData.Scale3D.StartValue[1], keyframeData.Scale3D.StartValue[2], keyframeData.Scale3D.StartValue[3]),
            Vector3(keyframeData.Scale3D.EndValue[1], keyframeData.Scale3D.EndValue[2], keyframeData.Scale3D.EndValue[3])
        }
        self._animationData[keyframeData.Scale3D] = aniInfo
    end

    if keyframeData.Shake then
        local shakeData = keyframeData.Shake
        local tweener =
            self._gameObject.transform:DOShakePosition(
            shakeData.Duration,
            Vector3(shakeData.Strength[1], shakeData.Strength[2], shakeData.Strength[3]),
            shakeData.Vibrato,
            0,
            false,
            shakeData.fadeOut
        )
        local aniInfo = {
            HomeStoryEntityAnimationType.Shake,
            keyframeData.Time,
            tweener
        }
        self._animationData[keyframeData.Shake] = aniInfo
    end
end
function HomeStoryEntityMovable:StartAnimPlay(clip)
    Log.debug("###[recover stand] entity:",self._ID," 开始播动画:",clip)

    -- if self._event then
    --     GameGlobal.Timer():CancelEvent(self._event)
    --     self._event = nil
    -- end

    self._storyManager:RemoveRecoverStandEntity(self._ID)

    ---@type UnityEngine.AnimationClip
    if self.recvoerClips[clip] then
        Log.debug("###[recover stand] entity:",self._ID," 需要添加自动恢复,动画:",clip)


        ---@type UnityEngine.Animation
        local animCmp = self._gameObject:GetComponentInChildren(typeof(UnityEngine.Animation))
        local yieldTime
        local clip = animCmp:GetClip(clip)
        if clip then
            local length = math.floor(clip.length*1000) 
            if length>200 then
                yieldTime = length-200
            else
                yieldTime = length
            end
        else
            Log.error("[HomeStoryEntityMovable] entity animation clip not exist - ", clip)
            yieldTime = 200
        end

        self._storyManager:AddRecoverStandEntity(yieldTime,self._ID)

        -- self._event = GameGlobal.Timer():AddEvent(yieldTime,function()
        --     self:RecoverStand()
        -- end)
    end
end
-- function HomeStoryEntityMovable:RecoverStand()
--     ---@type UnityEngine.Animation
--     local animCmp = self._gameObject:GetComponentInChildren(typeof(UnityEngine.Animation))
--     animCmp:CrossFade(self.standClip,0.2)
--     self._event = nil
-- end
---动画处理----
---@param time number
---@return boolean 是否已经播放完全部的轨道动画
function HomeStoryEntityMovable:_UpdateAnimation(time)
    local allEnd = true
    for aniData, aniInfo in pairs(self._animationData) do
        allEnd = false
        local t = 1
        if aniData.Duration > 0 then
            t = (time - aniInfo[2]) / aniData.Duration
        end
        if t > 1 then
            t = 1
        end

        if aniInfo[1] == HomeStoryEntityAnimationType.AlphaChange then
            self:_SetAlpha(lmathext.lerp(aniInfo[3], aniInfo[4], t))
        elseif aniInfo[1] == HomeStoryEntityAnimationType.BrightnessChange then
            self:_SetBrightness(lmathext.lerp(aniInfo[3], aniInfo[4], t))
        elseif aniInfo[1] == HomeStoryEntityAnimationType.Translate then
            self:_SetPosition(Vector3.Lerp(aniInfo[3], aniInfo[4], t))
        elseif aniInfo[1] == HomeStoryEntityAnimationType.Rotate then
            self:_SetRotation(Quaternion.Lerp(aniInfo[3], aniInfo[4], t))
        elseif aniInfo[1] == HomeStoryEntityAnimationType.Scale then
            self:_SetScaling(Vector3.Lerp(aniInfo[3], aniInfo[4], t))
        elseif aniInfo[1] == HomeStoryEntityAnimationType.Shake then
            
        end

        if t >= 1 then
            self._animationData[aniData] = nil
        end
    end
    return allEnd
end

---动画数据更新方法---------
---透明度设置 需要子类自己实现
---@param alpha number
function HomeStoryEntityMovable:_SetAlpha(alpha)
end

---明暗度设置 需要子类自己实现
---@param brightness number
function HomeStoryEntityMovable:_SetBrightness(brightness)
end

---设置层级
---@param layer number
function HomeStoryEntityMovable:_SetLayer(layer)
    self._storyManager:SetLayer(self._gameObject.transform, layer)
    --self._gameObject.transform:SetSiblingIndex(layer)
end

---位置
---@param pos Vector3
function HomeStoryEntityMovable:_SetPosition(pos)
    self._gameObject.transform.localPosition = pos
end

---旋转
---@param pos Quaternion
function HomeStoryEntityMovable:_SetRotation(rot)
    self._gameObject.transform.localRotation = rot
end
---看向
---@param pos Quaternion
function HomeStoryEntityMovable:_SetLook(target,length)
    self._gameObject.transform:DOLookAt(target,length)
end
---缩放
---@param pos Vector3
function HomeStoryEntityMovable:_SetScaling(scale)
    self._gameObject.transform.localScale = scale
end
-------------------------------
