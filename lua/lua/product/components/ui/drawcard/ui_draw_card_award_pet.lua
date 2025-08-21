---@class UIDrawCardAwardPet:UICustomWidget
_class("UIDrawCardAwardPet", UICustomWidget)
UIDrawCardAwardPet = UIDrawCardAwardPet

function UIDrawCardAwardPet:OnShow()
    self._stars = self:GetUIComponent("UISelectObjectPath", "Stars")
    self.starItems = self._stars:GetAllSpawnList()
    self._petItem = self:GetUIComponent("UISelectObjectPath", "PetItem")
end

function UIDrawCardAwardPet:SetData(k,id)
    local cfg = Cfg.cfg_drawcard_pool_view[id]
    
    if k==1 then
        self._stars:SpawnObjects("UIDrawCardAwardUpstar",6)
        local rate = cfg.sixpet[1]/1000
        local count= #cfg.sixpet-1
        local petrate = math.floor((rate/count)* 1000) / 1000
        local up = cfg.sixup
        local upjudge = up and up[1][2] 
        if upjudge then
            count = count + #up
        end
        self._petItem:SpawnObjects("UIDrawCardAwardPetItem",count)
        self.petItems = self._petItem:GetAllSpawnList()
        --检查是否有六星up，有则将up光灵放到前面显示
        if upjudge  then
            local key = 1
            local petkey = 2--第一项数据为概率，第二项才是光灵id
            for next = 1 , #up do
                local item = self.petItems[next]
                item:SetData(6, up[key][1],up[key][2]/1000)
                key = key+1
            end

            for next = #up + 1 , count do
                local item = self.petItems[next]
                item:SetData(6, cfg.sixpet[petkey],petrate)
                petkey = petkey+1
            end
        else
            for idx, value in ipairs(self.petItems) do
                value:SetData(6, cfg.sixpet[idx+1],petrate)
            end
        end
    end

    if k==2 then
        self._stars:SpawnObjects("UIDrawCardAwardUpstar",5)
        local rate = cfg.fivepet[1]/1000
        local count = #cfg.fivepet-1
        local petrate = math.floor((rate/count)* 1000) / 1000
        local up = cfg.fiveup
        local upjudge = up and up[1][2]
        if upjudge then
            count = count + #up
        end
        self._petItem:SpawnObjects("UIDrawCardAwardPetItem",count)
        self.petItems = self._petItem:GetAllSpawnList()
        --检查是否有五星up，有则将up光灵放到前面显示
        if upjudge then
            local key = 1
            local petkey = 2--第一项数据为概率，第二项才是光灵id
            for next = 1 , #up do
                local item = self.petItems[next]
                item:SetData(5, up[key][1],up[key][2]/1000)
                key = key+1
            end

            for next = #up + 1 , count do
                local item = self.petItems[next]
                item:SetData(5, cfg.fivepet[petkey],petrate)
                petkey = petkey+1
            end
        else
            for idx, value in ipairs(self.petItems) do
                value:SetData(5, cfg.fivepet[idx+1],petrate)
            end
        end
    end

    if k==3 then
        self._stars:SpawnObjects("UIDrawCardAwardUpstar",4)
        local rate = cfg.fourpet[1]/1000
        local count = #cfg.fourpet-1
        local petrate = math.floor((rate/count)* 1000) / 1000
        self._petItem:SpawnObjects("UIDrawCardAwardPetItem",count)
        self.petItems = self._petItem:GetAllSpawnList()
        for idx, value in ipairs(self.petItems) do
            value:SetData(4, cfg.fourpet[idx+1],petrate)
        end
    end

    if k==4 then
        self._stars:SpawnObjects("UIDrawCardAwardUpstar",3)
        local rate = cfg.threepet[1]/1000
        local count = #cfg.threepet-1
        local petrate = math.floor((rate/count)* 1000) / 1000
        self._petItem:SpawnObjects("UIDrawCardAwardPetItem",count)
        self.petItems = self._petItem:GetAllSpawnList()
        for idx, value in ipairs(self.petItems) do
            value:SetData(3, cfg.threepet[idx+1],petrate)
        end
    end
end

function UIDrawCardAwardPet:OnHide()
end
