-- Extra Players Variables.
local leftPlayer = "tails"
local rightPlayer = "luigi"

-- The notes to use for the players.
local leftPlayerNotes = "arrow-tails"
local rightPlayerNotes = "noteSkins/luigi-arrows-pixel"

setOnLuas("customStrums",{leftPlayerNotes,rightPlayerNotes})

-- Second Chart Name (Must be on the same "/data/" as the current playing chart).
local chartName = "cross-console-clash-2"

-- Edit until here, past here edit only if necessary for what you want to do.

local chartData = nil
local visualNotes = {} -- aquí guardamos nuestras sprites
local danceDirections = {"left","down","up","right","left","down","up","right"}
local directions = {'purple', 'blue', 'green', 'red', 'purple', 'blue', 'green', 'red'}

local function getNoteX(lane)
    if lane >= 4 then
        return getPropertyFromGroup('opponentStrums', lane - 4, 'x')
    else
        return getPropertyFromGroup('playerStrums', lane, 'x')
    end
end


function onCreatePost()
    -- makeLuaSprite('hitLine', nil, 0, 570)
    -- makeGraphic('hitLine', screenWidth, 2, 'ff0000')
    -- setObjectCamera('hitLine', 'hud')
    -- addLuaSprite('hitLine')
    precacheImage(leftPlayerNotes)
    precacheImage(rightPlayerNotes)

    local path2 = string.match(chartPath, ".*(\\data\\.*)")
    local path2 = string.match(path2, "(.*\\)")..chartName..".json"
    chartData = callMethodFromClass("tjson.TJSON", "parse", {getTextFromFile(path2)})
    -- debugPrint("Chart cargado con " .. #chartData.notes .. " secciones")

    for i, section in ipairs(chartData.notes) do
        for j, note in ipairs(section.sectionNotes or {}) do
            
            local time = note[1]
            local lane = note[2]
            local sustain = note[3] or 0

            local spriteName = 'note_' .. i .. '_' .. j
            local x = getNoteX(lane)  -- posición horizontal según lane (ajustable)
            local y = -200  -- empieza fuera de pantalla
            
            local arrowSpr = chartData.arrowSkin
            local player = leftPlayer
            arrowSpr = leftPlayerNotes
            if lane < 4 then
                arrowSpr = rightPlayerNotes
                player = rightPlayer
            end
            makeAnimatedLuaSprite(spriteName, arrowSpr, x, y)

            arrowDir = directions[lane + 1]
            -- Agregamos una animación básica
            addAnimationByPrefix(spriteName, 'idle', arrowDir, 0, true)
            playAnim(spriteName, 'idle', true)
            --makeGraphic(spriteName, 115, 115, 'fff200')

            scaleObject(spriteName, 0.7, 0.7)
            setObjectCamera(spriteName, 'other')
            addLuaSprite(spriteName)

            table.insert(visualNotes, {
                sprite = spriteName,
                strumTime = time,
                lane = lane,
                sustain = sustain,
                player = player
            })
        end
    end
    setOnLuas("visualNotes",visualNotes)
end

local function noteOutOfSight(note)
    local plr = 0
    if note.lane < 4 then
        plr = 4
    else
        plr = 3
    end
    if note.shown then
        note.shown = false
        note.used = true
        if not getModSetting(tostring("player"..plr)) then
            removeLuaSprite(note.sprite)
            danceDir = danceDirections[note.lane + 1]
            local idleWait = 0.3
            setProperty("customStrum"..note.lane..".visible",true)
            playAnim("customStrum"..note.lane,'confirm', true)
            runTimer("resetCustomStrum"..note.lane, 0.15)
            if plr == 3 then
                playAnim(leftPlayer,danceDir)
                runTimer("resetidlel", idleWait)
            elseif plr == 4 then
                playAnim(rightPlayer,danceDir)
                runTimer("resetidler", idleWait)
            end
        end
    end
    if note.used == false then
        setProperty(note.sprite .. '.visible', false)
    end
end

function onUpdatePost(elapsed)
    if not chartData then return end
    local songPos = getSongPosition()  -- en milisegundos
    local scrollSpeed = chartData.speed   -- podés cambiar esto
    local hitY = downscroll and 130 or 570  -- línea de golpeo
    local preSpawnOffset = -500
    local direction = downscroll and 1 or -1

    for _, note in ipairs(visualNotes) do
        local timeDiff = (note.strumTime - songPos) + preSpawnOffset
        local y = hitY - (timeDiff * 0.5 * scrollSpeed * direction)

        setProperty(note.sprite .. '.y', y)

        -- podés agregar lógica para ocultar notas que ya pasaron
        -- if y > 800 or y < -200 then
        if not downscroll then
            if y > 800 or y < 50 then
                noteOutOfSight(note)
            else
                setProperty(note.sprite .. '.visible', true)
                note.shown = true
            end
        else
            if y > 575 or y < -100 then
                noteOutOfSight(note)
            else
                setProperty(note.sprite .. '.visible', true)
                note.shown = true
            end
        end
    end
end

function onTimerCompleted(tag)
    if tag == "resetidlel" then 
        playAnim(leftPlayer,"idle")
    elseif tag == "resetidler" then
        playAnim(rightPlayer,"idle")
    end
    for i = 1,8 do
        if tag == "resetCustomStrum"..i-1 then
            playAnim("customStrum"..i-1, 'static', true)
            setProperty("customStrum"..(i-1)..".visible",false)
        end
    end
end    