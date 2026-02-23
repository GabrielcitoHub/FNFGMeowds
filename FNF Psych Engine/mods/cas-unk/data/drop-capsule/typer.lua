local self = {
    id = "typerText",
    helpid = "typerHelpText",
    box = "typerBox",
    text = "",
    truthful = 1,
    combo = "6676343237137800978219791097953222243334321226662296",
    code = false,
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
    makeLuaText(helpid, "Hatch the code to open.", 300, 20, 200, 200)
    setObjectCamera(helpid, "other")
    screenCenter(helpid)
    scaleObject(helpid, 2, 2, false)
    setProperty(helpid .. ".y", getProperty(helpid .. ".y") + 135)
    addLuaText(helpid)
end

function self:update()
    local len = string.len(self.text)
    local limit = 7
    
    if len > limit then
        local lastC = string.sub(self.text, limit + 1, len)
        -- debugPrint("lastC: " .. lastC)
        self.text = lastC
    end

    setProperty(self.id .. ".text", self:convertDisplay(self.text))
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

    local code = self.code
    if code then
        self.code = code + 1
    end

    self:update()
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
    if curStep == 382 then
        self.text = ""
        self.code = 0
    elseif curStep == 394 and self.code < 4 then
        if isStoryMode then
            endSong()
        else
            exitSong()
        end
    end
end