local self = {
    debug = false,
    active = false,
    cant_hit = false,
    cant_die = false,
    drain = 0.09,
}

function onUpdate(elapsed)
    if not self.active then return end
    if getHealth() > 0.1 then
        local rest = (self.drain * elapsed) * -1
        if self.cant_hit then
            local newhp = self.health - rest * -1
            -- debugPrint("hp: " .. getHealth() .. " newhp: " .. newhp)
            setHealth(newhp)
            self.health = newhp
            return
        end
        addHealth(rest)
    end
end

function onBeatHit()
    if self.debug then
        self.active = true
    end
    if curBeat == 31 then
        self.active = true
    elseif curBeat == 33 then
        removeLuaSprite("ray", true)
    elseif curBeat == 96 then
        self.drain = 0.125
    elseif curBeat == 144 then
        self.drain = 0.05
        self.cant_die = true
    elseif curBeat == 144 then
        self.health = getHealth()
        self.cant_hit = true
    elseif curBeat == 160 then
        self.active = false
    end
end

function onGameOver()
    if not self.cant_die then return end
    return Function_Stop
end