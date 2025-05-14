local keys = {"left","down","up","right"}
local danceDirections = {"left","down","up","right","left","down","up","right"}
local directions = {'purple', 'blue', 'green', 'red', 'purple', 'blue', 'green', 'red'}
local players = {3,4}
local playersSprites = {}

local function getNoteX(lane)
    if lane >= 4 then
        return getPropertyFromGroup('opponentStrums', lane - 4, 'x')
    else
        return getPropertyFromGroup('playerStrums', lane, 'x')
    end
end

function onCreatePost()
    createCustomStrums()
end

function onUpdatePost(elapsed)
    updateCustomStrums()
    for plrIndex,plr in ipairs(players) do
        if getModSetting(tostring("player"..plr)) then
            for i, key in ipairs(keys) do
                if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.'..getModSetting(tostring("player"..plr.."-"..key.."key"))["keyboard"]) then
                    playAnim("customStrum"..i-1,'pressed', true)
                    setProperty("customStrum"..(i-1)..".visible",true)
                    local closestNote = nil
                    local closestTimeDiff = math.huge
                    for noteIndex,note in ipairs(visualNotes) do
                        if note.lane == i - 1 then
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
                        playAnim("customStrum"..i-1,'confirm', true)
                        removeLuaSprite(closestNote.sprite)
                        table.remove(visualNotes,closestNote.index)
                        local idleWait = 0.3
                        local danceDir = danceDirections[closestNote.lane + 1]
                        playAnim(closestNote.player,danceDir)
                        table.remove(playersSprites,plrIndex)
                        table.insert(playersSprites,plrIndex,closestNote.player)
                        runTimer(tostring("resetidle"..plr), idleWait)
                    end
                end
                if getPropertyFromClass('flixel.FlxG', 'keys.justReleased.'..getModSetting(tostring("player"..plr.."-"..key.."key"))["keyboard"]) then
                    playAnim("customStrum"..i-1,'static', true)
                    setProperty("customStrum"..(i-1)..".visible",false)
                end
            end
        end
    end
end

function onTimerCompleted(tag)
    for _,plr in ipairs(players) do
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
    for notePathIndex,notePath in ipairs(invertTable(customStrums)) do
        for i = 4, 1, -1 do
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

function updateCustomStrums()
    local strum = 0
    for notePathIndex,_ in ipairs(invertTable(customStrums)) do
        for i = 4, 1, -1 do
            local x = getNoteX(strum)
            local spriteName = tostring("customStrum"..strum)
            setProperty(spriteName..".x",x)
            setProperty(spriteName..".y",getPropertyFromGroup("strumLineNotes", strum, "y"))
            strum = strum + 1
        end
    end
end