local datasaved = false
local defaultScaleSize = scaleSize

local beatenlist
local fclist
local bltrimmed
local fcbltrimmed
local found
local fcfound

local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

local function getData()
    beatenlist = getTextFromFile("data/special/beatedsongs.txt")
    fclist = getTextFromFile("data/special/fcbeatedsongs.txt")
    
    -- Split the file contents into tables
    bltrimmed = split(beatenlist, "\n")
    fcbltrimmed = split(fclist, "\n")  -- Use fclist here instead of beatenlist
    
    -- Reset flags
    found = false
    fcfound = false
    
    -- Check if the song is in the beatenlist
    for i, v in pairs(bltrimmed) do
        if v == tostring(songName..difficultyName) then
            found = true
            break -- If found, no need to continue the loop
        end
    end

    -- Check if the song is in the full-combo list (fclist)
    for i, v in pairs(fcbltrimmed) do
        if v == tostring(songName..difficultyName) then
            fcfound = true
            break -- If found, no need to continue the loop
        end
    end
end

local function spawnSticker(fc)
    if not fc then
        makeLuaSprite('sticker',tostring('special/star'),150,597);
    else
        makeLuaSprite('sticker',tostring('special/crown'),150,592);
    end
    scaleObject('sticker',scaleSize,scaleSize)
    setProperty('sticker.antialiasing', false)
    setObjectCamera("sticker","hud")
    addLuaSprite('sticker', true)
    -- startTween('stickerSize', 'sticker.scale', {x = tonumber(scaleSize..".5"), y = tonumber(scaleSize..".5")}, 5, {ease = 'sineOut'})
end

-- Function to run when the song starts
local function checkSticker()
    getData() -- Load the data
    
    -- Determine whether to spawn the sticker
    if found then
        spawnSticker(false)
    elseif fcfound then
        spawnSticker(true)
    end
end

local function endSongSave()
    -- debugPrint("cool func called!")
    -- debugPrint("saving")
    runTimer("save",0.1)
    -- If the song is not full combo'd
    if not fcfound then
        if not found then
            if misses >= 1 then
                beatenlist = tostring(beatenlist.."\n"..tostring(songName..difficultyName))
            else
                fclist = tostring(fclist.."\n"..tostring(songName..difficultyName))
            end
        end
    elseif found then
        if not fcfound and misses == 0 then
            fclist = tostring(fclist.."\n"..tostring(songName..difficultyName))
        end
    end
end
-- Function to get data from the files

function onCreatePost()
    if not botPlay then
        checkSticker()
    end
end

function onUpdate()
    if not botPlay then
        if songLength - getSongPosition() < 2000 then
            if not datasaved then
                datasaved = true
                -- debugPrint("song near end!!")
                endSongSave()  -- Save near the end of the song
            end
        end
    end
end

function onTimerCompleted(tag)
    if tag == "save" then
        -- debugPrint("hi")
        -- debugPrint('data/special/beatedsongs.txt',beatenlist)
        -- debugPrint('data/special/fcbeatedsongs.txt',fclist)
        saveFile(modFolder.."/data/special/beatedsongs.txt",beatenlist)
        saveFile(modFolder.."mushroom-mechanic-V5/data/special/beatedsongs.txt",fclist)
    end
end

function onTweenCompleted(tag)
    if tag == "stickerSize" then
        startTween('stickerDownSize', 'sticker.scale', {x = defaultScaleSize, y = defaultScaleSize}, 2, {ease = 'linear'})
    end
end