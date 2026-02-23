local customTimer = {}
local self = customTimer
self.timers = {}

function self:runTimer(tag,time,loops)
    if not loops then
        loops = 1
    end
    local timerData = {
        tag = tag,
        time = time,
        loops = loops,
        start = time
    }
    table.insert(self.timers,timerData)
end

function self:update(dt)
    for i,timerData in ipairs(self.timers) do
        local time = timerData.time
        local startTime = timerData.start
        local loopsLeft = timerData.loops
        -- debugPrint(tostring("Time: "..time.." loopsLeft: "..loopsLeft.." StartTime: "..startTime))
        if time > 0 then
            time = time - (1 * dt)
            timerData.time = time
            timers[i] = timerData
        else
            loopsLeft = loopsLeft - 1
            timerData.time = startTime
            timerData.loops = loopsLeft
            timers[i] = timerData
            if self.onTimerCompleted then
                self:onTimerCompleted(timerData.tag,loopsLeft)
            end
            if loopsLeft <= 0 then
                table.remove(timers,i)
                break
            end
        end
    end
end

return customTimer