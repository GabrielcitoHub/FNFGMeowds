local lastbfx = 0
local lastbfy = 0
local flashstate = false
local flashing = false
local powerup = 2
local powerupbeat = 0
local haspowerupbeat = false
local powerupspawned = false
local alreadymissed = false
local powerupnote = 0
local spawnedpowerup = 0
local fireballs = {}
local fireballsamount = 0

local firePressed = 0
local beatenlist
local fclist
local bltrimmed
local fcbltrimmed
local found
local fcfound

local scaleSize = 10

function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

-- Function to get data from the files
function getData()
    beatenlist = getTextFromFile("data/special/beatedsongs.txt")
    fclist = getTextFromFile("data/special/fcbeatedsongs.txt")
    
    -- Split the file contents into tables
    bltrimmed = split(beatenlist, ",")
    fcbltrimmed = split(fclist, ",")  -- Use fclist here instead of beatenlist
    
    
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

-- Function to run when the song starts
function checkSticker()
    getData() -- Load the data
    
    -- Determine whether to spawn the sticker
    if not fcfound then
        if found then
            spawnSticker(false)
        end
    else
        spawnSticker(true)
    end
end

function onCreate()
    showHideMobileGUI(isOnMobile())
    checkSticker()
end

function onCreatePost()
    getData()
    if found then
        spawnSticker(false)
    elseif fcfound then
        spawnSticker(true)
    end
end

function onDestroy()
end

function onSongStart()
end

function endSongSave()
    -- debugPrint("cool func called!")
    -- debugPrint("saving")
    runTimer("save",0.1)
    -- If the song is not full combo'd
    if not fcfound then
        if not found then
            if misses >= 1 then
                beatenlist = tostring(beatenlist..","..tostring(songName..difficultyName))
            else
                fclist = tostring(fclist..","..tostring(songName..difficultyName))
            end
        end
    elseif found then
        if not fcfound and misses == 0 then
            fclist = tostring(fclist..","..tostring(songName..difficultyName))
        end
    end
end

-- Function to run when the song ends
function onEndSong()
end

function updatedisplay()
    makeLuaSprite('powerdisplay',tostring('powerstates/'..powerup),50,600);
    scaleObject('powerdisplay',scaleSize,scaleSize)
    setProperty('powerdisplay.antialiasing', false)
    setObjectCamera("powerdisplay","hud")
    addLuaSprite('powerdisplay', true)
end

function spawnSticker(fc)
    if not fc then
        makeLuaSprite('sticker',tostring('special/star'),150,597);
    else
        makeLuaSprite('sticker',tostring('special/crown'),150,592);
    end
    scaleObject('sticker',scaleSize,scaleSize)
    setProperty('sticker.antialiasing', false)
    setObjectCamera("sticker","hud")
    addLuaSprite('sticker', true)
    -- debugPrint("Sticker!!")
end

updatedisplay()

local noteTime = 0

function onUpdatePost(elapsed)
    local songPos = getSongPosition()
    local strumLineY = getPropertyFromGroup('playerStrums', powerupnote, 'y')

    local songSpeed = getProperty("songSpeed")

    -- Debugging print (optional)
    -- debugPrint("Scroll Speed: " .. tostring(scrollSpeed))
    -- debugPrint("Song Speed: " .. tostring(songSpeed))

    -- Use them in your movement calculation as needed

    local distance = ((noteTime - songPos) / 1000) * 112 * scrollSpeed * songSpeed

    if not downscroll then
        setProperty('powerup.y', strumLineY + distance)
    else
        setProperty('powerup.y', strumLineY - distance)
    end
    setProperty("powerup.x", getPropertyFromGroup("playerStrums", powerupnote, "x"))
end

function spawnCustomNote(noteData)
    noteTime = (powerupbeat * 60000) / bpm
    powerupnote = noteData

    local spawnx = getPropertyFromGroup('playerStrums', powerupnote, 'x')
    local spawny = -1200  -- well below the visible screen height (usually ~720px)

    -- Notedata _ This refers to the note direction (0 = left, 1 = down, 2 = up, 3 = right)
    makeLuaSprite('powerup',tostring('powerstates/'..powerup+1),spawnx,spawny);
    spawnedpowerup = powerup+1
    scaleObject('powerup',scaleSize * 1.2,scaleSize * 1.2)
    setProperty('powerup.antialiasing', false)
    setObjectCamera("powerup","other")
    addLuaSprite('powerup', true)
end

function mushroommiss()
    if not alreadymissed then
        alreadymissed = true
    end
    if not flashing then
        powerup = powerup - 1
        flashing = true
        runTimer("updatebf",0.01)
        runTimer('flashing',0.05,32)
        -- debugPrint(powerup)
        if powerup >= 0 then
            playSound('power_down', 1)
            updatedisplay()
        else
            setOnLuas("mushroomkill", true)
            setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'death')
            setHealth(0)
        end
    end
end

function removePowerup()
    removeLuaSprite("powerup",true)
    if not songName == "Game over" then
        powerupbeat = curBeat + 16 + math.random(4)
    else
        powerupbeat = curBeat + 24 + math.random(6)
    end
    haspowerupbeat = false
    powerupspawned = false
end

function getOpponentX()
    -- Check the first available opponent in the "opponentStrums" group
    return getPropertyFromGroup('opponentStrums', 0, 'x')
end

function getOpponentY()
    -- Check the first available opponent in the "opponentStrums" group
    return getPropertyFromGroup('opponentStrums', 0, 'y')
end

function getOpponentWidth()
    -- Get the width of the opponent sprite (if available)
    return getPropertyFromGroup('opponentStrums', 0, 'width')
end

function getOpponentHeight()
    -- Get the height of the opponent sprite (if available)
    return getPropertyFromGroup('opponentStrums', 0, 'height')
end

function isBoyfriendFlipped()
    return getProperty('boyfriend.flipX')
end

function getBoyfriendX()
    return getProperty('boyfriend.x')
end

function getBoyfriendY()
    return getProperty('boyfriend.y')
end

function getBoyfriendHeight()
    return getProperty('boyfriend.height')
end

function isOnMobile()
    if buildTarget == 'android' then
        return true
    else
        return false
    end
end

function checkCollision(fireball)
    -- Get the boundaries of the fireball
    local fireballX = getProperty(fireball.id .. '.x')
    local fireballY = getProperty(fireball.id .. '.y')
    local fireballWidth = getProperty(fireball.id .. '.width')
    local fireballHeight = getProperty(fireball.id .. '.height')

    -- Get the boundaries of the opponent dynamically
    local opponentX = getOpponentX()
    local opponentY = getOpponentY()
    local opponentWidth = getOpponentWidth()
    local opponentHeight = getOpponentHeight()

    -- Check if the two objects overlap (bounding box collision detection)
    if fireballX < opponentX + opponentWidth and
       fireballX + fireballWidth > opponentX and
       fireballY < opponentY+1000 + opponentHeight and
       fireballY + fireballHeight > opponentY-1000 then
        return true  -- They are colliding
    end
    return false  -- No collision
end

local gravity = 0.5  -- Constant for gravity acceleration
local bounceFactor = 1  -- Reduce speed after each bounce (for friction)
local groundY = 800  -- Y position representing the ground or floor
local fireballRadius = 32  -- Assuming a fireball has a certain size/radius

function spawnFireball()
    if powerup == 2 then
        local id = "fireball"..fireballsamount
        local fireballData = {
            id = id,
            x = getBoyfriendX(),
            y = getBoyfriendY() + (getBoyfriendHeight()/2),
            speedx = 8,
            speedy = 0,  -- Start with no vertical movement
            onGround = false  -- Keep track if fireball is on the ground
        }
        if isBoyfriendFlipped() and not songName == "Gameover" then
            fireballData.speedx = fireballData.speedx * -1
        elseif songName == "Gameover" then
            fireballData.y = fireballData.y - 20
            if curSection >= 48 then
                fireballData.speedx = fireballData.speedx + 15
            else
                fireballData.speedx = fireballData.speedx * -1
            end
        end
        makeAnimatedLuaSprite(id, 'objects/fireball', fireballData.x, fireballData.y)
        -- Add the animation to the fireball
        addAnimationByPrefix(id, 'idle', 'fireball', 24, true)  -- Adjust the prefix and FPS as needed

        -- Start playing the animation
        playAnim(id, 'idle', true)
        
        -- Scale and add the sprite to the game
        if songName == "Gameover" then
            scaleObject(id, 0.5, 0.5)
        else
            scaleObject(id, 1, 1)
        end
        setProperty(tostring(id..".antialiasing"), false)
        addLuaSprite(id, true)
        if not isBoyfriendFlipped() then
            setProperty(tostring(id..'.flipX'), true)
        end
        if songName == "Gameover" and isBoyfriendFlipped() then
            setProperty(tostring(id..'.flipX'), false)
        end
        
        -- Add the fireball data to the table
        table.insert(fireballs, fireballData)
        fireballsamount = fireballsamount + 1
    end
end

function updateFireballs()
    groundY = (getBoyfriendY() + getBoyfriendHeight())
    if getOpponentY() >= getBoyfriendY() then
            groundY = (getOpponentY() + (getOpponentHeight()*2))
    end
    for i, v in ipairs(fireballs) do
        -- Gravity: Increase the vertical speed over time
        v.speedy = v.speedy + gravity

        -- Move fireball horizontally and vertically
        v.x = v.x - v.speedx
        v.y = v.y + v.speedy  -- Apply gravity to vertical movement

        -- Check for collision with the ground (bounce logic)
        if v.y >= groundY - fireballRadius then
            v.y = groundY - fireballRadius  -- Ensure it doesn't go below the ground
            v.speedy = -v.speedy * bounceFactor  -- Reverse vertical speed and apply bounce factor
        end

        -- Optional: Friction for horizontal speed, reducing it slightly each update
        v.speedx = v.speedx * 1  -- Slow down horizontal speed a little

        -- Apply the updated position to the fireball sprite
        setProperty(v.id .. '.x', v.x)
        setProperty(v.id .. '.y', v.y)

        if checkCollision(v) then
            -- Fireball has hit the opponent
            -- debugPrint("Fireball hit the opponent!")

            -- Perform actions here (e.g., damage the opponent, remove fireball)
            removeLuaSprite(v.id, true)  -- Remove the fireball from the screen
            table.remove(fireballs, i)  -- Remove fireball from the table
            addHealth(0.05)
        end
    end
end

function fireFireball()
    playSound('fireball', 1)
    runTimer('flashing',0.05,2)
    spawnFireball()
end

-- Function to check if the touch is within the sprite's bounds
function isTouchingSprite(spriteName)
    local spriteX = getProperty(tostring(spriteName..'.x'))+getProperty(tostring(spriteName..'.width'))
    local spriteY = getProperty(tostring(spriteName..'.y'))
    local spriteWidth = getProperty(tostring(spriteName..'.width'))
    local spriteHeight = getProperty(tostring(spriteName..'.height'))
    
    -- Check if the sprite is a HUD sprite
    local isHud = getProperty(tostring(spriteName..'.isHUD'))

    if mousePressed() then
        -- Get touch position on mobile (or mouse position on PC)
        local mouseX, mouseY = getMouseX(isHud), getMouseY(isHud)
        
        -- Check if the mouse/touch is within the sprite bounds
        if mouseX >= spriteX and mouseX <= spriteX + spriteWidth and
           mouseY >= spriteY and mouseY <= spriteY + spriteHeight then
            -- debugPrint("touching button!")
            return true  -- The sprite is being touched
        end
    end
    
    return false  -- The sprite is not being touched
end

local datasaved = false

function saveSongCompletion(songName, difficulty, fc)
    local key = songName .. ':' .. difficulty  -- Create a unique key for song + difficulty
    if not fc then
        if not beatenSongs[key] then
            table.insert(beatenSongs, key)  -- Save it to the table if it hasn't been saved yet
        end
    else
        if not fclist[key] then
            table.insert(fclist, key)  -- Save it to the table if it hasn't been saved yet
        end
    end
end

function onUpdate()
    updateFireballs()
    if mxupdatepowerup then
        setOnLuas("mxupdatepowerup", false)
        changeSprite()
    end
    -- debugPrint(difficultyName)
    local songPosition = getSongPosition()  -- Current song position in milliseconds
    -- local songLength = getPropertyFromClass('Conductor', 'songLength')      -- Total song length in milliseconds
    -- debugPrint(songLength - songPosition)
    if songLength - songPosition < 2500 then
        if not datasaved then
            datasaved = true
            -- debugPrint("song near end!!")
            endSongSave()  -- Save near the end of the song
        end
    end
    firePressed = firePressed - 0.1
    if haspowerupbeat == true then
        if not middlescroll then
            if getProperty('powerup.y') <= -100 then
                removePowerup()
            end
        else
            if getProperty('powerup.y') >= 750 then
                removePowerup()
            end
        end
    end

    if ghostTapping then
        local delay = 0.3
        if keyJustPressed('up') then
            testpowerup(0)
        elseif keyJustPressed('down') then
            testpowerup(1)
        elseif keyJustPressed('left') then
            testpowerup(2)
        elseif keyJustPressed('right') then
            testpowerup(3)
        end
    end

    if getPropertyFromClass("flixel.FlxG","keys.justPressed."..getModSetting("cfgmxactionkey")["keyboard"]) or gamepadJustPressed(0, getModSetting("cfgmxactionkey")["gamepad"]) then
        fireFireball()
    end
    -- showHideMobileGUI(true)
    -- debugPrint(isTouchingSprite("gui"))
    if isTouchingSprite("gui") then
        if firePressed <= 0 then
            fireFireball()
            if songName == "Gameover" then
                setOnLuas("mxbfjump",true)
            end
        end
        firePressed = 0.2
    end
end

function showHideMobileGUI(state)
    if state then
        local fireButtonSpr = 'buttons/fire_button'
        if getPropertyFromClass("backend.ClientPrefs", "data.language") == "es-AR" then
            fireButtonSpr = 'es-AR/buttons/fire_button'
        end
        makeLuaSprite('gui',fireButtonSpr,50,400)
        scaleObject('gui',2,2)
        setObjectCamera("gui","hud")
        setProperty("gui.antialiasing", false)
        addLuaSprite('gui')
    else
        removeLuaSprite('gui')
    end
end

function changeSprite()
    if songName == "Gameover" then
        -- debugPrint(tostring("running: " .. mxrunning))
        -- debugPrint(tostring("hiding: " .. mxbfhiding))
        -- debugPrint("Ouch!")
        if powerup == 2 then
            if not mxrunning then
                if not mxbfhiding then
                    triggerEvent('Change Character', 'BF', 'bfmxfire')
                else
                    triggerEvent('Change Character', 'BF', 'bf-wall-fire')
                end
            else
                triggerEvent('Change Character', 'BF', 'bf-chase-fire')
                playAnim("bflegs", 'runfire', true)
            end
        elseif powerup == 1 then
            if not mxrunning then
                if not mxbfhiding then
                    triggerEvent('Change Character', 'BF', 'bfmx')
                else
                    triggerEvent('Change Character', 'BF', 'bf-wall')
                end
            else
                triggerEvent('Change Character', 'BF', 'bf-chase')
                playAnim("bflegs", 'run', true)
            end
        elseif powerup == 0 then
            if not mxrunning then
                if not mxbfhiding then
                    triggerEvent('Change Character', 'BF', 'bf-small')
                else
                    triggerEvent('Change Character', 'BF', 'bf-wall-small')
                end
            else
                triggerEvent('Change Character', 'BF', 'bf-chase-small')
                playAnim("bflegs", 'runsmall', true)
            end
        end
        -- setProperty("boyfriend.x", lastbfx)
        -- setProperty("boyfriend.y", lastbfy)
    end
end

function hitpowerup()
    flashing = true
    powerup = spawnedpowerup
    runTimer("updatebf",0.01)
    playSound('powerup', 1)
    removeLuaSprite("powerup")
    runTimer('flashing',0.1,16)
    updatedisplay()
   -- debugPrint("mushroom!!")
    haspowerupbeat = false
    powerupspawned = false
    if not ghostTapping then
        addMisses(-1)
        addHealth(0.013)
        playAnim('boyfriend', 'idle', true)
    end
    if powerup >= 2 then
        -- nothing lul
    else
        alreadymissed = true
    end
end

function powerDown(state)
    if state == "miss" then
        if not ghostTapping then
            mushroommiss()
        end
    end
end

function testpowerup(note, state)
    if powerupspawned then
        local yPos = getProperty('powerup.y')
        local powerupYThreshold = getPropertyFromGroup('playerStrums', powerupnote, 'y')
        local collisionRange = 225 -- Adjust this range for better detection
        -- debugPrint(getProperty('powerup.y'))

        if not downscroll then
            -- Check if the Y position is within the collision range
            if yPos <= powerupYThreshold + collisionRange and yPos >= powerupYThreshold - collisionRange then
                if note == powerupnote then
                    hitpowerup()
                else
                    powerDown(state)
                end
            else
                powerDown(state)
            end
        else
            if yPos >= powerupYThreshold - collisionRange and yPos <= powerupYThreshold + collisionRange then
                if note == powerupnote then
                    hitpowerup()
                else
                    powerDown(state)
                end
            else
                powerDown(state)
            end
        end
    else
        if state == "miss" then
            powerDown(state)
        end
    end
end


function noteMissPress(note)
    if not haspowerupbeat then
        mushroommiss()
    else
        testpowerup(note,"miss")
    end
end

function goodNoteHit(membersIndex, noteData)
    testpowerup(noteData)
end

function noteMiss()
    mushroommiss()
end

function onTimerCompleted(tag,loops,loopsleft)
    if tag == "flashing" then
        flashing = true
        setProperty('boyfriendGroup.visible', flashstate);
        flashstate = not flashstate
        if loopsleft == 0 then
            setProperty('boyfriendGroup.visible', true);
            flashing = false
        end
    elseif tag == "save" then
        local paththingy = 'mushroom-mechanic-V4/data/special/'
        -- debugPrint("hi")
        -- debugPrint(paththingy..'beatedsongs.txt',beatenlist)
        -- debugPrint(paththingy..'fcbeatedsongs.txt',fclist)
        saveFile(paththingy..'beatedsongs.txt',beatenlist)
        saveFile(paththingy..'fcbeatedsongs.txt',fclist)
    elseif tag == "updatebf" then
        changeSprite()
    end
end

function onSpawnNote(membersIndex, noteData, noteType, isSustainNote, strumTime)
    if not mustHitSection then return end
    -- debugPrint(tostring(curBeat.."/ "..powerupbeat))
    if alreadymissed then
        if haspowerupbeat == false then
            if powerup < 2 then
                haspowerupbeat = true
                powerupbeat = curBeat + 24 + math.random(6)
                spawnCustomNote(noteData)
                powerupspawned = true
                alreadymissed = false
            end
        end
    end
end