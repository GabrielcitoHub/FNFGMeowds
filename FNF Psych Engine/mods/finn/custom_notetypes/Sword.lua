local self = {
	id = "Sword",
}
self.texture = self.id

function onCreate()
	--Prload the note image
	precacheImage(self.texture)

	--Iterate over all notes
	for i = getProperty('unspawnNotes.length') -1, 0, -1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == self.id then --Check if the note on the chart is a Bullet Note
			setPropertyFromGroup('unspawnNotes', i, 'texture', self.texture); --Change texture
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashHue', 30); --custom notesplash color, why not
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashSat', -80);
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashBrt', 3);
			setPropertyFromGroup('unspawnNotes', i, 'missHealth', 3);

			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false); --Miss has penalties
			end
		end
	end
end

function goodNoteHit(id, direction, noteType, isSustainNote)
	if noteType ~= self.id then return end
	playSound('slice', 0.3);
	playAnim('dad', 'attack', true);
	playAnim('boyfriend', 'dodge', true);
	setProperty('boyfriend.specialAnim', true);
	setProperty('dad.specialAnim', true);
	cameraShake('camGame', 0.01, 0.2)
end

function noteMiss(id, direction, noteType, isSustainNote)
	if noteType ~= self.id or difficulty == 0 then return end
	playSound('slice', 1);
	playAnim('dad', 'attack', true);
	playAnim('boyfriend', 'hurt', true);
end

function onTimerCompleted(tag, loops, loopsLeft)
	-- A loop from a timer you called has been completed, value "tag" is it's tag
	-- loops = how many loops it will have done when it ends completely
	-- loopsLeft = how many are remaining
	if loopsLeft >= 1 then
		setProperty('health', getProperty('health')-0.001);
	end
end