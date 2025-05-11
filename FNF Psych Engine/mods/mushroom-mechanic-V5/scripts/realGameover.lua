local deathSprs = {"bf", "mario"}
local stopScript = false
function table.contains (table, element)
    for _,value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function onCreatePost()
    if not table.contains(songs, songName) then
        stopScript = true
        return 
    end
end

local function getListIndex(list,value)
    for i,v in ipairs(list) do
        if v == value then
            break
        end
    end
    return i
end

local function killbf()
    setHealth(1)
    setProperty('boyfriendGroup.visible', false)
    setProperty('bflegs.visible', false)
    openCustomSubstate('gameover', true)
    playSound("death", 1)
    runTimer("restart", 3)

    deathSpr = deathSprs[getListIndex(songs,songName)]

    if deathSpr == nil then
        deathSpr = deathSprs[getListIndex(songs,songs[1])]
    end

    makeLuaSprite("bfdeadspr", "gameover/"..deathSpr.."-dead", getProperty('boyfriend.x'), getProperty('boyfriend.y'))
    setObjectCamera("bfdeadspr","hud")
    if songName == songs[1] then
        scaleObject("bfdeadspr", 4, 4)
    end
    --setObjectCamera("bfdeadspr", "hud")
    addLuaSprite("bfdeadspr", true) -- Add the sprite to the custom substate
    setProperty('bfdeadspr.antialiasing', false)

    -- Tween upwards quickly (Mario jumps up)
    doTweenY('jumpUp', 'bfdeadspr', getProperty('bfdeadspr.y') - 80, 0.8, 'circOut')
end

function onUpdate()
    if stopScript then return end
    -- Gameover (the real one)
    if mushroomkill then
        killbf()
    end
end

-- When the upward motion completes, fall down with gravity-like behavior
function onTweenCompleted(tag)
    if tag == 'jumpUp' then
        -- Small delay to mimic the pause at the peak
        runTimer('fallDelay', 0.3)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == "restart" then
        restartSong(true)
    elseif tag == 'fallDelay' then
        -- Now, make the sprite fall down slower, similar to gravity
        doTweenY('fallDown', 'bfdeadspr', getProperty('bfdeadspr.y') + 500, 1, 'circIn')
    end
end