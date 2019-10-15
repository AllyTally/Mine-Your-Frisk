-- https://github.com/Luigimaster1/cyf-console/
-- written by ally
-- please dont steal and claim as your own

local self = {}


-- configurable stuffles --

self.cursorcolor = "00FF00"
self.lines = 10
self.font = "arial"

-- hey, don't edit under this line unless youre going to change keybinds and all

self.active = false
self.history = {}
self.showhistory = {}
for i=1, self.lines do
    table.insert(self.showhistory," ")
end
self.lastkey = ""
self.keytimer = 0
self.inputstr = ""
self.capson = false
self.svcheats = 0
self.noclip = false
self.cursor = 0
self.historycursor = 0
self.toggled = false

self.keys = {
    "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "Alpha1", "Alpha2", "Alpha3", "Alpha4", "Alpha5", "Alpha6", "Alpha7", "Alpha8", "Alpha9", "Alpha0",
    "Backspace", "Space", "Period", "Exclaim", "At", "Hash", "Dollar", "Caret", "Ampersand", "Asterisk",
    "LeftParen", "RightParen", "Minus", "Plus", "Underscore", "Equals", "Colon", "Semicolon", "DoubleQuote", "Quote", "Return",
    "LeftBracket", "RightBracket", "Backslash", "Comma", "LeftArrow", "RightArrow", "UpArrow", "DownArrow", "Slash", "BackQuote"
}

self.letters = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}

self.overrides = {
["Space"] = " ",
["Alpha1"] = 1,
["Alpha2"] = 2,
["Alpha3"] = 3,
["Alpha4"] = 4,
["Alpha5"] = 5,
["Alpha6"] = 6,
["Alpha7"] = 7,
["Alpha8"] = 8,
["Alpha9"] = 9,
["Alpha0"] = 0,
["Period"] = ".",
["Exclaim"] = "!",
["At"] = "@",
["Hash"] = "#",
["Dollar"] = "$",
["Caret"] = "^",
["Ampersand"] = "&",
["Asterisk"] = "*",
["LeftParen"] = "(",
["RightParen"] = ")",
["Minus"] = "-",
["Plus"] = "+",
["Underscore"] = "-",
["Equals"] = "=",
["Colon"] = ":",
["Semicolon"] = ";",
["Quote"] = "'",
["LeftBracket"] = "ś",
["RightBracket"] = "]",
["Backslash"] = "\\",
["Comma"] = ",",
["Slash"] = "/",
["BackQuote"] = "~"
}

self.shifters = {
    ["1"] = "!",
    ["2"] = "@",
    ["3"] = "#",
    ["4"] = "$",
    ["5"] = "%",
    ["6"] = "^",
    ["7"] = "&",
    ["8"] = "*",
    ["9"] = "(",
    ["0"] = ")",
    ["'"] = "\"",
    ["]"] = "}",
    ["ś"] = "{",
    ["-"] = "_",
    ["."] = ">",
    [","] = "<",
    ["="] = "+",
    [";"] = ":",
    ["\\"] = "|",
    ["/"] = "?"
}

function __Update() end

function print(a)
    self.nprint(a)
    self.UpdateText()
end

function self.nprint(a)
    output = a
    if type(a) == "table" then
        output = self.TableDebugger(a)
    end
    table.insert(self.showhistory,output)
end

local _DEBUG = DEBUG
function DEBUG(a)
    if self.active then
        self.nprint(a)
        self.UpdateText()
    else
        _DEBUG(a)
    end
end

function self.CountCharacter(str,char)
    local t = {}
    local i = 0
    while true do
        i = string.find(str, char, i+1, true)
        if i == nil then break end
        table.insert(t, i)
    end
    return #t
end

function self.startsWith(str, start)
    return str:sub(1, #start) == start
end

function self.insert(str,index,char)
    return str:sub(1, index-1) .. char .. str:sub(index,str:len())
end

function self.trim(s)
    return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

-- Debugs a table's content. Cool function by RhenaudTheLukark
function self.TableDebugger(tab, nonest, nest)
    if nest == nil then nest = 1 end
    local result = "{\n"

    local first = true -- first is used to not create a comma on the first element of a line
    for k, v in pairs(tab) do
        -- If the key's a number, transforms it into a string
        if type(k) == "number" then k = "\"" .. tostring(k) .. "\"" end
        -- If the value is a string, keep the quotes
        if type(v) == "string" then v = "\"" .. tostring(v) .. "\"" end
        -- If the value is a table, call this function recursively
        if type(v) == "table" then
            if nonest then
                v = "(table)"
            else
                v = self.TableDebugger(v, false, nest + 1)
            end
        end

        v = tostring(k) .. " = " .. tostring(v) -- Add index of value

        -- Add comma and indents
        local stringToAdd = first and "" or ",\n"
        for i = 1, nest do stringToAdd = stringToAdd .. "    " end -- INDENTS!!!!!
        result = result .. stringToAdd .. v
        first = false
    end
    result = result .. "\n"
    for i = 1, nest - 1 do result = result .. "    " end -- INDENTS!!!!!
    if nest == 1 then print(result .. "}") else return result .. "}" end
end

function self.ParseString(string)
    local a,b = pcall(function() self.UnsafeParseString(string) end)
    if not a then
        local consolepos = b:find("): ") + 3
        self.nprint("[color:ff6666]" .. b:sub(consolepos,b:len()))
    end
end

function self.UnsafeParseString(stringa)
    local string = self.trim(stringa)
    string = string:gsub("ś","[")
    if self.startsWith(string, "sv_cheats") then
        local arg = string:sub(11,string:len())
        if arg == "" then
            self.nprint('"sv_cheats" = "' .. self.svcheats ..'" ( def. "0" ) notify replicated                                 - Allow cheats on server')
        else
            self.svcheats = arg
            self.nprint("[color:FFDD00]Server cvar 'sv_cheats' changed to " .. arg)
            self.nprint("[color:FFDD00]Server cvar 'sv_cheats' changed to " .. arg)
        end
    elseif self.startsWith(string, "noclip") then
        if tonumber(self.svcheats) ~= nil then
            if self.svcheats ~= 0 then
                local arg = string:sub(11,string:len())
                if arg == "" then
                    if self.noclip == false then
                        self.nprint('noclip ON')
                        self.noclip = true
                    else
                        self.nprint('noclip OFF')
                        self.noclip = false
                    end
                    Player.SetControlOverride(self.noclip)
                end
            end
        end
    else
        string = string:gsub("function Update", "function __Update")
        local a,b = load(string)
        if a then
            returnval = a()
            self.nprint(returnval)
        else
            local consolepos = b:find("): ") + 3
            self.nprint("[color:ff6666]" .. b:sub(consolepos,b:len()))
        end
    end
end

function self.TypeChar(character)
    if character == "Backspace" then
        if self.cursor > 0 then
            self.inputstr = self.inputstr:sub(1, self.cursor-1) .. self.inputstr:sub(self.cursor+1,self.inputstr:len())
            self.cursor = self.cursor - 1
        end
    elseif character == "LeftArrow" then
        if self.cursor > 0 then
            self.cursor = self.cursor - 1
        end
    elseif character == "RightArrow" then
        if self.cursor < self.inputstr:len() then
            self.cursor = self.cursor + 1
        end
    elseif character == "UpArrow" then
        if #self.history ~= 0 then
            if self.historycursor > 1 then
                self.historycursor = self.historycursor - 1
            end
            self.inputstr = self.history[self.historycursor]
            self.cursor = self.inputstr:len()
        end
    elseif character == "DownArrow" then
        if self.historycursor < #self.history+1 then
            self.historycursor = self.historycursor + 1
        end
        if self.historycursor == #self.history+1 then
            --self.inputstr = ""
        else
            self.inputstr = self.history[self.historycursor]
        end
        self.cursor = self.inputstr:len()
    elseif character == "Return" then
        local charscountedleftparen = self.CountCharacter(string.gsub(self.inputstr,[["([^"]+")]],""),"(")
        local charscountedrightparen = self.CountCharacter(string.gsub(self.inputstr,[["([^"]+")]],""),")")
        if (charscountedleftparen > charscountedrightparen) or (self.inputstr:sub(-1) == ";") or (Input.GetKey("LeftShift") > 0) or (Input.GetKey("RightShift") > 0) then
            self.inputstr = self.insert(self.inputstr,self.cursor+1,"\n")
            self.cursor = self.cursor + 1
        elseif self.inputstr:sub(-1) == "\\" then
            self.inputstr = self.insert(self.inputstr,self.cursor+1,"\\n")
            self.cursor = self.cursor + 2
        else
            self.cursor = 0
            table.insert(self.history,self.inputstr)
            self.historycursor = #self.history+1
            self.nprint("[color:AAAAAA]" .. self.inputstr)
            self.ParseString(self.inputstr)
            self.inputstr = ""
        end
    else
        local tempchar = character
        character = self.overrides[character]
        if character == nil then
            character = tempchar
        end
        character = tostring(character)
        if not self.capson then
            character = character:lower()
        end
        self.cursor = self.cursor + character:len()
        if (Input.GetKey("LeftShift") > 0) or (Input.GetKey("RightShift") > 0) then
            for i=1, #self.letters do
                if self.letters[i] == character:upper() then
                    character = character:upper()
                    break
                end
            end
            local tempchar = character
            character = self.shifters[character]
            if character == nil then
                character = tempchar
            end
        end
        self.inputstr = self.insert(self.inputstr,self.cursor,character)
    end
    self.UpdateText()
end

local _Update = Update
function Update()
    if self.active then
        self.text.x = 20 + Misc.cameraX
        self.text.y = 480 + Misc.cameraY
    end
    if self.noclip then
        local spd = 2
        if Input.Cancel > 0 then
            spd = 1
        end
        if Input.Up > 0 then
            Player.Move(0,spd,true)
        end
        if Input.Down > 0 then
            Player.Move(0,-spd,true)
        end
        if Input.Left > 0 then
            Player.Move(-spd,0,true)
        end
        if Input.Right > 0 then
            Player.Move(spd,0,true)
        end
    end
    if Input.GetKey("CapsLock") == 1 then
        self.capson = not self.capson
    end
    if (Input.GetKey("F10") == 1) or (Input.GetKey("BackQuote") == 1) then
        if self.active then
            if not ((Input.GetKey("LeftShift") > 0) or (Input.GetKey("RightShift") > 0)) then
                self.toggled = true
                self.hide()
                if self.noclip then
                    Player.SetControlOverride(self.noclip)
                end
                self.active = not self.active
            end
        else
            self.toggled = true
            self.show()
            self.active = not self.active
        end
    end
    if self.active then
        for i = 1, #self.keys do
            local a = Input.GetKey(self.keys[i])
            if a == 1 then
                if self.toggled then
                    self.toggled = false
                else
                    self.keytimer = 0
                    self.lastkey = self.keys[i]
                end
            end
        end
        if self.lastkey ~= "" then
            self.keytimer = self.keytimer + 1
            if Input.GetKey(self.lastkey) == 1 then
                self.TypeChar(self.lastkey)
            end
            if self.keytimer > 30 then
                self.TypeChar(self.lastkey)
            end
            if Input.GetKey(self.lastkey) == -1 then
                self.lastkey = ""
                self.keytimer = 0
            end
        end
    end
    if _Update then
        _Update()
    end
    __Update()
end

function self.show()
    State("PAUSE")
    self.text = CreateText("",{20,480},600,"SuperTop")
    self.UpdateText()
    self.text.HideBubble()
    self.text.progressmode = "none"
end

function self.UpdateText()
    local a = ""
    local b = ""
    for i=1, self.lines do
        b = self.showhistory[#self.showhistory-(self.lines-1-i)-1]
        if b == nil then
            a = a .. "[color:ffffff]nil\n"
        else
            a = a .. "[color:ffffff]" .. tostring(b) .. "\n"
        end
    end
    self.text.SetText({"[font:" .. self.font .. "][color:ffffff][instant]" .. a .. "[color:ffffff]> " .. self.inputstr:sub(1,self.cursor) .. "[color: ".. self.cursorcolor .. " ]|[color:FFFFFF]" .. self.inputstr:sub(self.cursor+1,self.inputstr:len())})
end

function self.hide()
    State(GetCurrentState())
    self.text.DestroyText()
end

console = self