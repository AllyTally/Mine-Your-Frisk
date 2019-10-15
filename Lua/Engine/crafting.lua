return (function()
    local self = {}

    self.recipes = {
        -- {recipe, definitions, {item id, count, nbt}, type}
        -- type
        -- 0: normal
        -- 1: shapeless
        {{
            {"#","#"},
            {"#","#"}
        }, {["#"]={"dirt",1},}, {"dirt",9}, 0}
    }

    function self.CompareItem(realitem,fakeitem)
        return realitem.id == fakeitem
    end

    function self.VerifyRecipe(recipe_table)
        for i=1, #self.recipes do -- Loop through all recipes
            possiblematch = true
            for offsetx=2,0,-1 do       -- hey we gotta make sure it works
                for offsety=2,0,-1 do   -- everywhere in the crafting grid
                    for y=1, #recipe_table do        -- Loop through all slots in the item grid
                        for x=1, #recipe_table[1] do -- Loop through all slots in the item grid
                            if self.recipes[i][1][y+offsety] then                -- If the slot we're checking for exists in the recipe
                                if self.recipes[i][1][y+offsety][x+offsetx] then -- If the slot we're checking for exists in the recipe
                                    if recipe_table[y][x].id == self.recipes[i][2][self.recipes[i][1][y+offsety][x+offsetx]][1] then -- If the ID of the table passed is the same as the ID in the current slot we're checking in the recipe
                                        -- Oh, hey! The item matches!
                                    else
                                        possiblematch = false -- Nope, the item doesn't match, meaning the whole recipe is wrong.
                                    end
                                end
                            end
                        end
                    end
                    if possiblematch then -- We got through it without a wrong item, meaning the recipe is correct.
                        DEBUG("HEY WAIT SOMETHING MATCHED ITS ID " .. i)
                        return self.recipes[i] -- Return the recipe!
                    end
                end
            end
        end
        return false -- No recipes returned, meaning whatever's in the grid isn't a valid recipe.
    end
    return self
end)()

--[[
    Loop through all recipes first                (lets assume it's just a 3x3 grid of dirt)
        Loop through each slot in the item grid
            Try and match item to the thing in the recipe
            If everything works, return the correct item
            Else, probably return either air or false
]]--