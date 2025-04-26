if version <= "0.7.3" then return end
function onCreate()
    -- Preload sounds
    precacheSound('countdown/countdown')
    precacheSound('countdown/countdownend')
    
    -- Create countdown sprites
    makeLuaSprite('three', 'countdown/three', 0, 0)
    screenCenter('three', 'xy')
    setObjectCamera('three', 'hud')
    setProperty('three.alpha', 0)  -- Initially hide the sprite
    
    makeLuaSprite('two', 'countdown/two', 0, 0)
    screenCenter('two', 'xy')
    setObjectCamera('two', 'hud')
    setProperty('two.alpha', 0)  -- Initially hide the sprite
    
    makeLuaSprite('one', 'countdown/one', 0, 0)
    screenCenter('one', 'xy')
    setObjectCamera('one', 'hud')
    setProperty('one.alpha', 0)  -- Initially hide the sprite
    
    makeLuaSprite('go', 'countdown/go-funkmix', 0, 0)
    screenCenter('go', 'xy')
    setObjectCamera('go', 'hud')
    setProperty('go.alpha', 0)  -- Initially hide the sprite

    -- Hide the default countdown sprites
    setProperty('countdownReady.visible', false)
    setProperty('countdownSet.visible', false)
    setProperty('countdownGo.visible', false)

    -- Disable the default intro sound suffix

	setProperty('countdownReady.visible', false)
	setProperty('countdownSet.visible', false)
	setProperty('countdownGo.visible', false)
	setProperty('introSoundsSuffix', '-NADALAVERGAEXACTO')
end

function onCountdownTick(counter)
    if counter == 0 then
        -- Show the 'three' sprite
        addLuaSprite('three', true)  -- 'true' ensures it's on the HUD layer
        setProperty('three.alpha', 1)  -- Make it visible
        playSound('countdown/countdown')
    elseif counter == 1 then
        -- Show the 'two' sprite and hide 'three'
        removeLuaSprite('three', false)  -- Don't destroy, just remove
        addLuaSprite('two', true)
        setProperty('two.alpha', 1)
        playSound('countdown/countdown')
		setProperty('countdownReady.visible', false)	
    elseif counter == 2 then
        -- Show the 'one' sprite and hide 'two'
        removeLuaSprite('two', false)
        addLuaSprite('one', true)
        setProperty('one.alpha', 1)
        playSound('countdown/countdown')
		setProperty('countdownSet.visible', false)
    elseif counter == 3 then
        -- Show the 'go' sprite and hide 'one'
        removeLuaSprite('one', false)
        addLuaSprite('go', true)
        setProperty('go.alpha', 1)
        playSound('countdown/countdownend')
		setProperty('countdownGo.visible', false)
    elseif counter == 4 then
        -- Remove 'go' sprite
        removeLuaSprite('go', false)
    end
end
