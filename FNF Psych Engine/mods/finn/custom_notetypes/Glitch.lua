local self = {
	id = "Glitch",
}
self.texture = "GlitchNotes"

function onCreate()
	--Prload the note image
	precacheImage(self.texture)

	--Iterate over all notes
	for i = getProperty('unspawnNotes.length') -1, 0, -1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == self.id then --Check if the note on the chart is a Bullet Note
			setPropertyFromGroup('unspawnNotes', i, 'texture', self.texture); --Change texture

			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true); --Miss has penalties
			end
		end
	end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
	if noteType ~= self.id or difficulty == 0 then return end
	playSound('glitchhit', 0.8);
	addMisses(999);
	playAnim('boyfriend', 'hurt', true);
	setProperty('health', getProperty('health')-3);
end

function noteMiss(id, direction, noteType, isSustainNote)
	if noteType ~= self.id then return end
	setProperty('health', getProperty('health') +0.0475);
	addMisses(-1);
	cameraShake('camGame', 0.01, 0.2);
end

function onTimerCompleted(tag, loops, loopsLeft)
	-- A loop from a timer you called has been completed, value "tag" is it's tag
	-- loops = how many loops it will have done when it ends completely
	-- loopsLeft = how many are remaining
	if loopsLeft >= 1 then
		setProperty('health', getProperty('health')-0.001);
	end
end