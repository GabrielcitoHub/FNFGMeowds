local stayTimer = 2
local overTime = false

local function loadLuaFile(filePath)
    local file = io.open(filePath, "r") -- Open the file for reading
    if file then
        local content = file:read("*all") -- Read the entire file
        file:close() -- Close the file
        local func, err = loadstring(content) -- Load the string as a Lua chunk
        if func then
            return func() -- Execute the loaded Lua chunk
        else
            print("Error loading file: " .. err)
        end
    else
        print("File not found: " .. filePath)
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

local itemList = loadLuaFile('mods/boss-rusher/scripts/items/items.lua')
local fadeIDs = {}

-- Function to create and display 3 random texts
local function createRandomTexts()
    -- Seed random for randomness
    math.randomseed(os.time())

    -- Shuffle itemList and pick the first 3 items
    local selectedItems = {}
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
        local textID = "itemText" .. i
        local imageID = "itemImage" .. i

        table.insert(fadeIDs, textID)
        table.insert(fadeIDs, imageID)
        
        makeLuaSprite(imageID, tostring("items/"..item.id), 100, 75 + (i * 100))
        upscaleSpriteIfSmaller(imageID, 128, 128)
        setObjectCamera(imageID, "other") -- Place the text on the "other" layer
        setObjectOrder(imageID,getObjectOrder("bg") + 1)
        setProperty(tostring(imageID..".antialiasing"), false)
        addLuaSprite(imageID)
        
        makeLuaText(textID, item.id .. "\n" .. item.desc .. "\n $" .. item.price, 500, 150, 75 + (i * 100))
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

function onCreate()
    createSprites()
    createRandomTexts()
    addLuaSprite("bg",true)
end

function onUpdate()
    stayTimer = stayTimer - 0.01
    if stayTimer >= 0 then
        -- debugPrint(stayTimer)
    else
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
end
