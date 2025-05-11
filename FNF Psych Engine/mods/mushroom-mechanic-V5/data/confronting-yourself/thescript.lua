function onSectionHit()
    if curSection == 24 or curSection == 26 or curSection == 28 or curSection == 30 or curSection == 56 or curSection == 72 or curSection == 80 then
        playAnim("bg","exe",true)
    elseif curSection == 25 or curSection == 27 or curSection == 29 or curSection == 48 or curSection == 64 or curSection == 68 or curSection == 73 then
        playAnim("bg","normal",true)
    end
end

function onStepHit()
    if curStep == 1074 or curStep == 1078 then
        playAnim("bg","exe",true)
    elseif curStep == 1076 or curStep == 1080 then
        playAnim("bg","normal",true)
    end
end