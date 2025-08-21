---可以控制运动的剧情元素
_class("StoryEntityMovable", StoryEntity)
---@class StoryEntityMovable:StoryEntity
StoryEntityMovable = StoryEntityMovable

---@class StoryEntityAnimationType
local StoryEntityAnimationType = {
    AlphaChange = 1,
    BrightnessChange = 2,
    Translate = 3,
    Rotate = 4,
    Scale = 5,
    Shake = 6,
    BlurChange = 7,
}
_enum("StoryEntityAnimationType", StoryEntityAnimationType)

function StoryEntityMovable:Constructor(ID, gameObject, resRequest, storyManager)
    StoryEntityMovable.super.Constructor(self, ID, gameObject, resRequest, storyManager)
    ---@type table<table,number> 运行时动画数据
    self._animationData = {}

    storyManager:InitLayerInfo(gameObject.transform)
end

---关键帧处理---
---@param keyframeData table
function StoryEntityMovable:_TriggerKeyframe(keyframeData)
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

    if keyframeData.Position ~= nil then
        self:_SetPosition(Vector3(keyframeData.Position[1], keyframeData.Position[2], 0))
    end

    if keyframeData.Rotation ~= nil then
        self:_SetRotation(Quaternion.Euler(0, 0, keyframeData.Rotation))
    end

    if keyframeData.Scaling ~= nil then
        self:_SetScaling(Vector3(keyframeData.Scaling[1], keyframeData.Scaling[2], 1))
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
            animCmp:Play(keyframeData.PlayAnimation)
        end
    end

    ---关键帧开始的动画数据
    if keyframeData.AlphaChange then
        local aniInfo = {
            StoryEntityAnimationType.AlphaChange,
            keyframeData.Time,
            keyframeData.AlphaChange.StartValue,
            keyframeData.AlphaChange.EndValue
        }
        self._animationData[keyframeData.AlphaChange] = aniInfo
    end

    if keyframeData.BrightnessChange then
        local aniInfo = {
            StoryEntityAnimationType.BrightnessChange,
            keyframeData.Time,
            keyframeData.BrightnessChange.StartValue,
            keyframeData.BrightnessChange.EndValue
        }
        self._animationData[keyframeData.BrightnessChange] = aniInfo
    end
    if keyframeData.BlurChange then
        local aniInfo = {
            StoryEntityAnimationType.BlurChange,
            keyframeData.Time,
            keyframeData.BlurChange.BlurType,
            keyframeData.BlurChange.BlurDirection,
            keyframeData.BlurChange.Duration,
            keyframeData.BlurChange.StartValue,
            keyframeData.BlurChange.EndValue,
         

        }
        self._animationData[keyframeData.BlurChange] = aniInfo
    end

    if keyframeData.Translate then
        local aniInfo = {
            StoryEntityAnimationType.Translate,
            keyframeData.Time,
            Vector3(keyframeData.Translate.StartValue[1], keyframeData.Translate.StartValue[2], 0),
            Vector3(keyframeData.Translate.EndValue[1], keyframeData.Translate.EndValue[2], 0)
        }
        self._animationData[keyframeData.Translate] = aniInfo
    end

    if keyframeData.Rotate then
        local aniInfo = {
            StoryEntityAnimationType.Rotate,
            keyframeData.Time,
            Quaternion.Euler(0, 0, keyframeData.Rotate.StartValue),
            Quaternion.Euler(0, 0, keyframeData.Rotate.EndValue)
        }
        self._animationData[keyframeData.Rotate] = aniInfo
    end

    if keyframeData.Scale then
        local aniInfo = {
            StoryEntityAnimationType.Scale,
            keyframeData.Time,
            Vector3(keyframeData.Scale.StartValue[1], keyframeData.Scale.StartValue[2], 1),
            Vector3(keyframeData.Scale.EndValue[1], keyframeData.Scale.EndValue[2], 1)
        }
        self._animationData[keyframeData.Scale] = aniInfo
    end

    --跳过过程不执行dotween
    if keyframeData.Shake and not self._storyManager:IsJumping() then
        local shakeData = keyframeData.Shake
        local tweener =
            self._gameObject.transform:DOShakePosition(
            shakeData.Duration,
            Vector3(shakeData.Strength[1], shakeData.Strength[2], 0),
            shakeData.Vibrato,
            0,
            false,
            shakeData.fadeOut
        )
        local aniInfo = {
            StoryEntityAnimationType.Shake,
            keyframeData.Time,
            tweener
        }
        self._animationData[keyframeData.Shake] = aniInfo
    end
end

---动画处理----
---@param time number
---@return boolean 是否已经播放完全部的轨道动画
function StoryEntityMovable:_UpdateAnimation(time)
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

        if aniInfo[1] == StoryEntityAnimationType.AlphaChange then
            self:_SetAlpha(lmathext.lerp(aniInfo[3], aniInfo[4], t))
        elseif aniInfo[1] == StoryEntityAnimationType.BrightnessChange then
            self:_SetBrightness(lmathext.lerp(aniInfo[3], aniInfo[4], t))
        elseif aniInfo[1] == StoryEntityAnimationType.Translate then
            self:_SetPosition(Vector3.Lerp(aniInfo[3], aniInfo[4], t))
        elseif aniInfo[1] == StoryEntityAnimationType.Rotate then
            self:_SetRotation(Quaternion.Lerp(aniInfo[3], aniInfo[4], t))
        elseif aniInfo[1] == StoryEntityAnimationType.Scale then
            self:_SetScaling(Vector3.Lerp(aniInfo[3], aniInfo[4], t))
        elseif aniInfo[1] == StoryEntityAnimationType.BlurChange then
            self:_SetPicBlur(aniInfo[3],aniInfo[4],lmathext.lerp(aniInfo[6], aniInfo[7], t))
        elseif aniInfo[1] == StoryEntityAnimationType.Shake then
            if self._storyManager:IsJumping() then
                aniInfo[3]:Kill(true)
                self._animationData[aniData] = nil
            end
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
function StoryEntityMovable:_SetAlpha(alpha)
end

---明暗度设置 需要子类自己实现
---@param brightness number
function StoryEntityMovable:_SetBrightness(brightness)
end
---模糊设置 需要子类自己实现
---@param brightness number
function StoryEntityMovable:_SetPicBlur(blurType,BlurDirection,blur)
end
---设置层级
---@param layer number
function StoryEntityMovable:_SetLayer(layer)
    self._storyManager:SetLayer(self._gameObject.transform, layer)
    --self._gameObject.transform:SetSiblingIndex(layer)
end

---位置
---@param pos Vector3
function StoryEntityMovable:_SetPosition(pos)
    self._gameObject.transform.localPosition = pos
end

---旋转
---@param pos Quaternion
function StoryEntityMovable:_SetRotation(rot)
    self._gameObject.transform.localRotation = rot
end

---缩放
---@param pos Vector3
function StoryEntityMovable:_SetScaling(scale)
    self._gameObject.transform.localScale = scale
end
-------------------------------
