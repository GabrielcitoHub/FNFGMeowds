------------OPTIONS------------

--General Config--
keys = {
	'A',
	'S',
	'W',
	'D'
}

strumLock = false
dontHitIgnore = false

enableSetLua = true --if disabled, lua functions and variables from this script won't trigger but may fix input issues


--Rating Config--
enableRatings = true --if disabled, P2 ratings won't appear but it might save you from some lag/memory issues

showCombo = false
showComboNum = true
showRating = true

comboOffset = {-300, -250, -300, -250}
scoreTxtOffsetY = 0


--Health Config--
cannotDieP1 = false
cannotDieP2 = false

healthDrainP1 = true
healthDrainP2 = true

missDrainP1 = true
missDrainP2 = true


--Other Config--
doEndScreen = true
showResultsOnGameOver = true

doNoteSplashes = true

botPlayKey = 'SIX'
disableMiddleScroll = true


------------dont change anything from this point on------------

cpuControlled = false

local scoreP2 = 0
local comboP2 = 0
local totalPlayedP2 = 0
local totalNotesHitP2 = 0
local hitsP1 = 0
local hitsP2 = 0
local songMissesP2 = 0
local noteMissesP2 = 0

local ratingsP2 = {sicks = 0, goods = 0, bads = 0, shits = 0}
local ratingsData = {}

local ratingNameP2 = '?'
local ratingFCP2 = 'SFC'
local ratingPercentP2 = 1

local ratingCount = 0
local gfSinging = false
local orMiddleScroll = nil

local deadP1 = false
local deadP2 = false

local endContinue = false
local continueTxtSine = 0

function onCreate()

	if tonumber(_G["playbackRate"]) == nil or not (type(_G["playbackRate"]) == 'number') then _G["playbackRate"] = 1 end
	
	addHaxeLibrary('FlxMath', 'flixel.math')
	addHaxeLibrary('Math')
	addHaxeLibrary('Std')

	orMiddleScroll = getPropertyFromClass('backend.ClientPrefs', 'data.middleScroll')
	if disableMiddleScroll then setPropertyFromClass('backend.ClientPrefs', 'data.middleScroll', false) end

end

function onCreatePost()

	if enableSetLua then
	
		--set defaults for variables
		setOnLuas("multiScript", true, true)
		setOnLuas("botplayP2", cpuControlled, true)
		
		setOnLuas("scoreP2", 0, true)
		setOnLuas("missesP2", 0, true)
		setOnLuas("noteMissesP2", 0, true)
		setOnLuas("comboP2", 0, true)
		setOnLuas("hitsP2", 0, true)
		
		setOnLuas("sicksP2", 0, true)
		setOnLuas("goodsP2", 0, true)
		setOnLuas("badsP2", 0, true)
		setOnLuas("shitsP2", 0, true)
		
		setOnLuas("ratingPercentP2", 1, true)
		setOnLuas("ratingNameP2", "?", true)
		setOnLuas("ratingFCP2", "SFC", true)
		
		setOnLuas("deadP2", false, true)
		
		setOnLuas("scrollTypeP1", getPropertyFromClass('backend.ClientPrefs', 'data.downScroll'), true)
		setOnLuas("scrollTypeP2", getPropertyFromClass('backend.ClientPrefs', 'data.downScroll'), true)
		
		setOnLuas("multiSwap", false, true)
		setOnLuas("multiStrumLock", strumLock, true)
		setOnLuas("multiSeparatedHealth", false, true)
		setOnLuas("multiNoIgnore", dontHitIgnore, true)
		
	end

	if enableRatings then

		makeLuaText('scoreTxtP2', 'Score: 0 | Misses: 0 | Rating: ?', 0, 0, getPropertyFromClass('backend.ClientPrefs', 'data.downScroll') and (650 + scoreTxtOffsetY) or scoreTxtOffsetY)
		addLuaText('scoreTxtP2', true)
		
		setObjectCamera('scoreTxtP2', 'camHUD')
		setProperty('scoreTxtP2.borderSize', 1.25)
		setTextSize('scoreTxtP2', 20)
		setTextAlignment('scoreTxtP2', 'center')

		setTextSize('scoreTxtP2', getTextSize('scoreTxt'))
		setProperty('scoreTxtP2.font', getTextFont('scoreTxt'))
		setProperty('scoreTxtP2.color', getProperty('scoreTxt.color'))
		setProperty('scoreTxtP2.visible', getProperty('scoreTxt.visible'))
		screenCenter('scoreTxtP2', 'x')
		
	end
	
end

function onUpdate(elapsed)

	if not (botPlayKey == nil or botPlayKey == '') then
	
		if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.'..botPlayKey:upper()) then
			cpuControlled = not cpuControlled
			setOnLuas("botplayP2", cpuControlled, true)
		end
	
	end
	
	--reset key
	if not (getPropertyFromClass('backend.ClientPrefs', 'data.noReset')) and keyJustPressed('reset') and getProperty('canReset') and not (getProperty('inCutscene')) and not (getProperty('endingSong')) then
		
		if not (cannotDieP1) and not (deadP1) and showResultsOnGameOver then
			openCustomSubstate('resultsScreenG1', true)
			deadP1 = true
		end
		
	end
	
end

function onUpdatePost(elapsed)
	
	animThing(elapsed)
	
	if strumLock then
		
		for i = 0, getProperty('playerStrums.length')-1 do
			setPropertyFromGroup('playerStrums', i, 'x', _G['defaultPlayerStrumX'..i])
			setPropertyFromGroup('playerStrums', i, 'y', _G['defaultPlayerStrumY'..i])
			setPropertyFromGroup('playerStrums', i, 'alpha', 1)
			setPropertyFromGroup('playerStrums', i, 'visible', true)
			setPropertyFromGroup('playerStrums', i, 'direction', 90)
			setPropertyFromGroup('playerStrums', i, 'downScroll', getPropertyFromClass('backend.ClientPrefs', 'data.downScroll'))
		end
		
		for i = 0, getProperty('opponentStrums.length')-1 do
			setPropertyFromGroup('opponentStrums', i, 'x', _G['defaultOpponentStrumX'..i])
			setPropertyFromGroup('opponentStrums', i, 'y', _G['defaultOpponentStrumY'..i])
			setPropertyFromGroup('opponentStrums', i, 'alpha', 1)
			setPropertyFromGroup('opponentStrums', i, 'visible', true)
			setPropertyFromGroup('opponentStrums', i, 'direction', 90)
			setPropertyFromGroup('opponentStrums', i, 'downScroll', getPropertyFromClass('backend.ClientPrefs', 'data.downScroll'))
		end
	
	end

	for i = 0, getProperty('notes.length')-1 do
	
		if getPropertyFromGroup('notes', i, 'mustPress') == false then
		
			local noteData = getPropertyFromGroup('notes', i, 'noteData')
			local noteType = getPropertyFromGroup('notes', i, 'noteType')
			local isSustainNote = getPropertyFromGroup('notes', i, 'isSustainNote')
			local strumTime = getPropertyFromGroup('notes', i, 'strumTime')
			local hitByOpponent = getPropertyFromGroup('notes', i, 'hitByOpponent')

			if strumTime > getPropertyFromClass('backend.Conductor', 'songPosition') - (getPropertyFromClass('backend.Conductor', 'safeZoneOffset') * getPropertyFromGroup('notes', i, 'lateHitMult')) 
				and strumTime < getPropertyFromClass('backend.Conductor', 'songPosition') + (getPropertyFromClass('backend.Conductor', 'safeZoneOffset') * getPropertyFromGroup('notes', i, 'earlyHitMult')) then
					setPropertyFromGroup('notes', i, 'canBeHit', true)
			else
				setPropertyFromGroup('notes', i, 'canBeHit', false)
			end
			
			if strumTime < getPropertyFromClass('backend.Conductor', 'songPosition') - getPropertyFromClass('backend.Conductor', 'safeZoneOffset') and hitByOpponent == false then
				setPropertyFromGroup('notes', i, 'tooLate', true)
			end
			
			if cpuControlled and not (getProperty('endingSong')) then
			
				if not (getPropertyFromGroup('notes', i, 'rating') == 'ignore') and hitByOpponent == false then

					if (isSustainNote and strumTime <= getPropertyFromClass('backend.Conductor', 'songPosition') + (getPropertyFromClass('backend.Conductor', 'safeZoneOffset') * getPropertyFromGroup('notes', i, 'earlyHitMult'))) 
						or (not isSustainNote and strumTime <= getPropertyFromClass('backend.Conductor', 'songPosition')) then
							goodNoteHitP2(i)
					end
					
				end
				
			end
			
			if getPropertyFromClass('backend.Conductor', 'songPosition') >= (getProperty('noteKillOffset') - 15) + strumTime then
				
				setPropertyFromGroup('notes', i, 'strumTime', getPropertyFromClass('backend.Conductor', 'songPosition'))

				if not (cpuControlled) and not (getPropertyFromGroup('notes', i, 'rating') == 'ignore') and not (getProperty('endingSong'))
				and (getPropertyFromGroup('notes', i, 'tooLate') or hitByOpponent == false) then
					noteMissP2(i, noteData, noteType, isSustainNote)
				end
				
				setPropertyFromGroup('notes', i, 'active', false)
				setPropertyFromGroup('notes', i, 'visible', false)
				removeFromGroup('notes', i)
				
			end
				
		end
	
	end

	if not (cpuControlled) and not (getProperty('inCutscene')) and not (getProperty('endingSong')) then
		input()
		holdInput()
	end
	
end

function onSpawnNote(id)

	if getPropertyFromGroup('notes', id, 'mustPress') == false then
	
		if getPropertyFromGroup('notes', id, 'ignoreNote') or getPropertyFromGroup('notes', id, 'hitCausesMiss') then
			setPropertyFromGroup('notes', id, 'rating', 'ignore')
		end
		
	end

	if getPropertyFromGroup('notes', id, 'mustPress') == false then
		
		if not (healthDrainP2) then
			setPropertyFromGroup('notes', id, 'hitHealth', 0)
		end
		
		if not (missDrainP2) then
			setPropertyFromGroup('notes', id, 'missHealth', 0)
		end
		
		setPropertyFromGroup('notes', id, 'ignoreNote', true)
		
	else
		
		if not (healthDrainP1) then
			setPropertyFromGroup('notes', id, 'hitHealth', 0)
		end
		
		if not (missDrainP1) then
			setPropertyFromGroup('notes', id, 'missHealth', 0)
		end
	
		setPropertyFromGroup('notes', id, 'rating', '')
		
	end
	
	if strumLock then
		setPropertyFromGroup('notes', id, 'copyAlpha', false)
	end

end

function input()

	for i, key in ipairs(keys) do
	
		local data = i - 1
	
		if not (i > getProperty('opponentStrums.length')) then
		
			if getPropertyFromClass('flixel.FlxG', 'keys.justPressed.'..key:upper()) then
				strumPlayAnim(data, 'pressed', true, -1)
				keyPress(data)
			end
			
			if getPropertyFromClass('flixel.FlxG', 'keys.justReleased.'..key:upper()) then
				strumPlayAnim(data, 'static', true, 0)
			end
		
		end
		
	end
			
end

function holdInput()

	for i, key in ipairs(keys) do
	
		local data = i - 1
	
		if not (i > getProperty('opponentStrums.length')) then
	
			if getPropertyFromClass('flixel.FlxG', 'keys.pressed.'..key:upper()) then
				
				for id = 0, getProperty('notes.length')-1 do

					if getPropertyFromGroup('notes', id, 'isSustainNote') and getPropertyFromGroup('notes', id, 'mustPress') == false and getPropertyFromGroup('notes', id, 'canBeHit') 
					and getPropertyFromGroup('notes', id, 'tooLate') == false and getPropertyFromGroup('notes', id, 'hitByOpponent') == false and getPropertyFromGroup('notes', id, 'noteData') == data then
					
						if (dontHitIgnore and not (getPropertyFromGroup('notes', id, 'rating') == 'ignore')) or not (dontHitIgnore) then
							goodNoteHitP2(id)
						end
						
					end
				
				end
						
			end
		
		end
			
	end

end

function keyPress(key)

	if getPropertyFromClass('backend.Conductor', 'songPosition') >= -(getProperty('noteKillOffset') - 15) and getProperty('startedCountdown') and not (getProperty('paused')) and key > -1 then

		if getProperty('generatedMusic') and not getProperty('endingSong') then
		
			local lastTime = getPropertyFromClass('backend.Conductor', 'songPosition')
			setPropertyFromClass('backend.Conductor', 'songPosition', getPropertyFromClass('flixel.FlxG', 'sound.music.time'))
			
			local canMiss = not getPropertyFromClass('backend.ClientPrefs', 'data.ghostTapping')
			
			local sortedNotesList = {}

			if getProperty('notes.length') > 0 then

				for i = 0, getProperty('notes.length')-1 do
				
					if getPropertyFromGroup('notes', i, 'mustPress') == false then
					
						local noteFunc = function(pr)
							return getPropertyFromGroup('notes', i, pr)
						end
						
						if noteFunc('canBeHit') and not (noteFunc('hitByOpponent')) and not (noteFunc('isSustainNote')) and not (noteFunc('blockHit')) then
						
							if (dontHitIgnore and not (noteFunc('rating') == 'ignore')) or not dontHitIgnore then
							
								if noteFunc('noteData') == key then
									table.insert(sortedNotesList, i)
								end
								--canMiss = true
								
							end
							
						end
					
					end
					
				end

			end

			if #sortedNotesList > 0 then
			
				for i, note in ipairs(sortedNotesList) do
				
					for j, doubleNote in ipairs(sortedNotesList) do
					
						if not (note == doubleNote) then

							if math.abs(getPropertyFromGroup('notes', doubleNote, 'strumTime') - getPropertyFromGroup('notes', note, 'strumTime')) < 2 then
								removeFromGroup('notes', doubleNote)
								sortedNotesList[j] = nil
							end
							
						end

					end
					
				end

				table.sort(sortedNotesList, function(a, b) return getPropertyFromGroup('notes', a, 'strumTime') - getPropertyFromGroup('notes', b, 'strumTime') end)
				
				local nearestNote = -4
				
				if #sortedNotesList > 1 then
				
					for _, note in ipairs(sortedNotesList) do
					
						if not (note == nil) then
					
							for _, note2 in ipairs(sortedNotesList) do
							
								if not (note == note2) and not (note2 == nil) then
								
									if nearestNote == -4 then
									
										if getPropertyFromGroup('notes', note, 'strumTime') < getPropertyFromGroup('notes', note2, 'strumTime') then
											nearestNote = note
											break
										else
											nearestNote = note2
											break
										end

									end
									
								end

							end

							if not (nearestNote == -4) then
							
								if getPropertyFromGroup('notes', note, 'strumTime') < getPropertyFromGroup('notes', nearestNote, 'strumTime') then
									nearestNote = note
								end

							end
						
						end
						
					end

				else
					nearestNote = sortedNotesList[1]
				end

				if not (nearestNote == -4) then
					goodNoteHitP2(nearestNote)
				end

			else

				if canMiss then
					noteMissPressP2(key)
				else
					if enableSetLua then callOnLuas('onGhostTapP2', {key}, false, true, {scriptName}) end
				end
				
			end
			
			setPropertyFromClass('backend.Conductor', 'songPosition', lastTime)
		
		end

	end

	if enableSetLua then callOnLuas('onKeyPressP2', {key}, false, true, {scriptName}) end
	
end

function goodNoteHitP2(id)

	local noteData = getPropertyFromGroup('notes', id, 'noteData')
	local noteType = getPropertyFromGroup('notes', id, 'noteType')
	local isSustainNote = getPropertyFromGroup('notes', id, 'isSustainNote')

	if not (getPropertyFromGroup('notes', id, 'hitByOpponent')) then
	
		if cpuControlled and (getPropertyFromGroup('notes', id, 'rating') == 'ignore' or getPropertyFromGroup('notes', id, 'hitCausesMiss')) then return end
		
		if not (getPropertyFromClass('states.PlayState', 'SONG.song'):lower() == 'tutorial') then setProperty('camZooming', true) end
		if not (getPropertyFromGroup('notes', id, 'hitsoundDisabled')) and not isSustainNote then playSound('hitsound', getPropertyFromClass('backend.ClientPrefs', 'data.hitsoundVolume')) end

		if getPropertyFromGroup('notes', id, 'hitCausesMiss') then
		
			if not (getPropertyFromGroup('notes', id, 'noteSplashData.disabled') and isSustainNote and doNoteSplashes) then spawnNoteSplash(id) end
			
			if getPropertyFromGroup('notes', id, 'noMissAnimation') == false then

				if noteType == 'Hurt Note' then
					playAnim('dad', 'hurt', true)
					setProperty('dad.specialAnim', true)
				end
				
			end
		
			setPropertyFromGroup('notes', id, 'hitByOpponent', true)
			setProperty('vocals.volume', 1)
			
			noteMissP2(id, noteData, noteType, isSustainNote)

			if isSustainNote == false then
				removeFromGroup('notes', id)
			else
				setPropertyFromGroup('notes', id, 'ignoreNote', false)
			end

			return
			
		end

		if enableRatings and not isSustainNote then
			comboP2 = comboP2 + 1
			if comboP2 > 9999 then combo = 9999 end
			popUpScore(id)
		end

		if healthDrainP2 then
		
			if getProperty('health') > getPropertyFromGroup('notes', id, 'hitHealth') * getProperty('healthGain') then
				setProperty('health', getProperty('health') - getPropertyFromGroup('notes', id, 'hitHealth') * getProperty('healthGain'))
			end
			
		end

		if getPropertyFromGroup('notes', id, 'noAnimation') == false then
		
			local animToPlay = getProperty('singAnimations')[noteData + 1]
			local animSuffix = getPropertyFromGroup('notes', id, 'animSuffix')
			if noteType == 'Alt Animation' or altAnim then animSuffix = '-alt' end
			
			if noteType == 'Hey!' then
			
				playAnim('dad', 'hey', true)
				setProperty('dad.specialAnim', true)
				setProperty('dad.heyTimer', 0.6)

				if not (getProperty('gf') == nil) then
					playAnim('gf', 'cheer', true)
					setProperty('gf.specialAnim', true)
					setProperty('gf.heyTimer', 0.6)
				end
				
			else
			
				local char = 'dad'
				gfSinging = false
				
				if getPropertyFromGroup('notes', id, 'gfNote') and not (getProperty('gf') == nil) then 
					char = 'gf'
					gfSinging = true
				end

				playAnim(char, animToPlay..animSuffix, true)
				if not (animSuffix == '') and not (getProperty(char..'.animation.curAnim.name') == animToPlay..animSuffix) then playAnim(char, animToPlay, true) end
				setProperty(char..'.holdTimer', 0)

			end
		
		end

		local time = 0

		if isSustainNote then
			if cpuControlled then time = time + 0.15 end
			strumPlayAnim(noteData % getProperty('opponentStrums.length'), 'confirm', true, time)
		else
			if cpuControlled then time = 0.15 end		
			strumPlayAnim(noteData % getProperty('opponentStrums.length'), 'confirm', true, time)
		end

		setPropertyFromGroup('notes', id, 'hitByOpponent', true)
		setProperty('vocals.volume', 1)
		
		if enableSetLua then 
			callOnLuas('opponentNoteHit', {id, noteData, noteType, isSustainNote}, false, true, {scriptName})
			callOnLuas('goodNoteHitP2', {id, noteData, noteType, isSustainNote}, false, true, {scriptName})
		end

		if isSustainNote == false then
			removeFromGroup('notes', id)
		else
			setPropertyFromGroup('notes', id, 'ignoreNote', false)
		end

	end
	
end

function noteMissP2(id, noteData, noteType, isSustainNote)
	
	if missDrainP2 then setProperty('health', getProperty('health') + (getPropertyFromGroup('notes', id, 'missHealth') * getProperty('healthLoss'))) end
	setProperty('vocals.volume', 0)
	
	if not (cannotDieP2) and not (deadP2) and missDrainP2 then
		
		if getProperty('health') > 2 and showResultsOnGameOver then
			openCustomSubstate('resultsScreenG2', true)
			deadP2 = true
		end
		
	end
	
	if enableRatings then
	
		comboP2 = 0
		
		if not (getProperty('endingSong')) then
			songMissesP2 = songMissesP2 + 1
			noteMissesP2 = noteMissesP2 + 1
		end

		if not (getProperty('practiceMode')) then scoreP2 = scoreP2 - 10 end
		totalPlayedP2 = totalPlayedP2 + 1
		
		RecalculateRating(true)
		
		if enableSetLua then
			setOnLuas("comboP2", 0, true)
			setOnLuas("missesP2", tonumber(songMissesP2), true)
			setOnLuas("noteMissesP2", tonumber(noteMissesP2), true)
			setOnLuas("scoreP2", tonumber(scoreP2), true)
		end
	
	end

	local char = 'dad'
	if getPropertyFromGroup('notes', id, 'gfNote') and not (getProperty('gf') == nil) then char = 'gf' end
	
	if getProperty(char..'.hasMissAnimations') then
	
		local animToPlay = getProperty('singAnimations')[noteData + 1]..'miss'
		local animSuffix = getPropertyFromGroup('notes', id, 'animSuffix')
		if noteType == 'Alt Animation' or altAnim then animSuffix = '-alt' end

		playAnim(char, animToPlay..animSuffix, true)
		if not (animSuffix == '') and not (getProperty(char..'.animation.curAnim.name') == animToPlay..animSuffix) then playAnim(char, animToPlay, true) end
		setProperty(char..'.specialAnim', true)
	
	end
	
	if enableSetLua then callOnLuas('noteMissP2', {id, noteData, noteType, isSustainNote}, false, true, {scriptName}) end
	
end

function noteMissPressP2(direction)

	if missDrainP2 then setProperty('health', getProperty('health') + (0.05 * getProperty('healthLoss'))) end
	setProperty('vocals.volume', 0)
	
	if not (cannotDieP2) and not (deadP2) and missDrainP2 then
		
		if getProperty('health') > 2 and showResultsOnGameOver then
			openCustomSubstate('resultsScreenG2', true)
			deadP2 = true
		end
		
	end
	
	if enableRatings then
	
		comboP2 = 0
		
		if getProperty('practiceMode') == false then scoreP2 = scoreP2 - 10 end
		if getProperty('endingSong') == false then songMissesP2 = songMissesP2 + 1 end
		totalPlayedP2 = totalPlayedP2 + 1
		
		RecalculateRating(true)
		
		if enableSetLua then
			setOnLuas("comboP2", 0, true)
			setOnLuas("missesP2", tonumber(songMissesP2), true)
			setOnLuas("scoreP2", tonumber(scoreP2), true)
		end
	
	end

	if getProperty('dad.hasMissAnimations') then
		playAnim('dad', getProperty('singAnimations')[direction + 1]..'miss', true)
		setProperty('dad'..'.specialAnim', true)
	end
	
	if enableSetLua then callOnLuas('noteMissPressP2', {direction}, false, true, {scriptName}) end

end

function spawnNoteSplash(id)

	local noteData = getPropertyFromGroup('notes', id, 'noteData')
	local x = getPropertyFromGroup('opponentStrums', noteData, 'x')
	local y = getPropertyFromGroup('opponentStrums', noteData, 'y')
	
	--fix for runHaxeCode not working as it should in v0.7+
	runHaxeCode([[
		function shit(x, y, data, id) 
		{
			var note = game.notes.members[id];
			game.spawnNoteSplash(x, y, data, note);
		}
	]])
	
	runHaxeFunction('shit', {x, y, noteData, id})

end

function popUpScore(id)
	
	local noteDiff = math.abs((getPropertyFromGroup('notes', id, 'strumTime') - getPropertyFromClass('backend.Conductor', 'songPosition') + getPropertyFromClass('backend.ClientPrefs', 'data.ratingOffset')) / _G["playbackRate"])

	ratingsData = {}

	for i = 1, getProperty('ratingsData.length') do
	
		ratingsData[i] = {}
		
		ratingsData[i].name = getProperty('ratingsData['..(i - 1)..'].name')
		
		if not (getProperty('ratingsData['..(i - 1)..'].image') == nil) then
			ratingsData[i].image = getProperty('ratingsData['..(i - 1)..'].image')
		else
			ratingsData[i].image = getProperty('ratingsData['..(i - 1)..'].name')
		end
		
		if not (getProperty('ratingsData['..(i - 1)..'].counter') == nil) then
			ratingsData[i].counter = getProperty('ratingsData['..(i - 1)..'].counter')
		else
			ratingsData[i].counter = getProperty('ratingsData['..(i - 1)..'].name')..'s'
		end

		ratingsData[i].ratingMod = getProperty('ratingsData['..(i - 1)..'].ratingMod')
		ratingsData[i].score = getProperty('ratingsData['..(i - 1)..'].score')
		ratingsData[i].noteSplash = getProperty('ratingsData['..(i - 1)..'].noteSplash')
		ratingsData[i].hitWindow = getProperty('ratingsData['..(i - 1)..'].hitWindow')
		
	end
	
	local daRating = judgeNote(noteDiff)
	
	for i = 1, #ratingsData do
	
		if daRating == ratingsData[i].name then
		
			if not (getPropertyFromGroup('notes', id, 'ratingDisabled')) then
			
				if ratingsP2[ratingsData[i].counter] == nil then ratingsP2[ratingsData[i].counter] = 0 end
				ratingsP2[ratingsData[i].counter] = ratingsP2[ratingsData[i].counter] + 1
				
				if enableSetLua then
					setOnLuas(ratingsData[i].counter..'P2', tonumber(ratingsP2[ratingsData[i].counter]), true)
				end
				
			end
			
			totalNotesHitP2 = totalNotesHitP2 + ratingsData[i].ratingMod
			setPropertyFromGroup('notes', id, 'rating', ratingsData[i].name)
			setPropertyFromGroup('notes', id, 'ratingMod', ratingsData[i].ratingMod)

			if getProperty('practiceMode') == false then scoreP2 = scoreP2 + ratingsData[i].score end

			if ratingsData[i].noteSplash and not (getPropertyFromGroup('notes', id, 'noteSplashData.disabled')) and doNoteSplashes then
				spawnNoteSplash(id)
			end
				
			ratingComboStuff(ratingsData[i].name, noteDiff, ratingsData[i].image)
			
		end
	
	end
	
	if not (getProperty('practiceMode')) and not (getPropertyFromGroup('notes', id, 'ratingDisabled')) then
		hitsP2 = hitsP2 + 1
		totalPlayedP2 = totalPlayedP2 + 1
		RecalculateRating(false)
	end
	
	if enableSetLua then
		setOnLuas('comboP2', tonumber(comboP2), true)
		setOnLuas('scoreP2', tonumber(scoreP2), true)
		setOnLuas('hitsP2', tonumber(hitsP2), true)
	end
	
end

function ratingComboStuff(rating, diff, ratingImg)

	if not (showCombo) and not (showComboNum) and not (showRating) then return end
	if ratingImg == nil then ratingImg = rating end
	
	makeLuaText('coolText', comboP2, 0, 0, 0)
	setTextSize('coolText', 32)
	screenCenter('coolText')
	setProperty('coolText.x', screenWidth * 0.35)

	local pixelShitPart1 = ''
	local pixelShitPart2 = ''
	local antialias = getPropertyFromClass('backend.ClientPrefs', 'data.antialiasing')

	if getPropertyFromClass('states.PlayState', 'isPixelStage') then
		pixelShitPart1 = 'pixelUI/'
		pixelShitPart2 = '-pixel'
		antialias = not getPropertyFromClass('states.PlayState', 'isPixelStage')
	end

	local sprName = 'rating'..ratingCount
	local comboName = 'combo'..ratingCount

	makeLuaSprite(sprName, pixelShitPart1..ratingImg..pixelShitPart2)
	setObjectCamera(sprName, 'camHUD')
	screenCenter(sprName)
	setProperty(sprName..'.x', getProperty('coolText.x') - 40)
	setProperty(sprName..'.y', getProperty(sprName..'.y') - 60)
	setProperty(sprName..'.acceleration.y', 550 * _G["playbackRate"] * _G["playbackRate"])
	setProperty(sprName..'.velocity.y', getProperty(sprName..'.velocity.y') - getRandomInt(140, 175) * _G["playbackRate"])
	setProperty(sprName..'.velocity.x', getProperty(sprName..'.velocity.x') - getRandomInt(0, 10) * _G["playbackRate"])
	setProperty(sprName..'.visible', not getPropertyFromClass('backend.ClientPrefs', 'data.hideHud') and showRating)
	setProperty(sprName..'.x', getProperty(sprName..'.x') + comboOffset[1])
	setProperty(sprName..'.y', getProperty(sprName..'.y') - comboOffset[2])
	setProperty(sprName..'.antialiasing', antialias)
	setObjectOrder(sprName, getObjectOrder('strumLineNotes'))
		
	if showRating then
		addLuaSprite(sprName, false)
	else
		setProperty(sprName..'.alpha', 0)
	end

	makeLuaSprite(comboName, pixelShitPart1..'combo'..pixelShitPart2)
	setObjectCamera(comboName, 'camHUD')
	screenCenter(comboName)
	setProperty(comboName..'.x', getProperty('coolText.x'))
	setProperty(comboName..'.acceleration.y', getRandomInt(200, 300) * _G["playbackRate"] * _G["playbackRate"])
	setProperty(comboName..'.velocity.y', getProperty(comboName..'.velocity.y') - getRandomInt(140, 160) * _G["playbackRate"])
	setProperty(comboName..'.visible', not getPropertyFromClass('backend.ClientPrefs', 'data.hideHud') and showCombo)
	setProperty(comboName..'.x', getProperty(comboName..'.x') + comboOffset[1])
	setProperty(comboName..'.y', getProperty(comboName..'.y') - comboOffset[2])
	setProperty(comboName..'.y', getProperty(comboName..'.y') + 60)
	setProperty(comboName..'.velocity.x', getProperty(comboName..'.velocity.x') + getRandomInt(1, 10) * _G["playbackRate"])
	setProperty(comboName..'.antialiasing', antialias)
	setObjectOrder(comboName, getObjectOrder('strumLineNotes'))
	
	if showCombo and comboP2 >= 10 then
		addLuaSprite(comboName, false)
	else
		setProperty(comboName..'.alpha', 0)
	end

	if not getPropertyFromClass('states.PlayState', 'isPixelStage') then
		scaleObject(sprName, 0.7, 0.7)
		setProperty(sprName..'.antialiasing', getPropertyFromClass('backend.ClientPrefs', 'data.globalAntialiasing'))
		scaleObject(comboName, 0.7, 0.7)
		setProperty(comboName..'.antialiasing', getPropertyFromClass('backend.ClientPrefs', 'data.globalAntialiasing'))
	else
		scaleObject(sprName, 6 * 0.85, 6 * 0.85)
		setProperty(sprName..'.antialiasing', false)
		scaleObject(comboName, 6 * 0.85, 6 * 0.85)
		setProperty(comboName..'.antialiasing', false)
	end

	updateHitbox(comboName)
	updateHitbox(sprName)

	local separatedScore = {}
	
	if comboP2 >= 1000 then
		separatedScore[#separatedScore + 1] = math.floor(comboP2 / 1000) % 10
	end
	separatedScore[#separatedScore + 1] = math.floor(comboP2 / 100) % 10
	separatedScore[#separatedScore + 1] = math.floor(comboP2 / 10) % 10
	separatedScore[#separatedScore + 1] = comboP2 % 10

	local daLoop = 0
	local xThing = 0
	for i = 1, #separatedScore do
	
		local comboNumName = i..'num'..ratingCount
		
		makeLuaSprite(comboNumName, pixelShitPart1..'num'..separatedScore[i]..pixelShitPart2)
		setObjectCamera(comboNumName, 'camHUD')
		screenCenter(comboNumName)
		setProperty(comboNumName..'.x', getProperty('coolText.x') + (43 * daLoop) - 90)
		setProperty(comboNumName..'.y', getProperty(comboNumName..'.y') + 80)
		
		setProperty(comboNumName..'.x', getProperty(comboNumName..'.x') + comboOffset[3])
		setProperty(comboNumName..'.y', getProperty(comboNumName..'.y') - comboOffset[4])

		if not getPropertyFromClass('states.PlayState', 'isPixelStage') then
			setProperty(comboNumName..'.antialiasing', getPropertyFromClass('backend.ClientPrefs', 'data.globalAntialiasing'))
			scaleObject(comboNumName, 0.5, 0.5)
		else
			setProperty(comboNumName..'.antialiasing', false)
			scaleObject(comboNumName, 6, 6)
		end
		
		updateHitbox(comboNumName)

		setProperty(comboNumName..'.acceleration.y', getRandomInt(200, 300) * _G["playbackRate"] * _G["playbackRate"])
		setProperty(comboNumName..'.velocity.y', getProperty(comboNumName..'.velocity.y') - getRandomInt(140, 160) * _G["playbackRate"])
		setProperty(comboNumName..'.velocity.x', getRandomInt(-5, 5) * _G["playbackRate"])
		setProperty(comboNumName..'.visible', not getPropertyFromClass('backend.ClientPrefs', 'data.hideHud'))
		setProperty(comboNumName..'.antialiasing', antialias)
		setObjectOrder(comboNumName, getObjectOrder('strumLineNotes'))

		if showComboNum then
			addLuaSprite(comboNumName, false)
		else
			setProperty(comboNumName..'.alpha', 0)
		end
		
		daLoop = daLoop + 1
		if getProperty(comboNumName..'.x') > xThing then xThing = getProperty(comboNumName..'.x') end
		
	end
	setProperty(comboName..'.x', xThing + 50)

	runTimer(sprName, crochet * 0.001 / _G["playbackRate"], 1)
	runTimer(comboName, crochet * 0.001 / _G["playbackRate"], 1)
	runTimer('num'..ratingCount, crochet * 0.002 / _G["playbackRate"], 1)

	ratingCount = ratingCount + 1
	if ratingCount > 100 then ratingCount = 0 end

end

function onTimerCompleted(tag)

	if string.find(tag, 'rating') or string.find(tag, 'combo') then doTweenAlpha(tag, tag, 0, 0.2 / _G["playbackRate"]) end
	
	if string.find(tag, 'num') then
		doTweenAlpha('1'..tag, '1'..tag, 0, 0.2 / _G["playbackRate"])
		doTweenAlpha('2'..tag, '2'..tag, 0, 0.2 / _G["playbackRate"])
		doTweenAlpha('3'..tag, '3'..tag, 0, 0.2 / _G["playbackRate"])
		doTweenAlpha('4'..tag, '4'..tag, 0, 0.2 / _G["playbackRate"])
	end
	
end

function onTweenCompleted(tag)

	if string.find(tag, 'rating') or string.find(tag, 'combo') then removeLuaSprite(tag, true) end
	
	if string.find(tag, 'num') then
		removeLuaSprite('1'..tag, true)
		removeLuaSprite('2'..tag, true)
		removeLuaSprite('3'..tag, true)
		removeLuaSprite('4'..tag, true)
	end
	
end

function judgeNote(diff)

	for i = 1, #ratingsData-1 do
		if diff <= ratingsData[i].hitWindow then return ratingsData[i].name end
	end
	
	return ratingsData[#ratingsData].name
	
end

function RecalculateRating(badHit)

	local ratingStuff = getPropertyFromClass('states.PlayState', 'ratingStuff')

	if totalPlayedP2 < 1 then
		ratingNameP2 = '?'
	else

		--Rating Percent
		ratingPercentP2 = math.min(1, math.max(0, totalNotesHitP2 / totalPlayedP2))
		
		--Rating Name
		if ratingPercentP2 >= 1 then
			ratingNameP2 = ratingStuff[#ratingStuff][1]
		else
		
			for i = 1, #ratingStuff do
			
				if ratingPercentP2 < ratingStuff[i][2] then
					ratingNameP2 = ratingStuff[i][1]
					break
				end
				
			end
			
		end
		
		ratingFCP2 = ''
		if ratingsP2.sicks > 0 then ratingFCP2 = 'SFC' end
		if ratingsP2.goods > 0 then ratingFCP2 = 'GFC' end
		if ratingsP2.bads > 0 or ratingsP2.shits > 0 then ratingFCP2 = 'FC' end
		if songMissesP2 > 0 and songMissesP2 < 10 then ratingFCP2 = 'SDCB'
		elseif songMissesP2 >= 10 then ratingFCP2 = 'Clear' end
		
	end

	updateScore(badHit)

	if enableSetLua then
		setOnLuas("ratingPercentP2", tonumber(ratingPercentP2), true)
		setOnLuas("ratingNameP2", ratingNameP2, true)
		setOnLuas("ratingFCP2", ratingFCP2, true)
	end
	
end

function updateScore(miss)

	if ratingNameP2 == '?' then
		setProperty('scoreTxtP2.text', 'Score: '..scoreP2..' | Misses: '..songMissesP2..' | Rating: '..ratingNameP2)
	else
		setProperty('scoreTxtP2.text', 'Score: '..scoreP2..' | Misses: '..songMissesP2..' | Rating: '..ratingNameP2..' ('..floorDecimal(ratingPercentP2 * 100, 2)..'%) - '..ratingFCP2)
	end

	if getPropertyFromClass('backend.ClientPrefs', 'data.scoreZoom') and not miss and not cpuControlled then
		setProperty('scoreTxtP2.scale.x', 1.075)
		setProperty('scoreTxtP2.scale.y', 1.075)
		doTweenX('scoreTxtP2scaleX', 'scoreTxtP2.scale', 1, 0.2)
		doTweenY('scoreTxtP2scaleY', 'scoreTxtP2.scale', 1, 0.2)
	end

	screenCenter('scoreTxtP2', 'x')

end

function onDestroy()

	if not (orMiddleScroll == nil) then
		setPropertyFromClass('backend.ClientPrefs', 'data.middleScroll', orMiddleScroll)
	end
	
end

function onGameOver()
	
	if cannotDieP1 then
		
		if getProperty('health') < 0 then
			setProperty('health', 0)
		end

	end
	
	return Function_Stop
	
end

function onEndSong()

	if not (endContinue) and not (getPropertyFromClass('states.PlayState', 'isStoryMode')) and doEndScreen then
		openCustomSubstate('resultsScreen', true)
		return Function_Stop
	end
	
	return Function_Continue
	
end

--for P1 gameover screen
function noteMiss()
	
	if not (cannotDieP1) and not (deadP1) then
	
		if getProperty('health') < 0 and showResultsOnGameOver then
			openCustomSubstate('resultsScreenG1', true)
			deadP1 = true
		end
		
	end
	
end

function noteMissPress()
	
	if not (cannotDieP1) and not (deadP1) then
	
		if getProperty('health') < 0 and showResultsOnGameOver then
			openCustomSubstate('resultsScreenG1', true)
			deadP1 = true
		end
		
	end
	
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
	
	if not (isSustainNote) then
		hitsP1 = hitsP1 + 1
	end
	
end

function onCustomSubstateCreate(name)
	
	if string.find(name, 'resultsScreen') then
	
		local _type = 0
		
		if name == 'resultsScreenG1' then
			_type = 1
		end
		
		if name == 'resultsScreenG2' then
			_type = 2
		end
	
		local continuetxt = [[
		PRESS ENTER TO RESTART
		
		PRESS ESCAPE TO EXIT
		]]
		
		local playertxt = 'PLAYER 1 GAMEOVER!'
	
		if _type == 2 then
			playertxt = 'PLAYER 2 GAMEOVER!'
		end
		
		if _type == 0 then
			continuetxt = 'PRESS ENTER TO CONTINUE'
			playertxt = (songName..' - '..difficultyName):upper()
		end
		
		makeLuaSprite('endBG', '', 0, 0)
		makeGraphic('endBG', screenWidth, screenHeight, '000000')
		setProperty('endBG.alpha', 0.6)
		setObjectCamera('endBG', 'camOther')
		addLuaSprite('endBG', true)
		
		makeLuaText('endTxt', '', 0, 0, 150)
		setObjectCamera('endTxt', 'camOther')
		setTextSize('endTxt', 25)
		addLuaText('endTxt', true)
		
		makeLuaText('continueTxt', continuetxt, 0, 0, screenHeight - 140)
		setObjectCamera('continueTxt', 'camOther')
		setTextSize('continueTxt', 40)
		addLuaText('continueTxt', true)
		
		makeLuaText('songNameTxt', playertxt, 0, 0, 60)
		setObjectCamera('songNameTxt', 'camOther')
		setTextSize('songNameTxt', 35)
		addLuaText('songNameTxt', true)

		local scoreTxtP2 = 'Score: '..scoreP2..' | Misses: '..songMissesP2..' | Rating: '..ratingNameP2
		
		if not (ratingNameP2 == '?') then
			scoreTxtP2 = 'Score: '..scoreP2..' | Misses: '..songMissesP2..' | Rating: '..ratingNameP2..' ('..floorDecimal(ratingPercentP2 * 100, 2)..'%) - '..ratingFCP2
		end
		
		setTextString('endTxt', [[
		
		PLAYER 1:
		
		]]..getProperty('scoreTxt.text')..' | Notes hit: '..hitsP1..[[
		
		
		
		
		PLAYER 2:
		
		]]..scoreTxtP2..' | Notes hit: '..hitsP2..[[
		
		
		
		
		
		]])
		
		if _type == 0 then
		setTextString('endTxt', getTextString('endTxt')..[[
		TOTAL NOTES P1: ]]..(hitsP1 + getProperty('songMisses'))..[[
		
		
		TOTAL NOTES P2: ]]..(hitsP2 + noteMissesP2)..[[
		
		]])
		end

		screenCenter('endTxt', 'x')
		screenCenter('continueTxt', 'x')
		screenCenter('songNameTxt', 'x')
		
	end
	
end

function onCustomSubstateUpdate(name, elapsed)

	if string.find(name, 'resultsScreen') then
	
		if name == 'resultsScreen' then
		
			if getPropertyFromClass('flixel.FlxG', 'keys.pressed.ENTER') then
				closeCustomSubstate()
				endContinue = true
				endSong()
			end
		
		--gameover
		else
	
			if getPropertyFromClass('flixel.FlxG', 'keys.pressed.ENTER') then
				closeCustomSubstate()
				restartSong()
			end
			
			if getPropertyFromClass('flixel.FlxG', 'keys.pressed.ESCAPE') then
				closeCustomSubstate()
				exitSong()
			end
		
		end
		
		continueTxtSine = continueTxtSine + (180 * elapsed)
		setProperty('continueTxt.alpha', 1 - math.sin((math.pi * continueTxtSine) / 180))
	
	end
	
end

function onCustomSubstateDestroy(name)
	removeLuaSprite('endBG')
	removeLuaText('continueTxt')
	removeLuaText('songNameTxt')
	removeLuaText('endTxt')
end

function animThing(elapsed)

	local controlHoldArray = {}
	
	for i = 1, #keys do
		controlHoldArray[i] = getPropertyFromClass('flixel.FlxG', 'keys.pressed.'..keys[i])
	end

	if cpuControlled or gfSinging then
	
		for i = 1, #controlHoldArray do
			controlHoldArray[i] = false
		end
		
	end

	local thing = getPropertyFromClass('backend.Conductor', 'stepCrochet') * 0.0011 * getProperty('dad.singDuration') / _G["playbackRate"]
	
	if table.contains(controlHoldArray, true) then
	
		if getProperty('dad.holdTimer') > thing - 0.03 then
			setProperty('dad.holdTimer', thing - 0.03)
		end
		
	end
	
end

function floorDecimal(value, decimals)

	if decimals < 1 then return math.floor(value) end

	local tempMult = 1
	for i = 0, decimals-1 do tempMult = tempMult * 10 end
	
	local newValue = math.floor(value * tempMult)
	return newValue / tempMult
	
end

function strumPlayAnim(id, anim, forced, resetTime)

	if resetTime == nil then resetTime = 0 end
	if forced == nil then forced = false end

	if forced then
		setPropertyFromGroup('strumLineNotes', id, 'animation.name', nil)
	end
	
	setPropertyFromGroup('strumLineNotes', id, 'animation.name', anim)
	setPropertyFromGroup('strumLineNotes', id, 'resetAnim', resetTime)
	
	if not (getPropertyFromClass('states.PlayState', 'SONG.disableNoteRGB')) then
	
		if anim == 'static' then
			setPropertyFromGroup('strumLineNotes', id, 'rgbShader.enabled', false)
		else
			setPropertyFromGroup('strumLineNotes', id, 'rgbShader.enabled', true)
		end
		
	end

	setPropertyFromGroup('strumLineNotes', id, 'origin.x', getPropertyFromGroup('strumLineNotes', id, 'frameWidth') / 2)
	setPropertyFromGroup('strumLineNotes', id, 'origin.y', getPropertyFromGroup('strumLineNotes', id, 'frameHeight') / 2)
	setPropertyFromGroup('strumLineNotes', id, 'offset.x', (getPropertyFromGroup('strumLineNotes', id, 'frameWidth') - getPropertyFromGroup('strumLineNotes', id, 'width')) / 2)
	setPropertyFromGroup('strumLineNotes', id, 'offset.y', (getPropertyFromGroup('strumLineNotes', id, 'frameHeight') - getPropertyFromGroup('strumLineNotes', id, 'height')) / 2)

end

function table.contains(table, val)

	for i = 1, #table do
		if table[i] == val then return true end
	end
	return false

end

function tableToString(tbl)
					
	local lol = "["

	for i, thing in ipairs(tbl) do
	
		if type(thing) == "table" then
			
			for j, thing2 in ipairs(thing) do
			
				lol = lol.."["
				
				if not (j == #thing2) then
					lol = lol..tostring(thing2)..', '
				else
					lol = lol..tostring(thing2)
				end
				
				lol = lol.."]"
				
			end
			
		end
	
		if not (i == #tbl) then
			lol = lol..tostring(thing)..', '
		else
			lol = lol..tostring(thing)
		end
		
	end
	
	lol = lol.."]"
	
	return lol
	
end