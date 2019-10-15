return (function()
    local self = {}

    self.cap = 255
    self.screenwidth = 21

    self.worldwidth = 200

    self.tilesys = {}
    self.tilemodifiers = {}
    self.itemsys = {}


    --             id                sprite         solidity    interactability  mineability    drops thing  mine time   tools        tool required

    self.tilesys["air"        ] = {"dirt"      ,  false,      false,            false,        false,       0  ,         false     ,  false              }
    self.tilesys["stone"      ] = {"stone"     ,  true ,      true ,            true ,        true ,       180,         "#pickaxe",  true               }
    self.tilesys["grass"      ] = {"grass_side",  true ,      true ,            true ,        true ,       60 ,         "#shovel" ,  false              }
    self.tilesys["dirt"       ] = {"dirt"      ,  true ,      true ,            true ,        true ,       60 ,         "#shovel" ,  false              }
    self.tilesys["log_oak"    ] = {"log_oak"   ,  true ,      true ,            true ,        true ,       120,         "#axe"    ,  false              }
    self.tilesys["leaves_oak" ] = {"leaves_oak",  true ,      true ,            true ,        false,       40 ,         "#shears" ,  false              }
    self.tilesys["coal_ore"   ] = {"coal_ore"  ,  true ,      true ,            true ,        true ,       180,         "#pickaxe",  true               }
    self.tilesys["iron_ore"   ] = {"iron_ore"  ,  true ,      true ,            true ,        true ,       180,         "#pickaxe",  "#pickaxe_1"       }
    self.tilesys["bedrock"    ] = {"bedrock"   ,  true ,      true ,            false,        true ,       10 ,         false     ,  false              }
    self.tilesys["gravel"     ] = {"gravel"    ,  true ,      true ,            true ,        true ,       60 ,         "#shovel" ,  false              }

    self.tilemodifiers["air"] = {}
    self.tilemodifiers["air"]["invisible"] = true

    self.tilemodifiers["leaves_oak"] = {}
    self.tilemodifiers["leaves_oak"]["color"] = {95,159,53}
    self.tilemodifiers["leaves_oak"]["transparent"] = true

    self.tilemodifiers["gravel"] = {}
    self.tilemodifiers["gravel"]["gravity"] = true

    self.tilemodifiers["grass"] = {}
    self.tilemodifiers["grass"]["drop"] = "dirt"

    --             id                 sprite                 max stack     type         right click function   size
    self.itemsys["wood_pickaxe"] = {"items/wood_pickaxe",  1,            "item",      false,                   1}
    self.itemsys["snowball"] =     {"items/snowball",      16,           "item",      "ThrowSnowball",         2}

    for k, v in pairs(self.tilesys) do
        if v[5] then
            self.itemsys[k] = {"renders/" .. v[1], 64, "block" , false, 0.112}
        end
    end

    function self.GetModifier(tile,modifier,default)
        if self.tilemodifiers[tile] then
            if self.tilemodifiers[tile][modifier] then
                return self.tilemodifiers[tile][modifier]
            end
        end
        if default == nil then return false else return default end
    end
    self.ores = {
    --   rarity     block         cluster max      max spawn height
        {2,         "coal_ore",   10,              255             },
        {1,         "iron_ore",   4 ,              255             },
        {50,        "bedrock",    0 ,              3               },
        {2,         "dirt",       10,              255             },
        {2,         "gravel",     10,              255             },
    }

    local tree = {
    {"air","leaves_oak","leaves_oak","leaves_oak","air"},
    {"air","leaves_oak","leaves_oak","leaves_oak","air"},
    {"leaves_oak","leaves_oak","leaves_oak","leaves_oak","leaves_oak"},
    {"leaves_oak","leaves_oak","leaves_oak","leaves_oak","leaves_oak"},
    {"air","air","log_oak","air","air"},
    {"air","air","log_oak","air","air"},
    {"air","air","log_oak","air","air"}
    }

    self.structures = {
    --   rarity     structure   offset
        {10,        tree,       {-2, 0}  }
    }

    self.biomes = {}
    self.biomes["plains"] = {0,2}

    function chance(ch)
        return (math.random(100) < (ch+1))
    end

    function table.reverse(arrp)
        arr = { table.unpack(arrp) }
    	local i, j = 1, #arr
    	while i < j do
    		arr[i], arr[j] = arr[j], arr[i]
    		i = i + 1
    		j = j - 1
        end
        return arr
    end

    function self.CheckForBlock(x,y)
        if self.map[y] then
            if self.map[y][x] then
                return true
            end
        end
        return false
    end

    function self.GetBlock(x,y)
        if not self.CheckForBlock(x,y) then return "air" end
        return self.map[y][x]
    end

    function self.TestForBlock(x,y,tile)
        return self.GetBlock(x,y) == tile
    end

    function self.PlaceBlock(x,y,tile)
        self.PlaceBlockSilent(x,y,tile)
        self.ModifyTile(world.GetTileMapFromCoords(x,y)[1],tile)
    end

    function self.PlaceBlockSilent(x,y,tile)
        if self.map[y] then
            if self.map[y][x] then
                self.map[y][x] = tile
            end
        end
    end

    function self.Solid(tile)
        if self.tilesys[tile] then
            return self.tilesys[tile][2]
        else
            return true
        end
    end

    function self.Generate()
        self.map = {{}}
        self.mapheights = {}
        self.tilemap = { }
        for i=1,self.worldwidth do
            if (#self.mapheights != 0) and (#self.mapheights != 0) then
                thingtouse = self.mapheights[i-1]
            else
                thingtouse = math.random(60,140)
            end
            table.insert(self.mapheights,math.random(thingtouse-2,thingtouse+2))
        end
        str = ""
        for y=self.cap,1,-1 do
            self.map[y] = {}
            for x=1,self.worldwidth do
                if y > self.mapheights[x] then
                    self.map[y][x] = "air"
                else
                    self.map[y][x] = "stone"
                    if self.map[y+1] then
                        if self.map[y+1][x] == "air" then
                            thing = math.random(1,2)
                            if thing == 1 then
                                self.map[y+1][x] = "dirt"
                                self.map[y+2][x] = "grass"
                                topper = 3
                            else
                                self.map[y+1][x] = "dirt"
                                self.map[y+2][x] = "dirt"
                                self.map[y+3][x] = "grass"
                                topper = 4
                            end
                        end
                    end
                    for i=1,#self.ores do
                        c_ore = self.ores[i]
                        if (y <= c_ore[4]) then
                            if chance(c_ore[1]) then
                                self.map[y][x] = c_ore[2]
                                for a=1,c_ore[3] do
                                    xrand = x+math.random(-3,3)
                                    yrand = y+math.random(-3,3)
                                    if self.map[yrand] then
                                        if self.map[xrand] then
                                            self.map[yrand][xrand] = c_ore[2]
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        for y=1,self.cap do
            for x=1,self.worldwidth do
                if self.map[y+1] then
                    if (self.map[y+1][x] == "air") and (self.map[y][x] ~= "air") then
                        thing = true
                        if self.tilemodifiers[self.map[y][x]] then
                            if self.tilemodifiers[self.map[y][x]]["transparent"] then
                                thing = false
                            end
                        end
                        if thing then
                            for i=1,#self.structures do
                                c_str = self.structures[i]
                                if chance(c_str[1]) then  
                                    usestruct = table.reverse(c_str[2])
                                    for y2=1,#usestruct do
                                        for x2=1,#usestruct[1] do
                                            if usestruct[y2][x2] ~= "air" then
                                                self.PlaceBlockSilent(x+x2-1+c_str[3][1],y+y2,usestruct[y2][x2])
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if y==1 then
                    self.PlaceBlockSilent(x,1,"bedrock")
                end
            end
        end
    end

    function self.SpawnTiles()
        self.tilemap = { }
        for y=1,self.cap do
            self.tilemap[y] = {}
            for x=1, self.screenwidth do
                self.index = self.map[y][x]
                if self.index ~= "air" then
                    tile = CreateSprite("blocks/" .. self.tilesys[self.index][1], "Tiles")
                    tile.x = ((x - 1) * 16) + 8
                    tile.y = ((y-1) * 16) + 8
                    --if (self.mapheights[x] - y) > 2 then
                    --    rip = (-((self.mapheights[x] - y) /15) + 1) + 0.1
                    --    tile.color = {rip,rip,rip}
                    --end
                    if self.tilemodifiers[self.index] then
                        if self.tilemodifiers[self.index]["color"] then
                            tile.color32 = {95,159,53}
                        end
                    end
                    self.tilemap[y][x] = tile
                end
            end
        end
    end

    function self.SpawnScreenTiles()
        for y=1,16 do
            self.tilemap[y] = {}
            for x=1,21 do
                self.index = self.map[y][x]
                tile = CreateSprite("blocks/" .. self.tilesys[self.index][1], "Tiles")
                tile.x = ((x - 1) * 32) + 16
                tile.y = ((y-1) * 32) + 16
                tile.Scale(2,2)
                --if (self.mapheights[x] - y) > 2 then
                --    rip = (-((self.mapheights[x] - y) /15) + 1) + 0.1
                --    tile.color = {rip,rip,rip}
                --end
                if self.tilemodifiers[self.index] then
                    if self.tilemodifiers[self.index]["color"] then
                        tile.color32 = {95,159,53}
                    end
                end
                self.tilemap[y][x] = {tile,x,y}
            end
        end
    end

    function self.Update()
        --if Input.Confirm == 1 then
            self.RecycleTiles()
            --DEBUG(self.tilemap[1][1][1].x)
        --end
    end

    function self.ModifyTile(tile,block)
        if block == nil then
            tile.Set("blocks/bone_block_side")
            tile.alpha = 1
            tile.color32 = {255,255,255}
        else
            tile.Set("blocks/" .. self.tilesys[block][1])
            tile.alpha = 1
            tile.color32 = {255,255,255}
            if self.tilemodifiers[block] then
                if self.tilemodifiers[block]["color"] then
                    tile.color32 = self.tilemodifiers[block]["color"]
                end
                if self.tilemodifiers[block]["invisible"] then
                    tile.alpha = 0
                end
            end
        end
    end

    function self.GetTileMapFromCoords(px,py)
        for y=1,#self.tilemap do
            for x=1,#self.tilemap[1] do
                if self.tilemap[y][x][2] == px then
                    if self.tilemap[y][x][3] == py then
                        return self.tilemap[y][x]
                    end
                end
            end
        end
        return false
    end

    function self.RecycleTiles()
        for y=1,#self.tilemap do
            for x=1,#self.tilemap[1] do
                if (self.tilemap[y][x][1].x)+16 < camera.x then
                    self.tilemap[y][x][2] = self.tilemap[y][x][2] + 21
                    self.tilemap[y][x][1].x = ((self.tilemap[y][x][2] - 1) * 32) + 16
                    self.tilemap[y][x][1].y = ((self.tilemap[y][x][3] - 1) * 32) + 16
                    self.ModifyTile(self.tilemap[y][x][1],self.map[self.tilemap[y][x][3]][self.tilemap[y][x][2]])
                end
                if (self.tilemap[y][x][1].x) > camera.x+640+16 then
                    self.tilemap[y][x][2] = self.tilemap[y][x][2] - 21
                    self.tilemap[y][x][1].x = ((self.tilemap[y][x][2] - 1) * 32) + 16
                    self.tilemap[y][x][1].y = ((self.tilemap[y][x][3] - 1) * 32) + 16
                    self.ModifyTile(self.tilemap[y][x][1],self.map[self.tilemap[y][x][3]][self.tilemap[y][x][2]])
                end
                if (self.tilemap[y][x][1].y)+16 < camera.y then
                    self.tilemap[y][x][3] = self.tilemap[y][x][3] + 16
                    self.tilemap[y][x][1].x = ((self.tilemap[y][x][2] - 1) * 32) + 16
                    self.tilemap[y][x][1].y = ((self.tilemap[y][x][3] - 1) * 32) + 16
                    self.ModifyTile(self.tilemap[y][x][1],self.map[self.tilemap[y][x][3]][self.tilemap[y][x][2]])
                end
                if (self.tilemap[y][x][1].y) > camera.y+480+16 then
                    self.tilemap[y][x][3] = self.tilemap[y][x][3] - 16
                    self.tilemap[y][x][1].x = ((self.tilemap[y][x][2] - 1) * 32) + 16
                    self.tilemap[y][x][1].y = ((self.tilemap[y][x][3] - 1) * 32) + 16
                    self.ModifyTile(self.tilemap[y][x][1],self.map[self.tilemap[y][x][3]][self.tilemap[y][x][2]])
                end
            end
        end
    end

    return self
end)()