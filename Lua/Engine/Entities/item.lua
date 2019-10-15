return (function ()
    local self = {}
    self.x = 0
    self.y = 0
    self.width = 16
    self.height = 16
    self.id = "dirt"
    self.nbt = {}
    self.sprite = {CreateSprite("px","Entities")}
    self.inventory = {}
    self.vsp = 0
    self.hsp = 0
    self.hinc = 0.1
    self.hcap = 4
    self.usesgravity = true
    self.alivetime = 0
    self.gravity = 0.40
    self.maxfall = -10
    self.pickupdelay = 0
    self.count = 1

    function self.UpdateItem()
        local isblock = (world.itemsys[self.id][3] == "block")
        if self.count > 1 then
            if #self.sprite < 3 then
                if isblock then
                    local ww = CreateSprite("blocks/" .. world.tilesys[self.id][1],"Entities")
                    table.insert(self.sprite,ww)
                else
                    local ww = CreateSprite(world.itemsys[self.id][1],"Entities")
                    table.insert(self.sprite,ww)
                end
            end
        end
        if self.count > 2 then
            if #self.sprite < 4 then
                if isblock then
                    local ww = CreateSprite("blocks/" .. world.tilesys[self.id][1],"Entities")
                    table.insert(self.sprite,ww)
                else
                    local ww = CreateSprite(world.itemsys[self.id][1],"Entities")
                    table.insert(self.sprite,ww)
                end
            end
        end
        if isblock then
            for i=1, #self.sprite do
                self.sprite[i].Set("blocks/" .. world.tilesys[self.id][1])
                self.sprite[i].Scale(1,1)
            end
        else
            for i=1, #self.sprite do
                self.sprite[i].Set(world.itemsys[self.id][1])
                self.sprite[i].Scale(world.itemsys[self.id][5],world.itemsys[self.id][5])
            end
        end
    end

    function self._Update()
        self.alivetime = self.alivetime + 1
        if self.alivetime > self.pickupdelay then
            rectangle  = rect(player.x-8,player.x+8,player.y,player.y+60)
            rectangle2 = rect(self.x-8,self.x+8,self.y,self.y+16)
            result = isColliding(rectangle,rectangle2)
            if result then
                thingy = CreateItemFromEntity(self)
                local ret = player.GiveItem(thingy)
                if (ret == 0) then
                    DestroyEntity(self)
                else
                    self.count = ret
                end
            end
            for i=#entities,1,-1 do
                local ent = entities[i]
                if self ~= ent then
                    if self.id == ent.id then
                        if TableEquals(self.nbt,ent.nbt) then
                            local entrect = rect(ent.x-8,ent.x+8,ent.y,ent.y+16)
                            if isColliding(rectangle2,entrect) then
                                if ent.alivetime >= self.alivetime then
                                    if (ent.count + self.count) <= world.itemsys[self.id][2] then
                                        ent.count = ent.count + self.count
                                        ent.UpdateItem()
                                        DestroyEntity(self)
                                        return
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end


    function self.Meeting(xdiff,ydiff)
        local entityx = math.floor(((self.x)+xdiff)/32)+1
        local entityy = math.floor(((self.y)+ydiff-8)/32)+1
        if world.map[entityx] then
            return world.map[entityy][entityx]
        else
            return "air"
        end
    end

    function self.Grounded()
        a = world.Solid(self.Meeting(-self.width, -2))
        b = world.Solid(self.Meeting( self.width, -2))
        return (a or b)
    end

    function self.Under()
        return self.Meeting(0, -2)
    end

    function self.MeetingSolid(xdiff,ydiff)
        a = world.Solid(self.Meeting(xdiff+(self.width/2),ydiff))
        b = world.Solid(self.Meeting(xdiff-(self.width/2),ydiff))
        c = world.Solid(self.Meeting(xdiff+(self.width/2),ydiff+self.height))
        d = world.Solid(self.Meeting(xdiff-(self.width/2),ydiff+self.height))
        return (a or b or c or d)
    end

    function self.Move(hsp,vsp)
        local temphsp
        if hsp < 0 then temphsp = -0.25 else temphsp = 0.25  end
        if self.x+hsp <= 0 then return {0,vsp} end
        local noinf = 0
        if (self.MeetingSolid(hsp,0)) then
            noinf = 0
            while (self.MeetingSolid(hsp,0)) do
                noinf = noinf + 1
                hsp = hsp - temphsp;
                if (noinf > 100) then
                    hsp = 0
                    temphsp = 0
                    self.x = self.x + 8
                    break
                end
            end
        end

        self.x = self.x + hsp

        if vsp < 0 then tempvsp = -0.25 else tempvsp = 0.25  end
        if self.y+vsp <= 0 then return {hsp,0} end
        local noinf = 0
        if (self.MeetingSolid(0,vsp)) then
            noinf = 0
            while (self.MeetingSolid(0,vsp)) do
                noinf = noinf + 1
                vsp = vsp - tempvsp;
                if (noinf > 100) then
                    vsp = 0
                    tempvsp = 0
                    self.y = self.y + 8
                    break
                end
            end
        end
        if (hsp > -0.5) and (hsp < 0.5) then
            hsp = 0
        end
        self.y = self.y + vsp
        return {hsp,vsp}
    end

    function self.Update()
        if self.Grounded() then
            usehinc = self.hinc*2
        else
            usehinc = self.hinc
        end
        if (self.hsp < 0) then self.hsp = self.hsp + usehinc end
        if (self.hsp > 0) then self.hsp = self.hsp - usehinc end
        if self.usesgravity then
            if (self.vsp > self.maxfall) then
                self.vsp = self.vsp - self.gravity
            else
                self.vsp = self.maxfall
            end
        end
        returnage = self.Move(self.hsp,self.vsp)
        self.hsp = returnage[1]
        self.vsp = returnage[2]
        self.sprite[1].x = self.x
        self.sprite[1].y = self.y
        if #self.sprite > 1 then
            self.sprite[2].x = self.x+3
            self.sprite[2].y = self.y+2
        end
        if #self.sprite > 2 then
            self.sprite[3].x = self.x-2
            self.sprite[3].y = self.y+1
        end
        self._Update()
    end

    return self
end)()