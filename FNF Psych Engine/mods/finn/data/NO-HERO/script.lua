function opponentNoteHit()
   health = getProperty('health')

   local diffsHealths = {1, 0.5, 0.1}
   local hpCap = diffsHealths[difficulty + 1]

   if health > hpCap then
      setProperty('health', health - 0.02);
	end
end