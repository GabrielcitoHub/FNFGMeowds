local oppNote = "arrow-sonic"
function onCreatePost()
	for i=0,4,1 do
		setPropertyFromGroup('opponentStrums', i, 'texture', oppNote)
        end
        
        for i = 0, getProperty('unspawnNotes.length')-1 do
		if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
			setPropertyFromGroup('unspawnNotes', i, 'texture', oppNote);
        end
	end
end