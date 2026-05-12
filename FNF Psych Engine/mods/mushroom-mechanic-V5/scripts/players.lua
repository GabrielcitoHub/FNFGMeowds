local keys = {"left","down","up","right"}
local danceDirections = {"left","down","up","right","left","down","up","right"}
local players = {3,4}

local powerups = {}
local flashings = {}
local flashstates = {}
local displays = 3
local playersSprites = {}

local customTimer = require("mods/" .. modFolder .. "/scripts/modules/customTimer")

local function getNoteX(lane)
    return getPropertyFromGroup("strumLineNotes", lane, "x")
end

-- 🔹 helper
local function contains(tbl, element)
    for _,value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

-- 🔹 IMPORTANT: get shared data
local function getPlayersSprites()
    local result = {}

    local visualNotes = getVar("visualNotes") -- 🔥 get from loadSecondChart
    if not visualNotes then return result end

    for plrIndex, plr in ipairs(players) do
        local laneOffset = (plr == 3) and 4 or 0

        for _, note in ipairs(visualNotes) do
            if note.lane == laneOffset then
                if not contains(result, note.player) then
                    table.insert(result, note.player)
                end
                break
            end
        end
    end

    return result
end

function onCreatePost()
    createCustomStrums()

    runTimer("getPlrsSprs", 0.1)

    for plrIndex, plr in ipairs(players) do
        powerups[plrIndex] = 2
        flashings[plrIndex] = false
        flashstates[plrIndex] = false

        local plrName = "player" .. plr

        createDisplay(plrName)

        if not getModSetting(plrName) then
            setProperty(plrName .. "powerdisplay.visible", false)
        else
            displays = displays + 1
        end
    end
end

function onUpdatePost(dt)
    customTimer:update(dt)

    -- 🔥 get sections from shared
    local sections = getVar("sections")
    local sectionVisualNotes = getVar("sectionVisualNotes")

    if sectionVisualNotes ~= nil and sections ~= nil then
        table.insert(sections, sectionVisualNotes)
        setVar("sections", sections) -- keep synced
        setVar("sectionVisualNotes", nil)
    end
    
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

            -- debugPrint(sections or "none")

            for i, key in ipairs(keys) do
                -- Handle iNput
                local keyInput = getModSetting(tostring("player" .. plr .. "-" .. key .. "key"))["keyboard"]
                local data = i - 1
                if plr == 3 then
                    data = data + 4
                end

                local secs = sections
                if secs then
                    if #secs > 2 then
                        local removeSection = secs[1]
                        local visualNotes = removeSection.sectionNotes
                        for _,note in ipairs(visualNotes) do
                            removeLuaSprite(note.sprite)
                        end

                        table.remove(secs,1)
                    end
                    -- check for misses
                    local missedNotes = {}
                    local collisionRange = 225
                    for sectionIndex,visualNotes in ipairs(secs) do
                        -- Handle missing
                        -- for _,note in ipairs(visualNotes) do
                            -- if note.lane == data then
                                -- local timeDiff = math.abs((note.strumTime+300) - getSongPosition())
                                -- debugPrint(timeDiff)
                                -- if timeDiff <= collisionRange then
                                    -- table.insert(missedNotes,note)
                                    -- debugPrint("MISS")
                                    -- debugPrint(timeDiff)
                                -- end
                            -- end
                        -- end
                        -- if #missedNotes > 0 then
                        --     for noteIndex, missedNote in ipairs(missedNotes) do
                        --         removeLuaSprite(missedNote.sprite)
                        --         table.remove(visualNotes,noteIndex)
                        --         sections[sectionIndex] = visualNotes
                        --         onPlayerMiss(plr,plrIndex)
                        --     end
                        -- end

                        -- Handle input
                        -- debugPrint(keyInput)
                        if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.' .. keyInput) then
                            -- debugPrint("Key pressed!! " .. keyInput)
                            playAnim("customStrum" .. data, 'pressed', true)
                            setProperty("customStrum" .. data .. ".visible", true)

                            local closestNote = nil
                            local closestTimeDiff = math.huge
                            local visualNotes = secs[1].sectionNotes
                            -- debugPrint(#secs)
                            -- debugPrint(#visualNotes)
                            for noteIndex,note in ipairs(visualNotes) do
                                local time = note[1]
                                local lane = note[2]
                                if lane == data then
                                    local timeDiff = math.abs(time - getSongPosition())
                                    local cond1 = timeDiff <= collisionRange
                                    local cond2 = timeDiff < closestTimeDiff

                                    -- debugPrint(cond1)
                                    -- debugPrint(cond2)

                                    if cond1 and cond2 then
                                        debugPrint("POG")
                                        -- note.index = noteIndex
                                        closestNote = note
                                        closestTimeDiff = timeDiff
                                    end
                                end
                            end


                            -- debugPrint((closestNote or "nah") .. " !!!")
                            if closestNote then
                                playAnim("customStrum" .. data, 'confirm', true)
                                -- removeLuaSprite(closestNote.sprite)
                                -- table.remove(visualNotes, closestNote.index)
                                -- sections[sectionIndex] = visualNotes
                                table.insert(extraRemovedNotes, {index = i})
                                setOnLuas("extraRemovedNotes", extraRemovedNotes)

                                local idleWait = 0.3
                                local danceDir = danceDirections[closestNote.lane + 1]

                                playAnim(closestNote.player,danceDir)
                                playersSprites[plrIndex] = closestNote.player

                                runTimer(tostring("resetidle" .. plr), idleWait)
                            else
                                -- debugPrint("EEEEEEEEEEEEEEEE")
                                onPlayerMiss(plr, plrIndex)
                            end
                        end

                        
                    end
                else
                    -- debugPrint(keyInput)
                    if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.' .. keyInput) then
                        -- debugPrint("Key pressed!! " .. keyInput)
                        playAnim("customStrum" .. data, 'pressed', true)
                        setProperty("customStrum" .. data .. ".visible", true)
                        onPlayerMiss(plr, plrIndex)
                    end
                end

                if getPropertyFromClass('flixel.FlxG', 'keys.justReleased.' .. keyInput) then
                    playAnim("customStrum" .. data, 'static', true)
                    setProperty("customStrum" .. data.. ".visible",false)
                end
            end
        end
    end
end

function onPlayerMiss(plr,plrIndex)
    local flashing = flashings[plrIndex]
    if not flashing then
        flashings[plrIndex] = true
        local powerup = powerups[plrIndex]
        local timerName = "player"..plr..'fsdown'
        -- debugPrint(powerup)
        powerups[plrIndex] = powerup-1
        playSound('power_down', 1)
        customTimer:runTimer(timerName,0.05,32)
        updatePowerDisplay(plr)
        local plrSprite = playersSprites[plrIndex]
        if powerup == 0 then
            setProperty(plrSprite..".visible",false)
            setOnLuas("mushroomkill",true)
        end
    end
end

function customTimer:onTimerCompleted(tag,loopsleft)
    for plrIndex,plr in ipairs(players) do
        if tag == tostring("player"..plr..'fs') or tag == tostring("player"..plr..'fsdown') or tag == tostring("player"..plr..'fsup') then
            local fs = flashstates[plrIndex]
            local plrSprite = playersSprites[plrIndex]
            -- debugPrint(plrSprite)
            setProperty(plrSprite..".visible", fs)
            fs = not fs
            if tag == tostring("player"..plr..'fsdown') or tag == tostring("player"..plr..'fsup') then
                flashstates[plrIndex] = fs
                flashings[plrIndex] = true
                if loopsleft == 0 then
                    setProperty(plrSprite..".visible", true)
                    flashings[plrIndex] = false
                end
            end
        end
    end
end

function onTimerCompleted(tag, loops, loopsleft)
    if tag == "getPlrsSprs" then
        updateCustomStrums()
        playersSprites = getPlayersSprites()
    end

    for plrIndex,plr in ipairs(players) do
        if tag == tostring("resetidle" .. plr) then
            local plrSprite = playersSprites[plr - 2]
            playAnim(plrSprite, "idle", true)
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
            local spriteName = tostring("customStrum" .. strum)
            -- debugPrint(spriteName)
            makeAnimatedLuaSprite(spriteName, notePath, x, getPropertyFromGroup("strumLineNotes", strum, "y"))
            scaleObject(spriteName, 0.7, 0.7)
            setObjectCamera(spriteName, "other")
            arrowDir = string.upper(danceDirections[strum + 1])
           -- Agregamos una animación básica
            addAnimationByPrefix(spriteName, 'static', "arrow" .. arrowDir, 0, true)
            addAnimationByPrefix(spriteName, 'pressed', tostring(string.lower(arrowDir) ..  " press"), 0, true)
            addAnimationByPrefix(spriteName, 'confirm', tostring(string.lower(arrowDir) .. " confirm"), 10, true)
            playAnim(spriteName, 'static', true)
            
            addLuaSprite(spriteName)
            setProperty(spriteName .. ".visible", false)
            -- debugPrint((tostring("customStrum"..(notePathIndex-1)..i-1)))
            strum = strum + 1
        end
    end
end

function createDisplay(plr)
    local spritename = "player" .. plr .. 'powerdisplay'
    local y = getProperty('powerdisplay.y') or 600
    if downscroll then
        y = getProperty('powerdisplay.y') or 30
    end

    makeLuaSprite(spritename, tostring('powerstates/' .. getPowerup(plr - 2)), ((50 + (getProperty('powerdisplay.height') or 50)) * displays) - 150, y)
    scaleObject(spritename, scaleSize, scaleSize)
    setProperty(spritename .. ".antialiasing", false)
    setObjectCamera(spritename,"hud")
    addLuaSprite(spritename, true)
end

function updateDisplay(plr)
    setProperty("player" .. plr .. "powerdisplay.y", getProperty('powerdisplay.y'))
end

function updatePowerDisplay(plr,powerup)
    loadGraphic("player" .. plr .. "powerdisplay", tostring('powerstates/' .. getPowerup(plr - 2)))
end

function getPowerup(plr)
    local powerup = powerups[plr]
    return powerup
end

function convertNum(num)
    if num == 3 then
        return 0
    elseif num == 2 then
        return 1
    elseif num == 1 then
        return 2
    elseif num == 0 then
        return 3
    elseif num == 4 then
        return 7
    elseif num == 5 then
        return 6
    elseif num == 6 then
        return 5
    elseif num == 7 then
        return 4
    end
    return num
end

function updateCustomStrums()
    local strum = 0
    if not getModSetting("arrowswap") then
        for _ = 0, 7 do
            local i = 7 - strum
            local x = getNoteX(convertNum(i))
            local y = getPropertyFromGroup("strumLineNotes", i, "y")
            local spriteName = tostring("customStrum" .. strum)
            setProperty(spriteName .. ".x", x)
            setProperty(spriteName .. ".y", y)
            strum = strum + 1
        end
    else
        for _ = 0, 7 do
            local x = getNoteX(strum)
            local y = getPropertyFromGroup("strumLineNotes", strum, "y")
            local spriteName = tostring("customStrum" .. strum)
            setProperty(spriteName .. ".x", x)
            setProperty(spriteName .. ".y", y)
            strum = strum + 1
        end
    end
end