local self = {
    active = true,
    CPU = getProperty("cpuControlled"),
}

function onCreate()
    if self.CPU then return end
    setProperty("cpuControlled", true)
end

function onStepHit()
    if self.CPU then return end
    if curStep == 126 then
        setProperty("cpuControlled", false)
    end
end