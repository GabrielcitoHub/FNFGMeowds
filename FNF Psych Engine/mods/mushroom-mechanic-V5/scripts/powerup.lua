local flashstate = false
local flashing
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

function onCreate()
    showHideMobileGUI(isOnMobile())
end

function onCreatePost()
    if not botPlay then
        makedisplay()
    end
end

function makedisplay()
    makeLuaSprite('powerdisplay',tostring('powerstates/'..powerup),50,600)
    scaleObject('powerdisplay',scaleSize,scaleSize)
    setProperty('powerdisplay.antialiasing', false)
    setObjectCamera("powerdisplay","hud")
    addLuaSprite('powerdisplay', true)
end

function updatedisplay()
    loadGraphic("powerdisplay", tostring('powerstates/'..powerup))
end

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
        flashing = true
        powerup = powerup - 1
        setOnLuas("powerup", powerup)
        setOnLuas("mxupdatepowerup", true)
        runTimer('flashingpowerdown',0.05,32)
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
    local id = "fireball"..fireballsamount
    local fireballData = {
        id = id,
        x = getProperty('boyfriend.x'),
        y = getProperty('boyfriend.y') + (getBoyfriendHeight()/2),
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
    elseif songName == "Cross-Console-Clash" then
        scaleObject(id, 0.1, 0.1)
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

function updateFireballs()
    groundY = (getProperty('boyfriend.y') + getBoyfriendHeight())
    if getOpponentY() >= getProperty('boyfriend.y') then
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
    if powerup == 2 then
        playSound('fireball', 1)
        runTimer('flashing',0.05,2)
        spawnFireball()
    end
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

function onUpdate()
    updateFireballs()
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

function hitpowerup()
    powerup = spawnedpowerup
    setOnLuas("powerup", powerup)
    setOnLuas("mxupdatepowerup", true)
    playSound('powerup', 1)
    removeLuaSprite("powerup")
    runTimer('flashingpowerup',0.1,16)
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
    testpowerup(note,"miss")
end

function goodNoteHit(membersIndex, noteData)
    testpowerup(noteData)
end

function noteMiss()
    mushroommiss()
end

function onTimerCompleted(tag,loops,loopsleft)
    if tag == "flashing" or "flashingpowerdown" or "flashingpowerup" then
        setProperty('boyfriendGroup.visible', flashstate);
        flashstate = not flashstate
        if tag == "flashingpowerdown" or "flashingpowerup" then
            flashing = true
            if loopsleft == 0 then
                setProperty('boyfriendGroup.visible', true);
                flashing = false
            end
        end
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