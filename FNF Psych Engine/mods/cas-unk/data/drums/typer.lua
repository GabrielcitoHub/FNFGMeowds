local self = {
    id = "typerText",
    helpid = "typerHelpText",
    box = "typerBox",
    text = "",
    truthful = 1,
    combo = "DRUMSDRUMSDRUMSDRUMSDRUMSDRUMSDRUMSDRUWUDRUMSDRUMSDRUMSDRUMSDRUMSDRUMSDRUMSDRUMSDRUMSDRUMS",
}

function onCreatePost()
    local box = self.box
    makeLuaSprite(box, "objects/typer/box")
    setObjectCamera(box, "other")
    screenCenter(box)
    scaleObject(box, 6, 2, false)
    setProperty(box .. ".y", getProperty(box .. ".y") + 200)
    setProperty(box .. ".antialiasing", false)
    addLuaSprite(box)

    local id = self.id
    makeLuaText(id, self.text, 300)
    setObjectCamera(id, "other")
    screenCenter(id)
    scaleObject(id, 2, 2, false)
    setProperty(id .. ".y", getProperty(id .. ".y") + 200)
    addLuaText(id)

    local helpid = self.helpid
    makeLuaText(helpid, "Play the drums.", 300, 20, 200, 200)
    setObjectCamera(helpid, "other")
    screenCenter(helpid)
    scaleObject(helpid, 2, 2, false)
    setProperty(helpid .. ".y", getProperty(helpid .. ".y") + 135)
    addLuaText(helpid)
end

function self:update(hit)
    local len = string.len(self.text)
    local limit = 5
    
    if len > limit then
        local lastC = string.sub(self.text, limit + 1, len)
        -- debugPrint("lastC: " .. lastC)
        self.text = lastC
    end

    setProperty(self.id .. ".text", self:convertDisplay(self.text))

    local code = self.code
    if code and hit then
        if getProperty("cpuControlled") then
            setProperty(self.id .. ".text", "You did nothing")
            return
        end

        setProperty(self.id .. ".text", ":D")
    end
end

function self:addText(text)
    text = text or "X"
    text = tostring(text)
    self.text = self.text .. text
    -- debugPrint(text)
    -- debugPrint(self:convertDisplay(self.text))
end

function self:convertDisplay(text)
    local len = string.len(text)
    local rText = ""

    for i = 1,len do
        local char = string.sub(text, i, i)
        -- debugPrint(i .. "/" .. char)
        if i ~= len then
            rText = rText .. char .. "-"
        else
            rText = rText .. char
        end
    end
    -- rText = string.sub(rText, 1, len - 1)

    return rText
end

function goodNoteHit(index, noteData, noteType, isSustain)
    local v = self.truthful
    local char = string.sub(self.combo,v,v)
    -- debugPrint("char: " .. char)
    self.truthful = v + 1
    self:addText(char)

    self:update(true)
end

function noteMissPress(direction)
    self:addText(math.random(0,9))
    self:update()

    if self.code then
        self.code = 0
    end
end

function noteMiss(index, noteData, noteType, isSustain)
    local v = self.truthful
    self.truthful = v + 1
end

function onStepHit()
    if curStep == 374 then
        self.text = ""
        self.code = 0
    end
end