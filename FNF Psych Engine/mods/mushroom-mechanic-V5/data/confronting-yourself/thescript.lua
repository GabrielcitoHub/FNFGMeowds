function hexToRGB(hex)
    local r = tonumber(hex:sub(2,3), 16) / 255
    local g = tonumber(hex:sub(4,5), 16) / 255
    local b = tonumber(hex:sub(6,7), 16) / 255
    return r, g, b
end


-- function onCreatePost()
--     -- Aplica el shader a un sprite (ej. 'boyfriend')
--     setSpriteShader('water', 'replaceColor')

--     -- Pasa los colores: el que quieres reemplazar y el nuevo
--     local r1, g1, b1 = hexToRGB("#991177") -- fromColor
--     local r2, g2, b2 = hexToRGB("#6C90B4") -- toColor

--     setShaderFloatArray('water',"fromColor",{r1,g1,b1})
--     setShaderFloatArray('water',"toColor",{r2,g2,b2})
-- end


local function exeChange(exe)
    if exe then
        playAnim("bg","exe",true)
        playAnim("green-flower","exe",true)
        playAnim("red-flower","exe",true)
    else
        playAnim("bg","normal",true)
        playAnim("green-flower","green",true)
        playAnim("red-flower","red",true)
    end
end

function onSectionHit()
    if curSection == 24 or curSection == 26 or curSection == 28 or curSection == 30 or curSection == 56 or curSection == 72 or curSection == 80 then
        exeChange(true)
    elseif curSection == 25 or curSection == 27 or curSection == 29 or curSection == 48 or curSection == 64 or curSection == 68 or curSection == 73 then
        exeChange(false)
    end
end

function onStepHit()
    if curStep == 1074 or curStep == 1078 then
        exeChange(true)
    elseif curStep == 1076 or curStep == 1080 then
        exeChange(false)
    end
end