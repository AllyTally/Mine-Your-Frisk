enemies = {}
music = "music/game/calm1"
unescape = true

CreateLayer("Tiles","Top")
CreateLayer("SelectionCursor","Tiles")
CreateLayer("DestroyUI","SelectionCursor")
CreateLayer("Entities","DestroyUI")
CreateLayer("Player_Back","Entities")
CreateLayer("Player","Player_Back")
CreateLayer("Player_Top","Player")
CreateLayer("GUI","Player_Top")
CreateLayer("HotbarSel","GUI")
CreateLayer("GUIItems","HotbarSel")
CreateLayer("GUIItemsText","GUIItems")
CreateLayer("Inventory","GUIItemsText")
CreateLayer("InventoryItems","Inventory")
CreateLayer("InventoryItemText","InventoryItems")
CreateLayer("Hover","InventoryItemText")
CreateLayer("SuperTop","Hover")

--local _CreateSprite = CreateSprite
--allsprites = {}
--
--function CreateSprite(sprite,layer)
--    local a = _CreateSprite(sprite,layer)
--    table.insert(allsprites,a)
--    return a
--end

entities = {}

blockcursor = CreateSprite("blockselect","SelectionCursor")
destroyblock = CreateSprite("blocks/destroy_stage_0","DestroyUI")
destroyblock.Scale(2,2)

camera = require "Engine/camera"
world = require "Engine/world"
crafting = require "Engine/crafting"

hotbar = CreateSprite("hotbar","GUI")
hotbarselection = CreateSprite("hotbarselection","HotbarSel")
hotbar.y = 40
hotbarselection.y = 40
camera.Attach(hotbar)
camera.Attach(hotbarselection)

hovercursorsprite = CreateSprite("invhover","Hover")
camera.Attach(hovercursorsprite)

hotbarsprites = {}

allslots = {}

function CreateInventory(x,y,width,height)
    local inventory = {}
    inventory.slots = {{}}
    inventory.slotdisplay = {}
    function inventory.Hide()
        for i=1,#inventory.slotdisplay do
            inventory.slotdisplay[i].Remove()
        end
    end
    function inventory.Show()
        for _y=1,height do
            inventory.slotdisplay[_y] = {}
            for _x=1,width do
                --CreateInventorySlot(x+(width*36),y+(height*36))
                inventory.slotdisplay[_y][_x] = CreateInventorySlot(x+(_x*36),y+(_y*36))
            end
        end
    end
    function inventory.InsertItem(x,y,item)
        inventory.slot[y][x] = item
        inventory.slotdisplay[y][x] = item
    end
    return inventory
end

function CreateInventorySlot(x,y,add,take,ghost)
    if add == nil then add = true end
    if take == nil then take = true end
    if ghost == nil then ghost = false end
    local slot = {}
    slot.x = x
    slot.y = y
    slot.sprite = CreateInventoryItemDisplay(x,y,"InventoryItems","InventoryItemText",true)
    slot.add = add
    slot.take = take
    slot.ghost = ghost
    slot.item = {}
    function slot.Hide()
        slot.sprite[1].alpha = 0
        slot.sprite[2][1].alpha = 0
        slot.sprite[2][2].alpha = 0
    end
    function slot.Show()
        slot.sprite[1].alpha = 1
        slot.sprite[2][1].alpha = 1
        slot.sprite[2][2].color = {0.3,0.3,0.3,1}
        slot.Update()
    end
    slot.Hide()
    table.insert(allslots,slot)
    function slot.Remove()
        for i=#allslots,1,-1 do
            if allslots[i] == slot then
                table.remove(allslots,i)
                camera.Detach(slot.sprite[1])
                slot.sprite[1].Remove()
                camera.DetachText(slot.sprite[2][1])
                camera.DetachText(slot.sprite[2][2])
                slot.sprite[2][1].DestroyText()
                slot.sprite[2][2].DestroyText()
            end
        end
    end
    function slot.Update()
        if next(slot.item) ~= nil then
            slot.sprite[1].alpha = 1
            slot.sprite[1].Set(world.itemsys[slot.item.id][1])
            slot.sprite[1].Scale(world.itemsys[slot.item.id][5],world.itemsys[slot.item.id][5])
            if slot.item.count <= 1 then
                slot.sprite[2][1].SetText("[instant]")
                slot.sprite[2][2].SetText("[instant]")
            else
                slot.sprite[2][1].SetText("[instant][font:Minecraft]" .. slot.item.count)
                slot.sprite[2][2].SetText("[instant][font:Minecraft]" .. slot.item.count)
                ind =  camera.GetTextIndex(slot.sprite[2][1])
                ind2 = camera.GetTextIndex(slot.sprite[2][2])
                if slot.item.count > 9 then
                    camera.attachedtext[ind ][2][1] = slot.x + 8 - 14
                    camera.attachedtext[ind2][2][1] = slot.x + 10 - 14
                else
                    camera.attachedtext[ind ][2][1] = slot.x + 8
                    camera.attachedtext[ind2][2][1] = slot.x + 10
                end
            end
        else
            slot.sprite[1].alpha = 0
            slot.sprite[2][1].SetText("[instant]")
            slot.sprite[2][2].SetText("[instant]")
        end
    end
    return slot
end

function CreateInventoryItemDisplay(x,y,layer,layer2,attach)
    spr = CreateSprite("blocks/dirt",layer)
    spr.Scale(2,2)
    spr.alpha = 0
    spr.x = x
    spr.y = y
    txt2 = CreateText("", {0,0}, 999, layer2, -1)
    txt2.progressmode = "none"
    txt2.color = {0.3,0.3,0.3}
    txt2.SetText("[instant][font:Minecraft]")
    txt2.HideBubble()
    txt2.x = x+10
    txt2.y = y-22
    txt = CreateText("", {0,0}, 999, layer2, -1)
    txt.progressmode = "none"
    txt.HideBubble()
    txt.color = {1,1,1}
    txt.x = x+8
    txt.y = y-20
    txt.SetText("[instant][font:Minecraft]")
    if attach then
        camera.Attach(spr)
        camera.AttachText(txt2,{txt2.x,txt2.y})
        camera.AttachText(txt,{txt.x,txt.y})
    end
    return {spr,{txt,txt2}}
end

for i=1,9 do 
    spr = CreateSprite("blocks/dirt","GUIItems")
    spr.x = 120 + (i*40)
    spr.y = 40
    spr.Scale(2,2)
    spr.alpha = 0
    camera.Attach(spr)
    txt2 = CreateText("", {0,0}, 999, "GUIItemsText", -1)
    txt2.progressmode = "none"
    txt2.color = {0.3,0.3,0.3,0}
    txt2.x = 130 + (i*40)
    txt2.y = 18
    txt2.SetText("[instant][font:Minecraft]")
    txt2.HideBubble()
    txt = CreateText("", {0,0}, 999, "GUIItemsText", -1)
    txt.progressmode = "none"
    txt.x = 128 + (i*40)
    txt.y = 20
    txt.HideBubble()
    txt.color = {1,1,1,0}
    txt.SetText("[instant][font:Minecraft]")
    camera.AttachText(txt2,{txt2.x,txt2.y})
    camera.AttachText(txt,{txt.x,txt.y})
    table.insert(hotbarsprites,{spr,{txt,txt2}})
end

function EncounterStarting()
    --Audio.Stop()
    Audio.Volume(1)
    State("NONE")
    world.Generate()
    --world.SpawnTiles()
    --offset = _world.mapheights[1] - 240
    world.SpawnScreenTiles()
    --world.SpawnTiles()
    player = require "Engine/player"
    camera.y = player.y - 240
    --player_entity = player.Spawn()
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function string.split(inputstr, sep, isPattern)
    if sep == nil then
        sep = "%s"
    end
    local t = { }
    if isPattern then
        while string.find(inputstr, sep) ~= nil do
            local matchrange = { string.find(inputstr, sep) }
            local preceding = string.sub(inputstr, 0, matchrange[1] - 1)
            table.insert(t, preceding ~= "" and preceding or nil)
            inputstr = string.sub(inputstr, matchrange[2] + 1)
        end
        table.insert(t, inputstr)
    else
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
        end
    end
    return t
end

function GetModName()
    local testError = function()
        CreateProjectile("asdbfiosdjfaosdijcfiosdjsdo", 0, 0)
    end

    local _, output = xpcall(testError, debug.traceback)

    -- Find the position of "Sprites/asdbfiosdjfaosdijcfiosdjsdo"
    local SpritesFolderPos = output:find("asdbfiosdjfaosdijcfiosdjsdo") - 10
    output = output:sub(1, SpritesFolderPos)

    local paths = string.split(output, "Attempted to load ", true)
    return paths[#paths]
end

function CreateItem(id,amount,nbt)
    local item = dofile(GetModName() .. "/Lua/Engine/inventory_item.lua")
    item.id = id
    if amount then item.count = amount end
    if nbt then item.nbt = nbt end
    return item
end

function CreateItemEntities(item,x,y,delay) -- This function loops through the item count and calls the function below
    itemtable = {}
    thing = CreateItemEntity(item,x,y,delay)
    thing.count = item.count
    thing.UpdateItem()
    table.insert(itemtable,thing)
    return itemtable
end

function CreateItemEntity(item,x,y,delay) -- This function ignores the item count
    local newitem = CreateEntity("item",x,y)
    newitem.id = item.id
    newitem.nbt = item.nbt
    if delay then
        newitem.pickupdelay = delay
    end
    newitem.UpdateItem()
    return newitem
end

function CreateItemFromEntity(itementity) -- This function ignores the item count
    local item = CreateItem(itementity.id)
    if itementity.count then item.count = itementity.count end 
    if itementity.nbt then item.nbt = itementity.nbt end
    return item
end

function CreateEntity(entity,x,y,nbt)
    local ent = dofile(GetModName() .. "/Lua/Engine/Entities/" .. entity .. ".lua")
    ent.x = x
    ent.y = y
    if nbt then ent.nbt = nbt end
    table.insert(entities,ent)
    return ent
end

function DestroyEntity(entity)
    for i=#entities,1,-1 do
        if entity == entities[i] then
            if entities[i].sprite then
                if type(entities[i].sprite) == "table" then
                    for x=1,#entities[i].sprite do
                        entities[i].sprite[x].Remove()
                    end
                else
                    entities[i].sprite.Remove()
                end
            end
            table.remove(entities,i)
        end
    end
end

function ToVector(angle,speed)
    local x = (speed * math.cos(math.rad(angle)))
    local y = (speed * math.sin(math.rad(angle)))
    return {x,y}
end

function ThrowSnowball()
    ent = CreateEntity("snowball",player.x,player.y+40)
    rettable = ToVector(math.deg(math.atan2(camera.y+Input.MousePosY - player.sprite.head.absy-8, camera.x+Input.MousePosX - player.sprite.head.absx)),8)
    ent.hsp = rettable[1]
    ent.vsp = rettable[2]*2
    player.RemoveItemFromInventory(player.inventory[1][player.selectedslot],1)
end

function TableEquals(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

function CompareInventoryItems(item1,item2)
    if item1.id != item2.id then return false end
    return TableEquals(item1.nbt,item2.nbt)
end

function rect(point1,point2,point3,point4)
    local _rect
    _rect = {}
    _rect.X1 = point1
    _rect.X2 = point2
    _rect.Y1 = point3
    _rect.Y2 = point4
    return _rect
end

function isColliding(r1,r2)
    return ((r1.X1 < r2.X2) and (r1.X2 > r2.X1) and (r1.Y1 < r2.Y2) and (r1.Y2 > r2.Y1))
end

function GiveItemQuick(id,count)
    if count == nil then count = 1 end
    player.GiveItem(CreateItem(id,count))
end

function Update()
    mousex = math.floor((camera.x+Input.MousePosX)/32)+1
    mousey = math.floor((camera.y+Input.MousePosY)/32)+1
    blockcursor.MoveTo((mousex*32)-16,(mousey*32)-16)
    destroyblock.MoveTo((mousex*32)-16,(mousey*32)-16)
    if mousex < 1 then mousex = 1 end
    if mousey < 1 then mousey = 1 end
    if Input.GetKey("R") == 1 then
        GiveItemQuick("dirt",64)
        GiveItemQuick("snowball",16)
        a = CreateInventory(20,20,4,4)
        a.Show()
--        thingy = CreateItem("dirt",64)
--        woaslot = CreateInventorySlot(356,354)
--        woaslot.item = thingy
--        woaslot.Show()
--        thingy = CreateItem("dirt",64)
--        woaslot = CreateInventorySlot(392,354)
--        woaslot.item = thingy
--        woaslot.Show()
--        thingy = CreateItem("dirt",64)
--        woaslot = CreateInventorySlot(356,318)
--        woaslot.item = thingy
--        woaslot.Show()
--        thingy = CreateItem("dirt",64)
--        woaslot = CreateInventorySlot(392,318)
--        woaslot.item = thingy
--        woaslot.Show()
    end
    player.Update()
    for i=#entities,1,-1 do
        entities[i].Update()
    end
    hovercursorsprite.alpha = 0
    if player.invopen then
        for i=#allslots,1,-1 do
            local currentslotloop = allslots[i]
            --currentslotloop.Show()
            if (Input.MousePosX > currentslotloop.x-16) and (Input.MousePosX < currentslotloop.x+16) then
                if (Input.MousePosY > currentslotloop.y-16) and (Input.MousePosY < currentslotloop.y+16) then
                    hovercursorsprite["realx"] = currentslotloop.x
                    hovercursorsprite["realy"] = currentslotloop.y
                    hovercursorsprite.alpha = 1
                    if (Input.GetKey("Mouse0") == 1) then
                        local temp = currentslotloop.item
                        if not player.incursor then
                            currentslotloop.item = {}
                            player.incursor = temp
                        else
                            currentslotloop.item = player.incursor
                            player.incursor = temp
                        end
                        if next(player.incursor) == nil then
                            player.incursor = false
                        end
                        player.UpdateHotbar()
                        player.UpdateInventory()
                        currentslotloop.Update()
                    end
                    break
                end
            end
        end
    else
--        for i=#allslots,1,-1 do
--            local currentslotloop = allslots[i]
--            currentslotloop.Hide()
--        end
    end
    camera.Update()
    world.Update()
end