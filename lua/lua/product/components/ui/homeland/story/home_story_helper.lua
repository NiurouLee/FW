--[[
    家园剧情帮助类
]]
---@class HomeStoryHelper:Singleton
---@field GetInstance HomeStoryHelper
_class("HomeStoryHelper", Singleton)
HomeStoryHelper = HomeStoryHelper

function HomeStoryHelper:Constructor()
end
--获得一个文本的第n个字的某个顶点的世界坐标
---@param text UnityEngine.UI.Text
---@param canvas UnityEngine.Canvas
function HomeStoryHelper:GetPosWithTextIndexVert(canvas,text,content,charIndex,dir)
    local textStr = content
    local charPos = Vector3(0,0,0)
    if (charIndex <= HomeStoryHelper:GetInstance():GetstringCount(textStr) and charIndex>0) then
        ---@type UnityEngine.TextGenerator
        local textGen = text.cachedTextGenerator
        -- local textGen = UnityEngine.TextGenerator:New(textStr.Length)
        ---@type Vector2
        local extents = text.gameObject:GetComponent("RectTransform").rect.size;
        textGen:Populate(textStr, text:GetGenerationSettings(extents))
       
        local str1 = string.sub(textStr,1,charIndex)
        local str2 = string.split(str1,'\n')
        local newLine = #str2-1
        local whiteSpace = #string.split(string.sub(textStr,1,charIndex),' ')-1
        local indexOfTextQuad = (charIndex * 4) + (newLine * 4) - 4
        if (indexOfTextQuad<textGen.vertexCount) then
            if dir == 1 then
                charPos = textGen.verts[indexOfTextQuad].position
            elseif dir == 2 then
                charPos = textGen.verts[indexOfTextQuad+1].position
            elseif dir == 3 then
                charPos = textGen.verts[indexOfTextQuad+2].position
            elseif dir == 4 then
                charPos = textGen.verts[indexOfTextQuad+3].position
            else
                charPos = (textGen.verts[indexOfTextQuad].position + textGen.verts[indexOfTextQuad + 1].position + textGen.verts[indexOfTextQuad + 2].position + textGen.verts[indexOfTextQuad + 3].position) / 4
            end
        end
    end
    charPos =  charPos / canvas.scaleFactor
    charPos = text.transform:TransformPoint(charPos)
    return charPos
end
function HomeStoryHelper:GetstringCount(str)
    local _,count = string.gsub(str, "[^\128-\193]", "")
    return count
end
--获取emoji的总宽度
function HomeStoryHelper:GetEmojiWidth(str)
    local width = 64
    local strs = string.split(str, "<sprite.*/>")
    --TODO--需要计算配置的eomji的size，去size后面的值
    local times = #strs-1
    local allWidth = width*times
    return allWidth
end
--去除html标签
function HomeStoryHelper:FilterHtml(str)
    local plainStr = string.gsub(str, "<size=%d*>", "")
    plainStr = string.gsub(plainStr, "</size>", "")
    plainStr = string.gsub(plainStr, "<color=#%x*>", "")
    plainStr = string.gsub(plainStr, "</color>", "")
    plainStr = string.gsub(plainStr, "<sprite.*/>", "")
    local finalStr = string.gsub(plainStr, "|", "")
    return finalStr
end
