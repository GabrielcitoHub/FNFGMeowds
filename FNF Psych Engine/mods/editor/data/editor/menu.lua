function getCurrentDirectory()
    local folders = {}

    local handle = io.popen('dir mods /b /ad')
    local result = handle:read("*a")

    -- Iterate through each line (folder name) and add it to the list
    for folder in string.gmatch(result, "[^\r\n]+") do
        table.insert(folders, folder)
    end

    --handle:close()
    
    return folders
end

local modFolders = getCurrentDirectory()

local function createSprites()
    makeLuaSprite("bg")
    makeGraphic("bg",1300,750,"000000")
    setObjectCamera("bg","hud")
    screenCenter("bg","xy")

    -- Create a sprite for the cursor
    makeLuaSprite('cursor', 'cursor', 0, 0) -- 'cursor' is the image name without .png extension
    setObjectCamera('cursor', 'hud') -- This ensures the cursor is visible in the HUD layer      
    setProperty('cursor.visible', true) -- Make sure the cursor is visible
end 

local function spawnModFlrs()
    -- Example usage
    for _, folder in ipairs(modFolders) do
        debugPrint(folder)
    end
end

function onCreate()
    createSprites()
end

function onCountdownTick(coolness)
    if coolness == 0 then
        openCustomSubstate("menu",true)
        addLuaSprite("bg", true)
        addLuaSprite('cursor', true) -- Add the cursor sprite to the game
        spawnModFlrs()
        debugPrint("Welcome! Please select a mod folder below, Press R to reload or ESC to exit.")
    end
end

function onCustomSubstateUpdate(name, elapsed)
    if name == "menu" then
        if keyboardJustPressed("ESCAPE") then
            exitSong(true)
        elseif keyboardJustPressed("R") then
            restartSong(true)
        end
    end
    -- Set the cursor's position to follow the mouse
    setProperty('cursor.x', getMouseX('hud'))
    setProperty('cursor.y', getMouseY('hud'))
end