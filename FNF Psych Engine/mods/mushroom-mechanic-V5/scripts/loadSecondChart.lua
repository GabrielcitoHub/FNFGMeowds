local chartData
local visualNotes = {} -- aquí guardamos nuestras sprites
local usedNotes = {}
local danceDirections = {"left","down","up","right","left","down","up","right"}
local directions = {'purple', 'blue', 'green', 'red', 'purple', 'blue', 'green', 'red'}
function table.contains (table, element)
    for _,value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

local chartName
local leftPlayer
local rightPlayer
local leftPlayerNotes
local rightPlayerNotes

function onCreatePost()
    local startPath = string.match(chartPath, ".*(data\\.*)")
    local path1 = string.match(startPath, "(.*\\)") .. "second-chart.json"
    local secondChartData = callMethodFromClass("tjson.TJSON", "parse", {getTextFromFile(path1)})
    if secondChartData ~= nil then
        chartName = secondChartData["chartname"]
        leftPlayer = secondChartData["leftplayer"]
        rightPlayer = secondChartData["rightplayer"]
        leftPlayerNotes = secondChartData["leftplayernotes"]
        rightPlayerNotes = secondChartData["rightplayernotes"]
        setOnLuas("customStrums",{leftPlayerNotes,rightPlayerNotes})

        -- makeLuaSprite('hitLine', nil, 0, 570)
        -- makeGraphic('hitLine', screenWidth, 2, 'ff0000')
        -- setObjectCamera('hitLine', 'hud')
        -- addLuaSprite('hitLine')
        precacheImage(leftPlayerNotes)
        precacheImage(rightPlayerNotes)

        local path2 = string.match(startPath, "(.*\\)")..chartName..".json"
        chartData = callMethodFromClass("tjson.TJSON", "parse", {getTextFromFile(path2)})
        -- debugPrint("Chart cargado con " .. #chartData.notes .. " secciones")
    end
end

function onSectionHit()
    local spawnSection = curSection + 2
    if chartData == nil then return end
    local section = chartData.notes[spawnSection] or {}
    local sections = sections or {}
    table.insert(sections, section)
    setOnLuas("sections", sections)

    for j, note in ipairs(section.sectionNotes or {}) do
        local time = note[1]
        local lane = note[2]
        local sustain = note[3] or 0

        local spriteName = 'note_' .. spawnSection .. '_' .. j
        local x = getProperty("customStrum" .. lane .. ".x")  -- posición horizontal según lane (ajustable)
        local y = -200  -- empieza fuera de pantalla
        
        local arrowSpr = leftPlayerNotes
        local player = leftPlayer
        if lane < 4 then
            arrowSpr = rightPlayerNotes
            player = rightPlayer
        end
        local arrowDir = directions[lane + 1]
        local noteFound = false
        if #usedNotes > 0 then
            for usedNoteIndex,usedNote in ipairs(usedNotes) do
                if usedNote.lane == lane and usedNote.sprite == arrowSpr then
                    table.remove(visualNotes,usedNoteIndex)
                    table.remove(usedNotes,usedNoteIndex)
                    spriteName = usedNote.sprite
                    setProperty(tostring(spriteName..".x"),x)
                    setProperty(tostring(spriteName..".y"),y)
                    noteFound = true
                    break
                end
            end
        end
        local visualNoteData = {
            sprite = spriteName,
            strumTime = time,
            lane = lane,
            sustain = sustain,
            player = player
        }
        if not noteFound then
            makeAnimatedLuaSprite(spriteName, arrowSpr, x, y)
            addAnimationByPrefix(spriteName, 'idle', arrowDir, 0, true)
            playAnim(spriteName, 'idle', true)
            scaleObject(spriteName, 0.7, 0.7)
            setObjectCamera(spriteName, 'other')
            addLuaSprite(spriteName)
        end
        table.insert(visualNotes, visualNoteData)
    end
    
    setOnLuas("visualNotes", visualNotes)

    if #visualNotes > 0 then
        -- debugPrint(tostring("there is "..#visualNotes.." sprite notes"))
        -- setOnLuas("sectionVisualNotes",visualNotes)
    end
end
local removedNotes = {}

local function noteOutOfSight(note,noteIndex)
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
            table.insert(usedNotes,note)
            setProperty(note.sprite..".visible",false)
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
            note.index = noteIndex
            table.insert(removedNotes,note)
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
    -- local preSpawnOffset = -365
    local preSpawnOffset = 0
    local direction = downscroll and -1 or 1

    for noteIndex, note in ipairs(visualNotes) do
        local timeDiff = (note.strumTime - songPos) + preSpawnOffset
        local y = (timeDiff * 0.5 * scrollSpeed * direction)

        setProperty(note.sprite .. '.y', y)

        -- podés agregar lógica para ocultar notas que ya pasaron
        -- if y > 800 or y < -200 then
        if not downscroll then
            if y > 800 or y < 50 then
                noteOutOfSight(note,noteIndex)
            else
                setProperty(note.sprite .. '.visible', true)
                note.shown = true
            end
        else
            if y > 575 or y < -100 then
                noteOutOfSight(note,noteIndex)
            else
                setProperty(note.sprite .. '.visible', true)
                note.shown = true
            end
        end
    end

    if extraRemovedNotes then
        for _,removeNote in ipairs(extraRemovedNotes) do
            table.insert(removedNotes, removeNote)
        end

        extraRemovedNotes = {}
    end

    local i = 0
    for _,removeNote in ipairs(removedNotes) do
        table.remove(visualNotes, removeNote.index - i)
        i = i + 1
    end

    -- for _,usedNote in ipairs(usedNotes) do
    --     table.insert(visualNotes,usedNote)
    -- end

    removedNotes = {}
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