local self = {
    damage = 0.5,
    instaKill = false,
}

function onCreate()
    --variables
	Dodged = false;
    canDodge = false;
    DodgeTime = 0;
	
    precacheImage('spacebar');
    precacheSound('DODGE');
	precacheSound('Dodged');
end

function onEvent(name, value1, value2)
    if name == "DodgeEvent" then
        --Get Dodge time
        DodgeTime = (value1);
        
        --Make Dodge Sprite
        makeAnimatedLuaSprite('spacebar', 'spacebar', 400, 200);
        addAnimationByPrefix('spacebar', 'spacebar', 'spacebar', 25, true);
        playAnim('spacebar', 'spacebar');
        setObjectCamera('spacebar', 'other');
        scaleObject('spacebar', 0.50, 0.50); 
        addLuaSprite('spacebar', true); 
        
        --Set values so you can dodge
        playSound('DODGE', 0.4);
        canDodge = true;
        runTimer('Died', DodgeTime);

        -- DAD shit
        playAnim('dad', 'shoot', true);
        setProperty('dad.specialAnim', true);

        -- BF shit
        playAnim('boyfriend', 'pre-attack', true);
        setProperty('boyfriend.specialAnim', true);
	end
end

function onUpdate()
    local spacePressed = getPropertyFromClass('flixel.FlxG', 'keys.justPressed.SPACE')
    if canDodge == true and spacePressed then
        Dodged = true;
        playSound('Dodged', 0.7);
        playAnim('boyfriend', 'dodge', true);
        setProperty('boyfriend.specialAnim', true);
        removeLuaSprite('spacebar');
        canDodge = false
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'Died' then
        -- DAD shit
        -- setProperty('dad.specialAnim', true)

        local damage = self.damage
        if self.instaKill then damage = 2 end

        if not Dodged then
            addHealth(-damage)
            playSound('Dodged', 0.4);
            playAnim('boyfriend', 'hurt', true);
            setProperty('boyfriend.specialAnim', true);
            removeLuaSprite('spacebar')
        else
            addHealth(damage / 4)
            -- playAnim('dad', 'jump', true);
            Dodged = false
        end
    end
end