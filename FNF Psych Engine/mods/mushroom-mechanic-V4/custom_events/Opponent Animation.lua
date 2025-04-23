local stunned = false

function onEvent(name, value1, value2)
    -- If the event is 'Opponent Animation', play the specified animation
    if name == 'Opponent Animation' then
        -- value1 is the animation name (e.g., 'danceLeft', 'singUP', etc.)
        -- value2 is whether the animation should loop ('true' or 'false')
        if value2 == nil then
            value2 = false
        end
        playAnim('dad', value1, value2)
        --setProperty('dad.holdTimer', 0)
        -- Optional: force the animation to finish before returning to idle
    end
end
