return (function()
    local self = {}



    self.x = 16
    self.y = (world.mapheights[2]+4)*32

    self.sprite = {}
    self.sprite.right_leg = CreateSprite("player/leg_right_inner","Player_Back")
    self.sprite.left_leg = CreateSprite("player/leg_left","Player_Top")
    self.sprite.right_arm = CreateSprite("player/arm_right_inner","Player_Back")
    self.sprite.body = CreateSprite("player/body_left","Player")
    self.sprite.left_arm = CreateSprite("player/arm_left","Player_Top")
    self.sprite.head = CreateSprite("player/head_right","Player_Top")

    self.sprite.right_leg.SetParent(self.sprite.left_leg)
    self.sprite.body.SetParent(self.sprite.left_leg)
    self.sprite.right_arm.SetParent(self.sprite.body)
    self.sprite.left_arm.SetParent(self.sprite.body)
    self.sprite.head.SetParent(self.sprite.body)

    self.invopen = false

    self.lockmovement = false

    self.health = 20
    self.maxhealth = 20

    self.distancefallen = 0

    self.startingblock = false

    playerscale = 2
    self.movespd = 4

    self.sprite.body.y = 12*playerscale
    self.sprite.head.y = 6*playerscale

    self.sprite.head.SetPivot(0.5,0)

    self.sprite.left_leg.x = self.x
    self.sprite.left_leg.y = self.y

    self.inventory = {
        {{},{},{},{},{},{},{},{},{}}, -- hotbar (This is at the top instead of the bottom for lazy reasons)
        {{},{},{},{},{},{},{},{},{}}, -- 3
        {{},{},{},{},{},{},{},{},{}}, -- 2
        {{},{},{},{},{},{},{},{},{}}, -- 1
    }

    self.breaking = {0,0}
    self.breaktimer = -1

    self.selectedslot = 1

    self.inventorysprites = {
        {{},{},{},{},{},{},{},{},{}}, -- hotbar (This is at the top instead of the bottom for lazy reasons)
        {{},{},{},{},{},{},{},{},{}}, -- 3
        {{},{},{},{},{},{},{},{},{}}, -- 2
        {{},{},{},{},{},{},{},{},{}}, -- 1
    }

    self.incursor = false

    for k, v in pairs(self.sprite) do
        v.Scale(playerscale,playerscale)
    end

    cset = 1

    function self.Hurt(damage)
        self.health = self.health - damage
        DEBUG(self.health)
    end

    function self.rx(n)
        return self.x + n
    end
    function self.ry(n)
        return self.y + n
    end
    function self.HideInventory()
        self.invopen = false
        self.lockmovement = false
        camera.Detach(self.literallyblack)
        self.literallyblack.Remove()
        camera.Detach(self.inventorysprite)
        self.inventorysprite.Remove()
        for i=1,4 do
            for x=1,9 do
                camera.Detach(self.inventorysprites[i][x][1])
                self.inventorysprites[i][x][1].Remove()
                camera.DetachText(self.inventorysprites[i][x][2][1])
                camera.DetachText(self.inventorysprites[i][x][2][2])
                self.inventorysprites[i][x][2][1].DestroyText()
                self.inventorysprites[i][x][2][2].DestroyText()
            end
        end
        camera.Detach(self.hovercursorsprite)
        self.hovercursorsprite.Remove()
        self.incursor = false
        camera.Detach(self.incursorsprite[1])
        self.incursorsprite[1].Remove()
        camera.DetachText(self.incursorsprite[2][1])
        camera.DetachText(self.incursorsprite[2][2])
        self.incursorsprite[2][1].DestroyText()
        self.incursorsprite[2][2].DestroyText()
    end

    function self.ShowInventory()
        self.invopen = true
        self.lockmovement = true
        self.literallyblack = CreateSprite("black","Inventory")
        self.literallyblack.alpha = 0.5
        camera.Attach(self.literallyblack)
        self.inventorysprite = CreateSprite("inventory","Inventory")
        self.inventorysprite.Scale(2,2)
        camera.Attach(self.inventorysprite)
        for i=1,4 do
            for x=1,9 do
                local aax = 140 + (x*36)
                local aay = 294-(i*36)
                if (i == 1) then
                    aay = 106
                end
                self.inventorysprites[i][x] = CreateInventoryItemDisplay(aax,aay,"InventoryItems","InventoryItemText",true)
                self.inventorysprites[i][x][1].alpha = 1
                self.inventorysprites[i][x][2][1].SetText("[instant][font:Minecraft]")
                self.inventorysprites[i][x][2][2].SetText("[instant][font:Minecraft]")
            end
        end
        self.hovercursorsprite = CreateSprite("invhover","InventoryItems")
        camera.Attach(self.hovercursorsprite)
        self.incursorsprite = CreateInventoryItemDisplay(Input.MousePosX,Input.MousePosY,"InventoryItems","InventoryItemText",true)
        self.incursorsprite[2][1].SetText("[instant][font:Minecraft]")
        self.incursorsprite[2][2].SetText("[instant][font:Minecraft]")
        self.UpdateInventory()
    end

    function self.UpdateInventory()
        for i=1,4 do
            for x=1,9 do
                if next(self.inventory[i][x]) ~= nil then
                    self.inventorysprites[i][x][1].alpha = 1
                    self.inventorysprites[i][x][1].Set(world.itemsys[self.inventory[i][x].id][1])
                    self.inventorysprites[i][x][1].Scale(world.itemsys[self.inventory[i][x].id][5],world.itemsys[self.inventory[i][x].id][5])
                    if self.inventory[i][x].count <= 1 then
                        self.inventorysprites[i][x][2][1].SetText("[instant]")
                        self.inventorysprites[i][x][2][2].SetText("[instant]")
                    else
                        self.inventorysprites[i][x][2][1].SetText("[instant][font:Minecraft]" .. self.inventory[i][x].count)
                        self.inventorysprites[i][x][2][2].SetText("[instant][font:Minecraft]" .. self.inventory[i][x].count)
                        ind =  camera.GetTextIndex(self.inventorysprites[i][x][2][1])
                        ind2 = camera.GetTextIndex(self.inventorysprites[i][x][2][2])
                        if self.inventory[i][x].count > 9 then
                            camera.attachedtext[ind ][2][1] = 148 - 14 + (x*36)
                            camera.attachedtext[ind2][2][1] = 150 - 14 + (x*36)
                        else
                            camera.attachedtext[ind ][2][1] = 148 + (x*36)
                            camera.attachedtext[ind2][2][1] = 150 + (x*36)
                        end
                    end
                else
                    self.inventorysprites[i][x][1].alpha = 0
                    self.inventorysprites[i][x][2][1].SetText("[instant]")
                    self.inventorysprites[i][x][2][2].SetText("[instant]")
                end
            end
        end
    end

    function self.GiveItem(item)
        itemcounter = 0
        for aa=1,item.count do
            didthing = self.GiveItemLogic(item)
            if not didthing then
                itemcounter = itemcounter + 1
            end
        end
        self.UpdateHotbar()
        if self.invopen then
            self.UpdateInventory()
        end
        return itemcounter
    end

    function self.GiveItemLogic(item)
        for i=1,4 do
            local ci = self.inventory[i]
            for x=1,9 do
                if next(ci[x]) == nil then
                    local useitem = item
                    useitem.count = 1
                    self.inventory[i][x] = useitem
                    return true
                elseif CompareInventoryItems(ci[x],item) then
                    if (self.inventory[i][x].count + 1) <= world.itemsys[item.id][2] then
                        self.inventory[i][x].count = self.inventory[i][x].count + 1
                        return true
                    end
                end
            end
        end
        return false
    end

    function self.UpdateHotbar()
        for i=1,9 do
            if next(self.inventory[1][i]) ~= nil then
                hotbarsprites[i][1].alpha = 1
                hotbarsprites[i][1].Set(world.itemsys[self.inventory[1][i].id][1])
                hotbarsprites[i][1].Scale(world.itemsys[self.inventory[1][i].id][5],world.itemsys[self.inventory[1][i].id][5])
                if self.inventory[1][i].count <= 1 then
                    hotbarsprites[i][2][1].alpha = 0
                    hotbarsprites[i][2][2].alpha = 0
                    hotbarsprites[i][2][1].SetText("[instant]")
                    hotbarsprites[i][2][2].SetText("[instant]")
                else
                    hotbarsprites[i][2][1].SetText("[instant][font:Minecraft]" .. self.inventory[1][i].count)
                    hotbarsprites[i][2][2].SetText("[instant][font:Minecraft]" .. self.inventory[1][i].count)
                    hotbarsprites[i][2][1].alpha = 1
                    hotbarsprites[i][2][2].alpha = 1
                    ind =  camera.GetTextIndex(hotbarsprites[i][2][1])
                    ind2 = camera.GetTextIndex(hotbarsprites[i][2][2])
                    if self.inventory[1][i].count > 9 then
                        camera.attachedtext[ind ][2][1] = 128-14 + (i*40)
                        camera.attachedtext[ind2][2][1] = 130-14 + (i*40)
                    else
                        camera.attachedtext[ind ][2][1] = 127 + (i*40)
                        camera.attachedtext[ind2][2][1] = 129 + (i*40)
                    end
                end
            else
                hotbarsprites[i][1].alpha = 0
                hotbarsprites[i][2][1].alpha = 0
                hotbarsprites[i][2][2].alpha = 0
                hotbarsprites[i][2][1].SetText("[instant]")
                hotbarsprites[i][2][2].SetText("[instant]")
            end
        end
    end

    function self.Meeting(xdiff,ydiff)
        playerx = math.floor(((self.x)+xdiff)/32)+1
        playery = math.floor(((self.y)+ydiff-8)/32)+1
        if world.map[playery] then
            return world.map[playery][playerx]
        else
            return "air"
        end
    end

    function self.Grounded()
        local a = world.Solid(self.Meeting(-8, -2))
        local b = world.Solid(self.Meeting( 8, -2))
        return (a or b)
    end

    function self.Under()
        return self.Meeting(0, -2)
    end

    function self.MeetingSolid(xdiff,ydiff)
        local a = world.Solid(self.Meeting(xdiff+8,ydiff))
        local b = world.Solid(self.Meeting(xdiff-8,ydiff))
        local c = world.Solid(self.Meeting(xdiff+8,ydiff+32))
        local d = world.Solid(self.Meeting(xdiff-8,ydiff+32))
        local e = world.Solid(self.Meeting(xdiff+8,ydiff+60))
        local f = world.Solid(self.Meeting(xdiff-8,ydiff+60))
        --g = world.Solid(self.Meeting(xdiff+8,ydiff+96))
        --h = world.Solid(self.Meeting(xdiff-8,ydiff+96))
        return (a or b or c or d or e or f)
    end

    function self.Move(hsp,vsp)
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

    function self.PlaceBlock(x,y,id)
        if world.CheckForBlock(x,y) then
            if world.TestForBlock(x,y,"air") then
                if (not world.TestForBlock(x-1,y,"air")) or (not world.TestForBlock(x+1,y,"air")) or (not world.TestForBlock(x,y-1,"air")) or (not world.TestForBlock(x,y+1,"air")) then
                    local old = self.MeetingSolid(0,0)
                    world.PlaceBlock(x,y,id)
                    if not old then
                        if self.MeetingSolid(0,0) then
                            world.PlaceBlock(x,y,"air")
                            return 
                        end
                    end
                    return true
                end
            end
        end
        return false
    end


    function self.RemoveItemFromInventory(item,amount)
        item.count = item.count - amount
        self.CheckForEmptyItems()
    end

    function self.CheckForEmptyItems()
        for i=1,4 do
            local ci = self.inventory[i]
            for x=1,9 do
                if next(ci[x]) ~= nil then
                    if ci[x].count <= 0 then
                        self.inventory[i][x] = {}
                    end
                end
            end
        end
        self.UpdateHotbar()
    end

    hsp = 0
    vsp = 0

    hcap = 4
    hinc = 1

    function self.Update()
        if self.lockmovement then
            left = false
            right = false
            lclick = false
            rclick = false
            jump = false
        else
            left = Input.Left > 0
            right = Input.Right > 0
            lclick = Input.GetKey("Mouse0") > 0
            rclick = Input.GetKey("Mouse1") == 1
            jump = Input.GetKey("Space") == 1
        end
        escape = Input.GetKey("Escape") == 1
        openinv = Input.GetKey("E") == 1
        dropitem = Input.GetKey("Q") == 1
        leftctrl = Input.GetKey("LeftControl") > 0
        if left and right then
            left = false
            right = false
        end
        if left then
            if (hsp > -hcap) then hsp = hsp - hinc end
            if (hsp < -hcap) then hsp = -hcap end
        else
            if (hsp < 0) then hsp = hsp + hinc end
        end
        if right then
            if (hsp < hcap) then hsp = hsp + hinc end
            if (hsp > hcap) then hsp = hcap end
        else
            if (hsp > 0) then hsp = hsp - hinc end
        end
        if lclick then
            if (self.breaking[1] ~= mousex) or (self.breaking[2] ~= mousey) then
                self.breaking = {mousex,mousey}
                self.breaktimer = 0
            end
            self.breaktimer = self.breaktimer + 1
        else
            self.breaktimer = -1
        end
        if rclick then
            local citem = self.inventory[1][self.selectedslot]
            if next(citem) ~= nil then
                if world.itemsys[citem.id][3] == "block" then
                    local aaa = self.PlaceBlock(mousex,mousey,citem.id)
                    if aaa then
                        self.RemoveItemFromInventory(citem,1)
                    end
                    self.UpdateHotbar()
                else
                    if world.itemsys[citem.id][4] ~= false then
                        _G[world.itemsys[citem.id][4]]()
                    end
                end
            end
        end
        if dropitem then
            local citem = self.inventory[1][self.selectedslot]
            if next(citem) ~= nil then
                if leftctrl then
                    rettable = CreateItemEntities(citem,self.x,self.y+20,120)
                    for i=1,#rettable do
                        rettable2 = ToVector(math.deg(math.atan2(camera.y+Input.MousePosY - self.sprite.head.absy-8, camera.x+Input.MousePosX - self.sprite.head.absx)),6)
                        rettable[i].hsp = rettable2[1]
                        rettable[i].vsp = rettable2[2]
                    end
                    self.RemoveItemFromInventory(citem,citem.count)
                else
                    ent = CreateItemEntity(citem,self.x,self.y+20,120)
                    rettable = ToVector(math.deg(math.atan2(camera.y+Input.MousePosY - self.sprite.head.absy-8, camera.x+Input.MousePosX - self.sprite.head.absx)),6)
                    ent.hsp = rettable[1]
                    ent.vsp = rettable[2]
                    self.RemoveItemFromInventory(citem,1)
                end
                self.UpdateHotbar()
            end
        end
        whattile = world.tilesys[world.map[mousey][mousex]]
        if whattile == nil then
            self.breaktimer = -1
            breaktimer = 0
        else
            breaktimer = whattile[6]
            if not whattile[4] then self.breaktimer = 0 end
            if not whattile[3] then self.breaktimer = -1 end
        end
        if self.breaktimer == -1 then
            destroyblock.alpha = 0
        else
            destroyblock.alpha = 1
            stage = (self.breaktimer/breaktimer) * 10
            if stage < 10 then
                destroyblock.Set("blocks/destroy_stage_" .. tostring(math.floor(stage)))
            end
        end
        if self.breaktimer >= breaktimer then
            if whattile[5] then
                local woa = world.GetModifier(world.map[mousey][mousex],"drop")
                if woa then
                    thingy = CreateItem(woa,1)
                else
                    thingy = CreateItem(world.map[mousey][mousex],1)
                end
                CreateItemEntity(thingy,(mousex*32)-16,(mousey*32)-16)
            end
            world.PlaceBlock(mousex,mousey,"air")
            destroyblock.alpha = 0
            self.breaktimer = -1
        end
        if self.Grounded() then
            if (self.distancefallen > 2) then
                self.Hurt(self.distancefallen-2)
            end
            self.distancefallen = 0
            self.startingblock = false
            if jump then
                vsp = 6
            end
        else
            if (vsp < 0) then
                local currenty = math.floor((self.y-8)/32)+1
                if (self.startingblock == false) then
                    self.startingblock = currenty
                end
                self.distancefallen = self.startingblock - currenty
            else
                self.startingblock = false
                self.distancefallen = 0
            end
        end
        if (vsp > -10) then
            vsp = vsp - 0.40
        else
            vsp = -10
        end
        returnage = self.Move(hsp,vsp)
        hsp = returnage[1]
        vsp = returnage[2]

        if Input.GetKey("Alpha1") == 1 then
            self.selectedslot = 1
        end
        if Input.GetKey("Alpha2") == 1 then
            self.selectedslot = 2
        end
        if Input.GetKey("Alpha3") == 1 then
            self.selectedslot = 3
        end
        if Input.GetKey("Alpha4") == 1 then
            self.selectedslot = 4
        end
        if Input.GetKey("Alpha5") == 1 then
            self.selectedslot = 5
        end
        if Input.GetKey("Alpha6") == 1 then
            self.selectedslot = 6
        end
        if Input.GetKey("Alpha7") == 1 then
            self.selectedslot = 7
        end
        if Input.GetKey("Alpha8") == 1 then
            self.selectedslot = 8
        end
        if Input.GetKey("Alpha9") == 1 then
            self.selectedslot = 9
        end

        hotbarselection["realx"] = 120 + (self.selectedslot*40)
        if escape then
            if self.invopen then
                self.HideInventory()
            else
                State("DONE")
            end
        end
        if openinv then
            if self.invopen then
                self.HideInventory()
            else
                self.ShowInventory()
            end
        end

        if self.invopen then
            if self.incursor ~= false then
                self.incursorsprite[1].alpha = 1
                self.incursorsprite[1].Set(world.itemsys[self.incursor.id][1])
                self.incursorsprite[1].Scale(world.itemsys[self.incursor.id][5],world.itemsys[self.incursor.id][5])
                if self.incursor.count <= 1 then
                    self.incursorsprite[2][1].SetText("[instant]")
                    self.incursorsprite[2][2].SetText("[instant]")
                else
                    self.incursorsprite[2][1].SetText("[instant][font:Minecraft]" .. self.incursor.count)
                    self.incursorsprite[2][2].SetText("[instant][font:Minecraft]" .. self.incursor.count)
                end
            else
                self.incursorsprite[1].alpha = 0
                self.incursorsprite[2][1].SetText("[instant]")
                self.incursorsprite[2][2].SetText("[instant]")
            end
            self.incursorsprite[1]["realx"] = Input.MousePosX
            self.incursorsprite[1]["realy"] = Input.MousePosY
            ind = camera.GetTextIndex(self.incursorsprite[2][1])
            ind2 = camera.GetTextIndex(self.incursorsprite[2][2])
            if self.incursor then
                if self.incursor.count > 9 then
                    camera.attachedtext[ind ][2][1] = Input.MousePosX + 8  - 14
                    camera.attachedtext[ind2][2][1] = Input.MousePosX + 10 - 14
                else
                    camera.attachedtext[ind ][2][1] = Input.MousePosX + 8
                    camera.attachedtext[ind2][2][1] = Input.MousePosX + 10
                end
            else
                camera.attachedtext[ind ][2][1] = Input.MousePosX + 8
                camera.attachedtext[ind2][2][1] = Input.MousePosX + 10
            end
            camera.attachedtext[ind ][2][2] = Input.MousePosY - 20
            camera.attachedtext[ind2][2][2] = Input.MousePosY - 22
            self.hoveredover = false
            for i=1,4 do
                for x=1,9 do
                    local aax = 140 + (x*36)
                    local aay = 294-(i*36)
                    if (i == 1) then
                        aay = 106
                    end
                    if (Input.MousePosX > aax-16) and (Input.MousePosX < aax+16) then
                        if (Input.MousePosY > aay-16) and (Input.MousePosY < aay+16) then
                            self.hoveredover = {x,i}
                            break
                        end
                    end
                end
            end
            if self.hoveredover then
                self.hovercursorsprite.alpha = 1
                local aax = 140 + (self.hoveredover[1]*36)
                local aay = 294 - (self.hoveredover[2]*36)
                if (self.hoveredover[2] == 1) then
                    aay = 106
                end
                self.hovercursorsprite["realx"] = aax
                self.hovercursorsprite["realy"] = aay
            else
                self.hovercursorsprite.alpha = 0
            end
            if (Input.GetKey("Mouse0") == 1) then
                if self.hoveredover then
                    --local temp = CreateItem(self.inventory[self.hoveredover[2]][self.hoveredover[1]].id,self.inventory[self.hoveredover[2]][self.hoveredover[1]].count,self.inventory[self.hoveredover[2]][self.hoveredover[1]].nbt)
                    local temp = self.inventory[self.hoveredover[2]][self.hoveredover[1]]
                    if not self.incursor then
                        self.inventory[self.hoveredover[2]][self.hoveredover[1]] = {}
                        self.incursor = temp
                    else
                        self.inventory[self.hoveredover[2]][self.hoveredover[1]] = self.incursor
                        self.incursor = temp
                    end
                    if next(self.incursor) == nil then
                        self.incursor = false
                    end
                    self.UpdateHotbar()
                    self.UpdateInventory()
                end
            end
        end

        camera.x = lerp(camera.x,self.x-240,1/10)
        camera.y = lerp(camera.y,self.y-240,1/10)
        if (camera.x+Input.MousePosX - self.sprite.head.absx) < 0 then
            if cset == 0 then
                self.sprite.right_leg.Set("player/leg_left_inner","Player_Back")
                self.sprite.left_leg.Set("player/leg_right","Player_Top")
                self.sprite.right_arm.Set("player/arm_left_inner","Player_Back")
                self.sprite.body.Set("player/body_right","Player")
                self.sprite.left_arm.Set("player/arm_right","Player_Top")
                self.sprite.head.Set("player/head_left")
                cset = 1
            end
        else
            if cset == 1 then
                self.sprite.right_leg.Set("player/leg_right_inner","Player_Back")
                self.sprite.left_leg.Set("player/leg_left","Player_Top")
                self.sprite.right_arm.Set("player/arm_right_inner","Player_Back")
                self.sprite.body.Set("player/body_left","Player")
                self.sprite.left_arm.Set("player/arm_left","Player_Top")
                self.sprite.head.Set("player/head_right")
                cset = 0
            end
        end
        self.sprite.left_leg.x = self.x
        self.sprite.left_leg.y = self.y
        self.sprite.head.rotation = math.deg(math.atan2(camera.y+Input.MousePosY - self.sprite.head.absy-8, camera.x+Input.MousePosX - self.sprite.head.absx)) + (cset*180)
    end
    return self
end)()