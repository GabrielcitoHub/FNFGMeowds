function onSpawnNoteSplash(id, noteData, noteType, isSustainNote)
    -- Tamaño (1 = normal, 2 = el doble, 0.5 = más chico)
    local scale = 4

    -- Aplica el scale al splash recién creado
    setProperty('noteSplashesGroup.members[' .. id .. '].scale.x', scale)
    setProperty('noteSplashesGroup.members[' .. id .. '].scale.y', scale)

    -- Esto remueve el color y la transparencia
    setProperty('noteSplashesGroup.members[' .. id .. '].alpha', 1)
    setProperty('noteSplashesGroup.members[' .. id .. '].color', getColorFromHex('FFFFFF'))
end
