function onUpdate()
    if getHealth() <= 0.3 then
        if getRandomInt(1,100) == 1 then
            addHealth(0.1)
        end
    end
end