function copyFile(src, dest)
    local infile = io.open(src, "rb")
    if not infile then
        debugPrint("Failed to open source file: " .. src)
        return false
    end

    local content = infile:read("*all")
    infile:close()

    local outfile = io.open(dest, "wb")
    if not outfile then
        debugPrint("Failed to open destination file: " .. dest)
        return false
    end

    outfile:write(content)
    outfile:close()

    debugPrint("File copied successfully!")
    return true
end

function onCreate()
    local file = io.open("lastsong.txt", "w")
    file:write(songName) -- Replace with your song name (matching folder name)
    file:close()
    debugPrint("Saved song to resume!")
    
    copyFile("mods/test/keepopen.bat", "keepopen.bat")
    io.popen("start \"\" \"keepopen.bat\"")
end

function onUpdate()
    setProperty("health",1)
end