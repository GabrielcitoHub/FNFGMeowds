local keys = {"left","down","up","right"}
local danceDirections = {"left","down","up","right","left","down","up","right"}
local directions = {'purple', 'blue', 'green', 'red', 'purple', 'blue', 'green', 'red'}
local players = {3,4}
local powerups = {}
local flashings = {}
local flashstates = {}
local displays = 3
local playersSprites = {}

local timersTags = {}
local timersTimes = {}
local timersStartTimes = {}
local timersLoops = {}

local function getNoteX(lane)
    if lane >= 4 then
        return getPropertyFromGroup('opponentStrums', lane - 4, 'x')
    else
        return getPropertyFromGroup('playerStrums', lane, 'x')
    end
end

local function getPlayersSprites()
    local playersSprites = {}
    for plrIndex,plr in ipairs(players) do
        local data = 0
        if plr == 3 then
            data = data + 4
        end
        for _,note in ipairs(visualNotes) do
            if note.lane == data then
                if not table.contains(playersSprites,note.player) then
                    table.insert(playersSprites,plrIndex,note.player)
                    break
                end
            end
        end
    end
    return playersSprites
end

function table.contains (table, element)
    for _,value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function table.set(t,i,v)
    table.remove(t,i)
    table.insert(t,i,v)
end

function onCreatePost()
    createCustomStrums()
    runTimer("getPlrsSprs",0.1)
    for plrIndex,plr in ipairs(players) do
        table.insert(powerups,plrIndex,2)
        table.insert(flashings,plrIndex,false)
        table.insert(flashstates,plrIndex,false)
        if getModSetting(tostring("player"..plr)) then
            createDisplay(plr)
            displays = displays + 1
        else
            createDisplay(plr)
        end
        if not getModSetting(tostring("player"..plr)) then
            setProperty("player"..plr.."powerdisplay.visible",false)
        end
    end
end

function updateTimers(elapsed)
    for i,v in ipairs(timersTags) do
        local time = timersTimes[i]
        local startTime = timersStartTimes[i]
        local loopsLeft = timersLoops[i]
        -- debugPrint(tostring("Time: "..time.." loopsLeft: "..loopsLeft.." StartTime: "..startTime))
        if time > 0 then
            time = time - (1 * elapsed)
            table.set(timersTimes,i,time)
        else
            loopsLeft = loopsLeft - 1
            table.set(timersTimes,i,startTime)
            table.set(timersLoops,i,loopsLeft)
            onCustomTimerCompleted(v,loopsLeft)
            if loopsLeft <= 0 then
                table.remove(timersTags,i)
                table.remove(timersStartTimes,i)
                table.remove(timersTimes,i)
                table.remove(timersLoops,i)
                break
            end
        end
    end
end

function runCustomTimer(tag,time,loops)
    if not loops then
        loops = 1
    end
    table.insert(timersTimes,time)
    table.insert(timersStartTimes,time)
    table.insert(timersLoops,loops)
    table.insert(timersTags,tag)
end

function onCustomTimerCompleted(tag,loopsleft)
    for plrIndex,plr in ipairs(players) do
        if tag == tostring("player"..plr..'fs') or tag == tostring("player"..plr..'fsdown') or tag == tostring("player"..plr..'fsup') then
            local fs = flashstates[plrIndex]
            local plrSprite = playersSprites[plrIndex]
            -- debugPrint(plrSprite)
            setProperty(plrSprite..".visible", fs)
            fs = not fs
            if tag == tostring("player"..plr..'fsdown') or tag == tostring("player"..plr..'fsup') then
                table.set(flashstates,plrIndex,fs)
                table.set(flashings,plrIndex,true)
                if loopsleft == 0 then
                    setProperty(plrSprite..".visible", true)
                    table.set(flashings,plrIndex,false)
                end
            end
        end
    end
end

local oldNoteTime = 0

function onUpdatePost(elapsed)
    updateTimers(elapsed)
    updateCustomStrums()
    for plrIndex,plr in ipairs(players) do
        updateDisplay(plr)
        if getModSetting(tostring("player"..plr)) then
            if not botPlay then
                local newy = -100
                if downscroll then
                    newy = newy * - 1
                end
                setProperty("sticker.x",getProperty("powerdisplay.x"))
                setProperty("sticker.y",getProperty("powerdisplay.y")+newy)
            end
            for i, key in ipairs(keys) do
                local data = i - 1
                if plr == 3 then
                    data = data + 4
                end
                -- check for misses
                local missedNotes = {}
                for _,note in ipairs(visualNotes) do
                    if note.lane == data then
                        local timeDiff = math.abs(note.strumTime - getSongPosition())
                        local collisionRange = 225
                        if timeDiff <= collisionRange - 175 then
                            table.insert(missedNotes,note)
                        end
                    end
                end
                for missedNoteIndex,missedNote in ipairs(missedNotes) do
                    table.remove(missedNotes,missedNoteIndex)
                    removeLuaSprite(missedNote.sprite)
                    onPlayerMiss(plr,plrIndex)
                end
                if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.'..getModSetting(tostring("player"..plr.."-"..key.."key"))["keyboard"]) then
                    playAnim("customStrum"..data,'pressed', true)
                    setProperty("customStrum"..data..".visible",true)
                    local closestNote = nil
                    local closestTimeDiff = math.huge
                    for noteIndex,note in ipairs(visualNotes) do
                        if note.lane == data then
                            local timeDiff = math.abs(note.strumTime - getSongPosition())
                            local collisionRange = 225
                            if timeDiff <= collisionRange and timeDiff < closestTimeDiff then
                                note.index = noteIndex
                                closestNote = note
                                closestTimeDiff = timeDiff
                            end
                        end
                    end
                    if closestNote then
                        if oldNoteTime == closestNote.strumTime then
                            debugPrint("COPY DETECTED! "..oldNoteTime)
                        end
                        oldNoteTime = closestNote.strumTime
                        playAnim("customStrum"..data,'confirm', true)
                        removeLuaSprite(closestNote.sprite)
                        table.remove(visualNotes,closestNote.index)
                        local idleWait = 0.3
                        local danceDir = danceDirections[closestNote.lane + 1]
                        playAnim(closestNote.player,danceDir)
                        table.set(playersSprites,plrIndex,closestNote.player)
                        runTimer(tostring("resetidle"..plr), idleWait)
                    else
                        onPlayerMiss(plr,plrIndex)
                    end
                end
                if getPropertyFromClass('flixel.FlxG', 'keys.justReleased.'..getModSetting(tostring("player"..plr.."-"..key.."key"))["keyboard"]) then
                    playAnim("customStrum"..data,'static', true)
                    setProperty("customStrum"..data..".visible",false)
                end
            end
        end
    end
end

function onPlayerMiss(plr,plrIndex)
    local flashing = flashings[plrIndex]
    if not flashing then
        table.set(flashings,plrIndex,true)
        local powerup = powerups[plrIndex]
        local timerName = "player"..plr..'fsdown'
        -- debugPrint(powerup)
        table.set(powerups,plrIndex,powerup-1)
        playSound('power_down', 1)
        runCustomTimer(timerName,0.05,32)
        updatePowerDisplay(plr)
        local plrSprite = playersSprites[plrIndex]
        if powerup == 0 then
            setProperty(plrSprite..".visible",false)
            setOnLuas("mushroomkill",true)
        end
    end
end

function onTimerCompleted(tag,loops,loopsleft)
    if tag == "getPlrsSprs" then
        playersSprites = getPlayersSprites()
    end
    for plrIndex,plr in ipairs(players) do
        if tag == tostring("resetidle"..plr) then
            local plrSprite = playersSprites[plr-2]
            playAnim(plrSprite,"idle",true)
        end
    end
end

function invertTable(t)
    local inverted = {}
    for i = #t, 1, -1 do
        table.insert(inverted, t[i])
    end
    return inverted
end

function createCustomStrums()
    local strum = 0
    for _,notePath in ipairs(invertTable(customStrums)) do
        for _ = 4, 1, -1 do
            local x = getNoteX(strum)
            local spriteName = tostring("customStrum"..strum)
            -- debugPrint(spriteName)
            makeAnimatedLuaSprite(spriteName,notePath,x,getPropertyFromGroup("strumLineNotes", strum, "y"))
            scaleObject(spriteName, 0.7, 0.7)
            setObjectCamera(spriteName,"other")
            arrowDir = string.upper(danceDirections[strum + 1])
           -- Agregamos una animación básica
            addAnimationByPrefix(spriteName, 'static', "arrow"..arrowDir, 0, true)
            addAnimationByPrefix(spriteName, 'pressed', tostring(string.lower(arrowDir).." press"), 0, true)
            addAnimationByPrefix(spriteName, 'confirm', tostring(string.lower(arrowDir).." confirm"), 10, true)
            playAnim(spriteName, 'static', true)
            
            addLuaSprite(spriteName)
            setProperty(spriteName..".visible",false)
            -- debugPrint((tostring("customStrum"..(notePathIndex-1)..i-1)))
            strum = strum + 1
        end
    end
end

function createDisplay(plr)
    local spritename = "player"..plr..'powerdisplay'
    local y = getProperty('powerdisplay.y') or 600
    if downscroll then
        y = getProperty('powerdisplay.y') or 30
    end
    makeLuaSprite(spritename,tostring('powerstates/'..getPowerup(plr-2)),((50+(getProperty('powerdisplay.height') or 50))*displays)-150,y)
    scaleObject(spritename,scaleSize,scaleSize)
    setProperty(spritename..".antialiasing", false)
    setObjectCamera(spritename,"hud")
    addLuaSprite(spritename, true)
end

function updateDisplay(plr)
    setProperty("player"..plr.."powerdisplay.y",getProperty('powerdisplay.y'))
end

function updatePowerDisplay(plr,powerup)
    loadGraphic("player"..plr.."powerdisplay", tostring('powerstates/'..getPowerup(plr-2)))
end

function getPowerup(plr)
    local powerup = powerups[plr]
    return powerup
end

function updateCustomStrums()
    local strum = 0
    for _,_ in ipairs(invertTable(customStrums)) do
        for _ = 4, 1, -1 do
            local x = getNoteX(strum)
            local spriteName = tostring("customStrum"..strum)
            setProperty(spriteName..".x",x)
            setProperty(spriteName..".y",getPropertyFromGroup("strumLineNotes", strum, "y"))
            strum = strum + 1
        end
    end
end