local self = {}
self.bg = "bg"
self.bottom = "bottom"
self.speed = 120
self.enabled = false

function onCountdownTick(counter)
    if counter == 4 then
        self.enabled = true
    end
end

function onBeatHit()
    if curBeat == 31 then
        self.enabled = false
    end
end

function onUpdate(elapsed)
    if not self.enabled then return end
    setProperty(self.bg .. ".x", getProperty(self.bg .. ".x") + self.speed * elapsed)
    setProperty(self.bottom .. ".x", getProperty(self.bg .. ".x"))
end