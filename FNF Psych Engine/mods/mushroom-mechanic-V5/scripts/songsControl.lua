local hadghosttapping = false
local stopScript
function table.contains (table, element)
    for _,value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function onCreatePost()
    if not table.contains(songs, songName) then
        stopScript = true
        return 
    end
    setProperty('showComboNum', false)
    setProperty('showRating', false)

    setProperty('timeTxt.visible', false)
    setProperty('scoreTxt.visible', false)

    setProperty('healthBar.visible', false)        -- The main health bar
    setProperty('healthBarBG.visible', false)      -- The backgrounds of the health bar
    setProperty('iconP1.visible', false)           -- The player (Boyfriend) icon
    setProperty('iconP2.visible', false)           -- The opponent (Dad, etc.) icon

    if songName == "Gameover" then
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
    else
        -- Opponent's strum positions (0-3 for left to right)
        setPropertyFromGroup('opponentStrums', 0, 'x', 100)  -- Left note
        setPropertyFromGroup('opponentStrums', 1, 'x', 225)  -- Down note
        setPropertyFromGroup('opponentStrums', 2, 'x', 350)  -- Up note
        setPropertyFromGroup('opponentStrums', 3, 'x', 475)  -- Right note

        setPropertyFromGroup('playerStrums', 0, 'x', 700)    -- Left note
        setPropertyFromGroup('playerStrums', 1, 'x', 825)    -- Down note
        setPropertyFromGroup('playerStrums', 2, 'x', 950)   -- Up note
        setPropertyFromGroup('playerStrums', 3, 'x', 1075)   -- Right note
        
    end
end

if stopScript then return end

function onCountdownTick(swagCounter)
    if ghostTapping then
        hadghosttapping = true
        setPropertyFromClass('backend.ClientPrefs', 'data.ghostTapping', false)
    end
end

-- Custom script to change Boyfriend's and Opponent's strum notes in FNF Psych Engine
function onSongStart()
    setPropertyFromClass('ClientPrefs', 'ghostTapping', false);
end

function onDestroy()
    setPropertyFromClass('lime.app.Application', 'current.window.title', "Friday Night Funkin: Psych Engine")
    if hadghosttapping then
        setPropertyFromClass('backend.ClientPrefs', 'data.ghostTapping', true)
    end
end

function onUpdatePos()
    setProperty("health",1)
end

function onUpdate()
    setProperty("vocals.volume",1)
end

function onGameOver()
    return Function_Stop
end