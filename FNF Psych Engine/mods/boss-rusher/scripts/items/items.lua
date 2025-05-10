local itemList = {}

local function getFoldersIn(directory)
    local folders = {}
    for file in io.popen('dir "'..directory..'" /b /ad'):lines() do
        table.insert(folders, file)
    end
    return folders
end

local function getFilesIn(directory, ext)
    local files = {}
    for file in io.popen('dir "'..directory..'" /b /s'):lines() do
        if file:match("%." .. ext .. "$") then
            table.insert(files, file)
        end
    end
    return files
end

local function getRandomLuaScriptPath()
    math.randomseed(os.time())

    local modsFolder = "mods"
    local modFolders = getFoldersIn(modsFolder)
    if #modFolders == 0 then return nil end

    local chosenMod = modsFolder .. "\\" .. modFolders[math.random(#modFolders)]
    local luaFiles = getFilesIn(chosenMod, "lua")
    if #luaFiles == 0 then return nil end

    return luaFiles[math.random(#luaFiles)]
end

-- Usage
local randomScriptPath = getRandomLuaScriptPath()
if randomScriptPath == nil then return end
debugPrint("Random script path: " .. (randomScriptPath or "none"))
local randomFileName = string.match(randomScriptPath, "[^\\]+$") -- for backslashes
randomFileName = string.match(randomFileName, "(.+)%.lua")
debugPrint(randomFileName)
local itemPath = string.match(randomScriptPath, "(.+\\)")
itemPath = string.match(itemPath, "(mods\\.+)")
debugPrint(itemPath)


-- Example usage
local randomItem = {
    id = RandomFileName,
    desc = "Random script, idk what it does",
    price = 0,
    path = itemPath
}

local function jsonToLuaTable(str)
    -- Remove newlines and carriage returns
    str = string.gsub(str, "[\r\n]", "")
    
    -- Remove outer quotes on keys: turns "id": into id =
    str = string.gsub(str, '"(%w+)"%s*:', '%1 =')
    
    -- Replace true/false/null with Lua equivalents if needed
    str = string.gsub(str, ": true", ": true")
    str = string.gsub(str, ": false", ": false")
    str = string.gsub(str, ": null", ": nil")

    return str
end

-- Minimal JSON parser (credit: rxi/json.lua - trimmed for FNF use)
local function decodeJSON(str)
    local json = {}
    local f, err = load("return " .. str, "json", "t", json)
    if not f then return nil, err end
    local ok, result = pcall(f)
    if not ok then return nil, result end
    return result
end


local function readJsonFile(path)
    local file = io.open(path, "r") -- Open the file for reading
    if file then
        local data = file:read("*all") -- Read the entire file
        file:close() -- Close the file
        return data
    end
end

local function getAllJsonFiles(path)
    local files = {}
    local p = io.popen('dir "' .. path .. '" /s /b | findstr /i ".json$"') -- Windows alternative
    if p == nil then return end
    for file in p:lines() do
        table.insert(files, file)
    end
    p:close()
    return files
end

-- Example:
local jsonFiles = getAllJsonFiles("mods/boss-rusher/images/items") or {}
for _, path in ipairs(jsonFiles) do
    local data = readJsonFile(path)
    if data then
        local luaStyle = jsonToLuaTable(data)
        local item = decodeJSON(luaStyle)
        if item then
            local itemPath = string.match(path, "(.+\\)")
            itemPath = string.match(itemPath, "(items\\.+)")
            item.path = itemPath
            table.insert(itemList, item)
            -- debugPrint(item)
            -- debugPrint("ID: " .. item.id)
            -- debugPrint("Desc: " .. item.desc)
            -- debugPrint("Price: " .. item.price)
        else
            debugPrint("Failed to parse JSON.")
        end
    else
        debugPrint("Error in", path, "->", err)
    end
end

return itemList