local luigiBackAmount = 30
local luigiAirAmount = 30
local realBotPlay = botPlay

function onCreate()
    setProperty("tails.visible", false)
    setProperty("luigi.visible", false)
    luigiStartX = getProperty("luigi.x")+luigiBackAmount
end

function onSectionHit()
    if curSection == 39 then
        local flyAmount = 50
        local backAmount = 40
        playAnim("tails","fly")
        setProperty("tails.x",getProperty("tails.x")-backAmount)
        setProperty("tails.y",getProperty("tails.y")-flyAmount)
        doTweenX("tailsWalk","tails",getProperty("tails.x")+backAmount,1.1,'quadOut')
        doTweenY("tailsGravity","tails",getProperty("tails.y")+flyAmount,0.95)
    elseif curSection == 40 then
        setProperty("luigi.alpha",0)
    elseif curSection >= 45 then
        setProperty("luigi.alpha",1)
    end
end

function onBeatHit()
    if curBeat == 159 then
        playAnim("tails","skid")
    elseif curBeat == 160 then
        playAnim("tails","idle")
    elseif curBeat == 162 then
        playAnim("luigi","jump")
        setProperty("luigi.alpha",1)
        setProperty("luigi.x",luigiStartX)
        setProperty("luigi.y",getProperty("luigi.y")-luigiAirAmount)
        doTweenX("luigiWalk","luigi",getProperty("luigi.x")-luigiBackAmount,0.3,'quadOut')
        doTweenY("luigiGravity","luigi",getProperty("luigi.y")+luigiAirAmount,0.3)
    elseif curBeat == 163 then
        playAnim("luigi","idle")
    end
end

local marioJumpHeight = 12
local marioGroundY = getProperty("boyfriend.y")

function onTweenCompleted(tag)
    if tag == "marioUp" then
        doTweenY("marioDown","boyfriend",getProperty("boyfriend.y")+marioJumpHeight,0.2)
    elseif tag == "marioUp2" then
        cancelTween("marioDown")
        doTweenY("marioDown","boyfriend",marioGroundY,0.2)
    end
end

function onStepHit()
    if curStep == 616 then
        doTweenY("marioUp","boyfriend",getProperty("boyfriend.y")-marioJumpHeight,0.1,'quadOut')
    elseif curStep == 620 then
        doTweenY("marioUp2","boyfriend",getProperty("boyfriend.y")-marioJumpHeight,0.1,'quadOut')
    end
end