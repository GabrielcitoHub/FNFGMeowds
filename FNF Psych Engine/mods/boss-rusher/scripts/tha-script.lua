local stayTimer = 2
local overTime = false
local selected = 1

local function loadLuaFile(filePath)
    local file = io.open(filePath, "r") -- Open the file for reading
    if file then
        local content = file:read("*all") -- Read the entire file
        file:close() -- Close the file
        local func, err = loadstring(content) -- Load the string as a Lua chunk
        if func then
            return func() -- Execute the loaded Lua chunk
        else
            debugPrint("Error loading file: " .. err)
        end
    else
        debugPrint("File not found: " .. filePath)
    end
end

-- Function to upscale a sprite if its size is smaller than the target size
local function upscaleSpriteIfSmaller(spriteID, targetWidth, targetHeight)
    -- Get the current size of the sprite
    local currentWidth = getProperty(spriteID .. ".width")
    local currentHeight = getProperty(spriteID .. ".height")

    -- Check if the sprite's width or height is smaller than the target
    if currentWidth < targetWidth or currentHeight < targetHeight then
        -- Calculate the scale factors for both dimensions
        local scaleX = targetWidth / currentWidth
        local scaleY = targetHeight / currentHeight

        -- Use the larger of the two scale factors to maintain aspect ratio
        local scaleFactor = math.max(scaleX, scaleY)

        -- Set the new scale for the sprite
        setProperty(spriteID .. ".scale.x", scaleFactor)
        setProperty(spriteID .. ".scale.y", scaleFactor)
    end
end

-- Function to upscale a sprite if its size is larger than the target size
local function downscaleSpriteIfLarger(spriteID, targetWidth, targetHeight)
    -- Get the current size of the sprite
    local currentWidth = getProperty(spriteID .. ".width")
    local currentHeight = getProperty(spriteID .. ".height")

    -- Check if the sprite's width or height is smaller than the target
    if currentWidth > targetWidth or currentHeight > targetHeight then
        -- Calculate the scale factors for both dimensions
        local scaleX = targetWidth / currentWidth
        local scaleY = targetHeight / currentHeight

        -- Use the larger of the two scale factors to maintain aspect ratio
        local scaleFactor = math.max(scaleX, scaleY)

        -- Set the new scale for the sprite
        setProperty(spriteID .. ".scale.x", scaleFactor)
        setProperty(spriteID .. ".scale.y", scaleFactor)
    end
end

local itemList = loadLuaFile('mods/boss-rusher/scripts/items/items.lua')
local fadeIDs = {}

-- Function to create and display 3 random texts
local selectedItems = {}
local function createRandomTexts()
    -- Seed random for randomness
    math.randomseed(os.time())

    -- Shuffle itemList and pick the first 3 items
    
    local selectedIndexes = {}

    while #selectedItems < 3 do
        local randomIndex = math.random(1, #itemList)
        if not selectedIndexes[randomIndex] then
            table.insert(selectedItems, itemList[randomIndex])
            selectedIndexes[randomIndex] = true
        end
    end

    -- Create the 3 texts using the selected items
    for i, item in ipairs(selectedItems) do
        -- debugPrint(item.path..item.id)
        local textID = string.lower(item.id).."Text"
        local imageID = string.lower(item.id).."Image"

        table.insert(fadeIDs, textID)
        table.insert(fadeIDs, imageID)
        
        makeLuaSprite(imageID, item.path..item.id, 100, 75 + (i * 100))
        upscaleSpriteIfSmaller(imageID, 128, 128)
        downscaleSpriteIfLarger(imageID, 128, 128)
        setObjectCamera(imageID, "other") -- Place the text on the "other" layer
        setObjectOrder(imageID,getObjectOrder("bg") + 1)
        setProperty(tostring(imageID..".antialiasing"), false)
        addLuaSprite(imageID)

        -- local itemTexttext = item.id .. "\n" .. item.desc .. "\n $" .. item.price
        local itemTexttext = item.id .. "\n" .. item.desc
        makeLuaText(textID, itemTexttext, 500, 150, 75 + (i * 100))
        setObjectCamera(textID, "other") -- Place the text on the "other" layer
        setObjectOrder(textID,getObjectOrder("bg") + 1)
        setProperty(tostring(textID..".antialiasing"), false)
        addLuaText(textID)
    end
end

local function createSprites()
    makeLuaSprite("bg","bg")
    setObjectCamera("bg","hud")
    scaleObject("bg",16,15)
    setProperty("bg.alpha",0.8)
    setProperty("bg.antialiasing",false)
    screenCenter(bg)
end

local function updateSelection()
    local optsLen = 0
    for i,v in ipairs(selectedItems) do
        optsLen = i
        setProperty(string.lower(v.id).."Text.alpha", 0.7)
    end
    if selected < 1 then
        selected = optsLen
    elseif selected > optsLen then
        selected = 1
    end
    local selectedItem = selectedItems[selected]
    local itemText = string.lower(selectedItem.id).."Text"
    setProperty(itemText..".alpha", 1)
end

function onCreate()
    createSprites()
    createRandomTexts()
    updateSelection()
    addLuaSprite("bg",true)
end

function noteMissPress()
    if not overTime then
        addHealth(0.05*healthGainMult)
        addMisses(-1)
        addScore(10)
        return Function_Stop
    end
end

local function hidePopupThingy()
    if not overTime then
        overTime = true
        -- Define the tween table for the background
        local tween = {"bgFade", "bg", 0, 0.6, "cubeOut"}

        -- Perform the background fade using doTweenAlpha
        doTweenAlpha(tween[1], tween[2], tween[3], tween[4], tween[5])

        -- Loop through the selected items and apply a unique tween for each
        for i, txtID in ipairs(fadeIDs) do
            local uniqueTweenID = "textFade" .. i -- Create a unique tween ID for each text item
            doTweenAlpha(uniqueTweenID, txtID, tween[3], tween[4], tween[5])
        end
    end
end

function onUpdate()
    if not overtime then
        if keyJustPressed("up") then
            selected = selected - 1
        elseif keyJustPressed("down") then
            selected = selected + 1
        end

        if keyJustPressed("up") or keyJustPressed("down") then
            updateSelection()
        end

        stayTimer = stayTimer - 0.01
        if stayTimer >= 0 then
            if getPropertyFromClass("flixel.FlxG","keys.justPressed.SPACE") then
                stayTimer = -1
                local selectedItem = selectedItems[selected]
                hidePopupThingy()
                loadLuaFile("mods\\boss-rusher\\images\\"..selectedItem.path..selectedItem.id..".lua")
                debugPrint(selectedItem.desc)
                debugPrint(selectedItem.id .. " selected!")
                playSound("confirm_menu", 0.4)
            end
            -- debugPrint(stayTimer)
        else
            hidePopupThingy()
        end
    end
end
