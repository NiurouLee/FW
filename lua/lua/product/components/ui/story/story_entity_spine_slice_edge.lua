--[[------------------
    SpineEdge切片剧情元素
--]]------------------

_class("StoryEntitySpineSliceEdge", StoryEntityMovable)
---@class StoryEntitySpineSliceEdge:Object
StoryEntitySpineSliceEdge = StoryEntitySpineSliceEdge

function StoryEntitySpineSliceEdge:Constructor(ID, gameObject, resRequest, storyManager, entityConfig)
    StoryEntitySpineSliceEdge.super.Constructor(self, ID, gameObject, resRequest, storyManager)
    self._type = StoryEntityType.SpineSliceEdge
    self._spineGameObject = gameObject
    self._spineSke = gameObject:GetComponentInChildren(typeof(Spine.Unity.SkeletonGraphic))
    self._spineSkeMultipleTex = gameObject:GetComponentInChildren(typeof(Spine.Unity.Modules.SkeletonGraphicMultiObject))
    self._entityConfig = entityConfig
    self._isSpeaking = false
    self._spineColor = nil
    self._matInsList = {}
    self._EMIMatResRequest = nil
    self._EMIMat = nil
    if self._spineSke then
        self._spineSke.material = UnityEngine.Material:New(self._spineSke.material)
        if entityConfig.Effect == "EMI" then
            self._EMIMatResRequest = ResourceManager:GetInstance():SyncLoadAsset("spine_graphic_dc.mat", LoadType.Mat)
            self._EMIMat = self._EMIMatResRequest.Obj
            self._spineSke.material.shader = self._EMIMat.shader
            self._spineSke.material:SetTexture("_NoiseTex", self._EMIMat:GetTexture("_NoiseTex"))
        end
        self._spineSke.material:SetFloat("_StencilComp", 3)
        self._matInsList[1] = self._spineSke.material
        self._spineColor = self._spineSke.color
        self._spineSke.AnimationState:SetAnimation(0, "Story_norm", true)
    elseif self._spineSkeMultipleTex then
        self._spineSkeMultipleTex.UseInstanceMaterials = true
        if entityConfig.Effect == "EMI" then
            self._EMIMatResRequest = ResourceManager:GetInstance():SyncLoadAsset("spine_dc.mat", LoadType.Mat)
            self._EMIMat = self._EMIMatResRequest.Obj
        end
        self._spineSkeMultipleTex.OnInstanceMaterialCreated = function(material)
            self:HandleMultipleTexSpineMatCreated(material)
        end
        self._spineSkeMultipleTex:UpdateMesh()
        if self._spineSkeMultipleTex.Skeleton then
            self._spineColor = Color(
                self._spineSkeMultipleTex.Skeleton.R,
                self._spineSkeMultipleTex.Skeleton.G,
                self._spineSkeMultipleTex.Skeleton.B,
                self._spineSkeMultipleTex.Skeleton.A
            )
        else
            self._spineColor = Color.white
        end
        self._spineSkeMultipleTex.AnimationState:SetAnimation(0, "Story_norm", true)
    end
    if not self._spineColor then
        self._spineColor = Color.white
    end
    self._defaultSliceWidth = 350
    self._sliceWidth = 350
    self._sliceHeight = 1438

    self._defaultEdgeSliceWidth = 540
    self._edgeSliceWidth = 540
    self._edgeSliceHeight = 1438

    local rootGO = UnityEngine.GameObject:New(gameObject.name)
    rootGO.transform:SetParent(gameObject.transform.parent, false)
    rootGO.transform.localPosition = gameObject.transform.localPosition
    rootGO:SetActive(gameObject.activeSelf)
    self._gameObject = rootGO

    self._spineMaskObject = UnityEngine.GameObject.Instantiate(storyManager:GetSpineSliceMaskTemplate(), rootGO.transform)
    self._spineMaskObject:SetActive(true)
    self._spineMaskObject.transform.localPosition = Vector3.zero
    gameObject.transform:SetParent(self._spineMaskObject.transform, false)
    gameObject:SetActive(true)

    self._edgeResRequest = ResourceManager:GetInstance():SyncLoadAsset("StorySliceEdge.prefab", LoadType.GameObject)
    self._edgeMaskObject = UnityEngine.GameObject.Instantiate(storyManager:GetMaskTemplate(), rootGO.transform)
    self._edgeMaskObject:SetActive(true)
    self._edgeMaskObject.transform.localPosition = Vector3.zero
    self._edgeObject = self._edgeResRequest.Obj
    if self._edgeObject then
        self._edgeObject.transform:SetParent(self._edgeMaskObject.transform, false)
        self._edgeObject:SetActive(true)
    end
    self._edgeImg = self._edgeObject:GetComponent("RawImage")
    self._edgeImgColor = self._edgeImg.color
    if entityConfig.FitSize then
        local canvasRect = storyManager:GetCanvasRect()
        local edgeRect = self._edgeObject:GetComponent("RectTransform")
        local targetWidth = canvasRect.width + 300
        local targetHeight = edgeRect.sizeDelta.y * targetWidth / edgeRect.sizeDelta.x
        edgeRect.sizeDelta = Vector2(targetWidth, targetHeight)
    end
end
function StoryEntitySpineSliceEdge:HandleMultipleTexSpineMatCreated(material)
    material:SetFloat("_StencilComp", 3)
    if self._entityConfig.Effect == "EMI" then
        material.shader = self._EMIMat.shader
        material:SetTexture("_NoiseTex", self._EMIMat:GetTexture("_NoiseTex"))
    end
end
function StoryEntitySpineSliceEdge:_TriggerKeyframe(keyframeData)
    StoryEntitySpineSliceEdge.super._TriggerKeyframe(self, keyframeData)
    local spineSke = nil
    if self._spineSke then
        spineSke = self._spineSke
    elseif self._spineSkeMultipleTex then
        spineSke = self._spineSkeMultipleTex
    else
        return
    end

    if not spineSke.AnimationState then
        return
    end

    if keyframeData.LoopAnimation ~= nil then
        if spineSke then
            spineSke.AnimationState:SetAnimation(0, keyframeData.LoopAnimation, true)
        end
    end

    if keyframeData.Animation ~= nil then
        if spineSke then
            spineSke.AnimationState:SetAnimation(0, keyframeData.Animation, false)
        end
    end

    if keyframeData.SpineOffset then
        self:_SetSpinePosition(Vector3(keyframeData.SpineOffset[1],keyframeData.SpineOffset[2],0))
    end

    if keyframeData.SliceWidthScale then
        self._sliceWidth = self._defaultSliceWidth * keyframeData.SliceWidthScale
        self._edgeSliceWidth = self._defaultEdgeSliceWidth * keyframeData.SliceWidthScale
    end

    if keyframeData.SliceWidthScaleAnim then
        self._inScaling = true
        self._edgeMaskObject:GetComponent("Image").enabled = true
        self._edgeMaskObject:GetComponent("Mask").enabled = true
        self._scalingStartValue = keyframeData.SliceWidthScaleAnim.StartValue
        self._scalingEndValue = keyframeData.SliceWidthScaleAnim.EndValue
        self._scalingDuration = keyframeData.SliceWidthScaleAnim.Duration
        self._scalingStartTime = keyframeData.Time
    end

    if keyframeData.SpineSkin ~= nil then
        spineSke.Skeleton:SetSkin(keyframeData.SpineSkin)
    end

    if keyframeData.Scroll ~= nil then
        self._inScrolling = true
        self._scrollStartFromCover = keyframeData.Scroll.StartFromCover
        self._scrollType = StoryPictureScrollType[keyframeData.Scroll.Toward]
        self._scrollStartTime = keyframeData.Time
        self._scrollDuration = keyframeData.Scroll.Duration
        self._edgeMaskObject:GetComponent("Image").enabled = true
        self._edgeMaskObject:GetComponent("Mask").enabled = true
        local maskRect = self._spineMaskObject:GetComponent("RectTransform")
        local spineRect = self._spineGameObject:GetComponent("RectTransform")
        local edgeMaskRect = self._edgeMaskObject:GetComponent("RectTransform")
        local edgeImgRect = self._edgeObject:GetComponent("RectTransform")
        edgeImgRect.sizeDelta = Vector2(self._edgeSliceWidth, self._edgeSliceHeight)
        if self._scrollStartFromCover then
            if self._scrollType == StoryPictureScrollType.LeftToRight or self._scrollType == StoryPictureScrollType.RightToLeft or self._scrollType == StoryPictureScrollType.HorizontalSpread then
                maskRect.sizeDelta = Vector2(0, self._sliceHeight)
                edgeMaskRect.sizeDelta = Vector2(0, self._edgeSliceHeight)
             elseif self._scrollType == StoryPictureScrollType.UpToDown or self._scrollType == StoryPictureScrollType.DownToUp or self._scrollType == StoryPictureScrollType.VerticalSpread then
                maskRect.sizeDelta = Vector2(self._sliceWidth, 0)
                edgeMaskRect.sizeDelta = Vector2(self._edgeSliceWidth, 0)
            elseif self._scrollType == StoryPictureScrollType.Spread then
                maskRect.sizeDelta = Vector2.zero
                edgeMaskRect.sizeDelta = Vector2.zero
            end
        else
            maskRect.sizeDelta = Vector2(self._sliceWidth, self._sliceHeight)
            edgeMaskRect.sizeDelta = Vector2(self._edgeSliceWidth, self._edgeSliceHeight)
        end

        if (self._scrollStartFromCover and self._scrollType == StoryPictureScrollType.LeftToRight) or (not self._scrollStartFromCover and self._scrollType == StoryPictureScrollType.RightToLeft) then
            --spine
            maskRect.pivot = Vector2(0, 0.5)
            maskRect.transform.localPosition = Vector3( -self._sliceWidth / 2,  maskRect.transform.localPosition.y, maskRect.transform.localPosition.z)
            spineRect.anchorMin = Vector2(0, 0.5)
            spineRect.anchorMax = Vector2(0, 0.5)
            if self._scrollStartFromCover then
                spineRect.transform.localPosition = Vector3(spineRect.transform.localPosition.x + self._sliceWidth / 2, spineRect.transform.localPosition.y, spineRect.transform.localPosition.z)
            end
            --edge
            edgeMaskRect.pivot = Vector2(0, 0.5)
            edgeMaskRect.transform.localPosition = Vector3(-self._edgeSliceWidth / 2, edgeMaskRect.transform.localPosition.y, edgeMaskRect.transform.localPosition.z)
            edgeImgRect.anchorMin = Vector2(0, 0.5)
            edgeImgRect.anchorMax = Vector2(0, 0.5)
            edgeImgRect.transform.localPosition = Vector3(self._edgeSliceWidth / 2, edgeImgRect.transform.localPosition.y, edgeImgRect.transform.localPosition.z)
        elseif (self._scrollStartFromCover and self._scrollType == StoryPictureScrollType.RightToLeft) or (not self._scrollStartFromCover and self._scrollType == StoryPictureScrollType.LeftToRight) then
            --spine
            maskRect.pivot = Vector2(1, 0.5)
            maskRect.transform.localPosition = Vector3(self._sliceWidth / 2, maskRect.transform.localPosition.y, maskRect.transform.localPosition.z)
            spineRect.anchorMin = Vector2(1, 0.5)
            spineRect.anchorMax = Vector2(1, 0.5)
            if self._scrollStartFromCover then
                spineRect.transform.localPosition = Vector3(spineRect.transform.localPosition.x-self._sliceWidth / 2,spineRect.transform.localPosition.y,spineRect.transform.localPosition.z)
            end
            --edge
            edgeMaskRect.pivot = Vector2(1, 0.5)
            edgeMaskRect.transform.localPosition = Vector3(self._edgeSliceWidth / 2, edgeMaskRect.transform.localPosition.y, edgeMaskRect.transform.localPosition.z)
            edgeImgRect.anchorMin = Vector2(1, 0.5)
            edgeImgRect.anchorMax = Vector2(1, 0.5)
            edgeImgRect.transform.localPosition = Vector3(-self._edgeSliceWidth / 2, edgeImgRect.transform.localPosition.y, edgeImgRect.transform.localPosition.z)
        elseif (self._scrollStartFromCover and self._scrollType == StoryPictureScrollType.UpToDown) or (not self._scrollStartFromCover and self._scrollType == StoryPictureScrollType.DownToUp) then
            --spine
            maskRect.pivot = Vector2(0.5, 1)
            maskRect.transform.localPosition = Vector3( maskRect.transform.localPosition.x, self._sliceHeight / 2, maskRect.transform.localPosition.z)
            local offset = 0
            if spineRect.anchorMin == Vector2(0.5, 1) then
                offset = 0
            elseif spineRect.anchorMin == Vector2(0.5, 0) then
                offset = self._sliceHeight
            else
                offset = self._sliceHeight / 2
            end
            spineRect.anchorMin = Vector2(0.5, 1)
            spineRect.anchorMax = Vector2(0.5, 1)
            if self._scrollStartFromCover then
                spineRect.transform.localPosition = Vector3(spineRect.transform.localPosition.x, spineRect.transform.localPosition.y - offset, spineRect.transform.localPosition.z)
            end
            --edge
            edgeMaskRect.pivot = Vector2(0.5, 1)
            edgeMaskRect.transform.localPosition = Vector3(edgeMaskRect.transform.localPosition.x, edgeImgRect.sizeDelta.y / 2, edgeMaskRect.transform.localPosition.z)
            edgeImgRect.anchorMin = Vector2(0.5, 1)
            edgeImgRect.anchorMax = Vector2(0.5, 1)
            edgeImgRect.transform.localPosition = Vector3(edgeImgRect.transform.localPosition.x, -edgeImgRect.sizeDelta.y / 2, edgeImgRect.transform.localPosition.z)
        elseif (self._scrollStartFromCover and self._scrollType == StoryPictureScrollType.DownToUp) or (not self._scrollStartFromCover and self._scrollType == StoryPictureScrollType.UpToDown) then
            --spine
            maskRect.pivot = Vector2(0.5, 0)
            maskRect.transform.localPosition =Vector3(maskRect.transform.localPosition.x, -self._sliceHeight / 2, maskRect.transform.localPosition.z)
            local offset = 0
            if spineRect.anchorMin == Vector2(0.5, 0) then
                offset = 0
            elseif spineRect.anchorMin == Vector2(0.5, 1) then
                offset = self._sliceHeight
            else
                offset = self._sliceHeight / 2
            end
            spineRect.anchorMin = Vector2(0.5, 0)
            spineRect.anchorMax = Vector2(0.5, 0)
            if self._scrollStartFromCover then
                spineRect.transform.localPosition = Vector3(spineRect.transform.localPosition.x, spineRect.transform.localPosition.y + offset, spineRect.transform.localPosition.z)
            end
            --edge
            edgeMaskRect.pivot = Vector2(0.5, 0)
            edgeMaskRect.transform.localPosition = Vector3(edgeMaskRect.transform.localPosition.x, -edgeImgRect.sizeDelta.y / 2, edgeMaskRect.transform.localPosition.z)
            edgeImgRect.anchorMin = Vector2(0.5, 0)
            edgeImgRect.anchorMax = Vector2(0.5, 0)
            edgeImgRect.transform.localPosition = Vector3(edgeImgRect.transform.localPosition.x, edgeImgRect.sizeDelta.y / 2, edgeImgRect.transform.localPosition.z)
        elseif self._scrollType == StoryPictureScrollType.Spread then
        elseif self._scrollType == StoryPictureScrollType.HorizontalSpread then
        elseif self._scrollType == StoryPictureScrollType.VerticalSpread then
        end
    end
end

---设置spine说话状态，如果进入说话状态，则表情动作更换为说话的表情动作，并且后续表情变化也是根据这个状态来设置动作
---@param speaking boolean
function StoryEntitySpineSliceEdge:SetSpeak(speaking)
    local spineSke = nil
    if self._spineSke then
        spineSke = self._spineSke
    elseif self._spineSkeMultipleTex then
        spineSke = self._spineSkeMultipleTex
    else
        return
    end
    self._isSpeaking = speaking
    local curAnimName = "normal"
    local loop = true
    local track = spineSke.AnimationState:GetCurrent(1)
    if track then
        curAnimName = track.Animation.Name
        loop = track.Loop
    end
    if self._isSpeaking ~= string.equal_with_ignorecase(curAnimName, "shoot") then
        if self._isSpeaking then
            spineSke.AnimationState:SetAnimation(1, "shoot", loop)
        else
            spineSke.AnimationState:SetAnimation(1, "aim", loop)
        end
    end
end
function StoryEntitySpineSliceEdge:_SetSpinePosition(pos)
    self._spineGameObject.transform.localPosition = pos
end
function StoryEntitySpineSliceEdge:_UpdateAnimation(time)
    local baseAllEnd = StoryEntitySpineSliceEdge.super._UpdateAnimation(self, time)
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
        if not self._maskRect then
            self._maskRect = self._spineMaskObject:GetComponent("RectTransform")
        end
        if not self._edgeMaskRect then
            self._edgeMaskRect = self._edgeMaskObject:GetComponent("RectTransform")
        end
        if not self._edgeRect then
            self._edgeRect = self._edgeObject:GetComponent("RectTransform")
        end
        if self._scrollType == StoryPictureScrollType.LeftToRight or self._scrollType == StoryPictureScrollType.RightToLeft or self._scrollType == StoryPictureScrollType.HorizontalSpread then
            local deltaMaskWidth = lmathext.lerp(0, self._sliceWidth, effectT)
            local deltaEdgeWidth = lmathext.lerp(0, self._edgeSliceWidth, effectT)
            --spine
            if self._scrollType ~= StoryPictureScrollType.HorizontalSpread then
                deltaMaskWidth = math.min(deltaEdgeWidth, self._sliceWidth)
            end
            self._maskRect.sizeDelta = Vector2(deltaMaskWidth, self._sliceHeight)
            --edge
            self._edgeMaskRect.sizeDelta = Vector2(deltaEdgeWidth, self._edgeSliceHeight)
            if self._scrollType == StoryPictureScrollType.HorizontalSpread then
                self._edgeRect.sizeDelta = Vector2(deltaEdgeWidth, self._edgeSliceHeight)
            end
        elseif self._scrollType == StoryPictureScrollType.UpToDown or self._scrollType == StoryPictureScrollType.DownToUp or self._scrollType == StoryPictureScrollType.VerticalSpread then
            local deltaHeight = lmathext.lerp(0, self._edgeSliceHeight, effectT)
            --spine
            self._maskRect.sizeDelta = Vector2(self._sliceWidth, math.min(deltaHeight, self._sliceHeight))
            --edge
            self._edgeMaskRect.sizeDelta = Vector2(self._edgeSliceWidth, deltaHeight)
        elseif self._scrollType == StoryPictureScrollType.Spread then
            local deltaMaskWidth = lmathext.lerp(0, self._sliceWidth, effectT)
            local deltaMaskHeight = lmathext.lerp(0, self._sliceHeight, effectT)
            --spine
            self._maskRect.sizeDelta = Vector2(deltaMaskWidth, deltaMaskHeight)
            --edge
            local deltaEdgeWidth = lmathext.lerp(0, self._edgeSliceWidth, effectT)
            local deltaEdgeHeight = lmathext.lerp(0, self._edgeSliceHeight, effectT)
            self._edgeMaskRect.sizeDelta = Vector2(deltaEdgeWidth, deltaEdgeHeight)
            self._edgeRect.sizeDelta = Vector2(deltaEdgeWidth, deltaEdgeHeight)
        end
        if t >= 1 then
            self._inScrolling = false
        end
        return false
    elseif self._inScaling then --scaling和scrolling不能同时执行
        local t = 1
        if self._scalingDuration > 0 then
            t = (time - self._scalingStartTime) / self._scalingDuration
        end
        if t > 1 then
            t = 1
        end
        if not self._maskRect then
            self._maskRect = self._spineMaskObject:GetComponent("RectTransform")
        end
        if not self._edgeMaskRect then
            self._edgeMaskRect = self._edgeMaskObject:GetComponent("RectTransform")
        end
        if not self._edgeRect then
            self._edgeRect = self._edgeObject:GetComponent("RectTransform")
        end
        --spine
        self._sliceWidth = self._defaultSliceWidth * lmathext.lerp(self._scalingStartValue, self._scalingEndValue, t)
        self._maskRect.sizeDelta = Vector2(self._sliceWidth, self._sliceHeight)
        --edge
        self._edgeSliceWidth = self._defaultEdgeSliceWidth * lmathext.lerp(self._scalingStartValue, self._scalingEndValue, t)
        self._edgeMaskRect.sizeDelta = Vector2(self._edgeSliceWidth, self._edgeSliceHeight)
        self._edgeRect.sizeDelta = Vector2(self._edgeSliceWidth, self._edgeSliceHeight)
        if t >= 1 then
            self._inScaling = false
        end
        return false
    else
        return baseAllEnd
    end
end
function StoryEntitySpineSliceEdge:_SetAlpha(alpha)
    self._spineColor.a = alpha
    if self._spineSke then
        self._spineSke.color = self._spineColor
    elseif self._spineSkeMultipleTex and self._spineSkeMultipleTex.Skeleton then
        self._spineSkeMultipleTex.Skeleton.A = alpha
    end
    self._edgeImgColor.a = alpha
    self._edgeImg.color = self._edgeImgColor
end
function StoryEntitySpineSliceEdge:_SetBrightness(brightness)
    self._spineColor:Set(brightness, brightness, brightness, self._spineColor.a)
    if self._spineSke then
        self._spineSke.color = self._spineColor
    elseif self._spineSkeMultipleTex and self._spineSkeMultipleTex.Skeleton then
        self._spineSkeMultipleTex.Skeleton.R = brightness
        self._spineSkeMultipleTex.Skeleton.G = brightness
        self._spineSkeMultipleTex.Skeleton.B = brightness
    end
    self._edgeImgColor:Set(brightness, brightness, brightness, self._edgeImgColor.a)
    self._edgeImg.color = self._edgeImgColor
end
function StoryEntitySpineSliceEdge:_SetRotation(rot)
    self._spineGameObject.transform.localRotation = rot
end
function StoryEntitySpineSliceEdge:_SetScaling(scale)
    self._spineGameObject.transform.localScale = scale
end
function StoryEntitySpineSliceEdge:Destroy()
    StoryEntitySpineSliceEdge.super.Destroy(self)
    for i = 1, #self._matInsList do
        UnityEngine.Object.Destroy(self._matInsList[i])
    end
    self._matInsList = {}
    if self._EMIMatResRequest then
        self._EMIMat = nil
        self._EMIMatResRequest:Dispose()
        self._EMIMatResRequest = nil
    end
    if self._edgeResRequest ~= nil then
        self._edgeResRequest:Dispose()
        self._edgeResRequest = nil
    end
end
function StoryEntitySpineSliceEdge:GetMaterial()
    if self._spineSke then
        return self._spineSke.material
    end
    if self._spineSkeMultipleTex then
        if self._spineSkeMultipleTex.material then
            return self._spineSkeMultipleTex.material
        else
            if self._spineSkeMultipleTex.canvasRenderers.Count > 0 then
                local materials = {}
                for i = 0, self._spineSkeMultipleTex.canvasRenderers.Count - 1 do
                    local material = self._spineSkeMultipleTex.canvasRenderers[i]:GetMaterial()
                    if material then
                        table.insert(materials, material)
                    end
                end
                if #materials > 0 then
                    return materials
                end
            end
        end
    end
    return nil
end