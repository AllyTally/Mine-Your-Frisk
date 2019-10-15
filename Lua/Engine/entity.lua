return (function()
    local self = {}
    self.x = 0
    self.y = 0
    self.width = 20
    self.height = 20
    self.sprite = false
    self.inventory = {}
    self.hsp = 0
    self.vsp = 0
    self.hcap = 4
    self.hinc = 1
    self.gravity = 0.40
    self.maxfall = -10
    self.usesgravity = true

    function self.Load(path)
        ent = dofile(GetModName() .. path .. ".lua")
        for k, v in pairs(ent) do
            if k == "Update" then
                self._Update = v
            else
                self[k] = v
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
        self.y = self.y + vsp
        return {hsp,vsp}
    end

    function self.Update()
        if (self.hsp < 0) then self.hsp = self.hsp + self.hinc end
        if (self.hsp > 0) then self.hsp = self.hsp - self.hinc end
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
        if self.sprite then
            self.sprite.x = self.x
            self.sprite.y = self.y
        end
        if self._Update then
            self._Update()
            DEBUG(self.alivetime)
        end
    end
    return self
end)()