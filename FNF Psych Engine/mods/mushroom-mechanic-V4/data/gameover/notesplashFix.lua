function goodNoteHit()
    debugPrint(getProperty("grpNoteSplashes.lenght"))
    setPropertyFromGroup("grpNoteSplashes", getProperty("grpNoteSplashes.lenght")-1, "alpha", 1)
end