local loop = 0
local loopsbgs = {}
local songStarted = false
local hadghosttapping = false
local popupx = 0
local camerabffollow = true
local canJump = false
setOnLuas("mxrunning", false)
local runningspeed = 16
local overworld = false
local mxJumpSteps = {}
local block = 0

local function getBoyfriendX()
    return getProperty('boyfriend.x')
end

local function getBoyfriendY()
    return getProperty('boyfriend.y')
end

local inGameBoyfriendX = getBoyfriendX()
local inGameBoyfriendY = getBoyfriendY()

local inGameDadX = getProperty('dad.x')
local inGameDadY = getProperty('dad.y')

-- jumping vars
local groundlevel = inGameBoyfriendY
local groundGravitylevel = inGameBoyfriendY
local mxGroundGravitylevel = inGameDadY
local gravity = 1750  -- Gravity value (affects falling speed
local mxbfjump = false
local jumpPower = -650  -- Jump velocity (affects how high the jump is
local bfVelocityY = 0  -- Initial velocity for the character in the Y-axis
local bfOnGround = true  -- Check if BF is on the ground

-- mx jumping vars
local mxJump = false
local mxJumpPower = -650  -- Jump velocity (affects how high the jump is
local mxVelocityY = 0  -- Initial velocity for the character in the Y-axis
local mxOnGround = true  -- Check if BF is on the ground

local function removeLegs()
    removeLuaSprite("legs")
    removeLuaSprite("bflegs")
end

local function makebflegs()
    makeAnimatedLuaSprite("bflegs", "background/pcport/bflegs", getProperty('bf.x'), groundlevel)
    scaleObject("bflegs", 5, 5)
    setProperty('bflegs.antialiasing', false)
    addLuaSprite("bflegs", true)
    
    -- Debugging to make sure the animation exists and groundlevel is valid
    -- debugPrint("groundlevel: " .. tostring(groundlevel))
    
    addAnimationByPrefix("bflegs", 'run', 'run', 30, true) -- Ensure 'run' is the correct animation prefix
    addAnimationByPrefix("bflegs", 'runfire', 'runfire', 30, true)
    addAnimationByPrefix("bflegs", 'runsmall', 'runsmall', 30, true)

    addAnimationByPrefix("bflegs", 'jump', 'jump', 0, true)
    addAnimationByPrefix("bflegs", 'jumpfire', 'jumpfire', 0, true)
    addAnimationByPrefix("bflegs", 'jumpsmall', 'jumpsmall', 0, true)
    playAnim("bflegs", 'run', true)
end

local function updateBfLegs()
    -- BF Legs
    setProperty("bflegs.x", getProperty('boyfriend.x')-88)
    setProperty("bflegs.y", getProperty('boyfriend.y')-100)
end

local function makelegs()
    makeAnimatedLuaSprite("legs","background/pcport/legs",getProperty('dad.x'),getProperty('dad.y'))
    scaleObject("legs", 5, 5)
    setProperty('legs.antialiasing', false)
    addLuaSprite("legs",true)
    addAnimationByPrefix("legs", 'legs', 'legs', 60, true)  -- Adjust the prefix and FPS as needed
    addAnimationByPrefix("legs", 'legsmad', 'runmad', 30, true)
    addAnimationByPrefix("legs", 'jump', 'legjump', 0, true)
    playAnim("legs", 'legs', true)
end

function onCreate()
    precacheImage('background/pcport/loop')
    setPropertyFromClass('lime.app.Application', 'current.window.title', 'Funk Mix: Game Over')
    setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'empty')
    initPauseMenu()
end

function onCountdownTick(swagCounter)
    if ghostTapping then
        hadghosttapping = true
        setPropertyFromClass('backend.ClientPrefs', 'data.ghostTapping', false)
    end
end

local options = {"CONTINUE","RETRY","OPTIONS","END"}
local pauseMenuSprs = {}
local selectedOption = 1

local function initPauseMenu()
    precacheImage("pause/bg")
    precacheImage("pause/pause")
    precacheImage("pause/progressbar")
    precacheImage("pause/stand")
    precacheImage("pause/selector")

    precacheSound("menu_select")
    precacheSound("pause")
    precacheSound("stomp")
    precacheSound("coin")
    
    makeLuaSprite('substateBG', 'pause/bg', 0, 0)
    scaleObject("substateBG", 10, 10)
    screenCenter('substateBG', 'xy')

    makeLuaSprite('pauseText', 'pause/pause', 0, 0)
    scaleObject("pauseText", 6, 6)
    screenCenter('pauseText', 'X')
    setProperty('pauseText.y', 42)
    setProperty('pauseText.x', getProperty("pauseText.x") -4.05)

    makeLuaText('songnameText', 'GAME OVER', 200, 344.48, 183)
    scaleObject("songnameText", 3, 3)
    setTextFont("songnameText", "smb1.ttf")

    makeLuaSprite('progressbar', 'pause/progressbar', 0, 0)
    scaleObject("progressbar", 6, 6)
    screenCenter('progressbar', 'X')
    setProperty('progressbar.y', 284)
    setProperty('progressbar.x', getProperty("progressbar.x") -4.05)

    makeLuaSprite('mxStand', 'pause/stand', 0, 0)
    scaleObject("mxStand", 6, 6)
    setProperty('mxStand.x', getProperty("progressbar.x"))
    setProperty('mxStand.y', (getProperty("progressbar.y") - getProperty("mxStand.height")) + (getProperty("progressbar.height") / 2))

    makeLuaSprite('selector', 'pause/selector', 0, 0)
    scaleObject("selector", 6, 6)
    screenCenter('selector', 'X')

    table.insert(pauseMenuSprs,"substateBG")

    local curY = 372

    for i,v in ipairs(options) do
        local sprName = tostring(string.lower(v).."Text")
        makeLuaText(sprName, v, 200, 448.1, curY)
        scaleObject(sprName, 3, 3)
        setTextFont(sprName, "smb1.ttf")
        setTextAlignment(sprName,"left")
        curY = curY + 81

        table.insert(pauseMenuSprs,sprName)
    end

    setProperty("selector.x",(getProperty("continueText.x") - (getProperty("continueText.height") / 2) - getProperty("selector.height")))
    setProperty("selector.y",(getProperty("continueText.y") + (getProperty("selector.width") / 4)))
    
    table.insert(pauseMenuSprs,"pauseText")
    table.insert(pauseMenuSprs,"songnameText")
    table.insert(pauseMenuSprs,"progressbar")
    table.insert(pauseMenuSprs,"mxStand")
    table.insert(pauseMenuSprs,"selector")

    for i,v in ipairs(pauseMenuSprs) do
        setObjectCamera(v, 'other')
        setProperty(tostring(v..".antialiasing"),valse)
    end
end

local function updatePauseSelection()
    local optsLen = 0
    for i,_ in ipairs(options) do
        optsLen = i
    end
    if selectedOption < 1 then
        selectedOption = optsLen
    elseif selectedOption > optsLen then
        selectedOption = 1
    end
    local pauseOption = tostring(string.lower(options[selectedOption]).."Text")
    setProperty("selector.x",(getProperty(tostring(pauseOption)..".x") - (getProperty(tostring(pauseOption)..".height") / 2) - getProperty("selector.height")))
    setProperty("selector.y",(getProperty(tostring(pauseOption)..".y") + (getProperty("selector.width") / 4)))
end

-- Custom script to change Boyfriend's and Opponent's strum notes in FNF Psych Engine
function onSongStart()
    setPropertyFromClass('ClientPrefs', 'ghostTapping', false);
end

function onCreatePost()
    setProperty('showComboNum', false)
    setProperty('showRating', false)

    setProperty('timeTxt.visible', false)
    setProperty('scoreTxt.visible', false)

    -- Opponent's strum positions (0-3 for left to right)
    setPropertyFromGroup('opponentStrums', 0, 'x', 700)  -- Left note
    setPropertyFromGroup('opponentStrums', 1, 'x', 825)  -- Down note
    setPropertyFromGroup('opponentStrums', 2, 'x', 950)  -- Up note
    setPropertyFromGroup('opponentStrums', 3, 'x', 1075)  -- Right note

    -- Boyfriend's strum positions (4-7 for left to right)
    setPropertyFromGroup('playerStrums', 0, 'x', 100)    -- Left note
    setPropertyFromGroup('playerStrums', 1, 'x', 225)    -- Down note
    setPropertyFromGroup('playerStrums', 2, 'x', 350)   -- Up note
    setPropertyFromGroup('playerStrums', 3, 'x', 475)   -- Right note

    setProperty('healthBar.visible', false)        -- The main health bar
    setProperty('healthBarBG.visible', false)      -- The background of the health bar
    setProperty('iconP1.visible', false)           -- The player (Boyfriend) icon
    setProperty('iconP2.visible', false)           -- The opponent (Dad, etc.) icon
end

local function killbf()
    setHealth(1)
    setProperty('boyfriendGroup.visible', false)
    setProperty('bflegs.visible', false)
    openCustomSubstate('gameover', true)
    playSound("death", 1)
    runTimer("restart", 3)

    -- Add the sprite to the custom substate instead of the main game
    -- debugPrint("x"..getBoyfriendX().."/ Y"..getBoyfriendY())
    makeLuaSprite("bfdeadspr", "gameover/bf-dead", getBoyfriendX()-15, getBoyfriendY())
    scaleObject("bfdeadspr", 4, 4)
    --setObjectCamera("bfdeadspr", "hud")
    addLuaSprite("bfdeadspr", true) -- Add the sprite to the custom substate
    setProperty('bfdeadspr.antialiasing', false)

    -- Tween upwards quickly (Mario jumps up)
    doTweenY('jumpUp', 'bfdeadspr', getProperty('bfdeadspr.y') - 80, 0.8, 'circOut')
end

local function playLegsAnim(anim, ground)
    if not ground then
        if anim == "bf-chase" then
            playAnim("bflegs", 'jump', true)
        elseif anim == "bf-chase-fire" then
            playAnim("bflegs", 'jumpfire', true)
        elseif anim == "bf-chase-small" then
            playAnim("bflegs", 'jumpsmall', true)
        end
    else
        if anim == "bf-chase" then
            playAnim("bflegs", 'run', true)
        elseif anim == "bf-chase-fire" then
            playAnim("bflegs", 'runfire', true)
        elseif anim == "bf-chase-small" then
            playAnim("bflegs", 'runsmall', true)
        end
    end
end

local function playMxLegsAnim(anim, ground)
    if not ground then
        playAnim("legs", 'jump', true)
    else
        -- debugPrint(anim)
        if anim == "mx" then
            playAnim("legs", 'legs', true)
        else
            playAnim("legs", 'legsmad', true)
        end
    end
end

function onUpdatePost()
    setProperty("health",1)
    -- Check if the current animation is 'idle' and override it
    local currentAnimation = getProperty('boyfriend.animation.curAnim.name')
    local currentMxAnimation = getProperty('dad.animation.curAnim.name')

    if not bfOnGround then
        setProperty('bflegs.alpha', 1)
        if currentAnimation == 'idle' or currentAnimation == 'jump' then
            -- Play a different animation, e.g., 'singUP', 'singDOWN', etc.
            setProperty('boyfriend.animation.curAnim.name', 'jump')
            playAnim('boyfriend', 'jump', true)
        end
        playLegsAnim(getProperty('boyfriend.curCharacter'),false)
    else
        if currentAnimation == 'idle' then
            setProperty('bflegs.alpha', 0)
        else
            setProperty('bflegs.alpha', 1)
        end
    end
    -- If Boyfriend is about to go to 'idle', prevent it

    if not mxOnGround then
        setProperty('legs.visible', true)
        if currentMxAnimation == 'idle' or currentAnimation == 'jump' then
            -- Play a different animation, e.g., 'singUP', 'singDOWN', etc.
            setProperty('dad.animation.curAnim.name', 'jump')
            playAnim('dad', 'jump', true)
        end
        playMxLegsAnim(getProperty('dad.curCharacter'),false)
    else
        if currentMxAnimation == 'idle' then
            setProperty('legs.visible', false)
        else
            setProperty('legs.visible', true)
        end
    end
end

function onUpdate(elapsed)
    -- Gameover (the real one)
    if mushroomkill then
        killbf()
    end
    setProperty("popup.x", inGameBoyfriendX-300-popupx)
    setProperty("popup.y", groundlevel-265)

    -- gravity stuff

    -- Apply gravity to bfVelocityY if he's not on the ground
    if not bfOnGround then
        bfVelocityY = bfVelocityY + gravity * elapsed
        if getProperty('boyfriend.animation.curAnim.name') == "idle" then
            playAnim('boyfriend', 'jump', true)
        end
    end
        
    -- Move the boyfriend based on his velocity
    local bfY = inGameBoyfriendY
    inGameBoyfriendY = bfY + bfVelocityY * elapsed
    
    -- Check if the space key is pressed for jumping
    if bfOnGround and getPropertyFromClass("flixel.FlxG","keys.justPressed.SPACE") and mxrunning then
        bfmxjump = true
    end

    if bfmxjump then
        bfmxjump = false
        if overworld then
            table.insert(mxJumpSteps,curStep+5)
        end
        setProperty("boyfriend.flipX", true)
        -- debugPrint("Jump!")
        bfVelocityY = jumpPower  -- Set the jump velocity when space is pressed
        inGameBoyfriendY = inGameBoyfriendY - 1
        bfOnGround = false  -- BF is no longer on the ground
    end
    
    -- Check if BF is hitting the ground (assuming 500 is the ground level)
    if inGameBoyfriendY >= groundGravitylevel then
        if not bfOnGround then
            -- debugPrint("ground!")
            playLegsAnim(getProperty('boyfriend.curCharacter'),true)
            if getProperty('boyfriend.animation.curAnim.name') == "jump" then
                playAnim('boyfriend', 'idle', true)
            end
        end
        bfOnGround = true  -- BF is on the ground
        inGameBoyfriendY = groundGravitylevel  -- Reset BF to ground level
        bfVelocityY = 0  -- Reset vertical velocity when BF hits the ground
    end

    -- mx gravity stuff

    -- Apply gravity to mxVelocityY if he's not on the ground
    if not mxOnGround then
        mxVelocityY = mxVelocityY + gravity * elapsed
        if getProperty('dad.animation.curAnim.name') == "idle" then
            playAnim('dad', 'jump', true)
        end
    end
        
    -- Move the boyfriend based on his velocity
    local mxY = inGameDadY
    inGameDadY = mxY + mxVelocityY * elapsed
    
    -- Check if the space key is pressed for jumping
    if mxOnGround and mxJump and mxrunning then
        mxJump = false
        -- setProperty("dad.flipX", true)
        -- debugPrint("Jump!")
        mxVelocityY = mxJumpPower  -- Set the jump velocity when space is pressed
        inGameDadY = inGameDadY - 1
        mxOnGround = false  -- BF is no longer on the ground
    end
    
    -- Check if MX is hitting the ground (assuming 500 is the ground level)
    if inGameDadY >= mxGroundGravitylevel then
        if not mxOnGround then
            -- debugPrint("ground!")
            playMxLegsAnim(getProperty('dad.curCharacter'),true)
            if getProperty('boyfriend.animation.curAnim.name') == "jump" then
                playAnim('dad', 'idle', true)
            end
        end
        mxOnGround = true  -- BF is on the ground
        inGameDadY = mxGroundGravitylevel  -- Reset BF to ground level
        mxVelocityY = 0  -- Reset vertical velocity when BF hits the ground
    end

    -- move bf and mx
    if mxrunning then
        setProperty("boyfriend.flipX", false)
        inGameBoyfriendX = inGameBoyfriendX - runningspeed
        setProperty("boyfriend.x", inGameBoyfriendX)
        setProperty("boyfriend.y", inGameBoyfriendY)
        if camerabffollow then
            triggerEvent("Camera Follow Pos", inGameBoyfriendX-200, inGameBoyfriendY)
            -- triggerEvent("Camera Follow Pos", getProperty('bflegs.x'), getProperty('bflegs.y'))
            -- triggerEvent("Camera Follow Pos", getProperty('legs.x'), getProperty('legs.y'))
        else
            triggerEvent("Camera Follow Pos", inGameBoyfriendX-200, groundlevel-100)
        end

        inGameDadX = inGameDadX - runningspeed
        setProperty("dad.x", inGameDadX)
        setProperty("dad.y", inGameDadY)
        -- MX Legs
        setProperty("legs.x", getProperty('dad.x')+32)
        setProperty("legs.y", getProperty('dad.y')-205)

        updateBfLegs()
        -- setProperty('defaultCamZoom', 0.3)
    end

    if mxbfhiding then
        setProperty("boyfriend.x", inGameBoyfriendX-20)
        setProperty("boyfriend.y", groundlevel-138)
    end
    -- debugPrint(mushroomkill)
end

-- Stage Creation

local function createLoopGround()
    local sprite = "background/pcport/loop"
    local groundSpawnX = 291
    if overworld then
        sprite = "background/pcport/loopdark"
        groundSpawnX = 387
    end
    spritename = tostring("loopbg_"..loop)
    makeLuaSprite(spritename,sprite,getBoyfriendX()-6000,groundlevel-groundSpawnX)
    scaleObject(spritename,6,6)
    setProperty(tostring(spritename..'.antialiasing'), false)
    addLuaSprite(spritename, true)
    table.insert(loopsbgs,spritename)
    -- debugPrint(tostring("BG sprite "..spritename.." created!"))

    setObjectOrder('boyfriendGroup', getObjectOrder(spritename) + 1)
    setObjectOrder('dadGroup', getObjectOrder(spritename) + 1)

    setObjectOrder('legs', getObjectOrder("dadGroup") - 1)
    setObjectOrder('bflegs', getObjectOrder("boyfriendGroup") - 1)

    setObjectOrder("endpipe", getObjectOrder("boyfriendGroup") + 1)

    setObjectOrder('popup', getObjectOrder(spritename) + 3)

    loop = loop + 1
    if not overworld then
        runTimer("block",2.55)
        runTimer("breakBlock",2.90)
        runTimer("breakBlock1",3.415)
        runTimer("pit",2.9)
        runTimer("pit2",4.5)
        runTimer("mxJump",3.1)
        runTimer("mxJump1",4.9)
        if botPlay then
            runTimer("autoJump",1.95)
            runTimer("autoJump1",2.7)
            runTimer("autoJump2",4.1)
        end
    else
        runTimer("pit2",3.5)
        runTimer("pit3",4.6)
        if botPlay then
            runTimer("autoJump",3.3)
            runTimer("autoJump1",4.3)
            cancelTimer("autoJump2")
        end
    end
end

local function createEndPipe()
    spritename = "endpipe"
    makeLuaSprite(spritename,"background/pcport/endpipe",getBoyfriendX()-6000,groundlevel-291)
    scaleObject(spritename,6,6)
    setProperty(tostring(spritename..'.antialiasing'), false)
    addLuaSprite(spritename, true)
    -- debugPrint(tostring("Endpipe "..spritename.." created!"))
end

local function kill()
    if mxrunning and not mxbfhiding then
        killbf()
    end
end

local function section2()
    setOnLuas("mxbfhiding", true)
    setOnLuas("mxupdatepowerup", true)
    setProperty("bf.x", inGameBoyfriendX-100)

    setProperty("dad.x", inGameBoyfriendX-125)
    setProperty("dad.y", getBoyfriendY()-125)

    makeLuaSprite("hiddenwall","background/pcport/hiddenwall",inGameBoyfriendX-350, getBoyfriendY()-300)
    scaleObject("hiddenwall", 5, 5)
    setProperty('hiddenwall.antialiasing', false)
    addLuaSprite("hiddenwall",true)

    setObjectOrder('boyfriendGroup', getObjectOrder('hiddenwall') + 1)
    removeLegs()
end

local function luigiIsReal()
    makeLuaSprite("luigi","background/pcport/luigi",0, 0)
    scaleObject("luigi", 9, 9)
    setObjectCamera('luigi', 'hud')
    screenCenter("luigi","xy")
    setProperty('luigi.antialiasing', false)
    addLuaSprite("luigi",true)
end

local function innocenceDoesntGetYouFar()
    makeLuaSprite("popup","background/pcport/popup",inGameBoyfriendX, inGameBoyfriendY)
    scaleObject("popup", 6, 6)
    setObjectCamera('popup', 'game')
    -- screenCenter("popup","xy")
    setObjectOrder('popup', getObjectOrder('strumLineNotes') - 1)
    setProperty('popup.antialiasing', false)
    addLuaSprite("popup",true)
end

local function makeBlock(block)
    local sprName = tostring("block"..block)
    -- debugPrint(tostring("Block ".. sprName .. " created!"))
    makeLuaSprite(sprName,"",inGameDadX-50,groundlevel-30)
    makeGraphic(sprName, 150, 128, "#000000")
    setProperty(tostring(sprName..".antialiasing"), false)
    setObjectOrder(sprName, getObjectOrder("dadGroup") - 1)
    addLuaSprite(sprName,true)
end

local function breakBlock()
    block = block + 1
    makeBlock(block)
    playSound("break")
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == "restart" then
        restartSong(true)
    elseif tag == 'fallDelay' then
        -- Now, make the sprite fall down slower, similar to gravity
        doTweenY('fallDown', 'bfdeadspr', getProperty('bfdeadspr.y') + 500, 1, 'circIn')
    elseif tag == "ghostTapping" then
        exitSong(true)
    elseif tag == "bgLoop" then
        createLoopGround()
    elseif tag == "resetGround" then
        -- debugPrint(inGameBoyfriendY)
        groundGravitylevel = groundlevel
        bfOnGround = false
    elseif tag == "pit" then
        groundGravitylevel = groundGravitylevel + 200
        bfOnGround = false
        runTimer("block2",0.2)
    elseif tag == "block" then
        if inGameBoyfriendY >= 725 then
            kill()
        end
        groundGravitylevel = groundlevel - 100
    elseif tag == "breakBlock" or tag == "breakBlock1" then
        breakBlock()
    elseif tag == "block2" then
        if inGameBoyfriendY >= 822 then
            kill()
        end
        groundGravitylevel = groundlevel - 100
        runTimer("resetGround",0.1)
    elseif tag == "pit2" then
        local time = 0.3
        groundGravitylevel = groundGravitylevel + 200
        bfOnGround = false
        runTimer("pit2test",0.29)
        runTimer("resetGround",time)
    elseif tag == "pit3" then
        groundGravitylevel = groundGravitylevel + 200
        bfOnGround = false
        runTimer("pit3test",0.29)
        runTimer("resetGround",0.3)
    elseif tag == "pit2test" or tag == "pit3test" then
        if inGameBoyfriendY >= 848 then
            kill()
        end
    elseif tag == "mxJump" or tag == "mxJump1" then
        mxJump = true
    elseif tag == "autoJump" or tag == "autoJump1" or tag == "autoJump2" then
        if bfOnGround then
            bfmxjump = true
        end
    elseif tag == "end" then
        endSong()
    end
end

function onGameOver()
    return Function_Stop
    -- restartSong(true)
end

-- When the upward motion completes, fall down with gravity-like behavior
function onTweenCompleted(tag)
    if tag == 'jumpUp' then
        -- Small delay to mimic the pause at the peak
        runTimer('fallDelay', 0.3)
    end
end

function onSongStart()
    songStarted = true
end

function onCustomSubstateUpdate(name, elapsed)
    if name == "customPause" then
        local progress = getSongPosition() / songLength

        local diff = getProperty('progressbar.width') / 16
        local startX = getProperty('progressbar.x') + diff -- posición inicial
        local width = getProperty('progressbar.width') - (diff * 4.4) -- ancho total de la barra
    
        setProperty('mxStand.x', startX + (progress * width))

        if keyJustPressed("up") then
            selectedOption = selectedOption - 1
        elseif keyJustPressed("down") then
            selectedOption = selectedOption + 1
        end

        if keyJustPressed("up") or keyJustPressed("down") then
            playSound("menu_select")
            updatePauseSelection()
        end

        -- Check if the player presses the Space key to exit the substate
        if keyJustPressed('accept') then
            local optionText = tostring(string.lower(options[selectedOption]))
            if optionText == "continue" then
                for i,v in ipairs(pauseMenuSprs) do
                    removeLuaSprite(v)
                end
                playSound("pause")
                closeCustomSubstate() -- Close the substate and return to the main game
            elseif optionText == "retry" then
                playSound("stomp")
                restartSong()
            elseif optionText == "options" then
                playSound("stomp")
                -- THANKS YOU SO MUCH TABI REVIVAL MOD, your tha best!
                runHaxeCode([[
                import options.OptionsState;
                import backend.MusicBeatState;
                game.paused = true;
                game.vocals.volume = 0;
                MusicBeatState.switchState(new OptionsState());
                if (ClientPrefs.data.pauseMusic != 'None') {
                    FlxG.sound.playMusic(Paths.music("freakyMenu"), game.modchartSounds('pauseMusic').volume);
                    FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
                    FlxG.sound.music.time = game.modchartSounds('pauseMusic').time;
                }
                OptionsState.onPlayState = true;
                ]])
            elseif optionText == "end" then
                playSound("coin")
                exitSong()
            end
        end
    elseif name == "endpipe" then
        inGameBoyfriendX = inGameBoyfriendX - (runningspeed/4)
        setProperty("boyfriend.x", inGameBoyfriendX)
        inGameBoyfriendY = groundlevel-20
        setProperty("boyfriend.y", inGameBoyfriendY)
        updateBfLegs()
    end
end

function onSoundFinished(tag)
    if tag == 'music' then
        playSound("breakfast", 0.8, "music")
    end
end

function onPause()
    if songStarted then
        if not keyPressed("Left") or not keyPressed("Right") or not keyPressed("Up") or not keyPressed("Down") then
            initPauseMenu()
            for i,v in ipairs(pauseMenuSprs) do
                addLuaSprite(v,true)
            end
            playSound("pause")
            updatePauseSelection()
            openCustomSubstate('customPause', true)
            -- Create elements of the substate when it is initialized
        end
    end
    if not keyPressed("Left") or not keyPressed("Right") or not keyPressed("Up") or not keyPressed("Down") then
        return Function_Stop
    end
end

function onDestroy()
    setPropertyFromClass('lime.app.Application', 'current.window.title', "Friday Night Funkin: Psych Engine")
    if hadghosttapping then
        setPropertyFromClass('backend.ClientPrefs', 'data.ghostTapping', true)
    end
end

local function removeBgs()
    for i,sprname in ipairs(loopsbgs) do
        removeLuaSprite(sprname)
    end
end

function onSectionHit()
    if curSection == 48 or curSection == 128 then
        if curSection == 128 then
            overworld = true
            setProperty("boyfriend.x", inGameBoyfriendX)
        end
        removeBgs()
        cancelTimer("block")
        cancelTimer("pit")
        cancelTimer("pit2")
        cancelTimer("mxJump")
        cancelTimer("mxJump1")
        cancelTimer("breakBlock")
        cancelTimer("breakBlock1")
        makelegs()
        makebflegs()
        createLoopGround()
        runTimer("bgLoop",5.8,0)
        setOnLuas("mxrunning", true)
        setOnLuas("mxbfhiding", false)
        setOnLuas("mxupdatepowerup", true)
        canJump = true
        removeLuaSprite("hiddenwall",true)
    elseif curSection == 80 then
        removeLuaSprite("popup",true)
        camerabffollow = true
    end
end

function onStepHit()
    -- mxOnGround = bfOnGround

    for i,s in ipairs(mxJumpSteps) do
        -- debugPrint(tostring(curStep.."/"..s))
        if curStep == s then
            -- debugPrint(tostring(curStep.."/"..s))
            mxJump = true
            table.remove(mxJumpSteps,i)
        end
    end

    if curStep == 1255 then
        camerabffollow = false
        innocenceDoesntGetYouFar()
    elseif curStep == 1262 or curStep == 1264 or curStep == 1265 or curStep == 1267 then
        popupx = popupx + 960
    elseif curStep == 1530 then
        setOnLuas("mxrunning", false)
        setOnLuas("mxupdatepowerup", true)
        cancelTimer("bgLoop")
        removeBgs()
    elseif curStep == 1532 then
        luigiIsReal()
    elseif curStep == 1536 then
        removeLuaSprite("luigi", true)
        section2()
    elseif curStep == 2325 then
        createEndPipe()
    elseif curStep == 2341 then
        setOnLuas("mxrunning", false)
        cancelTimer("bgLoop")
        openCustomSubstate("endpipe",false)
        -- playSound("endsfx", 1)
        runTimer("end",3)
        triggerEvent("Camera Follow Pos", inGameBoyfriendX, inGameBoyfriendY)
    end
end