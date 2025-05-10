local loop = 0
local loopsbgs = {}
local popupx = 0
local camerabffollow = true
setOnLuas("mxrunning", false)
local runningspeed = 4
local overworld = false
local mxJumpSteps = {}
local block = 0

local inGameBoyfriendX = getProperty('boyfriend.x')
local inGameBoyfriendY = getProperty('boyfriend.y')

local inGameDadX = getProperty('dad.x')
local inGameDadY = getProperty('dad.y')

-- jumping vars
local groundlevel = inGameBoyfriendY
local groundGravitylevel = inGameBoyfriendY
local mxGroundGravitylevel = inGameDadY
local gravity = 175  -- Gravity value (affects falling speed
local mxbfjump = false
local jumpPower = -65  -- Jump velocity (affects how high the jump is
local bfVelocityY = 0  -- Initial velocity for the character in the Y-axis
local bfOnGround = true  -- Check if BF is on the ground

-- mx jumping vars
local mxJump = false
local mxJumpPower = -65  -- Jump velocity (affects how high the jump is
local mxVelocityY = 0  -- Initial velocity for the character in the Y-axis
local mxOnGround = true  -- Check if BF is on the ground

local function removeLegs()
    removeLuaSprite("legs")
    removeLuaSprite("bflegs")
end

local function makebflegs()
    makeAnimatedLuaSprite("bflegs", "backgrounds/pcport/bflegs", getProperty('bf.x'), groundlevel)
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
    setProperty("bflegs.x", getProperty('boyfriend.x'))
    setProperty("bflegs.y", getProperty('boyfriend.y'))
end

local function makelegs()
    makeAnimatedLuaSprite("legs","backgrounds/pcport/legs",getProperty('dad.x'),getProperty('dad.y'))
    setProperty('legs.antialiasing', false)
    addLuaSprite("legs",true)
    addAnimationByPrefix("legs", 'legs', 'legs', 60, true)  -- Adjust the prefix and FPS as needed
    addAnimationByPrefix("legs", 'legsmad', 'runmad', 30, true)
    addAnimationByPrefix("legs", 'jump', 'legjump', 0, true)
    playAnim("legs", 'legs', true)
end

local function makespacebar()
    local spaceSprPath = "buttons/space"
    local keySprPath = "buttons/key"
    if getPropertyFromClass("backend.ClientPrefs", "data.language") == "es-AR" then
        spaceSprPath = "es-AR/buttons/space"
        keySprPath = "es-AR/buttons/key"
    end
    if getModSetting("cfgmxactionkey")["keyboard"] == "SPACE" then
        makeAnimatedLuaSprite("spacebar", spaceSprPath, 0, 0)
    else
        makeAnimatedLuaSprite("spacebar", keySprPath, 0, 0)
    end
    setObjectCamera("spacebar","hud")
    scaleObject("spacebar", 20, 20)
    screenCenter("spacebar","xy")
    setProperty('spacebar.antialiasing', false)
    setProperty("spacebar.alpha", (getModSetting("cfgspacebaropacity") / 100))
    
    -- Debugging to make sure the animation exists and groundlevel is valid
    -- debugPrint("groundlevel: " .. tostring(groundlevel))
    
    addAnimationByPrefix("spacebar", 'spawn', 'spawn', 0, false) -- Ensure 'run' is the correct animation prefix
    addAnimationByPrefix("spacebar", 'press', 'press', 0, false)
    addAnimationByPrefix("spacebar", 'pressloop', 'pressloop', 30, true)
end

function onCreate()
    local lang = getPropertyFromClass("backend.ClientPrefs", "data.language")

    precacheSound("stomp")

    precacheImage('gameover/bf-dead')
    precacheImage('backgrounds/pcport/loop')
    precacheImage('backgrounds/pcport/loopdark')
    precacheImage('backgrounds/pcport/legs')
    precacheImage('backgrounds/pcport/bflegs')
    precacheImage('backgrounds/pcport/endpipe')
    precacheImage('backgrounds/pcport/hiddenwall')
    precacheImage('backgrounds/pcport/luigi')
    if lang ~= "es-AR" then
        precacheImage('backgrounds/pcport/popup')
        precacheImage('buttons/space')
        precacheImage('buttons/key')
    else
        precacheImage('es-AR/backgrounds/pcport/popup')
        precacheImage('es-AR/buttons/space')
        precacheImage('es-AR/buttons/key')
    end
    setPropertyFromClass('lime.app.Application', 'current.window.title', 'Funk Mix: Game Over')
    setPropertyFromClass('substates.GameOverSubstate', 'deathSoundName', 'empty')

    if getModSetting("cfgspacebar") then
        makespacebar()
    end
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
    if bfOnGround and getPropertyFromClass("flixel.FlxG","keys.justPressed."..getModSetting("cfgmxactionkey")["keyboard"]) or gamepadJustPressed(0, getModSetting("cfgmxactionkey")["gamepad"]) and mxrunning then
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
        updatedMovingSpeed = (runningspeed * 60) * elapsed
        setProperty("boyfriend.flipX", false)
        inGameBoyfriendX = inGameBoyfriendX - updatedMovingSpeed
        setProperty("boyfriend.x", inGameBoyfriendX)
        setProperty("boyfriend.y", inGameBoyfriendY)
        if camerabffollow then
            triggerEvent("Camera Follow Pos", inGameBoyfriendX-50, inGameBoyfriendY+30)
            -- triggerEvent("Camera Follow Pos", getProperty('bflegs.x'), getProperty('bflegs.y'))
            -- triggerEvent("Camera Follow Pos", getProperty('legs.x'), getProperty('legs.y'))
        else
            triggerEvent("Camera Follow Pos", inGameBoyfriendX-200, groundlevel-100)
        end

        inGameDadX = inGameDadX - updatedMovingSpeed
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
    local sprite = "backgrounds/pcport/loop"
    if overworld then
        sprite = "backgrounds/pcport/loopdark"
    end
    spritename = tostring("loopbg_"..loop)
    makeLuaSprite(spritename,sprite,getProperty('boyfriend.x'),groundlevel)
    setProperty(tostring(spritename..'.x'),getProperty(tostring(spritename..'.x'))-getProperty(tostring(spritename..'.width')))
    setProperty(tostring(spritename..'.y'),getProperty(tostring(spritename..'.y'))-(getProperty(tostring(spritename..'.height'))/2)+(getProperty("boyfriend.height")/2))
    setProperty(tostring(spritename..'.antialiasing'), false)
    addLuaSprite(spritename, true)
    table.insert(loopsbgs,spritename)
    -- debugPrint(tostring("BG sprite "..spritename.." created!"))

    setObjectOrder('boyfriendGroup', getObjectOrder(spritename) + 1)
    setObjectOrder('dadGroup', getObjectOrder(spritename) + 1)

    setObjectOrder('legs', getObjectOrder("dadGroup") - 1)
    setObjectOrder('bflegs', getObjectOrder("boyfriendGroup") - 1)

    setObjectOrder("endpipe", getObjectOrder("boyfriendGroup") + 1)

    setObjectOrder('popup', getObjectOrder(spritename) + 4)

    loop = loop + 1
    if not overworld then
        runTimer("block",2.55)
        runTimer("breakBlock",2.90)
        runTimer("breakBlock1",3.415)
        runTimer("pit",2.9)
        runTimer("pit2",4.5)
        runTimer("mxJump",3.1)
        runTimer("mxJump1",4.9)
        runTimer("autoJump",1.95)
        runTimer("autoJump1",2.6)
        runTimer("autoJump2",4.1)
    else
        runTimer("pit2",3.5)
        runTimer("pit3",4.5)
        runTimer("autoJump",3)
        runTimer("autoJump1",4)
        cancelTimer("autoJump2")
    end
end

local function createEndPipe()
    spritename = "endpipe"
    makeLuaSprite(spritename,"backgrounds/pcport/endpipe",getProperty('boyfriend.x'),groundlevel)
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
    setProperty("dad.y", getProperty('boyfriend.y')-125)

    makeLuaSprite("hiddenwall","backgrounds/pcport/hiddenwall",inGameBoyfriendX, getProperty('boyfriend.y'))
    setProperty('hiddenwall.antialiasing', false)
    addLuaSprite("hiddenwall",true)

    setObjectOrder('boyfriendGroup', getObjectOrder('hiddenwall') + 1)
    removeLegs()
end

local function luigiIsReal()
    makeLuaSprite("luigi","backgrounds/pcport/luigi",0, 0)
    scaleObject("luigi", 9, 9)
    setObjectCamera('luigi', 'hud')
    screenCenter("luigi","xy")
    setProperty('luigi.antialiasing', false)
    addLuaSprite("luigi",true)
end

local function innocenceDoesntGetYouFar()
    local lang = getPropertyFromClass("backend.ClientPrefs", "data.language")
    local sprPath = "backgrounds/pcport/popup"

    if lang == "es-AR" then
        sprPath = "es-AR/backgrounds/pcport/popup"
    end

    makeLuaSprite("popup",sprPath,inGameBoyfriendX, inGameBoyfriendY)
    
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
    if tag == "ghostTapping" then
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
        if botPlay then
            if bfOnGround then
                bfmxjump = true
            end
        else
            if not overworld and tag == "autoJump1" or not getModSetting("cfgspacebar") then return end
            addLuaSprite("spacebar", true)
            playAnim("spacebar", 'spawn', true)
            runTimer("spaceNow",0.2)
        end
    elseif tag == "spaceNow" then
        playAnim("spacebar", 'press', true)
        runTimer("spaceLoop",0.3)
    elseif tag == "spaceLoop" then
        if flashingLights then
            playAnim("spacebar", 'pressloop', true)
        end
        if not overworld then
            runTimer("spaceHide",1)
        else
            runTimer("spaceHide",0.4)
        end
    elseif tag == "spaceHide" then
        removeLuaSprite("spacebar",false)
    elseif tag == "end" then
        endSong()
    end
end

function onCustomSubstateUpdate(name, elapsed)
    if name == "endpipe" then
        inGameBoyfriendX = inGameBoyfriendX - (runningspeed/4)
        setProperty("boyfriend.x", inGameBoyfriendX)
        inGameBoyfriendY = groundlevel-20
        setProperty("boyfriend.y", inGameBoyfriendY)
        updateBfLegs()
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
        cancelTimer("autoJump")
        cancelTimer("autoJump1")
        cancelTimer("autoJump2")
        makelegs()
        makebflegs()
        createLoopGround()
        runTimer("bgLoop",5.8,0)
        setOnLuas("mxrunning", true)
        setOnLuas("mxbfhiding", false)
        setOnLuas("mxupdatepowerup", true)
        removeLuaSprite("hiddenwall",true)
    elseif curSection == 80 then
        removeLuaSprite("popup")
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