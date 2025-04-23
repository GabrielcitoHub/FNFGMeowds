function onCreate()
    -- If coming from boot, this will resume the song
    runHaxeCode([[
        if (sys.FileSystem.exists("lastsong.txt")) {
            var songName = sys.io.File.getContent("lastsong.txt").trim();
            if (songName != "") {
                sys.FileSystem.deleteFile("lastsong.txt");
                PlayState.SONG = Song.loadFromJson(songName, songName);
                PlayState.isStoryMode = false;
                PlayState.storyDifficulty = 1;
                MusicBeatState.switchState(new PlayState());
            }
        }
    ]])
end

function onGameOver()
    -- This runs on game over; save the current song name so it can resume
    saveLastSong()
end

function onEndSong()
    -- Also save after winning a song
    saveLastSong()
end

function saveLastSong()
    local song = songName or (songPath or "") -- fallback
    if song ~= nil and song ~= "" then
        local file = io.open("lastsong.txt", "w")
        file:write(song)
        file:close()
        -- Optional: restart game (you must create a restart.bat for this)
        -- runHaxeCode('Sys.command("restart.bat"); Sys.exit(0);')
    end
end
