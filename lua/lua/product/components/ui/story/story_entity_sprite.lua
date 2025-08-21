--[[------------------
    Sprite剧情元素
--]] ------------------

_class("StoryEntitySprite", StoryEntityMovable)
---@class StoryEntitySprite:StoryEntityMovable
StoryEntitySprite = StoryEntitySprite

---@param storyManager StoryManager
function StoryEntitySprite:Constructor(ID, gameObject, resRequest, storyManager, entityConfig)
    StoryEntitySprite.super.Constructor(self, ID, gameObject, resRequest, storyManager)
    self._type = StoryEntityType.Picture
    self._picObject = gameObject
    ---@type UnityEngine.UI.RawImage
    self._picCmp = gameObject:GetComponent("Image")
    self._picColor = self._picCmp.color

    self._inScrolling = false
    self._scrollStartFromCover = true
    self._scrollType = nil
    self._scrollStartTime = 0
    self._scrollDuration = 0
--[[
    local newGameObject = UnityEngine.GameObject:New(gameObject.name)
    newGameObject.transform:SetParent(gameObject.transform.parent, false)
    newGameObject.transform.localPosition = gameObject.transform.localPosition
    newGameObject:SetActive(gameObject.activeSelf)
    self._gameObject = newGameObject

    self._maskObject = UnityEngine.GameObject.Instantiate(storyManager:GetMaskTemplate(), newGameObject.transform)
    self._maskObject:SetActive(true)
    self._maskObject.transform.localPosition = Vector3.zero
    gameObject.transform:SetParent(self._maskObject.transform, false)
    gameObject:SetActive(true)
]]
    if entityConfig.FitSize then
        local canvasRect = storyManager:GetCanvasRect()
        local picRect = gameObject:GetComponent("RectTransform")
        local targetWidth = canvasRect.width + 300
        local targetHeight = picRect.sizeDelta.y * targetWidth / picRect.sizeDelta.x
        picRect.sizeDelta = Vector2(targetWidth, targetHeight)
    end
end

function StoryEntitySprite:_TriggerKeyframe(keyframeData)
    StoryEntitySprite.super._TriggerKeyframe(self, keyframeData)
    if keyframeData.Scroll ~= nil then
        self._inScrolling = true
        self._scrollStartFromCover = keyframeData.Scroll.StartFromCover
        self._scrollType = StoryPictureScrollType[keyframeData.Scroll.Toward]
        self._scrollStartTime = keyframeData.Time
        self._scrollDuration = keyframeData.Scroll.Duration

        self._maskObject:GetComponent("Image").enabled = true
        self._maskObject:GetComponent("Mask").enabled = true
        local maskRect = self._maskObject:GetComponent("RectTransform")
        local picRect = self._picObject:GetComponent("RectTransform")
        if self._scrollStartFromCover then
            if self._scrollType == StoryPictureScrollType.LeftToRight or self._scrollType == StoryPictureScrollType.RightToLeft or self._scrollType == StoryPictureScrollType.HorizontalSpread then
                maskRect.sizeDelta = Vector2(0, picRect.sizeDelta.y)
            elseif self._scrollType == StoryPictureScrollType.UpToDown or self._scrollType == StoryPictureScrollType.DownToUp or self._scrollType == StoryPictureScrollType.VerticalSpread then
                maskRect.sizeDelta = Vector2(picRect.sizeDelta.x, 0)
            elseif self._scrollType == StoryPictureScrollType.Spread then
                maskRect.sizeDelta = Vector2.zero
            end
        else
            maskRect.sizeDelta = picRect.sizeDelta
        end
        if (self._scrollStartFromCover and self._scrollType == StoryPictureScrollType.LeftToRight) or (not self._scrollStartFromCover and self._scrollType == StoryPictureScrollType.RightToLeft) then
            maskRect.pivot = Vector2(0, 0.5)
            maskRect.transform.localPosition = Vector3(-picRect.sizeDelta.x / 2, maskRect.transform.localPosition.y, maskRect.transform.localPosition.z)
            picRect.anchorMin = Vector2(0, 0.5)
            picRect.anchorMax = Vector2(0, 0.5)
            picRect.transform.localPosition = Vector3(picRect.sizeDelta.x / 2, picRect.transform.localPosition.y, picRect.transform.localPosition.z)
        elseif (self._scrollStartFromCover and self._scrollType == StoryPictureScrollType.RightToLeft) or (not self._scrollStartFromCover and self._scrollType == StoryPictureScrollType.LeftToRight) then
            maskRect.pivot = Vector2(1, 0.5)
            maskRect.transform.localPosition = Vector3(picRect.sizeDelta.x / 2, maskRect.transform.localPosition.y, maskRect.transform.localPosition.z)
            picRect.anchorMin = Vector2(1, 0.5)
            picRect.anchorMax = Vector2(1, 0.5)
            picRect.transform.localPosition = Vector3(-picRect.sizeDelta.x / 2, picRect.transform.localPosition.y, picRect.transform.localPosition.z)
        elseif (self._scrollStartFromCover and self._scrollType == StoryPictureScrollType.UpToDown) or (not self._scrollStartFromCover and self._scrollType == StoryPictureScrollType.DownToUp) then
            maskRect.pivot = Vector2(0.5, 1)
            maskRect.transform.localPosition = Vector3(maskRect.transform.localPosition.x, picRect.sizeDelta.y / 2, maskRect.transform.localPosition.z)
            picRect.anchorMin = Vector2(0.5, 1)
            picRect.anchorMax = Vector2(0.5, 1)
            picRect.transform.localPosition = Vector3(picRect.transform.localPosition.x, -picRect.sizeDelta.y / 2, picRect.transform.localPosition.z)
        elseif (self._scrollStartFromCover and self._scrollType == StoryPictureScrollType.DownToUp) or (not self._scrollStartFromCover and self._scrollType == StoryPictureScrollType.UpToDown) then
            maskRect.pivot = Vector2(0.5, 0)
            maskRect.transform.localPosition = Vector3(maskRect.transform.localPosition.x, -picRect.sizeDelta.y / 2, maskRect.transform.localPosition.z)
            picRect.anchorMin = Vector2(0.5, 0)
            picRect.anchorMax = Vector2(0.5, 0)
            picRect.transform.localPosition = Vector3(picRect.transform.localPosition.x, picRect.sizeDelta.y / 2, picRect.transform.localPosition.z)
        elseif self._scrollType == StoryPictureScrollType.Spread then
        elseif self._scrollType == StoryPictureScrollType.HorizontalSpread then
        elseif self._scrollType == StoryPictureScrollType.VerticalSpread then
        end
    end

    if keyframeData.FullScreen ~= nil then
        if keyframeData.FullScreen then
            local rectTrans = self._picObject:GetComponent("RectTransform")
            if rectTrans then
                self:_SetPicFullScreen(rectTrans)
            end
        else
            self._storyManager:SetUIBlackSideSize(0, 0)
        end
    end

    if keyframeData.FullAnchor ~= nil then
        ---@type UnityEngine.RectTransform         
        local rectTrans = self._picObject:GetComponent("RectTransform")
        rectTrans.anchorMin = Vector2.zero
        rectTrans.anchorMax = Vector2.one
        rectTrans.offsetMin = Vector2.zero
        rectTrans.offsetMax = Vector2.zero
    end
end

---@param rectTrans UnityEngine.RectTransform
function StoryEntitySprite:_SetPicFullScreen(rectTrans)
    -- 全屏图片资源固定长宽为2532/1170
    local fullPicWidth = 2532
    local fullPicHeight = 1170

    local screenWidth, screenHeight = self._storyManager:GetUICanvasSize()

    local picAspect = fullPicWidth / fullPicHeight
    local screenAspect = screenWidth / screenHeight

    local blackSideHeight = 0
    local blackSideWidth = 0

    if screenAspect < picAspect then
        local picHeight = fullPicHeight * screenWidth / fullPicWidth
        rectTrans.sizeDelta = Vector2(screenWidth, picHeight)
        blackSideHeight = math.abs(screenHeight - picHeight) / 2
    elseif screenAspect > picAspect then
        local picWidth = fullPicWidth * screenHeight / fullPicHeight
        rectTrans.sizeDelta = Vector2(picWidth, screenHeight)
        blackSideWidth = math.abs(screenWidth - picWidth) / 2
    else
        rectTrans.sizeDelta = Vector2(screenWidth, screenHeight)
    end

    self._storyManager:SetUIBlackSideSize(blackSideWidth, blackSideHeight)
end

---卷轴动画处理----
---@param time number
---@return boolean 是否已经播放完全部的轨道动画
function StoryEntitySprite:_UpdateAnimation(time)
    local res = StoryEntitySprite.super._UpdateAnimation(self, time)

    if self._inScrolling and self._scrollType then
        local t = 1
        if self._scrollDuration > 0 then
            t = (time - self._scrollStartTime) / self._scrollDuration
        end
        if t > 1 then
            t = 1
        end
        local effectT = t
        if not self._scrollStartFromCover then
            effectT = 1 - effectT
        end
        if not self._maskRect  then
            self._maskRect = self._maskObject:GetComponent("RectTransform")
        end
        if not self._picRect then
            self._picRect = self._picObject:GetComponent("RectTransform")
        end
        if self._scrollType == StoryPictureScrollType.LeftToRight or self._scrollType == StoryPictureScrollType.RightToLeft or self._scrollType == StoryPictureScrollType.HorizontalSpread then
            self._maskRect.sizeDelta = Vector2(lmathext.lerp(0, self._picRect.sizeDelta.x, effectT), self._picRect.sizeDelta.y)
        elseif self._scrollType == StoryPictureScrollType.UpToDown or self._scrollType == StoryPictureScrollType.DownToUp or self._scrollType == StoryPictureScrollType.VerticalSpread then
            self._maskRect.sizeDelta = Vector2(self._picRect.sizeDelta.x, lmathext.lerp(0, self._picRect.sizeDelta.y, effectT))
        elseif self._scrollType == StoryPictureScrollType.Spread then
            self._maskRect.sizeDelta = Vector2(lmathext.lerp(0, self._picRect.sizeDelta.x, effectT), lmathext.lerp(0, self._picRect.sizeDelta.y, effectT))
        end
        if t >= 1 then
            self._inScrolling = false
        end
        return false
    else
        return res
    end
end

function StoryEntitySprite:_SetAlpha(alpha)
    self._picColor.a = alpha
    self._picCmp.color = self._picColor
end

function StoryEntitySprite:_SetBrightness(brightness)
    self._picColor:Set(brightness, brightness, brightness, self._picColor.a)
    self._picCmp.color = self._picColor
end
