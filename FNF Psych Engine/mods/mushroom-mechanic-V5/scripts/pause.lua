local songStarted = false
local options = {"CONTINUE","RETRY","OPTIONS","END"}
local spanishOptions = {"CONTINUAR", "REINTENTAR", "OPCIONES", "END"}
local pauseMenuSprs = {}
local selectedOption = 1

function table.contains (table, element)
    for _,value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

local function initPauseMenu()
    makeLuaSprite('substateBG', 'pause/bg', 0, 0)
    scaleObject("substateBG", 10, 10)
    screenCenter('substateBG', 'xy')

    local pauseSprPath = 'pause/PAUSE'
    if getPropertyFromClass("backend.ClientPrefs", "data.language") == "es-AR" then
        pauseSprPath = "es-AR/pause/PAUSE"
    end
    makeLuaSprite('pauseText', pauseSprPath, 0, 0)
    scaleObject("pauseText", 6, 6)
    screenCenter('pauseText', 'X')
    setProperty('pauseText.y', 42)
    setProperty('pauseText.x', getProperty("pauseText.x") -4.05)

    local pauseText = songName
    if songName == "Gameover" then
        pauseText = 'GAME OVER'
    end
    makeLuaText('songnameText', pauseText, 200, 344.48, 183)
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
        if getPropertyFromClass("backend.ClientPrefs", "data.language") == "es-AR" then
            v = spanishOptions[i]
        end
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

function onCreate()
    local lang = getPropertyFromClass("backend.ClientPrefs", "data.language")

    precacheImage("pause/bg")
    
    precacheImage("pause/progressbar")
    precacheImage("pause/stand")
    precacheImage("pause/selector")

    precacheSound("menu_select")
    precacheSound("pause")
    precacheSound("stomp")
    precacheSound("coin")

    if lang ~= "es-AR" then
        precacheImage("pause/PAUSE")
    else
        precacheImage("es-AR/pause/PAUSE")
    end
end

function onPause()
    if not table.contains(songs, songName) then return end
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
    end
end

function onSongStart()
    songStarted = true
end