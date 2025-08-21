---@class StateBounceInit : StateBounceBase
_class("StateBounceInit", StateBounceBase)
StateBounceInit = StateBounceInit

function StateBounceInit:OnEnter(TT, ...)
    self:Init()
    --资源池初始化

    --角色初始化
    self.objMgr:InitPlayer()

    --怪物生成器初始化
    table.clear(self.monsterGenerator)
    local genIdArray = self.bounceData.levelCfg.MonsterGenerator

    if  genIdArray then
        for i, genId in ipairs(genIdArray) do
            local genCfg = Cfg.cfg_bounce_monster_gen[genId]
            if genCfg then
                local generator = MonsterGenerator:New()
                generator:Init(genId)
                generator:SetCoreController(self.coreController)
                table.insert(self.monsterGenerator, generator)
            else
                Log.error("StateBounceInit err:can't find cfg_bounce_monster_gen with id = " .. genId)
            end
        end
    else
        Log.error("StateBounceInit err:can't find monster generator with levelId " .. self.bounceData.levleId )
    end
    self.coreController:ChgFsmState(StateBounce.Prepare)
end

function StateBounceInit:StartGameCore(TT)
end

function StateBounceInit:OnExit(TT)
end