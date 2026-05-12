local tailsGrabbed = false
local bgSpeedX = 0
local offsetX = -12
local offsetY = 20
local Clones = {}

function hexToRGB(hex)
    local r = tonumber(hex:sub(2,3), 16) / 255
    local g = tonumber(hex:sub(4,5), 16) / 255
    local b = tonumber(hex:sub(6,7), 16) / 255
    return r, g, b
end


-- function onCreatePost()
--     -- Aplica el shader a un sprite (ej. 'boyfriend')
--     setSpriteShader('water', 'replaceColor')

--     -- Pasa los colores: el que quieres reemplazar y el nuevo
--     local r1, g1, b1 = hexToRGB("#991177") -- fromColor
--     local r2, g2, b2 = hexToRGB("#6C90B4") -- toColor

--     setShaderFloatArray('water',"fromColor",{r1,g1,b1})
--     setShaderFloatArray('water',"toColor",{r2,g2,b2})
-- end

function onCreate()
    setProperty("tornado.visible", false)
    setProperty("checkerboard.visible", false)
end


local function exeChange(exe)
    if exe then
        playAnim("bg","exe",true)
        playAnim("green-flower","exe",true)
        playAnim("red-flower","exe",true)
    else
        playAnim("bg","normal",true)
        playAnim("green-flower","green",true)
        playAnim("red-flower","red",true)
    end
end

function changeCharacter(obj, char)
    local tag = obj
    local x, y = getProperty(tag .. ".x"), getProperty(tag .. ".y")
    local mirrored = getProperty(tag .. ".flipX")
    makeAnimatedLuaSprite(tag, "characters/" .. char, x, y)
    setProperty(tag .. ".flipX", mirrored)
    setProperty(tag .. ".antialiasing", false)
    
    addAnimationByPrefix(tag, "idle", "idle", 16, true)
    addAnimationByPrefix(tag, "up", "up", 12, false)
    addAnimationByPrefix(tag, "down", "down", 12, false)
    addAnimationByPrefix(tag, "left", "left", 12, false)
    addAnimationByPrefix(tag, "right", "right", 12, false)
    
    playAnim(obj, "idle", true)
    addLuaSprite(tag, true)
end

function moveBG(x, y)
    local mx = x or 0
    local my = y or 0

    if mx == 0 and my == 0 then return end
    local startmx, startmy = mx, my
    
    local sky = "sky"
    local water = "water"
    local objects = Clones
    for _,tagObject in pairs(objects) do
        mx = startmx
        my = startmy
        local tag, original = tagObject.tag, tagObject.original
        if original == sky then
            mx = mx / 2
            my = my / 2
        end

        setProperty(tag .. ".x", getProperty(tag .. ".x") + mx)
        setProperty(tag .. ".y", getProperty(tag .. ".y") + my)

        local x, y = getProperty(tag .. ".x"), getProperty(tag .. ".y")
        local w, h = getProperty(tag .. ".width"), getProperty(tag .. ".height")

        if x < -w then
            setProperty(tag .. ".x", w)
        end

        -- if y < 0 then
        --     setProperty(tag .. ".y", h)
        -- end
    end
end

function cloneBG(clones)
    local sky = "sky"
    local water = "water"
    local objects = {sky, water}
    for _,tag in pairs(objects) do
        table.insert(Clones, {tag = tag, original = tag})
        local x, y = getProperty(tag .. ".x"), getProperty(tag .. ".y")
        local w, h = getProperty(tag .. ".width"), getProperty(tag .. ".height")

        for i = 1,clones do
            local ctag = tostring(tag .. i + 1)
            local cx, cy = x + w * i, y
            if tag == water then
                makeAnimatedLuaSprite(ctag, "backgrounds/hill/water", cx, cy)

                addAnimationByPrefix(ctag, "flow", "flow", 12, true)

                playAnim(ctag, "flow", true)
            elseif tag == sky then
                makeLuaSprite(ctag, "backgrounds/hill/layer0", cx, cy)
            end

            setProperty(ctag .. ".antialiasing", false)
            addLuaSprite(ctag, true)
            setObjectOrder(ctag, getObjectOrder(tag) - 1)
            table.insert(Clones, {tag = ctag, original = tag})
            -- debugPrint(ctag)
        end
    end
end

function onSectionHit()
    local tag = "tails"
    if curSection == 24 or curSection == 26 or curSection == 28 or curSection == 30 or curSection == 56 or curSection == 72 or curSection == 80 then
        exeChange(true)
    elseif curSection == 25 or curSection == 27 or curSection == 29 or curSection == 48 or curSection == 64 or curSection == 68 or curSection == 73 then
        exeChange(false)
    end

    if curSection == 32 then
        setProperty("tornado.visible", true)
        setProperty("bg.visible", false)

        cloneBG(5)
        bgSpeedX = -5

        setProperty("green-flower.visible", false)
        setProperty("red-flower.visible", false)
        changeCharacter(tag, "tails-tornado")
        setProperty(tag .. ".flipX", false)
        setProperty(tag .. ".x", 263)
        setProperty(tag .. ".y", 69)
        setProperty("boyfriend.x", 277)
        setProperty("boyfriend.y", 26)
        triggerEvent("Play Animation", "fly", "dad")
        setProperty("dad.x", 142)
        setProperty("dad.y", 40)
    elseif curSection == 48 then
        setProperty("tornado.visible", false)

        bgSpeedX = 0
        
        setProperty("checkerboard.visible", true)
        changeCharacter(tag, "tails-cc")
        setProperty(tag .. ".flipX", true)
        setProperty(tag .. ".x", 246)
        setProperty(tag .. ".y", 100)
        setProperty("boyfriend.x", 216)
        setProperty("boyfriend.y", 100)
        triggerEvent("Play Animation", "idle", "dad")
        setProperty("dad.x", 82)
        setProperty("dad.y", 100)
    elseif curSection == 63 then
        changeCharacter(tag, "tails-super")
        setProperty(tag .. ".x", 254)
        setProperty(tag .. ".y", 111)

        addAnimationByPrefix(tag, "unleash", "unleash", 12, false)
        addAnimationByPrefix(tag, "transform", "transform", 10, false)

        playAnim(tag, "unleash", true)
        playAnim("emeralds", "spawn", true)
    elseif curSection == 64 then
        setProperty("bg.visible", true)
        setProperty("green-flower.visible", true)
        setProperty("red-flower.visible", true)
        setProperty("checkerboard.visible", false)
        setProperty(tag .. ".y", 114)
    elseif curSection == 80 then
        addAnimationByPrefix(tag, "fly", "fly", 12, true)

        playAnim(tag, "fly", true)
        local x, y = getProperty("boyfriend.x"), getProperty("boyfriend.y")
        local w, h = getProperty("boyfriend.width"), getProperty("boyfriend.height")
        local tw, th = getProperty(tag .. ".width"), getProperty(tag .. ".height")
        local time = 0.4
        doTweenX("tailsGrabX", tag, x - w / 2 + tw, time, "cubeOut")
        doTweenY("tailsGrabY", tag, y - h / 2, time)
    end
end

function onTweenCompleted(tweenTag)
    local tag = "tails"
    if tweenTag == "tailsGrabX" then
        tailsGrabbed = true
        setProperty(tag .. ".flipX", false)
        local x = getProperty(tag .. ".x")
        local y = getProperty(tag .. ".y")
        doTweenX("tailsFleeX", tag, x + 200, 0.8, "cubeIn")
        doTweenY("tailsFleeY", tag, y - 300, 0.9, "backIn")
    end
end

function onStepHit()
    if curStep == 1074 or curStep == 1078 then
        exeChange(true)
    elseif curStep == 1076 or curStep == 1080 then
        exeChange(false)
    end

    local tag = "tails"
    if curStep == 1018 then
        setProperty(tag .. ".x", 254)
        setProperty(tag .. ".y", 103)
        playAnim(tag, "transform", true)
    end
end

function onUpdate()
    local tag = "tails"
    if tailsGrabbed then
        local x, y = getProperty(tag .. ".x"), getProperty(tag .. ".y")
        local w, h = getProperty("boyfriend.width"), getProperty("boyfriend.height")
        local tw, th = getProperty(tag .. ".width"), getProperty(tag .. ".height")
        setProperty("boyfriend.x", x - w / 2 + tw / 2)
        setProperty("boyfriend.y", y - h / 2 + th)
    end

    moveBG(bgSpeedX)
end