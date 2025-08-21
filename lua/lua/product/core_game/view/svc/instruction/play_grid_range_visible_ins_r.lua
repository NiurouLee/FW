require("base_ins_r")
---@class PlayGridRangeVisibleInstruction: BaseInstruction
_class("PlayGridRangeVisibleInstruction", BaseInstruction)
PlayGridRangeVisibleInstruction = PlayGridRangeVisibleInstruction

function PlayGridRangeVisibleInstruction:Constructor(paramList)
	self._visible = tonumber(paramList["visible"])

end

---@param casterEntity Entity
---@param phaseContext SkillPhaseContext
function PlayGridRangeVisibleInstruction:DoInstruction(TT, casterEntity, phaseContext)
	local scopeGridRange = phaseContext:GetScopeGridRange()
	if not scopeGridRange then
		return InstructionConst.PhaseEnd
	end
	local maxScopeRangeCount = phaseContext:GetMaxRangeCount()
	if not maxScopeRangeCount then
		return InstructionConst.PhaseEnd
	end
	local curScopeGridRangeIndex = phaseContext:GetCurScopeGridRangeIndex()
	if curScopeGridRangeIndex > maxScopeRangeCount then
		return
	end
	--播放特效
	local world = casterEntity:GetOwnerWorld()
	---@type EffectService
	local effectService = world:GetService("Effect")
    ---@type PieceServiceRender
    local pieceSvc = self._world:GetService("Piece")
	for _, range in pairs(scopeGridRange) do
		if range then
			local posList = range[curScopeGridRangeIndex]
			if posList then
				local len = table.count(posList)
				for i = 1, len do
					local pos = posList[i]
					local pieceEntity = pieceSvc:FindPieceEntity(pos)
					pieceEntity:View():GetGameObject():SetActive(self._visible ==1)
					pieceEntity:View():SetViewVisible(self._visible ==1)
				end
			end
		end
	end
end

function PlayGridRangeVisibleInstruction:GetCacheResource()
	local t = {}
	return t
end
