function onUpdate()
    if mxupdatepowerup then
        setOnLuas("mxupdatepowerup", false)
        changeSprite()
    end
end

function changeSprite()
    if songName == "Gameover" then
        -- debugPrint(tostring("running: " .. mxrunning))
        -- debugPrint(tostring("hiding: " .. mxbfhiding))
        -- debugPrint("Ouch!")
        if powerup == 2 then
            if not mxrunning then
                if not mxbfhiding then
                    triggerEvent('Change Character', 'BF', 'bfmxfire')
                else
                    triggerEvent('Change Character', 'BF', 'bf-wall-fire')
                end
            else
                triggerEvent('Change Character', 'BF', 'bf-chase-fire')
                playAnim("bflegs", 'runfire', true)
            end
        elseif powerup == 1 then
            if not mxrunning then
                if not mxbfhiding then
                    triggerEvent('Change Character', 'BF', 'bfmx')
                else
                    triggerEvent('Change Character', 'BF', 'bf-wall')
                end
            else
                triggerEvent('Change Character', 'BF', 'bf-chase')
                playAnim("bflegs", 'run', true)
            end
        elseif powerup == 0 then
            if not mxrunning then
                if not mxbfhiding then
                    triggerEvent('Change Character', 'BF', 'bf-small')
                else
                    triggerEvent('Change Character', 'BF', 'bf-wall-small')
                end
            else
                triggerEvent('Change Character', 'BF', 'bf-chase-small')
                playAnim("bflegs", 'runsmall', true)
            end
        end
    elseif songName == "Cross-Console-Clash" then
        if powerup == 2 then
            triggerEvent('Change Character', 'BF', 'mario-ccc-fire')
        elseif powerup == 1 then
            triggerEvent('Change Character', 'BF', 'mario-ccc')
        elseif powerup == 0 then
            triggerEvent('Change Character', 'BF', 'mario-ccc-small')
        end
    end
end