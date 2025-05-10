-- Extra Players Variables.
local leftPlayer = "tails"
local rightPlayer = "luigi"

-- The notes to use for the players.
local leftPlayerNotes = "arrow-tails"
local rightPlayerNotes = "noteSkins/luigi-arrows-pixel"

-- Second Chart Name (Must be on the same "/data/" as the current playing chart).
local chartName = "cross-console-clash-2"

-- Edit until here, past here edit only if necessary for what you want to do.

local chartData = nil
local visualNotes = {} -- aquí guardamos nuestras sprites
local danceDirections = {"left","down","up","right","left","down","up","right"}

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

    local path2 = string.match(chartPath, ".*(\\data\\.*)")
    local path2 = string.match(path2, "(.*\\)")..chartName..".json"
    chartData = callMethodFromClass("tjson.TJSON", "parse", {getTextFromFile(path2)})
    -- debugPrint("Chart cargado con " .. #chartData.notes .. " secciones")
    local directions = {'purple', 'blue', 'green', 'red', 'purple', 'blue', 'green', 'red'}

    for i, section in ipairs(chartData.notes) do
        for j, note in ipairs(section.sectionNotes or {}) do
            
            local time = note[1]
            local lane = note[2]

            local sustain = note[3] or 0

            local spriteName = 'note_' .. i .. '_' .. j
            local x = getNoteX(lane)  -- posición horizontal según lane (ajustable)
            local y = -200  -- empieza fuera de pantalla
            
            local arrowSpr = chartData.arrowSkin
            arrowSpr = leftPlayerNotes
            if lane < 4 then
                arrowSpr = rightPlayerNotes
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
                sustain = sustain
            })
        end
    end
end

function onUpdatePost(elapsed)
    local songPos = getSongPosition()  -- en milisegundos
    local scrollSpeed = chartData.speed   -- podés cambiar esto
    local hitY = downscroll and 130 or 570  -- línea de golpeo

    for _, note in ipairs(visualNotes) do
        local preSpawnOffset = -500
        local timeDiff = (note.strumTime - songPos) + preSpawnOffset
        local direction = downscroll and 1 or -1
        local y = hitY - (timeDiff * 0.45 * scrollSpeed * direction)

        setProperty(note.sprite .. '.y', y)

        -- podés agregar lógica para ocultar notas que ya pasaron
        -- if y > 800 or y < -200 then
        if y > 800 or y < 50 then
            setProperty(note.sprite .. '.visible', false)
            if note.shown then
                note.shown = false
                removeLuaSprite(note.sprite)
                danceDir = danceDirections[note.lane + 1]
                local idleWait = 0.3
                if note.lane < 4 then
                    playAnim(rightPlayer,danceDir)
                    runTimer("resetidlel", idleWait)
                else
                    playAnim(leftPlayer,danceDir)
                    runTimer("resetidlet", idleWait)
                end
            end
        else
            setProperty(note.sprite .. '.visible', true)
            note.shown = true
        end
    end
end

function onTimerCompleted(tag)
    if tag == "resetidlet" or tag == "resetidlel" then
        if tag == "resetidlet" then 
            playAnim(leftPlayer,"idle")
        elseif tag == "resetidlel" then
            playAnim(rightPlayer,"idle")
        end
    end
end    